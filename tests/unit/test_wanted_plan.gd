extends GutTest

## Traffic control step 4 (control-transito.md, "Cómo se reconoce al buscado"): the seed picks the wanted car and its
## 3 clues; only it fits all 3, and 2 or 3 lookalikes fit 2. The radio gives one more clue every minute.


func test_same_seed_same_plan() -> void:
	var a := WantedPlan.draw(31)
	var b := WantedPlan.draw(31)
	assert_eq(a.cars, b.cars)
	assert_eq(a.clues, b.clues)
	assert_eq(a.wanted_index, b.wanted_index)


func test_only_the_wanted_car_fits_every_clue() -> void:
	for case_seed in range(1, 60):
		var plan := WantedPlan.draw(case_seed)
		assert_between(plan.total, WantedPlan.TOTAL.x, WantedPlan.TOTAL.y)
		assert_between(plan.lookalikes.size(), WantedPlan.LOOKALIKES.x, WantedPlan.LOOKALIKES.y)
		assert_eq(plan.clues.size(), WantedPlan.CLUES)
		for i in plan.total:
			var fit := plan.fits(plan.cars[i])
			if i == plan.wanted_index:
				assert_eq(fit, WantedPlan.CLUES, "seed %d: the wanted car fits all" % case_seed)
			elif i in plan.lookalikes:
				assert_eq(fit, WantedPlan.CLUES - 1, "seed %d: a lookalike fits all but one" % case_seed)
			else:
				assert_lte(fit, 1, "seed %d: car %d fits at most one" % [case_seed, i])


func test_clue_kinds_vary_and_read_as_text() -> void:
	var kinds := {}
	for case_seed in range(1, 40):
		var plan := WantedPlan.draw(case_seed)
		for i in plan.clues.size():
			kinds[plan.clues[i].kind] = true
			var text := plan.clue_text(i)
			assert_false(text.is_empty())
			assert_false(text.contains("CLUE_"), text)
	assert_eq(kinds.size(), WantedPlan.KINDS.size())


func test_radio_adds_a_clue_every_minute_up_to_three() -> void:
	assert_eq(WantedPlan.known_at(0), 1)
	assert_eq(WantedPlan.known_at(59), 1)
	assert_eq(WantedPlan.known_at(60), 2)
	assert_eq(WantedPlan.known_at(130), 3)
	assert_eq(WantedPlan.known_at(999), 3)
	var clues := TrafficClues.new()
	clues.plan = WantedPlan.draw(3)
	watch_signals(clues)
	add_child_autofree(clues)
	clues.set_physics_process(false)
	assert_eq(clues.known, 1)
	clues._physics_process(61)
	assert_eq(clues.known, 2)
	assert_signal_emit_count(clues, "clue_given", 2)
	assert_eq(clues.known_text().split("\n").size(), 2)


func test_the_queue_sends_the_plan_cars_and_then_stops() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.plan = WantedPlan.draw(8)
	add_child_autofree(queue)
	queue.set_physics_process(false)
	var wanted: QueueCar
	for i in queue.plan.total:
		var car := queue.spawn()
		car.set_physics_process(false)
		assert_eq(car.plate, queue.plan.cars[i].plate)
		if car.wanted:
			wanted = car
	assert_not_null(wanted)
	assert_eq(queue.plan.fits({"look": wanted.look, "plate": wanted.plate, "driver": wanted.driver}), WantedPlan.CLUES)
	queue.cars.clear()
	assert_false(queue._room_to_spawn())
	assert_eq((wanted.get_node("Plate") as Label3D).text, wanted.plate)
