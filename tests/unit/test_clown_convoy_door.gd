extends GutTest

## Clown convoy step 2 (control-payasos.md, "Cómo es", steps 3 and 4): opening a clown car's door lets out 3 to 6
## clowns, the driver first, who wander off; the car won't move or be let through until they're all back in, carried
## or pushed to its door, and loose clowns wear the queue's patience out.

var checkpoint: TrafficCheckpoint
var barrier: RoadBarrier
var queue: TrafficQueue


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	barrier = RoadBarrier.new()
	barrier.freeze = true
	add_child_autofree(barrier)
	barrier.global_transform = checkpoint.global_transform
	for z in [4.0, 7.0]:
		var cone := TrafficCone.new()
		cone.freeze = true
		add_child_autofree(cone)
		cone.global_position = checkpoint.global_transform * Vector3(-1, 0, z)
	checkpoint.ready_now = checkpoint.is_set_up()
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "clown_convoy"
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


## The first car, stopped at the barrier, with its door open.
func _spilled() -> QueueCar:
	_tick(10)
	var car := queue.front()
	assert_true(car.waiting())
	car.door.set_angle(TrunkLid.MAX_ANGLE)
	return car


func test_every_clown_car_has_a_door_on_the_driver_s_side() -> void:
	_tick(1)
	var car := queue.front()
	assert_not_null(car.door)
	assert_true(car.door.side)
	assert_eq(car.door.prompt_key(null), "PROMPT_CLOWN_DOOR")


func test_lifting_the_door_out_opens_it() -> void:
	_tick(10)
	var car := queue.front()
	car.door.holders[1] = car.global_transform * (QueueCar.CLOWN_DOOR_HINGE + Vector3(0.9, 0, -0.3))
	car.door._physics_process(0.1)
	car.door.holders.clear()
	assert_true(car.door.is_open, "pulled out toward +X it swings open")
	assert_false(car.clowns_out.is_empty())


func test_the_open_door_lets_out_its_clowns_driver_first() -> void:
	var car := _spilled()
	assert_eq(car.clowns_out.size(), car.riders())
	assert_between(car.riders(), QueueCar.CLOWN_RIDERS.x, QueueCar.CLOWN_RIDERS.y)
	assert_true(car.clowns_out[0].is_driver)
	assert_eq(car.clowns_out.filter(func(c: ConvoyClown) -> bool: return c.is_driver).size(), 1)
	assert_false((car.get_node("Driver") as Node3D).visible, "the seat is empty")
	assert_eq(queue.loose_clowns(), car.riders())


func test_riders_are_the_same_on_every_pc() -> void:
	var a := QueueCar.new()
	a.plate = "BCD 123"
	var b := QueueCar.new()
	b.plate = "BCD 123"
	assert_eq(a.riders(), b.riders())
	a.free()
	b.free()


func test_the_car_won_t_go_with_clowns_out() -> void:
	var car := _spilled()
	watch_signals(queue)
	barrier.use(null)
	assert_eq(car.state, "waiting")
	assert_eq(queue.front(), car)
	assert_signal_not_emitted(queue, "passed")
	var z := car.at.z
	_tick(2)
	assert_almost_eq(car.at.z, z, 0.01, "it stays put even with the barrier up")


func test_clowns_back_at_the_door_get_in_and_then_it_goes() -> void:
	var car := _spilled()
	for out in car.clowns_out.duplicate():
		out.out_for = ConvoyClown.OUT_AT_LEAST
		out.global_position = car.door_point()
		out._physics_process(0.1)
	await wait_physics_frames(2)
	assert_true(car.can_go())
	assert_eq(queue.loose_clowns(), 0)
	assert_true((car.get_node("Driver") as Node3D).visible, "the driver's back at the wheel")
	barrier.use(null)
	assert_eq(car.state, "going")


func test_a_clown_just_out_doesn_t_hop_back_in() -> void:
	var car := _spilled()
	var out := car.clowns_out[0]
	out.global_position = car.door_point()
	out._physics_process(0.1)
	assert_true(out in car.clowns_out)


func test_a_grabbed_clown_complains() -> void:
	var car := _spilled()
	var out := car.clowns_out[1]
	out.hold(1, out.global_position + Vector3.UP)
	assert_eq(out.saying(), tr("CONVOY_CLOWN_LINE_0"))


func test_loose_clowns_wear_the_patience_out() -> void:
	var car := _spilled()
	queue.patience = 0.0
	var before := queue.patience
	queue._physics_process(1.0)
	var waiting := queue.waiting_count() * TrafficQueue.PATIENCE_PER_CAR * float(TrafficQueue.VARIANTS.clown_convoy.patience)
	assert_almost_eq(queue.patience - before, waiting + car.riders() * TrafficQueue.PATIENCE_PER_CLOWN, 0.01)


func test_a_car_with_clowns_out_doesn_t_sneak_by() -> void:
	var car := _spilled()
	queue.patience = TrafficQueue.FULL
	queue._physics_process(0.1)
	assert_eq(car.state, "waiting")
	assert_eq(queue.sneaked, 0)


func test_texts_are_translated() -> void:
	for key in ["PROMPT_CLOWN_DOOR", "PROMPT_CONVOY_CLOWN", "HINT_CLOWNS_OUT"]:
		assert_ne(tr(key), key)
	for i in ConvoyClown.LINES:
		assert_ne(tr("CONVOY_CLOWN_LINE_%d" % i), "CONVOY_CLOWN_LINE_%d" % i)
