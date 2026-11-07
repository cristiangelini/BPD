extends GutTest

## The cat case's clues (escena-gato.md, step 5, second part; CatClues, CatNecklace, the mansion's CrimeClueItems)
## and how they get spoiled.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A seed whose case has (or hasn't) the clue `kind`.
func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var plan := CrimePlan.draw(NephewTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.cat.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func _mansion_case(seed_value: int) -> Array:
	var mansion := CatMansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = mansion
	add_child_autofree(case)
	case.start()
	return [mansion, case]


func test_the_clues_of_the_case_are_where_they_should_be() -> void:
	for seed_value in [2, 5, 11, 17]:
		var made := _mansion_case(seed_value)
		var mansion: CatMansion = made[0]
		var case: CrimeSceneCase = made[1]
		var clues := mansion.clues
		assert_eq(clues.flap.has_prints, case.plan.clues.has("prints"))
		assert_eq(clues.footprint != null, case.plan.clues.has("footprint"))
		assert_eq(case.items.has("hair"), case.plan.clues.has("hair"))
		assert_eq(case.items.has("bite"), case.plan.clues.has("bite"))
		if case.items.has("hair"):
			assert_eq(mansion.room(case.items.hair.global_position), "drawing", "on the armchair")
		if case.items.has("bite"):
			assert_eq(mansion.room(case.items.bite.global_position), "kitchen", "by the biscuit jar")
		var kind := clues.necklace_spot.get_slice("_", 0)
		assert_ne(kind, mansion.duchess_spot.get_slice("_", 0), "the necklace is somewhere else")
		if kind == "suitcase":
			assert_eq(clues.necklace_spot, "suitcase_%d" % case.plan.culprit)


func test_the_necklace_turns_up_and_its_clasp_tells_the_hand() -> void:
	var seed_value := _seed_with("necklace")
	var made := _mansion_case(seed_value)
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	mansion.search(mansion.clues.necklace_spot, cop)
	var necklace := mansion.clues.necklace
	assert_not_null(necklace, "out it comes")
	assert_true(mansion.cats[mansion.duchess].shut_in, "Duquesa is still hidden elsewhere")
	assert_eq(necklace.side, case.culprit().scratch)
	assert_eq(necklace.held_prompt_key(cop), "PROMPT_NECKLACE_LOOK")
	necklace.look_at_clasp(cop)
	assert_has(case.clues_found, "necklace")
	assert_string_contains(case.clue_line("necklace"), tr("CLUE_CAT_necklace_" + case.culprit().scratch))
	necklace.hold(get_instance_id(), mansion.lady.global_position + Vector3(0.5, 1.0, 0.5))
	necklace.global_position = mansion.lady.global_position + Vector3(0.5, 1.0, 0.5)
	await wait_physics_frames(2)
	assert_true(necklace.worn, "the señora puts it on")
	assert_eq(necklace.get_parent(), mansion.lady)
	assert_false(case.ruined.has("necklace"), "looked at first, nothing is lost")


func test_giving_the_necklace_unlooked_spoils_it() -> void:
	var made := _mansion_case(_seed_with("necklace"))
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	mansion.search(mansion.clues.necklace_spot, null)
	mansion.clues.necklace.hold(get_instance_id(), mansion.lady.global_position)
	mansion.clues.necklace.global_position = mansion.lady.global_position + Vector3(0.4, 1.0, 0)
	await wait_physics_frames(2)
	assert_has(case.ruined, "necklace")


func test_the_cats_spoil_the_flap_and_the_litter_tray() -> void:
	var seed_value := -1
	for s in range(1, 200):
		var plan := CrimePlan.draw(NephewTraits.draw(s), s, CrimeSceneCase.VARIANTS.cat.clues)
		if plan.clues.has("prints") and plan.clues.has("footprint"):
			seed_value = s
			break
	var made := _mansion_case(seed_value)
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var cat := mansion.cats[(mansion.duchess + 1) % CatMansion.CAT_COUNT]
	cat.freeze = true
	cat.global_position = mansion.to_global(CatMansion.CAT_FLAP_AT + Vector3(0, -0.1, -0.4))
	await wait_physics_frames(2)
	assert_has(case.ruined, "prints", "muddy paws on the flap")
	assert_eq(mansion.clues.flap.dusted(null), "PRINTS_CAT_FLAP_SMUDGED")
	cat.global_position = mansion.to_global(CatMansion.LITTER_AT + Vector3(0, 0.1, 0))
	await wait_physics_frames(2)
	assert_true(mansion.clues.footprint.wiped, "she used the tray")
	assert_has(case.ruined, "footprint")


func test_sitting_in_the_armchair_and_eating_the_biscuit_spoil_theirs() -> void:
	var seed_value := -1
	for s in range(1, 200):
		var plan := CrimePlan.draw(NephewTraits.draw(s), s, CrimeSceneCase.VARIANTS.cat.clues)
		if plan.clues.has("hair") and plan.clues.has("bite"):
			seed_value = s
			break
	var made := _mansion_case(seed_value)
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	await wait_physics_frames(3)
	assert_false(case.ruined.has("hair"), "the hair rests on the cushion")
	cop.global_position = mansion.to_global(CatMansion.ARMCHAIR_AT + Vector3(0, 0.6, 0))
	await wait_physics_frames(2)
	assert_has(case.ruined, "hair", "a cop sat in Duquesa's armchair")
	var biscuit: CrimeClueItem = case.items.bite
	assert_true(biscuit.is_food())
	biscuit.eat(cop)
	assert_has(case.ruined, "bite")
	TranslationServer.set_locale("es")
	assert_string_contains(case.clue_line("footprint"), str(case.culprit().shoe))
	assert_string_contains(case.clue_line("witness"), tr("NEPHEW_TIC_%d" % case.culprit().tic))
	for key in ["CLUE_CAT_prints", "CLUE_CAT_RUINED_bite", "HINT_CAT_RUINED_hair", "HINT_CLUE_EATEN_bite_mansion",
			"PRINTS_CAT_FLAP", "HINT_NECKLACE_BLOOD_left", "MANSION_LADY_NECKLACE"]:
		assert_ne(tr(key), key, "%s is translated" % key)
