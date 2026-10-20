extends Node

## The online session (docs/diseno/online.md): host a room, join one, who is in it and which slot (skin color) each
## player has, and starting the same case for everyone. Autoloaded as Net. Without a room the game plays solo, as
## always. A room goes through Steam (SteamRoom) when Steam is running, or by IP with ENet for testing on one PC.

## The player list changed: someone came in or left.
signal players_changed
## The room closed or couldn't be joined. `reason_key` is a tr() key for the notice.
signal session_ended(reason_key: String)
## The host started a case: every player opens `place` (a PlaceDraw id) with `case_seed`.
signal match_started(place: String, case_seed: int)

const MAX_PLAYERS := 4
const DEFAULT_PORT := 7777
## The host is always peer 1 in Godot's multiplayer.
const HOST_ID := 1
## Seconds a refused guest has to leave before the host kicks it.
const REFUSE_GRACE := 1.0
const COP_SCENE := preload("res://scenes/player/cop.tscn")
## Cops stand this far apart side by side at the start, in slot order, so they don't spawn inside each other.
const SPAWN_GAP := 1.2

## Peer id -> slot (0 to 3). The slot gives the skin color (decision 72) and the "Policía N" name.
var players := {}
## A case is being played: new players can't come in (they join in the room).
var in_match := false
## Off in tests, so starting a case only emits match_started.
var change_scenes := true
## Peers that have the current level loaded, so they can take the cops' state.
var scene_peers: Array[int] = []
## Peer id -> its CopSync in the current level.
var cop_syncs := {}
## The current level's physics objects, kept the same on every PC.
var props: PropSync
## What cops do to the current level, done on every PC in the same order.
var actions: ActionSync
## The current level's case, decided by the host (null if the level has none).
var case_sync: CaseSync
## The current level's people and animals, run by the host.
var npcs: NpcSync
## Steam lobbies and invites (does nothing where GodotSteam isn't installed).
var steam: SteamRoom
## Steam voice: hold V or T to talk (voz.md).
var voice: VoiceChat
## This PC has the current level loaded and its cops in place.
var _in_scene := false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	steam = SteamRoom.new()
	steam.name = "Steam"
	add_child(steam)
	steam.hosted.connect(_open_room)
	steam.joined.connect(func(peer: MultiplayerPeer) -> void: multiplayer.multiplayer_peer = peer)
	steam.failed.connect(_on_steam_failed)
	steam.invited.connect(_on_steam_invited)
	voice = VoiceChat.new(self)
	add_child(voice)
	if steam.start():
		# Launched from a friend's invite: the menu opens the room and joins it.
		Lobby.invite_lobby = SteamRoom.connect_lobby_arg(OS.get_cmdline_args())


## In a room, as host or guest.
func is_online() -> bool:
	var peer := multiplayer.multiplayer_peer
	return peer != null and not peer is OfflineMultiplayerPeer \
		and peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED


## Hosting a room, or playing solo (solo the player's game is the one that counts too).
func is_host() -> bool:
	return not is_online() or multiplayer.is_server()


## Opens a room on `port`. The host takes slot 0.
func host(port := DEFAULT_PORT) -> Error:
	leave()
	var peer := ENetMultiplayerPeer.new()
	# One place more than the guests, so a fifth player gets in long enough to hear the room is full.
	var error := peer.create_server(port, MAX_PLAYERS)
	if error != OK:
		return error
	_open_room(peer)
	return OK


## Opens a Steam room; friends come in through Steam's invites. players_changed or session_ended tell how it went.
func host_steam() -> void:
	leave()
	steam.host(MAX_PLAYERS)


## Enters a friend's Steam room. players_changed or session_ended tell how it went.
func join_steam(lobby_id: int) -> void:
	leave()
	steam.join(lobby_id)


## The room is a Steam one, so friends come in by invite instead of by IP.
func is_steam() -> bool:
	return is_online() and steam.lobby_id != 0


func _open_room(peer: MultiplayerPeer) -> void:
	multiplayer.multiplayer_peer = peer
	players = {HOST_ID: 0}
	in_match = false
	players_changed.emit()


## Tries to join the room at `address`. connected or session_ended tell how it went.
func join(address: String, port := DEFAULT_PORT) -> Error:
	leave()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	return OK


## Closes the room (host) or leaves it (guest), and goes back to solo.
func leave() -> void:
	if multiplayer.multiplayer_peer and not multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	if steam:
		steam.leave()
	var had_players := not players.is_empty()
	players = {}
	in_match = false
	_leave_scene()
	if had_players:
		players_changed.emit()


## This player's slot (0 to 3); 0 when playing solo.
func my_slot() -> int:
	return players.get(multiplayer.get_unique_id(), 0)


## The lowest free slot, or -1 if the room is full.
static func free_slot(taken: Array) -> int:
	for slot in MAX_PLAYERS:
		if not taken.has(slot):
			return slot
	return -1


## Host only: draws the case and opens the same place with the same seed for everyone.
func start_match() -> void:
	if not is_online() or not multiplayer.is_server():
		return
	var case_seed := PlaceDraw.next_seed()
	_start_match.rpc(PlaceDraw.pick(case_seed, OS.get_cmdline_user_args()), case_seed)


