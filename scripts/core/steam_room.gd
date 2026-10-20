class_name SteamRoom
extends Node

## Steam rooms (docs/diseno/online.md, "Cómo se conectan"): the host opens a Steam lobby and invites friends from
## Steam, and the traffic goes over Steam's network with SteamMultiplayerPeer, so nobody opens ports. It talks to
## GodotSteam by name, so the game still runs where the addon isn't installed (CI, a PC without Steam): there
## available() is false and the room only offers IP. Child of Net, which turns its signals into the room.

## The lobby is open and this PC hosts it with `peer`.
signal hosted(peer: MultiplayerPeer)
## This PC entered a friend's lobby and connects to its host with `peer`.
signal joined(peer: MultiplayerPeer)
## Opening or entering the lobby failed. `reason_key` is a tr() key for the notice.
signal failed(reason_key: String)
## The player accepted a friend's invite in Steam (or launched the game from one): join `lobby_id`.
signal invited(lobby_id: int)

## Spacewar, Valve's test app, until BPD has its own AppID (Cristian, 20/10).
const APP_ID := 480
## Steam's values, used if the addon doesn't expose its constants.
const FALLBACK := {"LOBBY_TYPE_FRIENDS_ONLY": 1, "RESULT_OK": 1, "CHAT_ROOM_ENTER_RESPONSE_SUCCESS": 1}

## GodotSteam's Steam singleton, or null without the addon.
var steam: Object
## The lobby this PC is in, 0 if none.
var lobby_id := 0
var _started := false
## Steam starts once per process: the tests build several Nets in one (online_pcs.gd), and a second steamInitEx errors.
static var _steam_started := false


## The lobby id after "+connect_lobby" among `args`, as Steam passes it when the game launches from an invite; 0 if none.
static func connect_lobby_arg(args: PackedStringArray) -> int:
	var index := args.find("+connect_lobby")
	if index < 0 or index + 1 >= args.size() or not args[index + 1].is_valid_int():
		return 0
	return args[index + 1].to_int()


## Steam is installed, running and logged in, so rooms can go through it.
func available() -> bool:
	return _started


## Starts Steam if the addon is there. Returns available().
func start() -> bool:
	if _started:
		return true
	if not Engine.has_singleton("Steam") or not ClassDB.class_exists("SteamMultiplayerPeer"):
		return false
	steam = Engine.get_singleton("Steam")
	if not _steam_started:
		var result: Dictionary = steam.call("steamInitEx", APP_ID)
		if int(result.get("status", -1)) != 0:
			push_warning("Steam didn't start: %s" % result.get("verbal", ""))
			return false
		_steam_started = true
	_started = true
	steam.connect("lobby_created", _on_lobby_created)
	steam.connect("lobby_joined", _on_lobby_joined)
	steam.connect("join_requested", _on_join_requested)
	return true


func _process(_delta: float) -> void:
	if _started:
		steam.call("run_callbacks")


## Opens a friends-only lobby for `max_members`. hosted or failed tell how it went.
func host(max_members: int) -> void:
	if not _started:
		failed.emit.call_deferred("NET_HOST_FAILED")
		return
	steam.call("createLobby", _constant("LOBBY_TYPE_FRIENDS_ONLY"), max_members)


## Enters a friend's lobby. joined or failed tell how it went.
func join(id: int) -> void:
	if not _started:
		failed.emit.call_deferred("NET_JOIN_FAILED")
		return
	steam.call("joinLobby", id)


## Steam's own window to invite friends to the open lobby.
func invite() -> void:
	if lobby_id != 0:
		steam.call("activateGameOverlayInviteDialog", lobby_id)


func leave() -> void:
	if _started and lobby_id != 0:
		steam.call("leaveLobby", lobby_id)
	lobby_id = 0


func _on_lobby_created(result: int, id: int) -> void:
	if result != _constant("RESULT_OK"):
		failed.emit("NET_HOST_FAILED")
		return
	lobby_id = id
	var peer: MultiplayerPeer = ClassDB.instantiate("SteamMultiplayerPeer")
	if peer.call("create_host", 0) != OK:
		leave()
		failed.emit("NET_HOST_FAILED")
		return
	hosted.emit(peer)


func _on_lobby_joined(id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response != _constant("CHAT_ROOM_ENTER_RESPONSE_SUCCESS"):
		failed.emit("NET_JOIN_FAILED")
		return
	lobby_id = id
	var owner: int = steam.call("getLobbyOwner", id)
	# Steam tells the host it joined its own lobby too; the host already has its peer.
	if owner == steam.call("getSteamID"):
		return
	var peer: MultiplayerPeer = ClassDB.instantiate("SteamMultiplayerPeer")
	if peer.call("create_client", owner, 0) != OK:
		leave()
		failed.emit("NET_JOIN_FAILED")
		return
	joined.emit(peer)


func _on_join_requested(id: int, _friend: int) -> void:
	invited.emit(id)


func _constant(name: String) -> int:
	if ClassDB.class_has_integer_constant("Steam", name):
		return ClassDB.class_get_integer_constant("Steam", name)
	return FALLBACK[name]
