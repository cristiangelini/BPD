extends GutTest

## Crowded car step 6 (control-auto-lleno.md, "Cómo es", steps 8 and 9, answer 3): the gang's packed car getting past
## runs off slower, its faces on the windows, and one of the gang jumps out at every corner it turns and runs off down
## the street, one face less each time; the driver stays at the wheel. Play draws the four controls a quarter each.

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
	queue.variant = "crowded_car"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, true)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


func _gang_at_the_barrier(riders := 16) -> QueueCar:
	queue.plan = null
	var car := queue.spawn()
	car.wanted = true
	car.crowd = riders
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func test_the_gang_runs_off_slower_with_its_faces() -> void:
	var car := _gang_at_the_barrier()
	var look := car.look
	queue.release_front()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, "traffic_%d" % (look % TrafficCar.MODELS.size()))
	var truck := case.chase.truck
	assert_true(truck.heavy)
	assert_almost_eq(truck.top_speed(), SuspectCar.SPEED * SuspectCar.HEAVY_SPEED, 0.01)
	assert_eq(truck.get_node("Faces").get_child_count(), mini(16, CrowdedCar.SLOTS.size()))
	assert_eq(case.chase.drops.riders_left, 15, "all but the driver can jump")
	var state := case.snapshot()
	assert_eq(state.run_off[4], 16, "guests know how many ride")
	assert_eq(state.run_off[5], car.plate)


func test_one_jumps_out_at_each_corner_it_turns() -> void:
	_gang_at_the_barrier()
	queue.release_front()
	var drops := case.chase.drops
	case.chase.chasing = true
	drops._on_corner(false)
	assert_eq(drops.jumpers.size(), 0, "only where it turns")
	drops._on_corner(true)
	assert_eq(drops.jumpers.size(), 1)
	assert_eq(drops.riders_left, 14)
	var jumper := drops.jumpers[0]
	assert_false(jumper.is_driver)
	assert_ne(jumper.runaway, Vector3.ZERO)
	assert_eq(jumper.saying(), tr("CROWD_JUMP_LINE_1"))
	var shown := case.chase.truck.get_node("Faces").get_children().filter(func(f: Node3D) -> bool: return f.visible)
	assert_eq(shown.size(), mini(15, CrowdedCar.SLOTS.size()))


func test_a_jumper_runs_off_once_landed() -> void:
	_gang_at_the_barrier()
	queue.release_front()
	var jumper := case.chase.drops.drop_jumper()
	jumper.out_for = CrowdRider.FLY
	jumper._physics_process(0.1)
	var flat := Vector3(jumper.linear_velocity.x, 0, jumper.linear_velocity.z)
	assert_almost_eq(flat.length(), CrowdRider.RUN_SPEED, 0.01)
	assert_gt(flat.normalized().dot(jumper.runaway), 0.99)


func test_no_more_jump_than_rode() -> void:
	_gang_at_the_barrier(15)
	queue.release_front()
	var drops := case.chase.drops
	case.chase.chasing = true
	for i in 20:
		drops._on_corner(true)
	assert_eq(drops.jumpers.size(), 14)
	assert_eq(drops.riders_left, 0)


func test_a_plain_car_runs_off_as_before() -> void:
	var car := _gang_at_the_barrier(2)
	queue.release_front()
	assert_false(case.chase.truck.heavy)
	assert_null(case.chase.truck.get_node_or_null("Faces"))
	assert_eq(case.chase.drops.riders_left, 0)
	assert_eq(car.crowd, 2)


func test_play_draws_the_crowded_car_too() -> void:
	assert_has(TrafficControlLevel.VARIANTS, "crowded_car")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=crowded_car"])), "crowded_car")


func test_texts_are_translated() -> void:
	for i in CrowdRider.JUMP_LINES:
		assert_ne(tr("CROWD_JUMP_LINE_%d" % i), "CROWD_JUMP_LINE_%d" % i)
