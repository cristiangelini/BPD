extends GutTest

## Doña Tinta as the aquarium's witness (escena-acuario.md, step 5b): a crab from the kitchen box makes her draw the
## thief's tank animal on her glass; a tap or a shout sends her into her cave and rubs it out, and the second time she
## takes offense for good (AquariumOctopus, AquariumCrab).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## An aquarium case whose clues have the witness (or don't, with `has` false).
func _case(has := true) -> CrimeSceneCase:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(DiverTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.aquarium.clues)
		if plan.clues.has("witness") == has:
			var aquarium := Aquarium.new()
			aquarium.case_seed = seed_value
			add_child_autofree(aquarium)
			var case := CrimeSceneCase.new()
			case.case_seed = seed_value
			case.place = aquarium
			add_child_autofree(case)
			case.start()
			return case
	return null


func _cop(at := Vector3(0, 0, 100)) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = at
	return cop


func test_a_crab_makes_her_draw_the_thiefs_animal() -> void:
	var case := _case()
	var octopus := (case.place as Aquarium).octopus
	assert_eq(octopus.animal, case.culprit().tank)
	assert_true(octopus.feed(_cop()), "she takes the crab")
	assert_eq(octopus.said(), "OCTOPUS_DRAWS")
	assert_not_null(octopus.drawing, "the animal in ink on her glass")
	assert_has(case.clues_found, "witness")
	assert_string_contains(case.clue_line("witness"), tr("CARE_" + case.culprit().tank))


func test_she_shrugs_when_she_saw_nothing() -> void:
	var case := _case(false)
	var octopus := (case.place as Aquarium).octopus
	assert_true(octopus.feed(_cop()))
	assert_eq(octopus.said(), "OCTOPUS_NOTHING")
	assert_null(octopus.drawing)


func test_a_tap_hides_her_and_rubs_out_the_drawing() -> void:
	var case := _case()
	var octopus := (case.place as Aquarium).octopus
	octopus.feed(_cop())
	octopus.use(_cop())
	assert_true(octopus.is_hidden())
	assert_eq(octopus.said(), "OCTOPUS_HIDES")
	assert_null(octopus.drawing, "the drawing goes with her")
	assert_eq(octopus.prompt_key(null), "PROMPT_OCTOPUS_HIDDEN")
	assert_false(octopus.feed(_cop()), "no crab while she is in her cave")
	assert_eq(octopus.said(), "OCTOPUS_HIDDEN")
	octopus.hidden_left = 0.01
	await wait_physics_frames(2)
	assert_false(octopus.is_hidden(), "she comes back after a while")
	assert_does_not_have(case.ruined, "witness", "once is not offense")


func test_the_second_scare_offends_her_for_good() -> void:
	var case := _case()
	var aquarium := case.place as Aquarium
	aquarium.octopus.use(_cop())
	aquarium.octopus.hidden_left = 0.0
	aquarium.octopus.use(_cop())
	assert_true(aquarium.witness_offended())
	assert_has(case.ruined, "witness")
	assert_eq(aquarium.octopus.prompt_key(null), "PROMPT_OCTOPUS_OFFENDED")
	assert_false(aquarium.octopus.feed(_cop()))
	assert_eq(aquarium.octopus.said(), "OCTOPUS_OFFENDED")


func test_only_a_shout_close_to_her_tank_scares_her() -> void:
	var case := _case()
	var aquarium := case.place as Aquarium
	aquarium.shouted_by(_cop(aquarium.to_global(Vector3(-Aquarium.HALF_X + 1, 0, 0))))
	assert_false(aquarium.octopus.is_hidden(), "from across the hall she doesn't hear")
	aquarium.shouted_by(_cop(aquarium.to_global(Aquarium.INK_TANK_AT + Vector3(-2, 0, 0))))
	assert_true(aquarium.octopus.is_hidden())


func test_the_kitchen_box_has_crabs_to_give_her() -> void:
	var case := _case()
	var aquarium := case.place as Aquarium
	var crabs := aquarium.find_children("Crab*", "AquariumCrab", false, false)
	assert_eq(crabs.size(), 3)
	var cop := _cop()
	assert_eq((crabs[0] as AquariumCrab).held_prompt_key(cop), "PROMPT_HOLDING_CRAB", "aimed at nothing")
	TranslationServer.set_locale("es")
	assert_ne(tr("PROMPT_GIVE_CRAB"), "PROMPT_GIVE_CRAB")
