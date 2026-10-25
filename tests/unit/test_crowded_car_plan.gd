extends GutTest

## Crowded car step 4 (control-auto-lleno.md): the plan sends 12 to 16 cars; the gang of 14 to 20 rides in the wanted
## one and its headcount is always the comisario's clue, then the radio's are about the car. A few packed cars carry
## one or two more or less, and only lookalikes ride exactly as many. The queue builds each car with its riders.


func test_fewer_cars_come_and_the_gang_comes_early() -> void:
	for case_seed in range(1, 30):
		var plan := WantedPlan.draw(case_seed, false, false, true)
		assert_true(plan.crowd)
		assert_between(plan.total, WantedPlan.CROWD_TOTAL.x, WantedPlan.CROWD_TOTAL.y)
		assert_between(plan.wanted_index, WantedPlan.CROWD_WANTED_AT.x, WantedPlan.CROWD_WANTED_AT.y)


func test_the_headcount_comes_first_then_the_car() -> void:
	for case_seed in range(1, 30):
		var plan := WantedPlan.draw(case_seed, false, false, true)
		assert_eq(plan.clues.size(), WantedPlan.CLUES)
		assert_eq(plan.clues[0].kind, "riders")
		var gang: int = plan.clues[0].value
		assert_between(gang, WantedPlan.GANG.x, WantedPlan.GANG.y)
		assert_eq(plan.cars[plan.wanted_index].crowd, gang)
		for clue in plan.clues.slice(1):
			assert_has(WantedPlan.CROWD_KINDS, clue.kind)
		assert_eq(plan.fits(plan.cars[plan.wanted_index]), WantedPlan.CLUES)
		for i in plan.total:
			if i != plan.wanted_index:
				assert_lt(plan.fits(plan.cars[i]), WantedPlan.CLUES, "only the gang's car fits all")


func test_some_packed_cars_carry_almost_as_many() -> void:
	for case_seed in range(1, 30):
		var plan := WantedPlan.draw(case_seed, false, false, true)
		var gang: int = plan.clues[0].value
		var near := 0
		for i in plan.total:
			if i == plan.wanted_index:
				continue
			var riders: int = plan.cars[i].crowd
			if absi(riders - gang) <= 2 and riders != gang:
				near += 1
			if riders == gang:
				assert_has(plan.lookalikes, i, "only a lookalike rides exactly as many")
		assert_gte(near, WantedPlan.NEAR.x)


func test_the_same_seed_draws_the_same_plan() -> void:
	var a := WantedPlan.draw(9, false, false, true)
	var b := WantedPlan.draw(9, false, false, true)
	assert_eq(a.cars, b.cars)
	assert_eq(a.clues, b.clues)


func test_the_headcount_clue_reads_well() -> void:
	var plan := WantedPlan.draw(3, false, false, true)
	plan.clues = [{"kind": "riders", "value": 17}]
	assert_eq(plan.clue_text(0), tr("CLUE_CROWD_RIDERS") % 17)
	assert_string_contains(plan.clue_text(0), "17")


func test_the_queue_builds_each_car_with_its_riders() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "crowded_car"
	queue.plan = WantedPlan.draw(5, false, false, true)
	queue.set_physics_process(false)
	add_child_autofree(queue)
	for i in queue.plan.total:
		var car := queue.spawn()
		car.set_physics_process(false)
		var data: Dictionary = queue.plan.cars[i]
		assert_eq(car.crowd, data.crowd)
		assert_eq(car.wanted, i == queue.plan.wanted_index)
		assert_eq(car.has_node("Faces"), CrowdedCar.packed(car.crowd))


func test_the_texts_are_translated() -> void:
	for key in ["CLUE_CROWD_RIDERS", "BRIEF_CROWD_A", "BRIEF_CROWD_C"]:
		assert_ne(tr(key), key)
