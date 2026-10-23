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
## Meters above a cop's feet where its player's name floats (the cop is 1.55 m tall, escala.md).
const NAME_TAG_HEIGHT := 1.8
## Longest name shown; longer Steam names are cut.
const NAME_LENGTH := 24

## Peer id -> slot (0 to 3). The slot gives the skin color (decision 72) and the "Policía N" name.
var players := {}
## Peer id -> the player's Steam name, "" without Steam (they show as "Policía N" then).
var names := {}
## A case is being played: a player who comes in now goes straight into it (online.md, "Entrar a mitad de un caso").
var in_match := false
## The case being played (PlaceDraw id and seed), for players who come in late.
var match_place := ""
var match_seed := 0
## The owner in custody the match's interrogation is about (PlaceDraw.custody_now), the host's; empty if none.
var match_custody := {}
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
## Esc during a case.
var pause_menu: PauseMenu
## This PC has the current level loaded and its cops in place.
var _in_scene := false
## The current level and where its cops start, for the cops of players who come in late.
var _level: Node
var _start := Transform3D.IDENTITY


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connected_to_server.connect(func() -> void: _tell_name.rpc_id(HOST_ID, my_name()))
	steam = SteamRoom.new()
	steam.name = "Steam"
	add_child(steam)
	steam.hosted.connect(_open_room)
	steam.joined.connect(func(peer: MultiplayerPeer) -> void: multiplayer.multiplayer_peer = peer)
	steam.failed.connect(_on_steam_failed)
	steam.invited.connect(_on_steam_invited)
	voice = VoiceChat.new(self)
	add_child(voice)
	pause_menu = PauseMenu.new(self)
	add_child(pause_menu)
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
	names = {HOST_ID: my_name()}
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
	names = {}
	in_match = false
	_leave_scene()
	if had_players:
		players_changed.emit()


## This PC's Steam name, or "" without Steam.
func my_name() -> String:
	return str(steam.steam.call("getPersonaName")) if steam.available() else ""


## What a player is called: their Steam name, or "Policía N" from their slot.
func player_name(id: int) -> String:
	var steam_name: String = names.get(id, "")
	return steam_name if steam_name != "" else tr("COP_NAME") % (players.get(id, 0) + 1)


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
	_start_match.rpc(draw_place(case_seed), case_seed, PlaceDraw.custody_now())


## The place the host's match opens for `case_seed`: the same draw as playing alone, chases and crime scenes too.
func draw_place(case_seed: int) -> String:
	return PlaceDraw.pick(case_seed, OS.get_cmdline_user_args(), PlaceDraw.shift_now())


@rpc("authority", "call_local", "reliable")
func _start_match(place: String, case_seed: int, custody := {}) -> void:
	in_match = true
	match_place = place
	match_seed = case_seed
	match_custody = custody
	# A guest plays the host's campaign: the owner in the chair is the host's, and its own saved one stays out of it.
	if not multiplayer.is_server():
		Campaign.current = null
		PlaceDraw.custody = custody
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
	_level = local.get_parent()
	_start = local.global_transform
	_add_cop(local, multiplayer.get_unique_id(), _start)
	_refresh_cops()
	props = PropSync.new(self, local.get_parent())
	add_child(props)
	actions = ActionSync.new(self, local.get_parent())
	add_child(actions)
	npcs = NpcSync.new(self, local.get_parent())
	add_child(npcs)
	var raids := local.get_parent().find_children("*", "RaidCase", true, false)
	raids.append_array(local.get_parent().find_children("*", "InterrogationCase", true, false))
	raids.append_array(local.get_parent().find_children("*", "ChaseCase", true, false))
	raids.append_array(local.get_parent().find_children("*", "CrimeSceneCase", true, false))
	raids.append_array(local.get_parent().find_children("*", "TrafficCase", true, false))
	raids.append_array(local.get_parent().find_children("*", "InfiltrationCase", true, false))
	raids.append_array(local.get_parent().find_children("*", "BankCase", true, false))
	raids.append_array(local.get_parent().find_children("*", "PoliticianCase", true, false))
	if not raids.is_empty():
		case_sync = CaseSync.new(self, raids[0])
		add_child(case_sync)
	_in_scene = true
	_entered_scene.rpc(true)
	if multiplayer.is_server():
		for peer in scene_peers:
			_resend(peer)


