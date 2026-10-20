class_name CaseSync
extends Node

## Keeps the case the same on every PC (docs/diseno/online.md, "Qué se sincroniza"): the host's RaidCase decides
## (suspicions, clues, fines, delivery, solved or failed, the end of shift numbers) and sends what the checklist shows
## whenever it changes; the guests' RaidCase follows it. A guest marking a suspicion asks the host. Lives under the
## Net autoload as "Case".

const SEND_RATE := 5.0

var net: Node
var raid: RaidCase
var _last_sent := {}
var _send_left := 0.0


func _init(owner_net: Node, level_case: RaidCase) -> void:
	net = owner_net
	raid = level_case
	name = "Case"
	raid.online = self
	raid.follower = not net.is_host()


## Host: sends the case to `peer` now (it just loaded the level).
func resend(peer: int) -> void:
	_state.rpc_id(peer, raid.snapshot())


func _physics_process(delta: float) -> void:
	if not net.is_host():
		return
	_send_left -= delta
	if _send_left > 0.0:
		return
	_send_left = 1.0 / SEND_RATE
	var state := raid.snapshot()
	if state == _last_sent:
		return
	_last_sent = state
	for peer: int in net.scene_peers:
		_state.rpc_id(peer, state)


@rpc("authority", "call_remote", "reliable")
func _state(state: Dictionary) -> void:
	raid.apply_snapshot(state)


## Guest: asks the host to mark suspicion `index`.
func request_mark(index: int) -> void:
	_mark.rpc_id(net.HOST_ID, index)


@rpc("any_peer", "call_remote", "reliable")
func _mark(index: int) -> void:
	if multiplayer.is_server():
		raid.mark(index)


## Host at the end of the shift: plays the next case with everyone; a guest waits for the host.
func play_again() -> void:
	if net.is_host():
		net.start_match()
