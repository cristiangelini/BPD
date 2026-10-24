extends GutTest

## The prisoner transfer online (traslado-presos.md, step 6; docs/diseno/online.md): the host's bus, inmates and case
## decide, and every PC sees the same plans, escapes, chases and count at the gate.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const TRANSFER_SCENE := preload("res://scenes/levels/prisoner_transfer.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = TRANSFER_SCENE.instantiate()
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
	var guest := _level(pcs[1])
	assert_true(guest.transfer_case.follower)
	assert_true(guest.transfer.follower, "only the host's inmates plan")
	assert_true(guest.escape.follower)
	assert_true(guest.transfer.inmates[0].follower)


func test_a_plan_and_a_trick_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.transfer.inmates[2].set_plan(90.0)
	host.transfer.inmates[3].play_sick()
	await wait_until(func() -> bool: return guest.transfer.inmates[3].lying, 5.0)
	assert_eq(guest.transfer.inmates[2].plan, 90.0)
	assert_eq(guest.transfer.inmates[3].prompt_key(OnlinePcs.own_cop(pcs[1])), "PROMPT_SEAT_INMATE",
		"the guest can sit them back too")


func test_an_escape_and_its_catch_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var inmate := host.transfer.inmates[4]
	inmate.jump_out()
	await wait_until(func() -> bool: return guest.escape.chase != null, 5.0)
	assert_eq(guest.escape.running, guest.transfer.inmates[4])
	var chase := host.escape.chase
	chase.pull_over()
	chase.suspect.cuffed(30.0)
	chase.escort.board()
	await wait_until(func() -> bool: return guest.escape.chase == null, 5.0)
	assert_eq(guest.escape.caught, 1, "caught on the guest too")
	assert_true(guest.transfer.inmates[4].visible, "back in their seat")


func test_a_getaway_counts_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.transfer.inmates[5].jump_out()
	await wait_until(func() -> bool: return guest.escape.chase != null, 5.0)
	host.escape.chase.fail("CASE_FAILED_ESCAPED")
	await wait_until(func() -> bool: return guest.escape.escaped.size() == 1, 5.0)
	assert_null(guest.escape.chase)
	assert_eq(guest.transfer_case.escaped(), 1)


func test_the_count_and_the_end_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.transfer_case.give_tip()
	var at := host.global_transform * Transform3D(Basis.IDENTITY, Vector3(0, 0.3, PrisonLevel.HALF_Z - 6.0))
	PhysicsServer3D.body_set_state(host.bus.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, at)
	host.bus.global_transform = at
	await wait_until(func() -> bool: return guest.transfer_case.counting, 5.0)
	await wait_until(func() -> bool: return guest.transfer_case.delivered, TransferCase.COUNT_STEP * 12)
	assert_eq(guest.transfer_case.counted, TransferPlan.INMATES)
	await wait_until(func() -> bool: return guest.transfer_case.shift_over, TransferCase.SHIFT_DELAY + 5.0)
	assert_true(guest.transfer_case.solved())


func test_a_lurch_throws_the_guests_own_cop() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	guest.bus.get_on(cop, 1)
	host.bus.last_push = Vector3(2, 0, 0)
	host.bus.lurched.emit(8.0)
	await wait_until(func() -> bool: return cop.is_staggered(), 5.0)
	assert_true(cop.is_staggered())
