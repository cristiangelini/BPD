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


## The guest's cop sits in `seat` of the patrol car (the host's is at the wheel).
func _seat_guest(pcs: Array[Node], seat: int) -> Cop:
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.act("use", _case(pcs[1]).car, [seat])
	await wait_until(func() -> bool: return _case(pcs[0]).car.seated[seat] != null, 5.0)
	return cop


func test_a_guest_megaphone_scares_him_on_the_host_and_shows_on_the_guest() -> void:
	var pcs := await _on()
	await _seat_guest(pcs, 3)
	_case(pcs[1]).tasks.do_job("shout")
	await wait_until(func() -> bool: return _case(pcs[0]).tasks.shouts == 1, 5.0)
	assert_gt(_level(pcs[0]).truck.nervous_left, 0.0, "the host's suspect got nervous")
	await wait_until(func() -> bool: return _case(pcs[1]).tasks.shouts == 1, 5.0)
	assert_true(_case(pcs[1]).tasks._shout_label.visible, "the guest sees the shout")


func test_a_guest_at_the_window_throws_the_spikes_for_everyone() -> void:
	var pcs := await _on()
	await _seat_guest(pcs, 2)
	_case(pcs[1]).tasks.do_job("throw_spikes")
	await wait_until(func() -> bool: return _case(pcs[0]).tasks.spikes_left == ChaseTasks.SPIKES - 1, 5.0)
	var traps := func(net: Node) -> Array: return _level(net).find_children("*", "ChaseTrap", true, false)
	await wait_until(func() -> bool: return not traps.call(pcs[1]).is_empty(), 5.0)
	assert_eq(traps.call(pcs[0]).size(), 1)
	var shown: ChaseTrap = traps.call(pcs[1])[0]
	assert_true(shown.shown_only, "the guest's spikes only show")
	assert_almost_eq(shown.global_position.distance_to((traps.call(pcs[0])[0] as Node3D).global_position), 0.0, 0.01)
	assert_eq(_case(pcs[1]).tasks.spikes_left, ChaseTasks.SPIKES, "the guest doesn't count its own")


func test_a_job_from_the_wrong_seat_is_not_done() -> void:
	var pcs := await _on()
	# At the megaphone, with the window empty: the window is the driver's (the host's cop), not this one's.
	await _seat_guest(pcs, 3)
	_case(pcs[1]).tasks.do_job("throw_net")
	await wait_physics_frames(20)
	assert_eq(_case(pcs[0]).tasks.nets_left, ChaseTasks.NETS, "the host didn't throw it for the wrong cop")


func test_he_gets_out_on_every_pc_and_a_guest_cuffs_and_walks_him() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.pull_over()
	await wait_until(func() -> bool: return guest.suspect != null, 5.0)
	assert_eq(guest.suspect.kind, "ice_cream", "the same suspect gets out on the guest")
	assert_eq(guest.suspect.get_parent(), _level(pcs[1]), "in the same place of the level")
	assert_true(guest.escort.follower, "the guest's escort only rides along")
	assert_almost_eq(guest.suspect.global_position.distance_to(host.suspect.global_position), 0.0, 0.5)
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.global_position = host.suspect.global_position + Vector3(0, 0, 1.2)
	cop.act("belt_cuff", cop, [guest.suspect, guest.suspect.global_position])
	await wait_until(func() -> bool: return host.suspect.was_cuffed, 5.0)
	await wait_until(func() -> bool: return guest.caught, 5.0)
	assert_true(host.caught, "cuffed by the guest, caught on the host")
	cop.act("use", guest.suspect)
	await wait_until(func() -> bool: return guest.escort.escorted_by == cop, 5.0)
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	assert_eq(host.escort.escorted_by, copy, "the host walks him after the guest's cop")


func test_a_guest_unhooks_the_towed_patrol_car_and_the_host_lowers_it() -> void:
	_suspect = "tow_truck"
	var pcs := await _pcs.two_pcs()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	host.give_tip()
	await wait_until(func() -> bool: return guest.tip_given, 5.0)
	host.pull_over()
	await wait_until(func() -> bool: return guest.stopped, 5.0)
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.act("use", _level(pcs[1]).truck.get_node("Hook"))
	await wait_until(func() -> bool: return host.unhooked, 5.0)
	assert_false(host.towed.freeze, "the host lowers it and drives it")
	await wait_until(func() -> bool: return guest.unhooked, 5.0)
	assert_true(guest.towed.freeze, "the guest's follows the host's")


func test_the_ice_cream_puddles_land_in_the_same_place_on_every_pc() -> void:
	var pcs := await _on()
	var puddle := _case(pcs[0]).drops.drip()
	await wait_until(func() -> bool: return not _case(pcs[1]).drops.puddles.is_empty(), 5.0)
	var copy: Node3D = _case(pcs[1]).drops.puddles[0][0]
	assert_almost_eq(copy.global_position.distance_to(puddle.global_position), 0.0, 0.01)
	assert_eq(_case(pcs[1]).drops.puddles.size(), 1, "the guest drips none of its own")


func test_the_moving_truck_furniture_falls_on_the_host_and_the_guest_sees_it() -> void:
	_suspect = "moving_truck"
	var pcs := await _on()
	var sofa := _case(pcs[0]).drops.drop_furniture() as ChaseFurniture
	var copy_of := func() -> ChaseFurniture: return _level(pcs[1]).get_node_or_null(NodePath(sofa.name)) as ChaseFurniture
	await wait_until(func() -> bool: return copy_of.call() != null, 5.0)
	var copy: ChaseFurniture = copy_of.call()
	assert_eq(copy.piece, sofa.piece, "the same piece")
	assert_true(copy.freeze, "it only falls on the host")
	await wait_physics_frames(30)
	await wait_until(func() -> bool: return copy.global_position.distance_to(sofa.global_position) < 0.2, 5.0)
	assert_almost_eq(copy.global_position.distance_to(sofa.global_position), 0.0, 0.2, "it lies where the host's lies")


func test_the_highway_traffic_and_a_broken_toll_barrier_are_the_host_s() -> void:
	_suspect = "highway"
	var pcs := await _on()
	var host_car: TrafficCar = _case(pcs[0]).highway.traffic[0]
	var guest_car: TrafficCar = _case(pcs[1]).highway.traffic[0]
	assert_false(guest_car.is_physics_processing(), "the guest's traffic only follows")
	var start := guest_car.global_position
	await wait_physics_frames(60)
	# It drives fast: the copy trails the host's by a packet or two.
	assert_gt(guest_car.global_position.distance_to(start), 3.0, "it drives on the guest")
	assert_lt(guest_car.global_position.distance_to(host_car.global_position), 6.0, "where the host's goes")
	var barrier: TollBarrier = _level(pcs[0]).find_children("*", "TollBarrier", true, false)[1]
	barrier._break(_case(pcs[0]).car)
	var copy: TollBarrier = _level(pcs[1]).find_children("*", "TollBarrier", true, false)[1]
	await wait_until(func() -> bool: return copy.is_broken, 5.0)
	assert_true(copy.is_broken, "the guest sees it broken")
