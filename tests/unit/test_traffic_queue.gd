extends GutTest

## Traffic control step 2 (control-transito.md): cars come once the checkpoint is set up, stop at the barrier and
## behind each other, E on the barrier lets the first one through, and the patience meter makes one sneak by.
## Time is stepped by hand, 0.1 s at a time.

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
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func test_no_cars_until_the_checkpoint_is_set_up() -> void:
	checkpoint.ready_now = false
	_tick(10)
	assert_eq(queue.spawned, 0)


func test_rush_hour_sends_a_car_every_three_seconds() -> void:
	assert_almost_eq(queue.spawn_every(), 3.0, 0.001)
	# The first one right away, then at 3, 6 and 9 s.
	_tick(9.05)
	assert_eq(queue.spawned, 4)


func test_cars_stop_at_the_barrier_and_behind_each_other() -> void:
	_tick(20)
	assert_gt(queue.cars.size(), 2)
	var first := queue.front()
	assert_true(first.waiting())
	assert_almost_eq(first.at.z, TrafficCheckpoint.ZONE.y / 2 + QueueCar.STOP_BEFORE, 0.1)
	var second := queue.cars[1]
	assert_true(second.waiting())
	assert_almost_eq(second.at.z - first.at.z, QueueCar.LENGTH + QueueCar.GAP, 0.1)


func test_the_barrier_lets_the_first_car_through() -> void:
	_tick(12)
	var first := queue.front()
	watch_signals(queue)
	barrier.use(null)
	assert_eq(first.state, "going")
	assert_ne(queue.front(), first)
	assert_signal_emitted_with_parameters(queue, "passed", [first, false])
	_tick(2)
	assert_lt(first.at.z, 0.0)
	# The next one rolls up to the barrier.
	_tick(4)
	assert_almost_eq(queue.front().at.z, TrafficCheckpoint.ZONE.y / 2 + QueueCar.STOP_BEFORE, 0.1)


func test_waiting_cars_wear_the_patience_out_until_one_sneaks_by() -> void:
	watch_signals(queue)
	var sneaked := false
	for i in 120:
		_tick(1)
		if get_signal_parameters(queue, "passed") != null and get_signal_parameters(queue, "passed")[1]:
			sneaked = true
			break
	assert_true(sneaked)
	assert_almost_eq(queue.patience, TrafficQueue.AFTER_SNEAK, 2.0)
	var car: QueueCar = get_signal_parameters(queue, "passed")[0]
	assert_eq(car.state, "sneaking")
	_tick(2)
	assert_gt(car.at.x, 3.0, "moves over to the sidewalk")


func test_patience_calms_down_with_nobody_waiting() -> void:
	queue._set_patience(50)
	checkpoint.ready_now = true
	queue._until_spawn = 999
	_tick(5)
	assert_almost_eq(queue.patience, 50 - TrafficQueue.CALM_DOWN * 5, 0.5)


func test_without_the_barrier_cars_drive_through() -> void:
	barrier.global_position += Vector3(0, 0, 30)
	_tick(14)
	assert_eq(queue.cars.filter(func(car: QueueCar) -> bool: return car.waiting()).size(), 0)
	assert_gt(queue.spawned, 0)


func test_sneaking_car_knocks_cones_over() -> void:
	var cone := TrafficCone.new()
	add_child_autofree(cone)
	cone.global_position = checkpoint.global_transform * Vector3(QueueCar.SNEAK_SIDE, 0, 3)
	var car := queue.spawn()
	car.set_physics_process(false)
	car.at = Vector3(QueueCar.SNEAK_SIDE, 0, 3.5)
	car.sneak()
	car._physics_process(0.1)
	assert_gt(cone.linear_velocity.length(), 1.0)
