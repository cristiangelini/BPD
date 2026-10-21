extends GutTest

## The dangerous suspect out on the street online (persecucion-final.md, decision 96; docs/diseno/online.md): the host
## decides he got out the front door and runs the chase after him, and every PC sees him drive off and how it ends.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/interrogation.tscn")
## A seed that draws the dangerous one (InterrogationCase.pick_suspect).
const SEED := 9

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: InterrogationLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		return level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _case(net: Node) -> InterrogationCase:
	return (OnlinePcs.level(net) as InterrogationLevel).case


## Host and guest with the case given and the dangerous one out the front door on the host.
func _out() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _case(pcs[0])
	host.give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	host.loose = true
	host.suspect.outside.emit()
	await wait_until(func() -> bool: return _case(pcs[1]).chase != null, 5.0)
	return pcs


func test_online_he_can_head_for_the_street() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _case(pcs[0])
	assert_eq(host.suspect_id, "dangerous")
	host.give_tip()
	host._seen = true
	host._unwatched = InterrogationCase.LOOSE_SECONDS
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).camera.look_at((cop as Cop).camera.global_position + Vector3.UP, Vector3.BACK)
	host._watch(0.1)
	assert_true(host.loose)
	assert_true(host.suspect.can_leave, "online too (it waited for the chase to be synced)")


func test_he_drives_off_in_the_old_patrol_car_on_every_pc() -> void:
	var pcs := await _out()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	assert_true(guest.chase.follower)
	assert_false(host.chase.follower)
	assert_true(guest.escaping)
	assert_false(guest.suspect.visible, "he's gone from the wing on the guest")
	assert_eq(guest.chase.truck, guest.getaway, "in the guest's copy of the old patrol car")
	var start := guest.getaway.global_position
	await wait_until(func() -> bool: return guest.getaway.global_position.distance_to(start) > 3.0, 5.0)
	assert_gt(guest.getaway.global_position.distance_to(start), 3.0, "he drives off on the guest")
	# A car drives fast: the copy trails the host's by a packet or two.
	await wait_until(func() -> bool:
		return guest.getaway.global_position.distance_to(host.getaway.global_position) < 3.0, 5.0)
	assert_lt(guest.getaway.global_position.distance_to(host.getaway.global_position), 3.0, "where the host's goes")
	await wait_until(func() -> bool: return guest.chase.time_left < ChaseCase.TIME_LIMIT, 5.0)
	assert_almost_eq(guest.chase.time_left, host.chase.time_left, 0.5, "the guest's clock is the host's")


func test_caught_he_is_back_in_his_chair_on_every_pc() -> void:
	var pcs := await _out()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.chase.pull_over()
	await wait_until(func() -> bool: return guest.chase.suspect != null, 5.0)
	assert_eq(guest.chase.suspect.kind, "dangerous", "he gets out on the guest")
	host.chase.suspect.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(2)
	host.chase.escort.board()
	await wait_until(func() -> bool: return not host.escaping, 5.0)
	await wait_until(func() -> bool: return not guest.escaping, 5.0)
	assert_true(guest.chase.case_solved, "caught on the guest too")
	assert_true(guest.suspect.visible, "back in the wing")
	assert_true(guest.is_on(), "the interrogation goes on")
	await wait_until(func() -> bool: return guest.nerves == host.nerves, 5.0)
	assert_eq(guest.nerves, InterrogationCase.CAUGHT_NERVES, "scared once, on the host")


func test_getting_away_loses_the_interrogation_everywhere() -> void:
	var pcs := await _out()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.chase.fail("CASE_FAILED_TIME")
	await wait_until(func() -> bool: return guest.escaped, 5.0)
	assert_true(guest.failed_label.visible)
	assert_eq(guest.failed_label.text, "CASE_FAILED_SUSPECT_ESCAPED")
	await wait_until(func() -> bool: return guest.shift_over, InterrogationCase.SHIFT_DELAY + 5.0)
	assert_true(host.shift_over, "the host ends the shift and the guest sees it")
