extends GutTest

## Ghost car step 5 (control-auto-fantasma.md, "Cómo es", steps 8 and 9): when the pilot's car goes by the checkpoint it
## runs off as usual, and his ghost car leaves the queue to follow him: at every corner he turns it cuts in across the
## street behind him, in the patrol car's way, unless the patrol car is right there. Play draws the five controls a
## fifth each.

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
	queue.variant = "ghost_car"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, false, true)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## The ghost car, then the pilot's car right behind it at the barrier (or a plain wanted car, `pilot` false).
func _pilot_at_the_barrier(pilot := true) -> QueueCar:
	queue.plan = null
	var ghost := queue.spawn()
	ghost.ghost = true
	ghost.set_physics_process(false)
	var car := queue.spawn()
	car.ghost = false
	car.wanted = true
	car.puppeteer = pilot
	car.set_physics_process(false)
	for i in 200:
		ghost._physics_process(0.1)
		car._physics_process(0.1)
	# The ghost car went ahead; the pilot's is the first now.
	queue.cars.erase(ghost)
	car.ahead = null
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	queue.cars.push_back(ghost)
	return car


func test_the_pilot_runs_off_and_his_ghost_car_follows() -> void:
	_pilot_at_the_barrier()
	queue.release_front()
	assert_not_null(case.chase)
	var look: int = case.plan.cars[case.plan.ghost_index].look
	assert_eq(case.chase.drops.ghost_look, look)
	assert_false(queue.cars.any(func(car: QueueCar) -> bool: return car.ghost), "it left the queue")
	assert_eq(case.snapshot().run_off[6], look, "guests know it follows")


func test_it_cuts_in_behind_him_at_every_corner_he_turns() -> void:
	_pilot_at_the_barrier()
	queue.release_front()
	var drops := case.chase.drops
	case.chase.chasing = true
	case.patrol_car.global_position += Vector3(0, 0, 500)
	drops._on_corner(false)
	assert_null(drops.ghost, "only where he turns")
	drops._on_corner(true)
	var ghost := drops.ghost
	assert_not_null(ghost)
	assert_true(ghost.crossing())
	assert_ne(ghost.get_node("Bubble").text, "")
	var truck := case.chase.truck
	var off := ghost.global_position - truck.global_position
	assert_almost_eq(off.dot(-truck.global_basis.z), ChaseDrops.GHOST_BEHIND, 0.01, "behind him")
	assert_almost_eq(absf(off.dot(truck.global_basis.x)), ChaseDrops.GHOST_SIDE, 0.01, "from one side")
	assert_lt(ghost.global_basis.z.dot(off.normalized()), 0.0, "heading across, toward the middle")
	ghost.set_physics_process(false)
	var start := ghost.global_position
	for i in 20:
		ghost._physics_process(0.1)
	assert_almost_eq(ghost.global_position.distance_to(start), ChaseGhost.CROSS, 0.01)
	assert_false(ghost.crossing(), "stopped in the way")
	assert_not_null(ghost.get_node_or_null("Antenna"))
	drops._on_corner(true)
	assert_eq(get_tree().get_nodes_in_group("chase_ghosts").size(), 1, "the same ghost car each time")
	assert_true(ghost.crossing())


func test_it_never_lands_on_the_patrol_car() -> void:
	_pilot_at_the_barrier()
	queue.release_front()
	var drops := case.chase.drops
	case.chase.chasing = true
	var truck := case.chase.truck
	case.patrol_car.global_position = truck.global_position - truck.global_basis.z * ChaseDrops.GHOST_BEHIND
	for i in 6:
		assert_null(drops.cut_in())


func test_a_plain_wanted_car_has_no_ghost() -> void:
	_pilot_at_the_barrier(false)
	queue.release_front()
	var drops := case.chase.drops
	case.chase.chasing = true
	assert_eq(drops.ghost_look, -1)
	drops._on_corner(true)
	assert_null(drops.ghost)


func test_play_draws_the_ghost_car_too() -> void:
	assert_has(TrafficControlLevel.VARIANTS, "ghost_car")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=ghost_car"])), "ghost_car")
	var count := {}
	for i in 500:
		var variant := TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)
		count[variant] = count.get(variant, 0) + 1
	assert_eq(count.size(), TrafficControlLevel.VARIANTS.size())
	for variant in count:
		assert_between(count[variant], 60, 140, variant)