@rpc("authority", "call_local", "reliable")
func _start_match(place: String, case_seed: int) -> void:
	in_match = true
	_leave_scene()
	match_started.emit(place, case_seed)
	if change_scenes:
		PlaceDraw.pending_seed = case_seed
		get_tree().change_scene_to_file(PlaceDraw.PLACES[place])


## Called by the player's own cop once its level is ready: puts that cop in its slot and adds a copy of every other
## player's cop next to it. Each cop gets a CopSync so its owner moves it on every PC.
func spawn_cops(local: Cop) -> void:
	if not is_online() or not is_instance_valid(local):
		return
	_leave_scene()
	var me := multiplayer.get_unique_id()
	var start := local.global_transform
	_add_cop(local, me, start)
	for id: int in players:
		if id == me:
			continue
		var copy: Cop = COP_SCENE.instantiate()
		copy.input_enabled = false
		copy.name = "Cop%d" % id
		copy.get_node("Grabber").input_enabled = false
		copy.get_node("Hud").visible = false
		local.get_parent().add_child(copy)
		_add_cop(copy, id, start)
	props = PropSync.new(self, local.get_parent())
	add_child(props)
	actions = ActionSync.new(self, local.get_parent())
	add_child(actions)
	npcs = NpcSync.new(self, local.get_parent())
	add_child(npcs)
	var raids := local.get_parent().find_children("*", "RaidCase", true, false)
	if not raids.is_empty():
		case_sync = CaseSync.new(self, raids[0])
		add_child(case_sync)
	_in_scene = true
	_entered_scene.rpc(true)
	if multiplayer.is_server():
		for peer in scene_peers:
			_resend(peer)


func _add_cop(cop: Cop, id: int, start: Transform3D) -> void:
	var slot: int = players.get(id, 0)
	cop.set_uniform(slot)
	if not cop.vehicle:
		cop.global_transform = start.translated(start.basis.x * (slot - (MAX_PLAYERS - 1) / 2.0) * SPAWN_GAP)
	var sync := CopSync.new(cop, self, id)
	add_child(sync)
	cop_syncs[id] = sync
	cop.sync = sync


## Another peer loaded the level. If this PC has it loaded too, it answers so the other one knows.
@rpc("any_peer", "call_remote", "reliable")
func _entered_scene(answer: bool) -> void:
	var id := multiplayer.get_remote_sender_id()
	if not scene_peers.has(id):
		scene_peers.append(id)
	if answer and _in_scene:
		_entered_scene.rpc_id(id, false)
	if _in_scene and multiplayer.is_server():
		_resend(id)


## Host: everything a peer that just loaded the level needs at once.
func _resend(peer: int) -> void:
	props.resend_all(peer)
	npcs.resend_all(peer)
	if case_sync:
		case_sync.resend(peer)


func _leave_scene() -> void:
	_in_scene = false
	scene_peers.clear()
	for sync: Node in cop_syncs.values():
		remove_child(sync)
		sync.queue_free()
	cop_syncs.clear()
	for sync: Node in [props, actions, npcs, case_sync]:
		if sync:
			remove_child(sync)
			sync.queue_free()
	props = null
	actions = null
	npcs = null
	case_sync = null


## A player left: their cop goes away (what it held drops, online.md).
func _remove_cop(id: int) -> void:
	scene_peers.erase(id)
	if not cop_syncs.has(id):
		return
	var sync: CopSync = cop_syncs[id]
	cop_syncs.erase(id)
	if is_instance_valid(sync.cop):
		sync.cop.get_node("Grabber").release()
		if sync.cop.vehicle:
			sync.cop.vehicle.exit(sync.cop)
		sync.cop.queue_free()
	remove_child(sync)
	sync.queue_free()


@rpc("authority", "call_remote", "reliable")
func _sync_players(list: Dictionary) -> void:
	players = list
	players_changed.emit()


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	var slot := free_slot(players.values())
	if slot < 0 or in_match:
		# Kicking right away would drop the notice: the guest leaves on its own, and is kicked if it doesn't.
		_refuse.rpc_id(id, "NET_ROOM_FULL" if slot < 0 else "NET_IN_MATCH")
		get_tree().create_timer(REFUSE_GRACE).timeout.connect(_kick.bind(id))
		return
	players[id] = slot
	_sync_players.rpc(players)
	players_changed.emit()


func _kick(id: int) -> void:
	if is_online() and multiplayer.is_server() and multiplayer.get_peers().has(id):
		multiplayer.multiplayer_peer.disconnect_peer(id)


func _on_peer_disconnected(id: int) -> void:
	_remove_cop(id)
	if not multiplayer.is_server() or not players.has(id):
		return
	players.erase(id)
	_sync_players.rpc(players)
	players_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _refuse(reason_key: String) -> void:
	leave()
	session_ended.emit(reason_key)


func _on_steam_failed(reason_key: String) -> void:
	leave()
	session_ended.emit(reason_key)


## A friend's invite accepted in Steam: whatever this PC was doing, it goes to the room and joins.
func _on_steam_invited(lobby_id: int) -> void:
	leave()
	Lobby.invite_lobby = lobby_id
	if change_scenes:
		get_tree().change_scene_to_file(MainMenu.LOBBY_SCENE)


func _on_connection_failed() -> void:
	leave()
	session_ended.emit("NET_JOIN_FAILED")


func _on_server_disconnected() -> void:
	leave()
	session_ended.emit("NET_HOST_LEFT")
