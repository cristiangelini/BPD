extends GutTest

## Clown convoy step 1 (control-payasos.md): in the "clown_convoy" variant every car in the queue is the same tiny
## clown car, with the same plate, a clown at the wheel and a smaller trunk, and they queue up by their own length.
## Time is stepped by hand, 0.1 s at a time, like test_traffic_queue.gd.

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


func test_every_car_is_a_clown_car_with_the_same_plate() -> void:
	_tick(20)
	assert_gt(queue.cars.size(), 2)
	for car in queue.cars:
		assert_true(car.clown)
		assert_eq((car.get_node("Plate") as Label3D).text, tr("PLATE_CLOWN"))
		assert_not_null(car.get_node_or_null("Driver"), "a clown at the wheel")
		assert_almost_eq(car.lid.size.x, QueueCar.CLOWN_LID.x, 0.001)


func test_clown_cars_queue_up_by_their_own_length() -> void:
	_tick(25)
	var first := queue.front()
	var second := queue.cars[1]
	assert_true(first.waiting())
	assert_true(second.waiting())
	assert_almost_eq(first.at.z, TrafficCheckpoint.ZONE.y / 2 + QueueCar.CLOWN_LENGTH / 2 + 0.5, 0.1)
	assert_almost_eq(second.at.z - first.at.z, QueueCar.CLOWN_LENGTH + QueueCar.GAP, 0.1)


func test_the_convoy_comes_less_often_than_the_rush_hour() -> void:
	assert_almost_eq(queue.spawn_every(), TrafficQueue.SPAWN_EVERY * 0.75, 0.001)


func test_rush_hour_cars_stay_as_they_were() -> void:
	queue.variant = "rush_hour"
	_tick(1)
	var car := queue.front()
	assert_false(car.clown)
	assert_eq((car.get_node("Plate") as Label3D).text, car.plate)
	assert_null(car.get_node_or_null("Driver"))


func test_the_level_takes_the_variant_from_the_args() -> void:
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=clown_convoy"])), "clown_convoy")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=nope"]), 4),
		TrafficControlLevel.variant_from("", PackedStringArray(), 4), "a wrong one draws it")
	assert_eq(TrafficControlLevel.variant_from("clown_convoy", PackedStringArray()), "clown_convoy")


func test_a_guest_copy_knows_it_is_a_clown_car() -> void:
	_tick(1)
	assert_true(queue.front().net_setup().clown)


func test_the_plate_is_translated() -> void:
	assert_ne(tr("PLATE_CLOWN"), "PLATE_CLOWN")
