extends GutTest

## What was stolen at the wedding (escena-boda.md, step 4): the seed draws the ring, the envelopes' box or the sugar
## couple and where it's hidden (the cake, the coats or the head table's centerpiece); searching the right spot turns
## it up for the case, the wrong ones don't, and cutting the cake open leaves it caved in.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _wedding_case(seed_value: int) -> Array:
	var hall := WeddingHall.new()
	hall.case_seed = seed_value
	add_child_autofree(hall)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hall
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [hall, case, cop]


func test_the_seed_draws_the_loot_and_its_spot() -> void:
	var loots := {}
	var spots := {}
	for seed_value in range(1, 40):
		var made := _wedding_case(seed_value)
		var hall: WeddingHall = made[0]
		assert_true(WeddingHall.LOOTS.has(hall.loot))
		assert_true(WeddingHall.LOOT_SPOTS.has(hall.loot_spot))
		loots[hall.loot] = true
		spots[hall.loot_spot] = true
		hall.free()
		(made[1] as Node).free()
		(made[2] as Node).free()
	assert_eq(loots.size(), 3, "every loot comes up")
	assert_eq(spots.size(), 3, "every spot comes up")
	var again: WeddingHall = _wedding_case(7)[0]
	var other: WeddingHall = _wedding_case(7)[0]
	assert_eq([again.loot, again.loot_spot], [other.loot, other.loot_spot], "same seed, same loot and spot")


func test_the_briefing_and_the_planilla_name_the_loot() -> void:
	TranslationServer.set_locale("es")
	var made := _wedding_case(3)
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var lines := case.briefing_lines()
	assert_eq(lines[0], "BRIEF_CRIME_WEDDING_A_" + hall.loot)
	for line in lines:
		assert_ne(tr(line), line, "%s is translated" % line)
	var loot_rows := case.rows().filter(func(row: Dictionary) -> bool:
		return row.text == "OBJ_WEDDING_LOOT_" + hall.loot)
	assert_eq(loot_rows.size(), 1, "the planilla asks for it")
	assert_false(loot_rows[0].done)


func test_searching_turns_it_up_only_in_its_spot() -> void:
	var made := _wedding_case(5)
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	for spot: String in WeddingHall.LOOT_SPOTS:
		assert_not_null(hall.get_node_or_null("Search_" + spot), "%s can be searched" % spot)
		assert_eq((hall.loot_spots[spot] as LootSpot).prompt_key(cop), "PROMPT_SEARCH_" + spot)
		assert_ne(tr("PROMPT_SEARCH_" + spot), "PROMPT_SEARCH_" + spot)
		assert_ne(tr("HINT_SEARCH_NOTHING_" + spot), "HINT_SEARCH_NOTHING_" + spot)
	for spot: String in WeddingHall.LOOT_SPOTS:
		if spot != hall.loot_spot:
			(hall.loot_spots[spot] as LootSpot).use(cop)
	assert_false(hall.loot_found, "nothing in the wrong spots")
	assert_null(hall.get_node_or_null("Loot"))
	(hall.loot_spots[hall.loot_spot] as LootSpot).use(cop)
	assert_true(hall.loot_found)
	assert_true(case.loot_found, "the case knows")
	var item := hall.get_node("Loot") as Node3D
	assert_lt(absf(item.position.x), WeddingHall.HALF_X)
	assert_lt(absf(item.position.z), WeddingHall.HALF_Z)
	assert_almost_eq(item.position.y, WeddingHall.FLOOR_TOP, 0.01, "on the floor")
	assert_ne(tr("HINT_LOOT_FOUND_" + hall.loot), "HINT_LOOT_FOUND_" + hall.loot)


func test_cutting_the_cake_caves_it_in() -> void:
	var made := _wedding_case(9)
	var hall: WeddingHall = made[0]
	var cop: Cop = made[2]
	assert_false(hall.cake_cut)
	hall.search("cake", cop)
	assert_true(hall.cake_cut)
	assert_eq(hall.cake.scale, WeddingHall.CUT_CAKE)
	assert_eq(hall.loot_found, hall.loot_spot == "cake", "the loot only turns up if it was in the cake")
