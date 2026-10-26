extends GutTest

## The circus move online (control-circo.md, step 6; docs/diseno/online.md): the host decides the queue, who El Peludo
## is, when he acts like a person and where a loose animal goes; every PC sees the same trucks and animals, his acts,
## the open cages and loose animals, the jewels, and his circus truck dropping banana peels when he runs off.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "circus_move"
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


## The plan's `index`th car, spawned on the host.
func _spawn(pcs: Array[Node], index: int) -> QueueCar:
	var host := _level(pcs[0])
	host.queue.spawned = index
	return host.queue.spawn()


func _real_truck(pcs: Array[Node]) -> int:
	var plan := _level(pcs[0]).plan
	for i in plan.total:
		if i != plan.wanted_index and not plan.cars[i].circus.is_empty():
			return i
	return -1


func _copy(pcs: Array[Node], car: QueueCar) -> QueueCar:
	await wait_until(func() -> bool:
		return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) != null, 5.0)
	return _level(pcs[1]).queue.get_node_or_null(NodePath(car.name)) as QueueCar


func test_both_pcs_play_the_same_circus() -> void:
	var pcs := await _on()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.plan.circus)
	assert_eq(guest.plan.wanted_index, host.plan.wanted_index)
	assert_eq(guest.plan.cars[guest.plan.wanted_index].circus, host.plan.cars[host.plan.wanted_index].circus)
	assert_eq(guest.get_tree().get_nodes_in_group("food_buckets").size(), 2 * CircusTruck.FOODS.size(),
		"the four buckets on every PC")


func test_the_guest_sees_el_peludo_in_his_sneakers_and_his_acts() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _level(pcs[0]).plan.wanted_index)
	var copy := await _copy(pcs, car)
	assert_eq(copy.circus, car.circus)
	assert_not_null(CircusTruck.animal_of(copy).get_node_or_null("Sneaker"))
	car.act_human()
	await wait_until(func() -> bool: return copy.acts == 1, 5.0)
	assert_eq(copy.acts, 1)
	assert_eq(copy.saying(), tr(CircusTruck.human_act(copy.plate, 1)), "the same person's thing")


func test_an_angry_animal_s_impatience_reaches_the_guest_s_meter() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _real_truck(pcs))
	await _copy(pcs, car)
	var wrong := ""
	for food in CircusTruck.FOODS:
		if food != CircusTruck.food_of(car.circus.animal):
			wrong = food
	var before := _level(pcs[0]).queue.patience
	assert_eq(car.feed(wrong), "angry")
	var host_patience := _level(pcs[0]).queue.patience
	assert_almost_eq(host_patience, before + CircusTruck.ANGRY_PATIENCE, 0.5)
	var guest := _level(pcs[1]).queue
	await wait_until(func() -> bool: return absf(guest.patience - _level(pcs[0]).queue.patience) < 0.5, 5.0)
	assert_almost_eq(guest.patience, _level(pcs[0]).queue.patience, 0.5)


func test_an_animal_let_out_on_the_host_roams_and_goes_home_on_the_guest() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _real_truck(pcs))
	var copy := await _copy(pcs, car)
	car.open_cage()
	await wait_until(func() -> bool: return is_instance_valid(copy.loose), 5.0)
	assert_true((copy.get_node("Cage/Door") as CageDoor).is_open)
	assert_false(CircusTruck.animal_of(copy).visible)
	car.loose.global_position += Vector3(3, 0, 0)
	var at := car.loose.global_position
	await wait_until(func() -> bool: return copy.loose.global_position.distance_to(at) < 0.5, 5.0)
	assert_lt(copy.loose.global_position.distance_to(at), 0.5, "where the host's is")
	car.loose.go_home()
	await wait_until(func() -> bool: return CircusTruck.animal_of(copy).visible, 5.0)
	assert_true(CircusTruck.animal_of(copy).visible, "back in on the guest too")
	assert_false(is_instance_valid(copy.loose))


func test_an_animal_gone_on_the_host_is_gone_and_a_complaint_on_the_guest() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _real_truck(pcs))
	var copy := await _copy(pcs, car)
	car.open_cage()
	await wait_until(func() -> bool: return is_instance_valid(copy.loose), 5.0)
	car.loose.run_off()
	await wait_until(func() -> bool: return copy.animal_lost, 5.0)
	assert_true(copy.animal_lost)
	await wait_until(func() -> bool: return _case(pcs[1]).innocents == 1, 5.0)
	assert_eq(_case(pcs[1]).innocents, 1)


func test_cuffed_el_peludo_s_jewels_and_empty_cage_show_on_the_guest() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _level(pcs[0]).plan.wanted_index)
	var copy := await _copy(pcs, car)
	car.state = "waiting"
	car.speed = 0.0
	car.open_cage()
	_case(pcs[0]).detain(car)
	await wait_until(func() -> bool:
		return _level(pcs[1]).find_children("*", "CircusJewels", true, false).size() > 0, 5.0)
	assert_eq(_level(pcs[1]).find_children("*", "CircusJewels", true, false).size(), 1)
	await wait_until(func() -> bool: return not CircusTruck.animal_of(copy).visible, 5.0)
	assert_false(CircusTruck.animal_of(copy).visible, "out of his cage on the guest too")


func test_he_runs_off_dropping_peels_on_the_guest_too() -> void:
	var pcs := await _on()
	var car := _spawn(pcs, _level(pcs[0]).plan.wanted_index)
	await _copy(pcs, car)
	_case(pcs[0]).queue.cars.erase(car)
	_case(pcs[0])._on_passed(car, false)
	var guest := _case(pcs[1])
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_eq(guest.chase.suspect_id, SuspectCar.CIRCUS_TRUCK)
	assert_not_null(guest.chase.truck.get_node_or_null("Cage/Animal/Sneaker"), "his truck, him in it")
	assert_true(guest.chase.drops.bananas)
	_case(pcs[0]).chase.drops.drop_peel()
	await wait_until(func() -> bool: return guest.chase.drops.peels.size() == 1, 5.0)
	assert_eq(guest.chase.drops.peels.size(), 1)
