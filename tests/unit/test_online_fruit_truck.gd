extends GutTest

## The fruit truck online (control-frutas.md, step 6; docs/diseno/online.md): the host's watermelons show on every PC,
## the same kinds, riding in the bed; a tap from a guest sounds on every PC; one split on the host splits everywhere and
## its complaint reaches the guests; one just gone with its truck goes without juice; and the wanted pickup running off
## is the fruit truck on every PC, in its paint.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")
const SEED := 4

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
		level.case_seed = SEED
		level.variant = "fruit_truck"
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


## The host's watermelon `melon` on the guest.
func _twin(pcs: Array[Node], melon: Watermelon) -> Watermelon:
	await wait_until(func() -> bool: return _level(pcs[1]).get_node_or_null(NodePath(melon.name)) != null, 5.0)
	return _level(pcs[1]).get_node_or_null(NodePath(melon.name)) as Watermelon


func test_both_pcs_play_the_fruit_truck() -> void:
	var pcs := await _on()
	assert_true(_level(pcs[0]).plan.fruit)
	assert_true(_level(pcs[1]).plan.fruit)


func test_the_host_s_watermelons_ride_on_the_guest() -> void:
	var pcs := await _on()
	var car := _stopped_car(pcs)
	var copy := await _copy(pcs, car)
	for melon in car.bed_melons():
		var twin := await _twin(pcs, melon)
		assert_not_null(twin, "named alike")
		assert_eq(twin.kind, melon.kind)
		assert_true(twin.freeze, "it follows the host's")
	await wait_physics_frames(2)
	assert_eq(copy.bed_melons().size(), 0, "not its own as well")
	assert_eq(copy.crate, car.crate)
	assert_eq(copy.hat, car.hat)


func test_a_tap_from_the_guest_sounds_everywhere() -> void:
	var pcs := await _on()
	var car := _stopped_car(pcs)
	await _copy(pcs, car)
	var melon := car.bed_melons()[0]
	var twin := await _twin(pcs, melon)
	OnlinePcs.own_cop(pcs[1]).act("use", twin)
	await wait_until(func() -> bool: return melon.taps == 1 and twin.taps == 1, 5.0)
	assert_eq(melon.saying(), tr(melon.tap_key()))
	assert_eq(twin.saying(), melon.saying())


func test_split_on_the_host_it_splits_on_the_guest_with_its_complaint() -> void:
	var pcs := await _on()
	var car := _stopped_car(pcs)
	await _copy(pcs, car)
	var melon := car.bed_melons()[0]
	var twin := await _twin(pcs, melon)
	var twin_ref: WeakRef = weakref(twin)
	twin = null
	melon.leave_bed()
	melon.hit(INF)
	await wait_until(func() -> bool: return twin_ref.get_ref() == null, 5.0)
	assert_null(twin_ref.get_ref(), "split there too")
	await wait_until(func() -> bool: return _case(pcs[1]).melon_complaints == 1, 5.0)
	assert_eq(_case(pcs[1]).melon_complaints, 1)


func test_gone_with_its_truck_it_goes_without_juice() -> void:
	var pcs := await _on()
	var car := _stopped_car(pcs)
	await _copy(pcs, car)
	var melon := car.bed_melons()[0]
	var twin := await _twin(pcs, melon)
	var twin_ref: WeakRef = weakref(twin)
	twin = null
	var juice := get_tree().get_nodes_in_group("melon_juice").size()
	melon.queue_free()
	await wait_until(func() -> bool: return twin_ref.get_ref() == null, 5.0)
	assert_null(twin_ref.get_ref())
	assert_eq(get_tree().get_nodes_in_group("melon_juice").size(), juice)


func test_the_wanted_pickup_runs_off_on_every_pc() -> void:
	var pcs := await _on()
	var host := _case(pcs[0])
	var guest := _case(pcs[1])
	var car := _stopped_car(pcs, true)
	await _copy(pcs, car)
	var look := car.look
	host._on_passed(car, false)
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_eq(guest.chase.suspect_id, SuspectCar.FRUIT_TRUCK, "the fruit truck on the guest too")
	var paints := guest.chase.truck.find_children("paint*", "MeshInstance3D", true, false)
	assert_gt(paints.size(), 0)
	assert_eq(((paints[0] as MeshInstance3D).material_override as StandardMaterial3D).albedo_color,
		QueueCar.FRUIT_PAINTS[look % QueueCar.FRUIT_PAINTS.size()])
