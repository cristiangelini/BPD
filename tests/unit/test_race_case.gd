extends GutTest

## Street race check step 5 (control-carrera.md, "Cómo es", steps 7 to 9): El Turbo's trophy is in his racer's trunk;
## cuffed, it's on its lid, +100 in the patrol car's trunk. If he gets past the checkpoint he runs off in his racer,
## faster than anyone, and spins round at every corner he turns. Play draws the seven controls a seventh each.

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
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "race"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, false, false, false, true)
	queue.plan = case.plan
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## El Turbo's heat out of the queue; El Turbo.
func _el_turbo() -> QueueCar:
	queue.heats = case.plan.turbo_heat
	var racers := queue.spawn_heat()
	for car in racers:
		car.set_physics_process(false)
	return racers[case.plan.turbo_slot]


func test_cuffed_his_trophy_is_on_the_trunk_and_worth_100_in_the_patrol_car() -> void:
	var turbo := _el_turbo()
	turbo.state = "racing"
	turbo.speed = RaceCar.SPEED
	turbo.puncture()
	for i in 60:
		turbo._physics_process(0.1)
	case.detain(turbo)
	assert_not_null(case.suspect)
	var trophy := level.get_node_or_null("RaceTrophy") as RaceTrophy
	assert_not_null(trophy)
	assert_lt(trophy.global_position.distance_to(turbo.global_position), 3.0, "on his racer")
	assert_eq(case.trophy_bonus(), [])
	case.patrol_car.delivered.append(trophy)
	assert_eq(case.trophy_bonus(), [RaceTrophy.VALUE])
	assert_has(case.extras(), RaceTrophy.VALUE)


func test_past_the_checkpoint_he_runs_off_in_his_racer_faster() -> void:
	var turbo := _el_turbo()
	case._on_passed(turbo, false)
	assert_not_null(case.chase)
	var truck := case.chase.truck
	assert_true(truck.racer)
	assert_true(case.chase.drops.race)
	assert_not_null(truck.get_node_or_null("Exhaust"), "his racer, pipes and all")
	assert_eq(truck.get_node("Roundel/Number").text, str(turbo.race.number))
	var city_car := SuspectCar.new()
	city_car.kind = truck.kind
	assert_almost_eq(truck.top_speed(), city_car.top_speed() * SuspectCar.RACER_SPEED, 0.01)
	city_car.free()
	assert_eq(case.snapshot().run_off[8], turbo.race, "guests dress his racer too")


func test_he_spins_round_at_every_corner_he_turns() -> void:
	case._on_passed(_el_turbo(), false)
	var truck := case.chase.truck
	var drops := case.chase.drops
	case.chase.chasing = true
	drops._on_corner(false)
	assert_eq(truck.spin_left, 0.0, "only where he turns")
	var heading := truck.rotation.y
	var at := truck.global_position
	drops._on_corner(true)
	assert_eq(truck.spin_left, SuspectCar.SPIN_SECONDS)
	truck.set_physics_process(false)
	truck._physics_process(SuspectCar.SPIN_SECONDS / 4)
	assert_ne(truck.rotation.y, heading, "spinning")
	for i in 3:
		truck._physics_process(SuspectCar.SPIN_SECONDS / 4)
	assert_lte(truck.spin_left, 0.0)
	assert_almost_eq(truck.rotation.y, heading, 0.001, "pointing where he did")
	var moved := Vector2(truck.global_position.x - at.x, truck.global_position.z - at.z).length()
	assert_lt(moved, 0.5, "going nowhere while he spins")
	truck._physics_process(0.5)
	assert_gt(Vector2(truck.velocity.x, truck.velocity.z).length(), 0.0, "and then he's off again")


func test_play_draws_the_street_race_too() -> void:
	assert_has(TrafficControlLevel.VARIANTS, "race")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=race"])), "race")
	var count := {}
	for i in 700:
		var variant := TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)
		count[variant] = count.get(variant, 0) + 1
	assert_eq(count.size(), 7)
	assert_gt(count.race, 50)


func test_texts_are_translated() -> void:
	for key in ["PROMPT_RACE_TROPHY", "HINT_RACE_TROPHY"]:
		assert_ne(tr(key), key)
