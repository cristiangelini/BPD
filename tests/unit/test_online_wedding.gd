extends GutTest

## The wedding breathalyzer check online (control-boda.md, step 6; docs/diseno/online.md): the host decides the queue,
## what each driver blows, who El Colado is and the designated drivers; every PC sees the same wedding cars, the keys
## taken, El Colado's envelopes and, in the chase, the cans he cuts loose.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "wedding"
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


## The host's `index`th car of the plan, stopped at the barrier.
func _stopped(pcs: Array[Node], index: int) -> QueueCar:
	var queue := _level(pcs[0]).queue
	queue.spawned = index
	var car := queue.spawn()
	car.set_physics_process(false)
	for i in 300:
		car._physics_process(0.1)
		if car.waiting():
			break
	car.set_physics_process(true)
	return car


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		var copy := _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar
		return copy != null and copy.waiting(), 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


## The first drunk guest of the host's plan.
func _drunk_index(pcs: Array[Node]) -> int:
	var plan := _level(pcs[0]).plan
	for i in plan.total:
		if plan.cars[i].alcohol > WeddingCar.DRUNK_ABOVE:
			return i
	return -1


func test_both_pcs_play_the_same_wedding() -> void:
	var pcs := await _on()
	assert_true(_level(pcs[0]).plan.wedding)
	assert_true(_level(pcs[1]).plan.wedding)
	assert_eq(_level(pcs[1]).plan.couple, _level(pcs[0]).plan.couple, "the same couple")
	assert_not_null(_level(pcs[1]).breathalyzer, "a breathalyzer on every PC")


func test_the_guest_sees_the_same_wedding_cars() -> void:
	var pcs := await _on()
	var plan := _level(pcs[0]).plan
	var car := _stopped(pcs, plan.newlyweds_index)
	var copy := await _copy(pcs, car)
	assert_true(copy.newlyweds)
	assert_not_null(copy.get_node_or_null("JustMarried"))
	assert_not_null(copy.get_node_or_null("Bow"))
	assert_eq(copy.alcohol, car.alcohol)
	assert_eq(copy.couple, car.couple)


func test_keys_taken_on_the_host_show_the_relative_on_the_guest() -> void:
	var pcs := await _on()
	var car := _stopped(pcs, _drunk_index(pcs))
	var copy := await _copy(pcs, car)
	var drunk := copy.get_node("WindowDriver")
	car.blow(null)
	car.take_keys()
	assert_eq(_case(pcs[0]).drunk_keys, 1)
	await wait_until(func() -> bool: return copy.keys_taken, 5.0)
	assert_true(copy.blown)
	assert_true(copy.keys_taken)
	await wait_process_frames(2)
	assert_ne(copy.get_node_or_null("WindowDriver"), drunk, "someone else at the window")
	await wait_until(func() -> bool: return _case(pcs[1]).drunk_keys == 1, 5.0)
	assert_eq(_case(pcs[1]).drunk_keys, 1, "the guest's pay counts it too")


func test_el_colado_s_envelopes_reach_the_guest() -> void:
	var pcs := await _on()
	var car := _stopped(pcs, _level(pcs[0]).plan.wanted_index)
	await _copy(pcs, car)
	_case(pcs[0]).detain(car)
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "GiftEnvelopes", true, false).size() > 0, 5.0)
	assert_eq(_level(pcs[1]).find_children("*", "GiftEnvelopes", true, false).size(), 1)


func test_the_cans_he_cuts_loose_show_on_the_guest() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var car := _stopped(pcs, _level(pcs[0]).plan.wanted_index)
	await _copy(pcs, car)
	host.queue.cars.erase(car)
	host._on_passed(car, false)
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_true(guest.chase.drops.wedding)
	assert_not_null(guest.chase.truck.get_node_or_null("Cans"), "the guest's runaway wears them too")
	host.chase.chasing = true
	host.chase.drops.drop_can()
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "ChaseCan", true, false).size() > 0, 5.0)
	assert_eq(_level(pcs[1]).find_children("*", "ChaseCan", true, false).size(), 1)
	assert_eq(guest.chase.drops.cans.size(), 0, "the guest drops none of its own")
