extends GutTest

## Circus move step 5 (control-circo.md, "Cómo es" 6 to 8): the cuffs go on whoever's in an open cage: El Peludo comes
## out cuffed and leaves the jewels in the straw (+100 in the patrol car's trunk); a real animal won't be cuffed. If he
## gets past the checkpoint he runs off in his circus truck, dropping banana peels at every corner, and the patrol car
## skids on them. Play draws the nine controls a ninth each.

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
	queue.variant = "circus_move"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, false, false, false, false, false, true)
	queue.plan = case.plan
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## The `index`th car of the plan at the barrier.
func _at_barrier(index: int) -> QueueCar:
	queue.spawned = index
	var car := queue.spawn()
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func _real_truck() -> int:
	for i in case.plan.total:
		if i != case.plan.wanted_index and not case.plan.cars[i].circus.is_empty():
			return i
	return -1


func test_his_cage_shut_the_cuffs_wait() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	assert_true(car.waiting())
	case.detain(car)
	assert_null(case.suspect)
	assert_eq(car.saying(), tr("CIRCUS_OPEN_CAGE_FIRST"))
	assert_eq(case.innocents, 0)


func test_a_real_animal_won_t_be_cuffed() -> void:
	var car := _at_barrier(_real_truck())
	car.open_cage()
	case.detain(car)
	assert_null(case.suspect)
	assert_eq(case.innocents, 0, "no complaint: opening its cage cost enough")
	assert_string_contains(car.saying(), tr(CircusTruck.animal_name(car.circus.animal)))


func test_cuffed_el_peludo_leaves_the_jewels_worth_100_in_the_patrol_car() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	car.open_cage()
	case.detain(car)
	assert_not_null(case.suspect)
	assert_false(CircusTruck.animal_of(car).visible, "out of his cage")
	var jewels := level.get_node_or_null("CircusJewels") as CircusJewels
	assert_not_null(jewels)
	assert_lt(jewels.global_position.distance_to(car.global_transform * CircusTruck.JEWELS_AT), 0.1, "in the straw")
	assert_eq(case.jewels_bonus(), [])
	case.patrol_car.delivered.append(jewels)
	assert_eq(case.jewels_bonus(), [CircusJewels.VALUE])
	assert_has(case.extras(), CircusJewels.VALUE)


func test_past_the_checkpoint_he_runs_off_in_his_circus_truck() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	queue.cars.erase(car)
	var traits := car.circus.duplicate()
	case._on_passed(car, false)
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.CIRCUS_TRUCK)
	assert_not_null(case.chase.truck.get_node_or_null("Cage/Animal/Sneaker"), "in his cage, sneakers and all")
	assert_true(case.chase.drops.bananas)
	assert_eq(case.snapshot().run_off[10], traits, "guests dress his truck too")


func test_he_drops_banana_peels_and_the_patrol_car_skids() -> void:
	var car := _at_barrier(case.plan.wanted_index)
	queue.cars.erase(car)
	case._on_passed(car, false)
	var drops := case.chase.drops
	case.chase.chasing = true
	drops._on_corner(false)
	assert_eq(drops.peels.size(), 0, "only where he turns")
	drops._on_corner(true)
	assert_eq(drops.peels.size(), ChaseDrops.PEELS_PER_CORNER)
	var peel: Node3D = drops.peels[0][0]
	case.patrol_car.global_position = peel.global_position + Vector3.UP * 0.3
	drops._physics_process(0.016)
	assert_almost_eq(case.patrol_car.grip, drops.weather_grip * ChaseDrops.PEEL_GRIP, 0.001)
	case.patrol_car.global_position = peel.global_position + Vector3(30, 0.3, 30)
	drops._physics_process(0.016)
	assert_almost_eq(case.patrol_car.grip, drops.weather_grip, 0.001, "off it, it grips again")
	drops._physics_process(ChaseDrops.PEEL_SECONDS)
	assert_eq(drops.peels.size(), 0, "swept away")


func test_play_draws_the_circus_too() -> void:
	assert_has(TrafficControlLevel.VARIANTS, "circus_move")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=circus_move"])), "circus_move")
	var count := {}
	for i in 900:
		var variant := TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)
		count[variant] = count.get(variant, 0) + 1
	assert_eq(count.size(), 9)
	assert_gt(count.circus_move, 60)


func test_texts_are_translated() -> void:
	for key in ["PROMPT_CIRCUS_JEWELS", "HINT_CIRCUS_JEWELS", "CIRCUS_OPEN_CAGE_FIRST", "CIRCUS_NO_CUFFS_FOR_ANIMALS"]:
		assert_ne(tr(key), key)
