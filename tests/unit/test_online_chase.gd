extends GutTest

## The chase online (docs/diseno/online.md, "Qué se sincroniza"; persecucion.md, "Online"): the host drives the suspect
## and decides the meters, and every PC sees him drive off, the clock, the distance and the end of shift.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")
const SEED := 7

var _pcs: OnlinePcs
var _suspect := "ice_cream"


func before_each() -> void:
	Campaign.current = null
	_suspect = "ice_cream"
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: ChaseLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.suspect_id = _suspect
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> ChaseLevel:
	return OnlinePcs.level(net) as ChaseLevel


func _case(net: Node) -> ChaseCase:
	return _level(net).case


## Host and guest with the case given and the host's cop at the wheel: the chase is on.
func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	_case(pcs[0]).give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	var cop := OnlinePcs.own_cop(pcs[0])
	cop.act("use", _case(pcs[0]).car, [0])
	await wait_until(func() -> bool: return _case(pcs[1]).chasing, 5.0)
	return pcs


func test_the_host_drives_him_and_the_guest_sees_him_go_and_the_clock_run() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	assert_false(host.follower)
	assert_true(guest.follower)
	var start := _level(pcs[1]).truck.global_position
	await wait_physics_frames(60)
	assert_gt(_level(pcs[0]).truck.global_position.distance_to(start), 3.0, "he drives off on the host")
	await wait_until(func() -> bool:
		return _level(pcs[1]).truck.global_position.distance_to(_level(pcs[0]).truck.global_position) < 1.0, 5.0)
	assert_gt(_level(pcs[1]).truck.global_position.distance_to(start), 3.0, "and on the guest")
	assert_lt(guest.time_left, ChaseCase.TIME_LIMIT, "the guest's clock runs")
	assert_almost_eq(guest.time_left, host.time_left, 0.5)
	host.distance = 40.0
	await wait_until(func() -> bool: return guest.distance > 30.0, 5.0)
	assert_almost_eq(_level(pcs[1]).distance_bar.value, guest.distance, 0.5, "the guest's meter shows it")


func test_the_guest_case_does_not_end_it_on_its_own() -> void:
	var pcs := await _on()
	var guest := _case(pcs[1])
	guest.fail("CASE_FAILED_TIME")
	guest.finish_shift()
	assert_false(guest.case_failed, "only the host loses the case")
	assert_false(guest.shift_over)


func test_losing_him_and_the_shift_screen_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.fail("CASE_FAILED_ESCAPED")
	await wait_until(func() -> bool: return guest.case_failed, 5.0)
	assert_true(guest.failed_label.visible)
	assert_eq(guest.failed_label.text, "CASE_FAILED_ESCAPED")
	await wait_until(func() -> bool: return guest.shift_over, ChaseCase.SHIFT_DELAY + 5.0)
	assert_true(host.shift_over)
	assert_true(guest.shift_screen.visible, "the guest sees the end of the shift")
	assert_false(guest.shift_screen.get_node("%AgainButton").visible, "only the host starts the next one")
	assert_true(host.shift_screen.get_node("%AgainButton").visible)


func test_he_gets_off_his_scooter_on_every_pc() -> void:
	_suspect = "moto"
	var pcs := await _on()
	var rider := _level(pcs[1]).truck.get_node("Rider") as Node3D
	assert_true(rider.visible)
	_case(pcs[0]).pull_over()
	await wait_until(func() -> bool: return _case(pcs[1]).stopped, 5.0)
	await wait_until(func() -> bool: return not rider.visible, 5.0)
	assert_false(rider.visible, "the rider is off on the guest too")
