extends GutTest

## Wedding breathalyzer check step 3 (control-boda.md, "Cómo es", step 3, answer 3): a driver who blew over the limit
## gives up the keys with E and a relative takes the wheel, +25 on a solved case's pay; a drunk let through at the
## wheel zigzags off knocking cones over, -25.

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
	queue.variant = "wedding"
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


## A car at the barrier whose driver blows `blows`.
func _car(blows: float) -> QueueCar:
	queue.plan = null
	var car := queue.spawn()
	car.set_physics_process(false)
	car.alcohol = blows
	car.wanted = false
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func test_over_the_limit_the_keys_come_out_and_a_relative_drives() -> void:
	var car := _car(1.2)
	assert_false(car.can_take_keys(), "not before blowing")
	car.blow(null)
	assert_true(car.can_take_keys())
	assert_eq(car.prompt_key(null), "PROMPT_TAKE_KEYS")
	var drunk := car.get_node("WindowDriver")
	car.use(null)
	assert_true(car.keys_taken)
	assert_false(car.drunk_at_wheel())
	assert_eq(case.drunk_keys, 1)
	assert_true(is_instance_valid(car.get_node_or_null("WindowDriver")), "someone at the window")
	assert_ne(car.get_node_or_null("WindowDriver"), drunk, "someone else")
	assert_eq(car.saying(), tr(WeddingCar.relative_line(car.plate)))
	assert_false(car.can_take_keys(), "once")


func test_under_the_limit_there_are_no_keys_to_take() -> void:
	var car := _car(0.4)
	car.blow(null)
	assert_false(car.can_take_keys())
	assert_eq(car.prompt_key(null), "PROMPT_PAPERS")
	car.use(null)
	assert_true(car.papers_checked)


func test_a_drunk_let_through_zigzags_and_costs_pay() -> void:
	var car := _car(1.5)
	queue.release_front()
	assert_eq(case.drunks_passed, 1)
	var xs := {}
	for i in 30:
		car._physics_process(0.1)
		xs[signf(car.at.x)] = true
	assert_true(xs.has(1.0) and xs.has(-1.0), "both ways across the lane")
	assert_eq(case.fines(), TrafficCase.DRUNK_KEYS)


func test_the_relative_drives_straight_and_costs_nothing() -> void:
	var car := _car(1.5)
	car.blow(null)
	car.take_keys()
	queue.release_front()
	assert_eq(case.drunks_passed, 0)
	for i in 30:
		car._physics_process(0.1)
		assert_eq(car.at.x, 0.0)


func test_keys_add_to_a_solved_case_s_pay() -> void:
	for i in 2:
		var car := _car(0.9)
		car.blow(null)
		car.take_keys()
		queue.pull_over(car)
	assert_eq(case.extras(), [TrafficCase.DRUNK_KEYS, TrafficCase.DRUNK_KEYS])
	var report := ShiftReport.pay(true, case.extras(), case.fines())
	assert_eq(report.total, ShiftReport.SALARY + 2 * TrafficCase.DRUNK_KEYS)
	assert_eq(case.snapshot().drunk_keys, 2)
