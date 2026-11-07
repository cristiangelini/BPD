extends GutTest

## The hidden mask (escena-teatro.md, step 4): its spot drawn with the seed, the search of the trunks, the tuba, the
## front-row seat and the old scenery (TheaterSpot), the props book (PropsBook) and the Golden Mask back in its case
## (GoldenMask).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _theater_case(seed_value: int) -> Array:
	var theater := Theater.new()
	theater.case_seed = seed_value
	add_child_autofree(theater)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = theater
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [theater, case, cop]


func test_the_spot_is_drawn_with_the_seed() -> void:
	var seen := {}
	for seed_value in range(1, 40):
		var theater: Theater = _theater_case(seed_value)[0]
		assert_has(Theater.MASK_SPOTS, theater.loot_spot)
		seen[theater.loot_spot] = true
	assert_gt(seen.size(), 5, "the mask hides in different spots from match to match")
	assert_eq((_theater_case(7)[0] as Theater).loot_spot, (_theater_case(7)[0] as Theater).loot_spot,
		"same seed, same spot")


func test_every_spot_has_its_body_and_prompt() -> void:
	var made := _theater_case(3)
	var theater: Theater = made[0]
	var cop: Cop = made[2]
	for spot: String in Theater.MASK_SPOTS:
		var body := theater.loot_spots[spot] as TheaterSpot
		assert_not_null(body, spot)
		assert_ne(tr(body.prompt_key(cop)), body.prompt_key(cop), "%s has its prompt" % spot)
		assert_ne(tr("HINT_THEATER_NOTHING_" + spot), "HINT_THEATER_NOTHING_" + spot, "%s has its nothing line" % spot)
		var out: Vector3 = body.position + body.get_meta("out")
		out.y = body.get_meta("floor") + 0.1
		assert_eq(theater.room(theater.to_global(out)), theater.room(theater.to_global(body.position)),
			"%s drops the mask in its own room" % spot)
	assert_eq((theater.loot_spots["trunk_moon"] as TheaterSpot).prompt_key(cop), "PROMPT_THEATER_SEARCH_trunk")
	for i in Theater.EMBROIDERIES.size():
		var trunk := theater.loot_spots["trunk_" + Theater.EMBROIDERIES[i]] as Node3D
		assert_eq(theater.room(trunk.global_position), "dressing")
		assert_almost_eq(trunk.position.x, Theater.dressing_at(i).x, 0.01, "the trunk is in its dressing room")
	assert_eq(theater.room(theater.loot_spots["tuba"].global_position), "hall", "the tuba is in the pit")
	assert_eq(theater.room(theater.loot_spots["scenery"].global_position), "basement")


func test_searching_takes_a_while_and_finds_the_mask_only_in_its_spot() -> void:
	var made := _theater_case(5)
	var theater: Theater = made[0]
	var cop: Cop = made[2]
	var spots := Theater.MASK_SPOTS
	var wrong: String = spots[(spots.find(theater.loot_spot) + 1) % spots.size()]
	(theater.loot_spots[wrong] as TheaterSpot).use(cop)
	assert_eq(cop._hint.text, "HINT_THEATER_SEARCHING")
	theater.search(theater.loot_spot, cop)
	assert_false(theater.mask_uncovered, "one search at a time")
	await wait_seconds(Theater.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_THEATER_NOTHING_" + wrong)
	assert_false(theater.mask_uncovered)
	theater.search(theater.loot_spot, cop)
	await wait_seconds(Theater.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_MASK_UNCOVERED")
	assert_true(theater.mask_uncovered)
	var spot := theater.loot_spots[theater.loot_spot] as Node3D
	var out: Vector3 = spot.position + spot.get_meta("out")
	assert_lt(Vector2(theater.mask.position.x, theater.mask.position.z).distance_to(Vector2(out.x, out.z)), 0.1,
		"the mask lies in front of its spot")
	assert_lt(theater.mask.position.y - (spot.get_meta("floor") as float), 0.2, "on the floor")


func test_the_book_tells_the_dressing_room_or_nothing_new() -> void:
	TranslationServer.set_locale("es")
	var made := _theater_case(2)
	var theater: Theater = made[0]
	theater.loot_spot = "trunk_clover"
	assert_string_contains(theater.book_says(), "camerino trébol")
	theater.loot_spot = "tuba"
	assert_eq(theater.book_says(), tr("HINT_PROPS_BOOK_EMPTY"))
	assert_eq(theater.book.prompt_key(made[2]), "PROMPT_PROPS_BOOK")
	theater.book.use(made[2])
	assert_eq((made[2] as Cop)._hint.text, "HINT_PROPS_BOOK_READING")
	assert_eq(theater.room(theater.book.global_position), "workshop", "the book is on the workshop's desk")


func test_the_mask_back_in_its_case_is_the_extra() -> void:
	var made := _theater_case(9)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.briefing_lines()[0], "BRIEF_THEATER_A_mask")
	assert_ne(tr(case.briefing_lines()[0]), case.briefing_lines()[0], "the briefing names the Golden Mask")
	var row: Dictionary = case.rows().filter(func(r: Dictionary) -> bool:
		return r.text == "OBJ_THEATER_LOOT_mask")[0]
	assert_true(row.optional)
	assert_false(row.done)
	theater.uncover_mask()
	assert_eq(theater.mask.prompt_key(cop), "PROMPT_MASK_RETURN")
	theater.mask.use(cop)
	assert_true(case.loot_found, "the case notes it for the salary")
	assert_eq(theater.mask.collision_layer, 0)
	assert_lt(Vector2(theater.mask.position.x, theater.mask.position.z).distance_to(
		Vector2(Theater.MASK_CASE_AT.x, Theater.MASK_CASE_AT.z)), 0.1, "back in its case")
	assert_ne(tr("HINT_LOOT_FOUND_mask"), "HINT_LOOT_FOUND_mask")
