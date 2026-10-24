extends GutTest

## The traffic control online (control-transito.md; docs/diseno/online.md, "Qué se sincroniza"): the host's queue
## brings the cars and decides who's detained, and every PC sees the same cars, meter, clues, trunks, the one who ran
## off and the end of shift.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 4

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		# Play draws the clown convoy for some seeds (control-payasos.md); this is the rush hour's.
		level.variant = "rush_hour"
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> TrafficControlLevel:
	return OnlinePcs.level(net) as TrafficControlLevel


func _case(net: Node) -> TrafficCase:
	return _level(net).case


## Host and guest with the case given and the host's barrier across the lane.
func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	host.case.give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	var barrier := host.get_node("Barrier") as RoadBarrier
	barrier.freeze = true
	barrier.global_transform = host.checkpoint.global_transform
	return pcs


## A car of the host's queue, stopped at the barrier (`wanted`: the one the case is after).
func _stopped_car(pcs: Array[Node], wanted := false) -> QueueCar:
	var queue := _level(pcs[0]).queue
	if wanted:
		queue.spawned = _level(pcs[0]).plan.wanted_index
	var car := queue.spawn()
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


## The guest's copy of the host's `car`.
func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		var copy := _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar
		return copy != null and copy.waiting(), 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


func test_the_guest_sees_the_host_s_cars_meter_and_clues() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	assert_true(guest.follower)
	assert_true(guest.queue.follower, "the guest's queue brings no cars of its own")
	var car := _stopped_car(pcs)
	var copy := await _copy(pcs, car)
	assert_not_null(copy, "the host's car shows on the guest")
	assert_eq(copy.plate, car.plate)
	assert_false(copy.wanted, "the guest doesn't know which one it is")
	await wait_until(func() -> bool: return copy.global_position.distance_to(car.global_position) < 0.2, 5.0)
	assert_almost_eq(copy.global_position.distance_to(car.global_position), 0.0, 0.2, "where the host's stopped")
	host.queue._set_patience(40.0)
	await wait_until(func() -> bool: return guest.queue.patience == 40.0, 5.0)
	assert_eq(_level(pcs[1]).meters.patience_bar.value, 40.0, "the guest's meter shows it")
	host.clues.elapsed = WantedPlan.RADIO_EVERY
	host.clues._catch_up()
	await wait_until(func() -> bool: return guest.clues.known == 2, 5.0)
	assert_eq(guest.clues.known, host.clues.known, "the radio's clue reaches the guest")


func test_a_guest_cuffs_an_innocent_and_the_host_counts_it() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var car := _stopped_car(pcs)
	assert_false(car.wanted)
	var copy := await _copy(pcs, car)
	var cop := OnlinePcs.own_cop(pcs[1])
	cop.global_position = copy.global_position + copy.global_basis.x * 2.0
	cop.act("belt_cuff", cop, [copy, copy.global_position])
	await wait_until(func() -> bool: return host.innocents == 1, 5.0)
	assert_eq(car.state, "going", "the host lets them go")
	await wait_until(func() -> bool: return guest.innocents == 1, 5.0)
	assert_eq(guest.innocents, 1, "counted once, on the host")


func test_a_trunk_opened_on_the_guest_opens_on_the_host() -> void:
	var pcs := await _on()
	var car := _stopped_car(pcs)
	var copy := await _copy(pcs, car)
	OnlinePcs.own_cop(pcs[1]).act("open_trunk", copy)
	await wait_until(func() -> bool: return car.trunk_checked, 5.0)
	assert_true(car.lid.is_open, "open on the host")
	assert_true(copy.lid.is_open)


func test_the_wanted_driver_gets_out_on_every_pc() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var car := _stopped_car(pcs, true)
	assert_true(car.wanted)
	await _copy(pcs, car)
	host.detain(car)
	await wait_until(func() -> bool: return guest.suspect != null, 5.0)
	assert_eq(guest.suspect.kind, "driver")
	assert_true(guest.escort.follower, "the guest's escort only rides along")


func test_the_wanted_car_runs_off_and_the_guest_follows_the_chase() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var car := _stopped_car(pcs, true)
	await _copy(pcs, car)
	host._on_passed(car, false)
	assert_not_null(host.chase)
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_true(guest.chase.follower)
	assert_eq(guest.chase.suspect_id, host.chase.suspect_id, "in the same car")
	host.chase.fail("CASE_FAILED_TIME")
	await wait_until(func() -> bool: return guest.escaped, 5.0)
	await wait_until(func() -> bool: return guest.shift_over, TrafficCase.SHIFT_DELAY + 5.0)
	assert_true(host.shift_over)
	assert_false(guest.shift_screen.get_node("%AgainButton").visible, "only the host starts the next one")
