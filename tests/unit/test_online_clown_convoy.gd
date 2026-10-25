extends GutTest

## The clown convoy online (control-payasos.md, step 6; docs/diseno/online.md): the host's clowns come out of the
## car on every PC, named alike and dressed the same, get back in everywhere, their cleaned faces show on the guests,
## and the wanted clown's empty seat and his clown car running off reach every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 4

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "clown_convoy"
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


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) != null, 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


## The host's car with its door opened from the guest, and the guest's copy once its clowns are there.
func _spilled(pcs: Array[Node], wanted := false) -> Array[QueueCar]:
	var car := _stopped_car(pcs, wanted)
	var copy := await _copy(pcs, car)
	OnlinePcs.own_cop(pcs[1]).act("open_door", copy)
	await wait_until(func() -> bool: return car.spilled, 5.0)
	await wait_until(func() -> bool: return copy.clowns_out.size() == car.clowns_out.size(), 5.0)
	return [car, copy]


func test_both_pcs_play_the_convoy() -> void:
	var pcs := await _on()
	assert_true(_level(pcs[0]).plan.convoy)
	assert_true(_level(pcs[1]).plan.convoy)
	assert_not_null(_level(pcs[1]).sponge)


func test_the_host_s_clowns_come_out_on_the_guest() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs)
	var car: QueueCar = cars[0]
	var copy: QueueCar = cars[1]
	assert_true(copy.follower)
	assert_eq(copy.clowns_out.size(), car.riders(), "the same clowns, not its own")
	for out in car.clowns_out:
		var twin := _level(pcs[1]).get_node_or_null(NodePath(out.name)) as ConvoyClown
		assert_not_null(twin, "named alike")
		assert_eq(twin.traits, out.traits)
		assert_eq(twin.is_driver, out.is_driver)
		assert_eq(twin.car, copy)


func test_clowns_back_in_on_the_host_are_back_in_on_the_guest() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs)
	var car: QueueCar = cars[0]
	var copy: QueueCar = cars[1]
	car.recall_clowns()
	await wait_until(func() -> bool: return copy.clowns_out.is_empty(), 5.0)
	assert_true(copy.can_go())


func test_a_face_cleaned_on_the_host_shows_on_the_guest() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs)
	var out: ConvoyClown = (cars[0] as QueueCar).clowns_out[0]
	for i in ConvoyClown.SCRUBS:
		out.scrub()
	var twin := _level(pcs[1]).get_node(NodePath(out.name)) as ConvoyClown
	await wait_until(func() -> bool: return not twin.makeup_on, 5.0)
	assert_false(twin.makeup_on)


func test_the_wanted_clown_s_seat_is_empty_on_every_pc() -> void:
	var pcs := await _on()
	var cars := await _spilled(pcs, true)
	var car: QueueCar = cars[0]
	var copy: QueueCar = cars[1]
	_case(pcs[0]).detain(car)
	var guest := _case(pcs[1])
	await wait_until(func() -> bool: return guest.suspect != null and guest.taken_from != "", 5.0)
	assert_eq(guest.suspect.kind, "clown")
	await wait_physics_frames(2)
	assert_null(copy.get_node_or_null("Driver"))


func test_the_wanted_clown_car_runs_off_on_every_pc() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var car := _stopped_car(pcs, true)
	await _copy(pcs, car)
	host._on_passed(car, false)
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_eq(guest.chase.suspect_id, SuspectCar.CLOWN_CAR, "the clown car on the guest too")
