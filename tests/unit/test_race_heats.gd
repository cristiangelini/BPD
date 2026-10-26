extends GutTest

## Street race check step 2 (control-carrera.md): the racers come in heats, out of the queue. A heat gathers at the
## back corner, revs 3 s shaking (the warning, answer 3), then races down the other lane at three times a city car's
## speed, swerves past the queue to clip the barrier's end (it flies and is back up 5 s later) and never stops. Time is
## stepped by hand, 0.1 s at a time, like test_race_cars.gd.

var checkpoint: TrafficCheckpoint
var barrier: RoadBarrier
var queue: TrafficQueue
var passed: Array[QueueCar] = []


func before_each() -> void:
	passed.clear()
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	barrier = RoadBarrier.new()
	barrier.freeze = true
	add_child_autofree(barrier)
	barrier.global_transform = checkpoint.global_transform
	barrier.set_physics_process(false)
	for z in [4.0, 7.0]:
		var cone := TrafficCone.new()
		cone.freeze = true
		add_child_autofree(cone)
		cone.global_position = checkpoint.global_transform * Vector3(-1, 0, z)
	checkpoint.ready_now = checkpoint.is_set_up()
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "race"
	queue.case_seed = 9
	add_child_autofree(queue)
	queue.set_physics_process(false)
	queue.passed.connect(func(car: QueueCar, _sneaked: bool) -> void: passed.append(car))


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		barrier._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func _heat() -> Array[QueueCar]:
	var heat := queue.spawn_heat()
	for car in heat:
		car.set_physics_process(false)
	return heat


func test_the_first_heat_comes_a_while_after_the_checkpoint_is_set_up() -> void:
	_tick(RaceCar.FIRST_HEAT - 1.0)
	assert_eq(queue.heats, 0)
	_tick(1.5)
	assert_eq(queue.heats, 1)
	assert_between(queue.racers.size(), RaceCar.HEAT_SIZE.x, RaceCar.HEAT_SIZE.y)
	for car in queue.racers:
		assert_eq(car.state, "gathering")
		assert_eq(car.at.x, RaceCar.LANE)


func test_a_heat_revs_shaking_before_it_launches() -> void:
	var heat := _heat()
	var leader := heat[0]
	var z := leader.at.z
	_tick(RaceCar.GATHER + 0.1)
	assert_eq(leader.state, "revving")
	assert_eq(leader.saying(), tr(RaceCar.rev_line(leader.plate)))
	assert_eq(leader.at.z, z, "it doesn't move while it revs")
	var shakes := {}
	for i in 10:
		_tick(0.1)
		shakes[snappedf(leader.lurch, 0.001)] = true
	assert_gt(shakes.size(), 3)
	assert_true((leader.get_node("Exhaust/Sparks") as CPUParticles3D).emitting)
	_tick(RaceCar.REV_SECONDS)
	assert_eq(leader.state, "racing")


func test_racers_race_three_times_faster_and_never_stop_at_the_barrier() -> void:
	var heat := _heat()
	_tick(RaceCar.GATHER + RaceCar.REV_SECONDS + 3.0)
	assert_almost_eq(heat[0].speed, RaceCar.SPEED, 0.01)
	assert_gt(RaceCar.SPEED, QueueCar.SPEED * 2.5)
	_tick(4.0)
	for car in heat:
		assert_true(passed.has(car), "past the checkpoint")
	assert_true(queue.racers.is_empty())


func test_they_swerve_past_the_queue_and_send_the_barrier_flying() -> void:
	assert_eq(RaceCar.lane_x(40.0), RaceCar.LANE)
	assert_eq(RaceCar.lane_x(0.0), RaceCar.CLIP_X)
	assert_eq(RaceCar.lane_x(-40.0), RaceCar.LANE)
	assert_lt(RaceCar.CLIP_X + 1.05, -QueueCar.LENGTH / 4, "they pass the queue's cars close, without hitting them")
	var home := barrier.global_transform
	var heat := _heat()
	var closest := RaceCar.LANE
	for i in 120:
		_tick(0.1)
		if heat[0].state == "racing":
			closest = maxf(closest, heat[0].at.x)
		if barrier.knocked():
			break
	assert_true(barrier.knocked())
	assert_almost_eq(closest, RaceCar.CLIP_X, 0.01)
	barrier.global_position += Vector3(3, 0, 2)
	_tick(RoadBarrier.BACK_SECONDS + 0.2)
	assert_false(barrier.knocked())
	assert_eq(barrier.global_transform, home, "back up where it stood")


func test_the_city_cars_still_queue_at_the_barrier() -> void:
	_tick(40)
	assert_gt(queue.cars.size(), 1)
	assert_eq(queue.front().state, "waiting")
	assert_almost_eq(queue.front().at.x, 0.0, 0.01)
