extends GutTest

## The common base of the crime scenes (escena-circo.md, step 1; CrimeScenePlace, CrimeSceneCase.VARIANTS): the pastry
## contest is one place, and the case plays on top of it with its variant's texts and clues.

const LEVEL := preload("res://scenes/levels/crime_scene.tscn")


func test_the_pastry_contest_is_a_crime_scene_place() -> void:
	var level: CrimeSceneLevel = LEVEL.instantiate()
	level.case_seed = 7
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	var place: CrimeScenePlace = level.contest
	assert_eq(level.case.place, place)
	assert_eq(place.variant, "pastry")
	assert_eq(level.case.texts(), CrimeSceneCase.VARIANTS.pastry)
	assert_eq(place.suspect(2), level.contest.cooks[2])
	assert_true(place.at_scene(place.global_position))
	assert_false(place.witness_offended())
	place.offend_witness()
	assert_true(level.contest.lady.offended, "the pastry's witness is the jury's lady")
	var getaway := place.getaway(0, level.get_node("City"))
	assert_false(place.at_scene((getaway.at as Transform3D).origin), "the bike waits out of the tent")
	assert_eq((getaway.via as Array).size(), 1, "it rides out of the plaza first")


func test_a_case_without_a_place_plays_the_pastry() -> void:
	var case := CrimeSceneCase.new()
	case.case_seed = 3
	add_child_autofree(case)
	case.start()
	assert_eq(case.texts().shift, "crime_pastry")
	assert_eq(case.plan.traits, CrimePlan.CLUES)
	assert_eq(case.cooks, CookTraits.draw(3))


func test_a_variant_can_tell_other_traits() -> void:
	var traits := {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "glasses": "glasses",
		"apron": "apron"}
	for seed_value in range(1, 80):
		var cooks := CookTraits.draw(seed_value)
		var plan := CrimePlan.draw(cooks, seed_value, traits)
		assert_eq(plan.traits, traits)
		assert_eq(CrimePlan.suspects_left(cooks, cooks[plan.culprit], plan.clues, traits), [plan.culprit],
			"its clues also leave only him (seed %d)" % seed_value)
