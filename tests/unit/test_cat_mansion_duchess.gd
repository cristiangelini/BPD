extends GutTest

## Where Duquesa is and bringing her home (escena-gato.md, step 5, first part): CatMansion's hiding spots and search,
## MansionLady.receive, the case's loot row and the level's case.

const LEVEL := preload("res://scenes/levels/cat_mansion.tscn")


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


func test_the_culprit_hid_duchess_in_one_of_three_spots() -> void:
	var kinds := {}
	for seed_value in range(1, 16):
		var made := _mansion_case(seed_value)
		var mansion: CatMansion = made[0]
		var case: CrimeSceneCase = made[1]
		var duchess := mansion.cats[mansion.duchess]
		assert_true(duchess.shut_in, "seed %d: she is locked away" % seed_value)
		assert_false(duchess.get_node("Model").visible, "out of sight")
		var kind := mansion.duchess_spot.get_slice("_", 0)
		assert_has(CatMansion.HIDING_SPOTS, kind)
		if kind == "suitcase":
			assert_eq(mansion.duchess_spot, "suitcase_%d" % case.plan.culprit, "in the culprit's own suitcase")
		kinds[kind] = true
		assert_almost_eq(duchess.global_position, mansion.search_spots[mansion.duchess_spot].global_position,
			Vector3.ONE * 0.01)
	assert_eq(kinds.size(), CatMansion.HIDING_SPOTS.size(), "the seed uses all three")
	assert_eq(_mansion_case(1)[0].search_spots.size(), 8, "six suitcases, the dumbwaiter and the basket")


func test_searching_lets_her_out_of_the_right_spot_only() -> void:
	var mansion: CatMansion = _mansion_case(3)[0]
	var duchess := mansion.cats[mansion.duchess]
	for spot: String in mansion.search_spots:
		if spot != mansion.duchess_spot:
			mansion.search(spot, null)
	assert_true(duchess.shut_in, "nothing in the other spots")
	assert_eq((mansion.search_spots.suitcase_0 as LootSpot).prompt_key(null), "PROMPT_SEARCH_suitcase")
	mansion.search(mansion.duchess_spot, null)
	assert_true(mansion.duchess_out)
	assert_false(duchess.shut_in, "she jumps out")
	assert_true(duchess.get_node("Model").visible)
	assert_false(duchess.freeze)
	assert_eq(duchess.collision_layer, 4)


func test_the_wrong_cat_is_sent_off_by_her_name() -> void:
	TranslationServer.set_locale("es")
	var made := _mansion_case(5)
	var mansion: CatMansion = made[0]
	var wrong := mansion.cats[(mansion.duchess + 1) % CatMansion.CAT_COUNT]
	watch_signals(mansion.lady)
	wrong.global_position = mansion.lady.global_position + Vector3(0.6, 0.5, 0.6)
	wrong.hold(get_instance_id(), wrong.global_position)
	await wait_physics_frames(2)
	assert_signal_emitted(mansion.lady, "got_wrong_cat")
	assert_eq(mansion.lady.said(), tr("MANSION_LADY_WRONG_CAT") % tr(wrong.cat_name))
	assert_string_contains(mansion.lady.said(), tr(wrong.cat_name))
	assert_false(wrong.home)
	assert_false(wrong.is_held())
	assert_true(wrong.is_hiding(), "off she runs")
	assert_false(mansion.loot_found)


func test_duchess_in_the_crate_goes_home_and_the_case_counts_it() -> void:
	var made := _mansion_case(7)
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var duchess := mansion.cats[mansion.duchess]
	mansion.search(mansion.duchess_spot, null)
	mansion.crate.put_in(duchess)
	mansion.crate.global_position = mansion.lady.global_position + Vector3(0.8, 0.1, 0.5)
	mansion.crate.hold(get_instance_id(), mansion.crate.global_position)
	await wait_physics_frames(2)
	assert_true(duchess.home, "in the señora's arms")
	assert_eq(duchess.get_parent(), mansion.lady)
	assert_null(mansion.crate.cat, "out of the crate")
	assert_eq(mansion.lady.said(), "MANSION_LADY_MY_BABY")
	assert_true(mansion.loot_found)
	assert_true(case.loot_found, "the case's +100")
	var row := case.rows().filter(func(r: Dictionary) -> bool: return r.text == "OBJ_CAT_LOOT_duchess")
	assert_eq(row.size(), 1)
	assert_true(row[0].done)


func test_the_level_starts_the_cat_case() -> void:
	var level: CatMansionLevel = LEVEL.instantiate()
	level.case_seed = 9
	add_child_autofree(level)
	assert_eq(level.case.texts(), CrimeSceneCase.VARIANTS.cat)
	assert_eq(level.case.briefing_lines()[0], "BRIEF_CAT_A_duchess")
	assert_eq(level.case.cooks, NephewTraits.draw(9))
	assert_eq(level.mansion.case, level.case)
	TranslationServer.set_locale("es")
	for key in ["BRIEF_CAT_A_duchess", "OBJ_CAT_LOOT_duchess", "HINT_LOOT_FOUND_duchess", "PROMPT_SEARCH_dumbwaiter",
			"HINT_SEARCH_NOTHING_basket", "HINT_DUCHESS_OUT", "CAT_NAME_3"]:
		assert_ne(tr(key), key, "%s is translated" % key)
