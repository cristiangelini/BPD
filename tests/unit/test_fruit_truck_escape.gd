extends GutTest

## Fruit truck step 5 (control-frutas.md, "Cómo es", steps 7 and 8): the wanted pickup getting past runs off in its own
## paint and drops watermelons rolling down the street at every corner it turns; splitting them is no complaint. Play
## draws the rush hour, the convoy and the fruit truck, a third each.

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
	queue.variant = "fruit_truck"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, true)
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


func test_the_wanted_pickup_runs_off_in_its_own_paint() -> void:
	_wanted_at_the_barrier()
	queue.release_front()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.FRUIT_TRUCK)
	assert_eq(case.chase.who, "driver")
	var tinted := 0
	for mesh in case.chase.truck.find_children("paint*", "MeshInstance3D", true, false):
		assert_eq(((mesh as MeshInstance3D).material_override as StandardMaterial3D).albedo_color,
			QueueCar.FRUIT_PAINTS[2])
		tinted += 1
	assert_gt(tinted, 0)
	var state := case.snapshot()
	assert_eq(state.run_off[1], 2, "guests paint it alike")
	assert_true(state.run_off[3], "guests know it's the fruit truck")


func test_it_drops_rolling_watermelons_at_the_corners() -> void:
	_wanted_at_the_barrier()
	queue.release_front()
	var drops := case.chase.drops
	case.chase.chasing = true
	drops._on_corner(false)
	assert_eq(drops.melons.size(), 0, "only where it turns")
	drops._on_corner(true)
	assert_eq(drops.melons.size(), ChaseDrops.MELONS_PER_CORNER)
	for melon in drops.melons:
		assert_true(melon.from_wanted)
		assert_false(melon.in_bed)
		assert_gt(melon.linear_velocity.length(), 1.0, "rolling")


func test_they_never_pile_up_past_the_limit() -> void:
	_wanted_at_the_barrier()
	queue.release_front()
	var drops := case.chase.drops
	for i in ChaseDrops.MAX_MELONS + 4:
		drops.drop_melon()
	await wait_physics_frames(1)
	assert_eq(drops.melons.filter(func(m: Watermelon) -> bool: return is_instance_valid(m)).size(),
		ChaseDrops.MAX_MELONS)


func test_splitting_a_dropped_one_is_no_complaint() -> void:
	_wanted_at_the_barrier()
	queue.release_front()
	var melon := case.chase.drops.drop_melon()
	melon.hit(INF)
	assert_eq(case.melon_complaints, 0)


func test_play_draws_the_three_a_third_each() -> void:
	var count := {}
	for i in 300:
		var variant := TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)
		count[variant] = count.get(variant, 0) + 1
	assert_eq(count.size(), 3)
	for variant in count:
		assert_between(count[variant], 70, 130, variant)
