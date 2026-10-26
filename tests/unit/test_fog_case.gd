extends GutTest

## Fog check step 5 (control-neblina.md, "Cómo es" 5 to 8): cuffed, La Bruma's lighthouse lamp is on his trunk lid,
## +100 in the patrol car's trunk. If he gets past the checkpoint he runs off in the fog with his headlights on and
## honks at every corner he turns, his horn's bubble seen through the fog. Play draws the eight controls an eighth each.

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
	queue.variant = "fog"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, false, false, false, false, true)
	queue.plan = case.plan
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## La Bruma's car at the barrier, warned.
func _la_bruma() -> QueueCar:
	queue.spawned = case.plan.wanted_index
	var car := queue.spawn()
	car.set_physics_process(false)
	car.warned = true
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func test_cuffed_his_lamp_is_on_the_trunk_and_worth_100_in_the_patrol_car() -> void:
	var car := _la_bruma()
	assert_true(car.waiting())
	case.detain(car)
	assert_not_null(case.suspect)
	var lamp := level.get_node_or_null("LighthouseLamp") as LighthouseLamp
	assert_not_null(lamp)
	assert_lt(lamp.global_position.distance_to(car.global_position), 3.0, "on his car")
	assert_eq(case.lamp_bonus(), [])
	case.patrol_car.delivered.append(lamp)
	assert_eq(case.lamp_bonus(), [LighthouseLamp.VALUE])
	assert_has(case.extras(), LighthouseLamp.VALUE)


func test_past_the_checkpoint_he_runs_off_with_his_headlights_on() -> void:
	var car := _la_bruma()
	queue.cars.erase(car)
	case._on_passed(car, false)
	assert_not_null(case.chase)
	var truck := case.chase.truck
	assert_not_null(truck.get_node_or_null("Lamp"), "his headlights, on")
	assert_eq(case.chase.drops.fog_horn, car.fog.horn)
	assert_eq(case.snapshot().run_off[9], car.fog, "guests dress his car too")


func test_he_honks_at_every_corner_he_turns() -> void:
	var car := _la_bruma()
	queue.cars.erase(car)
	case._on_passed(car, false)
	var drops := case.chase.drops
	case.chase.chasing = true
	drops._on_corner(false)
	assert_null(drops.horn_bubble, "only where he turns")
	drops._on_corner(true)
	assert_not_null(drops.horn_bubble)
	assert_true(drops.horn_bubble.showing())
	assert_eq(drops.horn_bubble.text, tr(FogCar.horn_text(car.fog.horn)))
	assert_eq(drops.horn_bubble.get_parent(), case.chase.truck)


func test_play_draws_the_fog_too() -> void:
	assert_has(TrafficControlLevel.VARIANTS, "fog")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=fog"])), "fog")
	var count := {}
	for i in 800:
		var variant := TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)
		count[variant] = count.get(variant, 0) + 1
	assert_eq(count.size(), 8)
	assert_gt(count.fog, 60)


func test_texts_are_translated() -> void:
	for key in ["PROMPT_LIGHTHOUSE_LAMP", "HINT_FOG_LAMP"]:
		assert_ne(tr(key), key)
