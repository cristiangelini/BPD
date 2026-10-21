extends GutTest

## The pastry contest's case (escena-del-crimen.md, step 2; CrimePlan, CrimeSceneCase).

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")


func test_the_clues_leave_only_the_culprit() -> void:
	for seed_value in range(1, 200):
		var cooks := CookTraits.draw(seed_value)
		var plan := CrimePlan.draw(cooks, seed_value)
		assert_eq(plan.clues.size(), CrimePlan.CLUES_PER_CASE, "4 clues (seed %d)" % seed_value)
		assert_eq(CrimePlan.suspects_left(cooks, cooks[plan.culprit], plan.clues), [plan.culprit],
			"together they leave only him (seed %d)" % seed_value)


func test_the_seed_draws_other_culprits_and_clues() -> void:
	var culprits := {}
	var sets := {}
	for seed_value in range(1, 60):
		var plan := CrimePlan.draw(CookTraits.draw(seed_value), seed_value)
		culprits[plan.culprit] = true
		sets[str(plan.clues)] = true
	assert_eq(culprits.size(), CookTraits.COUNT, "any of the six can be the culprit")
	assert_gt(sets.size(), 5, "the clues change from match to match")
	var cooks := CookTraits.draw(9)
	assert_eq(CrimePlan.draw(cooks, 9).clues, CrimePlan.draw(cooks, 9).clues, "same seed, same clues")


func test_a_clue_tells_a_trait_of_the_culprit() -> void:
	var culprit := {"name": "Clara", "shoe": 41, "hair": "red", "teeth": "gap", "left": true, "apron": "mint"}
	var other := culprit.duplicate()
	other.name = "Dora"
	other.shoe = 39
	assert_eq(CrimePlan.says("footprint", culprit), 41)
	assert_false(CrimePlan.fits(other, "footprint", culprit), "another shoe size")
	assert_true(CrimePlan.fits(other, "recipe", culprit), "also left-handed")
	assert_false(CrimePlan.fits(other, "prints", culprit), "the prints are only his")


func test_the_comisario_gives_the_case_and_the_planilla_follows_it() -> void:
	var level: CrimeSceneLevel = LEVEL.instantiate()
	level.case_seed = 11
	var cop: Cop = level.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	var case := level.case
	assert_false(case.tip_given, "the tip waits for the comisario")
	case.give_tip()
	assert_true(case.tip_given)
	assert_eq(case.culprit(), case.cooks[case.plan.culprit])
	assert_false(case.rows()[0].done, "nobody at the tent yet")
	cop.global_position = level.contest.global_position + Vector3(0, 0.1, 0)
	await wait_physics_frames(3)
	assert_true(case.at_tent)
	var rows := case.rows()
	assert_true(rows[0].done, "a cop got to the tent")
	assert_eq(rows[1].text, tr("OBJ_CRIME_CLUES") % [0, 4])
	assert_eq(rows[2].text, tr("OBJ_CRIME_FILES") % [0, 6])
	assert_eq(CaseObjectives.next_step(rows), 1, "next: find the clues")
