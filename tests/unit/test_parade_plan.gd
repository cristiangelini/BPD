extends GutTest

## Parade step 4 (control-desfile.md, "Cómo es" 1 and 5): the plan puts El Antifaz on one of the floats, one of its
## dancers; his clues are its theme, his mask, what he holds and the last digit of its number. Only he fits all three,
## a few floats have a dancer who fits two, and a few city cars come too.

func _plan(case_seed: int) -> WantedPlan:
	return WantedPlan.draw(case_seed, false, false, false, false, false, false, false, false, true)


func test_el_antifaz_dances_on_one_of_the_floats() -> void:
	for case_seed in 30:
		var plan := _plan(case_seed)
		assert_true(plan.parade)
		assert_between(plan.total, WantedPlan.PARADE_TOTAL.x, WantedPlan.PARADE_TOTAL.y)
		assert_between(plan.wanted_index, WantedPlan.PARADE_WANTED_AT.x, WantedPlan.PARADE_WANTED_AT.y)
		var his: Dictionary = plan.cars[plan.wanted_index].parade
		assert_between(int(his.thief), 0, his.dancers.size() - 1)
		var floats := 0
		for i in plan.total:
			var float_traits: Dictionary = plan.cars[i].parade
			if not float_traits.is_empty():
				floats += 1
			if i != plan.wanted_index:
				assert_false(float_traits.has("thief"), "only one El Antifaz")
		assert_between(floats, plan.total / 4, plan.total)


func test_only_el_antifaz_fits_every_clue_and_a_few_dancers_fit_two() -> void:
	var kinds := {}
	for case_seed in 40:
		var plan := _plan(case_seed)
		for clue in plan.clues:
			assert_has(WantedPlan.PARADE_KINDS, clue.kind)
			kinds[clue.kind] = true
		assert_eq(plan.fits(plan.cars[plan.wanted_index]), WantedPlan.CLUES)
		var twos := 0
		for i in plan.total:
			if i == plan.wanted_index:
				continue
			var fit := plan.fits(plan.cars[i])
			assert_lt(fit, WantedPlan.CLUES, "no other dancer fits them all")
			if fit == WantedPlan.CLUES - 1:
				twos += 1
				assert_false(plan.cars[i].parade.is_empty(), "a lookalike is a float")
		assert_between(twos, WantedPlan.LOOKALIKES.x, WantedPlan.LOOKALIKES.y)
	assert_eq(kinds.size(), WantedPlan.PARADE_KINDS.size(), "every kind of clue comes up")


func test_the_clues_read_about_him() -> void:
	var plan := WantedPlan.new()
	plan.clues.assign([{"kind": "theme", "value": "whale"}, {"kind": "mask", "value": 2},
		{"kind": "held", "value": 1}, {"kind": "float_number", "value": 7}])
	assert_string_contains(plan.clue_text(0), tr("PARADE_THEME_WHALE"))
	assert_string_contains(plan.clue_text(1), tr(ParadeFloat.MASK_NAMES[2]))
	assert_string_contains(plan.clue_text(2), tr(ParadeFloat.HELD_NAMES[1]))
	assert_string_contains(plan.clue_text(3), "7")


func test_the_queue_brings_el_antifaz_who_dances_the_wrong_step() -> void:
	var checkpoint := TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	var queue := TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "parade"
	queue.plan = _plan(9)
	add_child_autofree(queue)
	queue.set_physics_process(false)
	queue.spawned = queue.plan.wanted_index
	var car := queue.spawn()
	car.set_physics_process(false)
	assert_true(car.wanted)
	assert_eq(car.parade, queue.plan.cars[queue.plan.wanted_index].parade)
	var dancers := ParadeFloat.dancers_of(car)
	assert_true(dancers[int(car.parade.thief)].thief, "the plan's El Antifaz")
	assert_eq(dancers.filter(func(d: ParadeDancer) -> bool: return d.thief).size(), 1)
	car.state = "waiting"
	car.use()
	assert_ne(dancers[int(car.parade.thief)].step, ParadeFloat.step_of(car.parade.theme))


func test_the_comisario_tells_the_crown_s_story() -> void:
	var case := TrafficCase.new()
	case.plan = _plan(4)
	assert_eq(case.campaign_key(), "traffic_parade")
	case.free()


func test_texts_are_translated() -> void:
	for key in ["CLUE_PARADE_THEME", "CLUE_PARADE_MASK", "CLUE_PARADE_HELD", "CLUE_PARADE_NUMBER", "BRIEF_PARADE_A",
			"BRIEF_PARADE_C"]:
		assert_ne(tr(key), key)
