extends GutTest

## The crowded car online (control-auto-lleno.md, step 7; docs/diseno/online.md): the host decides how many ride in
## each car and who the gang is; its riders pop out on every PC, named alike and looking the same, with the faces on the
## windows going with them; a sticker put on from a guest gets the same number everywhere, looking inside and the
## overload fine reach the host's case, and the gang running off sheds jumpers on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 4

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "crowded_car"
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> TrafficControlLevel:
	return OnlinePcs.level(net) as TrafficControlLevel


func _case(net: Node) -> TrafficCase:
	return _level(net).case


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	host.case.give_tip()
	await wait_until(func() -> bool: return _case(pcs[1]).tip_given, 5.0)
	var barrier := host.get_node("Barrier") as RoadBarrier
	barrier.freeze = true
	barrier.global_transform = host.checkpoint.global_transform
	return pcs


## The host's car with the gang's headcount (or `riders`), stopped at the barrier.
func _stopped_car(pcs: Array[Node], wanted := false, riders := 12) -> QueueCar:
	var queue := _level(pcs[0]).queue
	if wanted:
		queue.spawned = _level(pcs[0]).plan.wanted_index
	else:
		queue.plan = null
	var car := queue.spawn()
	if not wanted:
		car.crowd = riders
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	car.set_physics_process(true)
	return car


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) != null, 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


## The host's car with its door opened from the guest, and the guest's copy once its riders are all out there.
func _spilled(pcs: Array[Node], wanted := false) -> Array[QueueCar]:
	var car := _stopped_car(pcs, wanted)
	var copy := await _copy(pcs, car)
	OnlinePcs.own_cop(pcs[1]).act("open_door", copy)
	await wait_until(func() -> bool: return car.spilled and car._to_pop == 0, 10.0)
	await wait_until(func() -> bool: return copy.clowns_out.size() == car.riders_out(), 5.0)
	return [car, copy]


func test_both_pcs_play_the_crowded_car() -> void:
	var pcs := await _on()
	assert_true(_level(pcs[0]).plan.crowd)
	assert_true(_level(pcs[1]).plan.crowd)


func test_the_guest_s_car_carries_the_host_s_riders() -> void:
	var pcs := await _on()
	var car := _stopped_car(pcs, true)
	var copy := await _copy(pcs, car)
	assert_eq(copy.crowd, car.crowd)
	assert_eq(copy.crowd, _level(pcs[0]).plan.clues[0].value, "the gang's headcount")
	assert_eq(copy.get_node("Faces").get_child_count(), car.get_node("Faces").get_child_count())


func test_the_host_s_riders_pop_out_on_the_guest() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs)
	var car: QueueCar = cars[0]
	var copy: QueueCar = cars[1]
	for out in car.clowns_out:
		var twin := _level(pcs[1]).get_node_or_null(NodePath(out.name)) as CrowdRider
		assert_not_null(twin, "named alike")
		assert_eq(twin.traits, out.traits)
		assert_eq(twin.is_driver, out.is_driver)
		assert_eq(twin.car, copy)
	var shown := copy.get_node("Faces").get_children().filter(func(f: Node3D) -> bool: return f.visible).size()
	assert_eq(shown, CrowdedCar.stay_in(car.plate, car.crowd), "only who stayed in shows on the guest's windows")


func test_a_sticker_from_the_guest_gets_the_same_number_everywhere() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs)
	var car: QueueCar = cars[0]
	var outs := car.clowns_out.slice(0, 3)
	for out in outs:
		var twin := _level(pcs[1]).get_node(NodePath(out.name)) as CrowdRider
		OnlinePcs.own_cop(pcs[1]).act("use", twin)
		await wait_until(func() -> bool: return (out as CrowdRider).sticker > 0, 5.0)
	for i in outs.size():
		var out := outs[i] as CrowdRider
		var twin := _level(pcs[1]).get_node(NodePath(out.name)) as CrowdRider
		assert_eq(out.sticker, i + 1)
		await wait_until(func() -> bool: return twin.sticker == out.sticker, 5.0)
		assert_eq(twin.sticker, out.sticker)
	assert_eq(car.counted, 3)


func test_the_overload_fine_from_the_guest_reaches_the_host() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs)
	var car: QueueCar = cars[0]
	var copy: QueueCar = cars[1]
	for out in car.clowns_out:
		car.count_rider(out)
		var twin := _level(pcs[1]).get_node(NodePath(out.name)) as CrowdRider
		copy.count_rider(twin)
	OnlinePcs.own_cop(pcs[1]).act("use", copy.door)
	await wait_until(func() -> bool: return car.looked_inside, 5.0)
	OnlinePcs.own_cop(pcs[1]).act("use", copy)
	await wait_until(func() -> bool: return _case(pcs[0]).crowd_fines == 1, 5.0)
	await wait_until(func() -> bool: return _case(pcs[1]).crowd_fines == 1, 5.0)
	assert_true(car.fined)
	assert_eq(_case(pcs[1]).crowd_fines, 1)


func test_riders_back_in_on_the_host_are_back_in_on_the_guest() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs)
	var car: QueueCar = cars[0]
	var copy: QueueCar = cars[1]
	car.recall_clowns()
	await wait_until(func() -> bool: return copy.clowns_out.is_empty(), 5.0)
	var shown := copy.get_node("Faces").get_children().filter(func(f: Node3D) -> bool: return f.visible).size()
	assert_eq(shown, mini(car.crowd, CrowdedCar.SLOTS.size()))


func test_the_gang_runs_off_shedding_jumpers_on_every_pc() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var car := _stopped_car(pcs, true)
	await _copy(pcs, car)
	host._on_passed(car, false)
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_true(guest.chase.truck.has_node("Faces"), "packed on the guest too")
	host.chase.chasing = true
	var jumper := host.chase.drops.drop_jumper()
	await wait_until(func() -> bool: return _level(pcs[1]).get_node_or_null(NodePath(jumper.name)) != null, 5.0)
	assert_not_null(_level(pcs[1]).get_node_or_null(NodePath(jumper.name)), "the jumper reaches the guest")
	await wait_until(func() -> bool: return guest.chase.drops.riders_left == host.chase.drops.riders_left, 5.0)
	assert_eq(guest.chase.drops.riders_left, host.chase.drops.riders_left)
