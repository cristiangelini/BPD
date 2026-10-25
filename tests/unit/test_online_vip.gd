extends GutTest

## The prison VIP inmate online (carcel-vip.md, step 7; docs/diseno/online.md): the host's plan, requests and case
## decide, and every PC sees the same cell, requests, mood, pieces, runner, lawyer and ending.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const VIP_SCENE := preload("res://scenes/levels/prison_vip.tscn")
const SEED := 8

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = VIP_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.vip_case.follower)
	assert_true(guest.vip.follower)
	assert_true(guest.vip.requests.follower)
	assert_true(guest.vip.rulo.follower, "only the host's Rulo decides")
	assert_eq(guest.vip.cell, host.vip.cell, "the same cell from the same seed")
	assert_eq(guest.vip.requests.order, host.vip.requests.order)


func test_the_requests_and_his_mood_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.vip.requests.started = true
	host.vip.requests.next_left = 999.0
	host.vip.requests.ask_next()
	await wait_until(func() -> bool: return guest.vip.requests.open.size() == 1, 5.0)
	assert_eq(guest.vip.requests.open[0].kind, host.vip.requests.order[0])
	assert_string_contains(guest.vip.requests.board.text, tr("VIP_WANT_%s"
		% VipRequests.Kind.keys()[host.vip.requests.order[0]]))
	host.vip.requests.set_mood(25)
	await wait_until(func() -> bool: return guest.vip.requests.mood == 25, 5.0)
	assert_string_contains(guest.vip_case.rows()[2].text, "25")


func test_the_guest_cannot_fulfil_by_itself() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	guest.vip.requests.open.append({"kind": VipRequests.Kind.MASSAGE, "left": 60.0})
	for i in VipRequests.MASSAGE:
		guest.vip.requests.pressed(guest.get_node("Cop"))
	assert_eq(guest.vip.requests.on_time, 0, "the host decides")


func test_the_run_and_the_runner_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.vip.pieces.assign([Contraband.Kind.FILE, Contraband.Kind.ROPE, Contraband.Kind.KEY])
	host.vip.got_piece.emit(3)
	await wait_until(func() -> bool: return guest.vip.runner != null, 5.0)
	await wait_until(func() -> bool: return not guest.vip.rulo.visible, 5.0)
	await wait_until(func() -> bool: return guest.cell_door(guest.vip.cell).is_open, 5.0)
	await wait_physics_frames(2)
	assert_not_null(OwnerEscort.of(guest.vip.runner), "the guest's cops can walk him to a cell")
	assert_eq(guest.vip.runner.model, VipInmate.MODEL, "with his own model")


func test_the_lawyer_and_the_ending_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.vip.call_lawyer()
	await wait_until(func() -> bool: return guest.vip.lawyers == 1, 5.0)
	await wait_until(func() -> bool: return not guest.vip.find_children("*", "VipLawyer", true, false).is_empty(), 5.0)
	var start_x := guest.vip.limo.position.x
	host.vip._on_manager_gone()
	await wait_until(func() -> bool: return guest.vip.released and guest.vip_case.solved_it, 5.0)
	await wait_until(func() -> bool: return guest.vip.limo.position.x > start_x + 1.0, 5.0)
	assert_gt(guest.vip.limo.position.x, start_x + 1.0, "the limo drives off on the guest too")