## Adds a copy of the cop of every player that has none yet (all of them when the level opens, or one who came in
## late), and keeps the name tags up to date.
func _refresh_cops() -> void:
	if not is_instance_valid(_level):
		return
	for id: int in players:
		if cop_syncs.has(id):
			var tag: Label3D = cop_syncs[id].cop.get_node_or_null("NameTag") if is_instance_valid(cop_syncs[id].cop) else null
			if tag:
				tag.text = player_name(id)
			continue
		var copy: Cop = COP_SCENE.instantiate()
		copy.input_enabled = false
		copy.name = "Cop%d" % id
		copy.get_node("Grabber").input_enabled = false
		copy.get_node("Hud").visible = false
		_level.add_child(copy)
		_add_cop(copy, id, _start)


func _add_cop(cop: Cop, id: int, start: Transform3D) -> void:
	var slot: int = players.get(id, 0)
	cop.set_uniform(slot)
	if id != multiplayer.get_unique_id():
		_add_name_tag(cop, id, slot)
	# A level with its own spots for each slot (the jailbreak's cells) puts the cop there; the rest stand in a row.
	if not cop.vehicle and is_instance_valid(_level) and _level.has_method("cop_spawn"):
		cop.global_transform = _level.cop_spawn(slot)
	elif not cop.vehicle:
		cop.global_transform = start.translated(start.basis.x * (slot - (MAX_PLAYERS - 1) / 2.0) * SPAWN_GAP)
	var sync := CopSync.new(cop, self, id)
	add_child(sync)
	cop_syncs[id] = sync
	cop.sync = sync


## The other players' cops carry their name over the head, in their skin color (online.md, "La sala").
func _add_name_tag(cop: Cop, id: int, slot: int) -> void:
	var tag := Label3D.new()
	tag.name = "NameTag"
	tag.text = player_name(id)
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.position = Vector3(0, NAME_TAG_HEIGHT, 0)
	tag.pixel_size = 0.004
	tag.font_size = 48
	tag.outline_size = 12
	tag.modulate = Lobby.SKIN_COLORS[slot % Lobby.SKIN_COLORS.size()]
	tag.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	cop.add_child(tag)


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
	_level = null
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
func _sync_players(list: Dictionary, name_list := {}) -> void:
	players = list
	names = name_list
	_refresh_cops()
	players_changed.emit()


## A guest that just came in tells the host its Steam name.
@rpc("any_peer", "call_remote", "reliable")
func _tell_name(player_name_text: String) -> void:
	var id := multiplayer.get_remote_sender_id()
	if not multiplayer.is_server() or not players.has(id):
		return
	names[id] = player_name_text.strip_edges().left(NAME_LENGTH)
	_sync_players.rpc(players, names)
	_refresh_cops()
	players_changed.emit()


func _on_peer_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	var slot := free_slot(players.values())
	if slot < 0:
		# Kicking right away would drop the notice: the guest leaves on its own, and is kicked if it doesn't.
		_refuse.rpc_id(id, "NET_ROOM_FULL")
		get_tree().create_timer(REFUSE_GRACE).timeout.connect(_kick.bind(id))
		return
	players[id] = slot
	_sync_players.rpc(players, names)
	_refresh_cops()
	players_changed.emit()
	# Coming in during a case opens it right away; once its level loads, the host sends it how everything is.
	if in_match:
		_start_match.rpc_id(id, match_place, match_seed, match_custody)


func _kick(id: int) -> void:
	if is_online() and multiplayer.is_server() and multiplayer.get_peers().has(id):
		multiplayer.multiplayer_peer.disconnect_peer(id)


func _on_peer_disconnected(id: int) -> void:
	_remove_cop(id)
	if not multiplayer.is_server() or not players.has(id):
		return
	players.erase(id)
	names.erase(id)
	_sync_players.rpc(players, names)
	players_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _refuse(reason_key: String) -> void:
	_end_session(reason_key)


func _on_steam_failed(reason_key: String) -> void:
	_end_session(reason_key)


## Back to solo with a notice. In the middle of a case everyone goes back to the room screen, which shows the notice
## (online.md, "Se va el anfitrión").
func _end_session(reason_key: String) -> void:
	var was_in_match := in_match
	leave()
	session_ended.emit(reason_key)
	if not was_in_match:
		return
	Lobby.notice = reason_key
	if change_scenes:
		get_tree().change_scene_to_file(MainMenu.LOBBY_SCENE)


## A friend's invite accepted in Steam: whatever this PC was doing, it goes to the room and joins.
func _on_steam_invited(lobby_id: int) -> void:
	leave()
	Lobby.invite_lobby = lobby_id
	if change_scenes:
		get_tree().change_scene_to_file(MainMenu.LOBBY_SCENE)


func _on_connection_failed() -> void:
	_end_session("NET_JOIN_FAILED")


func _on_server_disconnected() -> void:
	_end_session("NET_HOST_LEFT")
