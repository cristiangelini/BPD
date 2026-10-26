extends GutTest

## Street race check step 4 (control-carrera.md, "Cómo es", steps 5 to 7): the plan seats El Turbo in one of the
## middle heats, with 3 clues about his racer (paint, number, neon, spoiler) and a few lookalikes. Each racer stopped
## with the spike strips adds 25 to a solved case's pay; each city car punctured is a complaint and the second loses
## the case (answer 2). El Turbo, stopped on his rims, is cuffed out of his racer; cuffing another racer is a complaint.

var level: Node3D
var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var case: TrafficCase


func before_each() -> void:
	level = Node3D.new()
	add_child_autofree(level)
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
	level.add_child(case)
	case.start()


## The `heat`th heat, stopped on its rims.
func _stopped_heat(heat: int) -> Array[QueueCar]:
	queue.heats = heat
	var racers := queue.spawn_heat()
	for car in racers:
		car.set_physics_process(false)
		car.state = "racing"
		car.speed = RaceCar.SPEED
		car.puncture()
		for i in 60:
			car._physics_process(0.1)
	return racers


func test_el_turbo_races_in_a_middle_heat() -> void:
	for case_seed in 30:
		var plan := WantedPlan.draw(case_seed, false, false, false, false, false, true)
		assert_true(plan.race)
		assert_eq(plan.wanted_index, -1, "no city car is wanted")
		assert_between(plan.heats.size(), RaceCar.HEATS.x, RaceCar.HEATS.y)
		assert_between(plan.turbo_heat, WantedPlan.TURBO_HEAT.x, plan.heats.size() - 1)
		var wanted := 0
		for heat in plan.heats:
			assert_between(heat.size(), RaceCar.HEAT_SIZE.x, RaceCar.HEAT_SIZE.y)
			for racer: Dictionary in heat:
				assert_true(racer.racer)
				if racer.get("wanted", false):
					wanted += 1
		assert_eq(wanted, 1)
		assert_eq(plan.turbo().driver.trunk, "trophy")
		for car in plan.cars:
			assert_false(car.get("racer", false))


func test_only_el_turbo_fits_every_clue_and_a_few_racers_fit_two() -> void:
	for case_seed in 30:
		var plan := WantedPlan.draw(case_seed, false, false, false, false, false, true)
		assert_eq(plan.fits(plan.turbo()), WantedPlan.CLUES)
		var twos := 0
		for heat in plan.heats:
			for racer: Dictionary in heat:
				if racer.get("wanted", false):
					continue
				var fit := plan.fits(racer)
				assert_lt(fit, WantedPlan.CLUES)
				if fit == WantedPlan.CLUES - 1:
					twos += 1
		assert_between(twos, WantedPlan.LOOKALIKES.x, WantedPlan.LOOKALIKES.y)


func test_the_clues_read_about_his_racer() -> void:
	var plan := WantedPlan.new()
	plan.clues.assign([{"kind": "number", "value": 27}, {"kind": "neon", "value": 0}, {"kind": "spoiler", "value": 2}])
	assert_string_contains(plan.clue_text(0), "27")
	assert_string_contains(plan.clue_text(1), tr(RaceCar.NEON_NAMES[0]))
	assert_string_contains(plan.clue_text(2), tr("SPOILER_BIG"))


func test_the_queue_brings_the_plan_s_heats_and_el_turbo() -> void:
	queue.heats = case.plan.turbo_heat
	var heat := queue.spawn_heat()
	assert_eq(heat.size(), case.plan.heats[case.plan.turbo_heat].size())
	for slot in heat.size():
		assert_eq(heat[slot].race, case.plan.heats[case.plan.turbo_heat][slot].race)
		assert_eq(heat[slot].wanted, slot == case.plan.turbo_slot)
	assert_eq(queue.heats_total(), case.plan.heats.size())


func test_each_racer_punctured_adds_to_the_pay() -> void:
	var racers := _stopped_heat(0)
	assert_eq(case.racer_fines, racers.size())
	assert_eq(case.extras().size(), racers.size())
	assert_eq(case.extras()[0], TrafficCase.RACER_FINE)
	assert_eq(case.innocents, 0)


func test_two_city_cars_punctured_lose_the_case() -> void:
	for i in 2:
		var car := queue.spawn()
		car.set_physics_process(false)
		car.puncture()
	assert_eq(case.innocents, 2)
	assert_true(case.lost)


func test_el_turbo_stopped_on_his_rims_is_cuffed_out_of_his_racer() -> void:
	var racers := _stopped_heat(case.plan.turbo_heat)
	var turbo := racers[case.plan.turbo_slot]
	assert_true(turbo.stopped_racer())
	var other := racers[(case.plan.turbo_slot + 1) % racers.size()]
	other.cuffed(1.0)
	assert_eq(case.innocents, 1, "another racer isn't El Turbo: a complaint")
	assert_eq(other.saying(), tr("RACE_NOT_TURBO_LINE"))
	turbo.cuffed(1.0)
	assert_not_null(case.suspect)
	assert_eq(case.campaign_key(), "traffic_race")


func test_texts_are_translated() -> void:
	for key in ["CLUE_RACE_NUMBER", "CLUE_RACE_NEON", "CLUE_RACE_SPOILER", "BRIEF_RACE_A", "BRIEF_RACE_C",
			"HINT_RACE_FINED", "RACE_NOT_TURBO_LINE"]:
		assert_ne(tr(key), key)
