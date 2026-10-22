extends GutTest

## Traffic control step 5b (control-transito.md, decision 96): the wanted car getting past the checkpoint runs off in
## its own paint and the chase starts; caught it's solved, got away it's lost. Play draws the traffic control too.

var level: Node3D
var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var case: TrafficCase


func before_each() -> void:
	level = Node3D.new()
	add_child_autofree(level)
	var city := Node3D.new()
	city.name = "City"
	level.add_child(city)
	checkpoint = TrafficCheckpoint.new()
	level.add_child(checkpoint)
	checkpoint.global_transform = TrafficControlLevel.checkpoint_at()
	var barrier := RoadBarrier.new()
	barrier.freeze = true
	level.add_child(barrier)
	barrier.global_transform = checkpoint.global_transform
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


func _wanted_at_the_barrier() -> QueueCar:
	var car := queue.spawn()
	car.wanted = true
	car.look = 2
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func test_let_through_it_runs_off_and_the_chase_starts() -> void:
	var car := _wanted_at_the_barrier()
	var at := car.global_position
	queue.release_front()
	assert_false(case.lost)
	assert_not_null(case.chase)
	assert_eq(case.chase.who, "driver")
	assert_eq(case.chase.truck.kind, "traffic_2")
	assert_almost_eq(case.chase.truck.global_position.distance_to(at), 0.0, 0.5)
	await wait_physics_frames(1)
	assert_false(is_instance_valid(car))


func test_caught_its_solved_and_gone_its_lost() -> void:
	_wanted_at_the_barrier()
	queue.release_front()
	case.chase.ended.emit(true)
	assert_true(case.solved())
	var other := TrafficCase.new()
	add_child_autofree(other)
	other._on_chase_ended(false)
	assert_true(other.lost)
	assert_false(other.solved())


func test_sneaking_by_runs_off_too() -> void:
	_wanted_at_the_barrier()
	queue._set_patience(TrafficQueue.FULL)
	queue.set_physics_process(true)
	await wait_physics_frames(2)
	assert_not_null(case.chase)


func test_play_can_draw_the_traffic_control() -> void:
	var found := false
	for i in 200:
		if PlaceDraw.pick(i + 1, [], 1) == "traffic":
			found = true
			break
	assert_true(found)
	for i in 200:
		assert_ne(PlaceDraw.pick(i + 1, [], 1, false), "traffic", "not online until it's synced")
