extends Node

## The online session (docs/diseno/online.md): host a room, join one, who is in it and which slot (skin color) each
## player has, and starting the same case for everyone. Autoloaded as Net. Without a room the game plays solo, as
## always. For now the room goes by IP with ENet; Steam lobbies come in the next step.

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

## Peer id -> slot (0 to 3). The slot gives the skin color (decision 72) and the "Policía N" name.
var players := {}
## A case is being played: new players can't come in (they join in the room).
var in_match := false
## Off in tests, so starting a case only emits match_started.
var change_scenes := true


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


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
	multiplayer.multiplayer_peer = peer
	players = {HOST_ID: 0}
	in_match = false
	players_changed.emit()
	return OK


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
	var had_players := not players.is_empty()
	players = {}
	in_match = false
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
	var case_seed := PlaceDraw.new_seed()
	_start_match.rpc(PlaceDraw.pick(case_seed, OS.get_cmdline_user_args()), case_seed)


@rpc("authority", "call_local", "reliable")
func _start_match(place: String, case_seed: int) -> void:
	in_match = true
	match_started.emit(place, case_seed)
	if change_scenes:
		PlaceDraw.pending_seed = case_seed
		get_tree().change_scene_to_file(PlaceDraw.PLACES[place])


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
	if not multiplayer.is_server() or not players.has(id):
		return
	players.erase(id)
	_sync_players.rpc(players)
	players_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _refuse(reason_key: String) -> void:
	leave()
	session_ended.emit(reason_key)


func _on_connection_failed() -> void:
	leave()
	session_ended.emit("NET_JOIN_FAILED")


func _on_server_disconnected() -> void:
	leave()
	session_ended.emit("NET_HOST_LEFT")
