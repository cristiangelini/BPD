extends GutTest

## Ghost car step 3 (control-auto-fantasma.md): the plan sends 12 to 16 cars; the ghost car comes 3rd to 6th and the
## wanted car is its pilot's, 2 to 5 cars behind it. The clues are about the pilot (his car's color, its plate, his shirt
## or his decade) and only his car fits them all. The queue builds every car with its shirt and its part.


func _plan(case_seed: int) -> WantedPlan:
	return WantedPlan.draw(case_seed, false, false, false, true)


func test_the_ghost_car_comes_up_front_and_its_pilot_behind_it() -> void:
	for case_seed in range(1, 40):
		var plan := _plan(case_seed)
		assert_true(plan.ghost)
		assert_between(plan.total, WantedPlan.GHOST_TOTAL.x, WantedPlan.GHOST_TOTAL.y)
		assert_between(plan.ghost_index, GhostCar.AT.x, GhostCar.AT.y)
		assert_between(plan.wanted_index - plan.ghost_index, GhostCar.PILOT_BEHIND.x, GhostCar.PILOT_BEHIND.y)
		assert_lt(plan.wanted_index, plan.total)
		for i in plan.total:
			assert_eq(plan.cars[i].ghost, i == plan.ghost_index)
			assert_eq(plan.cars[i].puppeteer, i == plan.wanted_index)
			assert_between(int(plan.cars[i].shirt), 0, WantedPlan.SHIRTS.size() - 1)


func test_the_clues_are_about_the_pilot_and_only_he_fits_them_all() -> void:
	var kinds := {}
	for case_seed in range(1, 40):
		var plan := _plan(case_seed)
		assert_eq(plan.clues.size(), WantedPlan.CLUES)
		for clue in plan.clues:
			assert_has(WantedPlan.GHOST_KINDS, clue.kind)
			kinds[clue.kind] = true
		assert_eq(plan.fits(plan.cars[plan.wanted_index]), WantedPlan.CLUES)
		assert_false(plan.lookalikes.has(plan.ghost_index), "the ghost car is nobody's lookalike")
		for i in plan.total:
			if i != plan.wanted_index:
				assert_lt(plan.fits(plan.cars[i]), WantedPlan.CLUES)
		assert_between(plan.lookalikes.size(), WantedPlan.LOOKALIKES.x, WantedPlan.LOOKALIKES.y)
	assert_true(kinds.has("shirt"))


func test_other_variants_draw_as_before() -> void:
	assert_eq(WantedPlan.draw(4).cars, WantedPlan.draw(4, false, false, false, false).cars)
	assert_false(WantedPlan.draw(4).cars[0].has("shirt"))
	assert_eq(WantedPlan.draw(4).ghost_index, -1)


func test_the_shirt_clue_reads_well() -> void:
	var plan := _plan(3)
	plan.clues = [{"kind": "shirt", "value": 0}]
	assert_eq(plan.clue_text(0), tr("CLUE_GHOST_SHIRT") % tr("COLOR_RED"))


func test_the_queue_builds_each_car_with_its_shirt_and_part() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "ghost_car"
	queue.plan = _plan(5)
	queue.set_physics_process(false)
	add_child_autofree(queue)
	for i in queue.plan.total:
		var car := queue.spawn()
		car.set_physics_process(false)
		var data: Dictionary = queue.plan.cars[i]
		assert_eq(car.ghost, i == queue.plan.ghost_index)
		assert_eq(car.puppeteer, i == queue.plan.wanted_index)
		assert_eq(car.wanted, i == queue.plan.wanted_index)
		assert_eq(car.shirt, data.shirt)
		if not car.ghost:
			var shirt := car.get_node("WindowDriver").find_child("shirt", true, false)
			var mesh := shirt as MeshInstance3D if shirt is MeshInstance3D \
				else shirt.find_children("*", "MeshInstance3D")[0] as MeshInstance3D
			assert_eq((mesh.material_override as StandardMaterial3D).albedo_color, GhostCar.SHIRTS[data.shirt])


func test_the_comisario_tells_the_ghost_story() -> void:
	for key in ["BRIEF_GHOST_A", "BRIEF_GHOST_C", "CLUE_GHOST_SHIRT"]:
		assert_ne(tr(key), key)
