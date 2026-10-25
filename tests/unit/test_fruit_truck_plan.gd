extends GutTest

## Fruit truck step 3 (control-frutas.md): the plan sends 10 to 14 pickups; the clues are the color, the sign's name,
## the crate and the hat; only the wanted pickup's watermelons are hollow (2 or 3); some innocent ones carry one
## overripe watermelon; the queue builds each pickup as the plan says, and the comisario tells the fruit fair's story.


func test_fewer_pickups_come_and_the_wanted_one_comes_early() -> void:
	for case_seed in range(1, 30):
		var plan := WantedPlan.draw(case_seed, false, true)
		assert_between(plan.total, WantedPlan.FRUIT_TOTAL.x, WantedPlan.FRUIT_TOTAL.y)
		assert_between(plan.wanted_index, WantedPlan.FRUIT_WANTED_AT.x, WantedPlan.FRUIT_WANTED_AT.y)


func test_the_clues_are_about_the_pickup_and_its_seller() -> void:
	for case_seed in range(1, 30):
		var plan := WantedPlan.draw(case_seed, false, true)
		for clue in plan.clues:
			assert_has(WantedPlan.FRUIT_KINDS, clue.kind)
		var wanted: Dictionary = plan.cars[plan.wanted_index]
		assert_eq(plan.fits(wanted), WantedPlan.CLUES)
		for i in plan.total:
			if i != plan.wanted_index:
				assert_lt(plan.fits(plan.cars[i]), WantedPlan.CLUES, "only the wanted one fits all")


func test_only_the_wanted_pickup_has_hollow_watermelons() -> void:
	var overripe := 0
	for case_seed in range(1, 30):
		var plan := WantedPlan.draw(case_seed, false, true)
		for i in plan.total:
			var car: Dictionary = plan.cars[i]
			var kinds: Array = car.fruit.melons
			assert_eq(kinds.size(), QueueCar.melon_count(car.plate))
			var hollow := kinds.count("hollow")
			if i == plan.wanted_index:
				assert_between(hollow, FruitTraits.HOLLOW.x, FruitTraits.HOLLOW.y)
				assert_eq(kinds.count("overripe"), 0)
			else:
				assert_eq(hollow, 0)
				assert_lte(kinds.count("overripe"), 1)
				overripe += kinds.count("overripe")
	assert_gt(overripe, 0, "some innocent pickups sound odd too")


func test_the_same_seed_draws_the_same_plan() -> void:
	var a := WantedPlan.draw(7, false, true)
	var b := WantedPlan.draw(7, false, true)
	assert_eq(a.cars, b.cars)
	assert_eq(a.clues, b.clues)


func test_clue_texts_read_well() -> void:
	var plan := WantedPlan.draw(3, false, true)
	plan.clues = [{"kind": "sign", "value": "Dalia"}, {"kind": "crate", "value": "oranges"},
		{"kind": "hat", "value": "straw"}]
	assert_eq(plan.clue_text(0), tr("CLUE_FRUIT_SIGN") % (tr("FRUIT_SIGN") % "Dalia"))
	assert_string_contains(plan.clue_text(1), tr("FRUIT_CRATE_ORANGES"))
	assert_string_contains(plan.clue_text(2), tr("FRUIT_HAT_STRAW"))
	plan.clues = [{"kind": "color", "value": 1}]
	assert_eq(plan.clue_text(0), tr("CLUE_FRUIT_COLOR") % tr("COLOR_YELLOW"))


func test_the_queue_builds_each_pickup_as_planned() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "fruit_truck"
	queue.plan = WantedPlan.draw(5, false, true)
	queue.set_physics_process(false)
	add_child_autofree(queue)
	for i in queue.plan.total:
		var car := queue.spawn()
		car.set_physics_process(false)
		var data: Dictionary = queue.plan.cars[i]
		assert_eq(car.crate, data.fruit.crate)
		assert_eq(car.hat, data.fruit.hat)
		assert_eq(car.wanted, i == queue.plan.wanted_index)
		var kinds: Array[String] = []
		for melon in car.bed_melons():
			kinds.append(melon.kind)
		assert_eq(kinds, Array(data.fruit.melons, TYPE_STRING, "", null))
		var hat := car.get_node("Driver/Hat") as Node3D
		for kind in FruitTraits.HATS:
			assert_eq((hat.find_child("hat_" + kind, true, false) as Node3D).visible, kind == car.hat, kind)


func test_the_texts_are_translated() -> void:
	for key in ["CLUE_FRUIT_SIGN", "CLUE_FRUIT_CRATE", "CLUE_FRUIT_HAT", "CLUE_FRUIT_COLOR", "BRIEF_FRUIT_A",
			"BRIEF_FRUIT_C", "FRUIT_CRATE_BANANAS", "FRUIT_CRATE_ORANGES", "FRUIT_CRATE_PINEAPPLES", "FRUIT_HAT_STRAW",
			"FRUIT_HAT_CAP", "FRUIT_HAT_BERET"]:
		assert_ne(tr(key), key)
