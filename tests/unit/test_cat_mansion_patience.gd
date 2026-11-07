extends GutTest

## Señora Ofelia's patience and Don Plumas the witness (escena-gato.md, step 5, third part; CatPatience,
## MansionParrot, ParrotCrackers).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var plan := CrimePlan.draw(NephewTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.cat.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func _mansion_case(seed_value := 3) -> Array:
	var mansion := CatMansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = mansion
	add_child_autofree(case)
	case.start()
	return [mansion, case]


func test_her_patience_calls_the_comisario_and_then_throws_them_out() -> void:
	var made := _mansion_case()
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var patience := mansion.patience
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	watch_signals(patience)
	assert_eq(patience.value, CatPatience.FULL)
	patience.lose("wrong_cat")
	assert_eq(patience.value, 80.0)
	assert_eq(mansion.lady.said(), "MANSION_LADY_ANNOYED_wrong_cat")
	assert_eq(patience.calls, 0, "no call above 75")
	patience.lose("wrong_cat")
	assert_eq(patience.calls, 1, "below 75: the first call")
	assert_eq(case.fines, CatPatience.CALL_FINE)
	patience.lose("wrong_cat")
	patience.lose("wrong_cat")
	assert_eq(patience.calls, 3, "20: below 50 and 25 too")
	assert_eq(case.fines, 3 * CatPatience.CALL_FINE)
	cop.global_position = mansion.to_global(Vector3(0, 0.2, 2.0))
	patience.lose("wrong_cat")
	assert_true(patience.out, "at 0 she throws them out")
	assert_signal_emitted(patience, "thrown_out")
	await wait_physics_frames(2)
	assert_false(mansion.inside(cop.global_position), "out in the garden")
	assert_true(mansion.at_scene(cop.global_position))
	patience.lose("shout")
	assert_eq(case.fines, 3 * CatPatience.CALL_FINE, "no more calls")


func test_what_the_cops_do_costs_and_duchess_brings_it_back() -> void:
	var made := _mansion_case()
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var patience := mansion.patience
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = mansion.to_global(Vector3(-1, 0.2, 2.0))
	mansion.shouted_by(cop)
	assert_eq(patience.value, 95.0, "no shouting in her house")
	cop.global_position = mansion.to_global(CatMansion.ARMCHAIR_AT + Vector3(0, 0.6, 0))
	await wait_physics_frames(3)
	assert_eq(patience.value, 85.0, "into Duquesa's armchair, once")
	cop.global_position = mansion.to_global(Vector3(-1, 0.2, 2.0))
	await wait_physics_frames(2)
	cop.global_position = mansion.to_global(CatMansion.ARMCHAIR_AT + Vector3(0, 0.6, 0))
	await wait_physics_frames(2)
	assert_eq(patience.value, 75.0, "and again")
	var innocent := mansion.nephews[(case.plan.culprit + 1) % NephewTraits.COUNT]
	innocent.cuffed(3.0)
	assert_eq(patience.value, 60.0, "cuffing the wrong nephew")
	mansion.nephews[case.plan.culprit].cuffed(3.0)
	assert_eq(patience.value, 60.0, "the culprit, she doesn't mind")
	mansion._on_duchess_home()
	assert_eq(patience.value, 90.0, "Duquesa home: +30")
	mansion._on_duchess_home()
	assert_eq(patience.value, CatPatience.FULL, "never over 100")


func test_don_plumas_repeats_the_culprits_catchphrase_after_a_cracker() -> void:
	TranslationServer.set_locale("es")
	var made := _mansion_case(_seed_with("witness"))
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var parrot := mansion.parrot
	assert_true(parrot.knows)
	parrot.use(null)
	assert_eq(parrot.said(), "PARROT_PRETTY", "nothing without a cracker")
	assert_eq(mansion.crackers.prompt_key(null), "PROMPT_PARROT_CRACKERS")
	mansion.crackers.use(null)
	assert_true(parrot.fed)
	parrot.use(null)
	var tic := tr("NEPHEW_TIC_%d" % case.culprit().tic)
	assert_eq(parrot.said(), "%s %s" % [tic, tic])
	assert_has(case.clues_found, "witness")


func test_shouting_or_throwing_near_him_scares_him() -> void:
	var made := _mansion_case(_seed_with("witness"))
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = mansion.parrot.global_position + Vector3(2.0, -1.0, 0)
	case.shouted_by(cop)
	assert_true(mansion.parrot.scared)
	assert_true(mansion.witness_offended())
	assert_has(case.ruined, "witness")
	mansion.crackers.use(null)
	mansion.parrot.use(null)
	assert_eq(mansion.parrot.said(), "PARROT_SCARED", "only «¡Lorito bonito!» now")
	var other: CatMansion = _mansion_case(_seed_with("witness"))[0]
	var cat := other.cats[0]
	cat.global_position = other.parrot.global_position + Vector3(0.5, 0, 0)
	cat.linear_velocity = Vector3(-6, 0, 0)
	await wait_physics_frames(2)
	assert_true(other.parrot.scared, "a cat flying past him")
	for key in ["HUD_CAT_PATIENCE", "CAT_COMISARIO_CALL_1", "MANSION_LADY_OUT", "PARROT_SCARED",
			"MANSION_LADY_ANNOYED_armchair"]:
		assert_ne(tr(key), key, "%s is translated" % key)
