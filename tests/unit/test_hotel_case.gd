extends GutTest

## The hotel's case (escena-hotel.md, step 4a): what was stolen and where it's hidden, the comisario's briefing, the
## planilla's rows and the level that gives the case with the station's board and stamp.

const LEVEL := preload("res://scenes/levels/hotel.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _hotel_case(seed_value: int) -> Array:
	var hotel := Hotel.new()
	hotel.case_seed = seed_value
	add_child_autofree(hotel)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hotel
	add_child_autofree(case)
	case.start()
	return [hotel, case]


func test_the_seed_draws_what_was_stolen_and_where() -> void:
	var loots := {}
	var spots := {}
	for seed_value in range(1, 30):
		var hotel: Hotel = _hotel_case(seed_value)[0]
		assert_true(Hotel.LOOTS.has(hotel.loot))
		assert_true(Hotel.LOOT_SPOTS.has(hotel.loot_spot))
		loots[hotel.loot] = true
		spots[hotel.loot_spot] = true
	assert_eq(loots.size(), Hotel.LOOTS.size(), "all three get stolen")
	assert_eq(spots.size(), Hotel.LOOT_SPOTS.size(), "and hidden everywhere")


func test_the_briefing_names_it_and_the_suitcase_to_search_is_the_culprits() -> void:
	TranslationServer.set_locale("es")
	var made := _hotel_case(5)
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	var lines := case.briefing_lines()
	assert_eq(lines[0], "BRIEF_HOTEL_A_" + hotel.loot)
	for line in lines:
		assert_ne(tr(line), line, "%s is written" % line)
	assert_eq(hotel.loot_spots.suitcase, hotel.things[case.culprit().room].suitcase, "the culprit's suitcase")
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_HOTEL_LOOT_" + hotel.loot, "an optional row for the loot")
	assert_has(texts, "OBJ_HOTEL_GO")


## A seed whose loot hides in `spot`.
func _seed_hiding_in(spot: String) -> int:
	for seed_value in range(1, 100):
		if Hotel.LOOT_SPOTS[hash(["hotel loot spot", seed_value]) % Hotel.LOOT_SPOTS.size()] == spot:
			return seed_value
	return -1


func test_searching_finds_it_only_in_its_spot() -> void:
	for spot: String in Hotel.LOOT_SPOTS:
		var made := _hotel_case(_seed_hiding_in(spot))
		var hotel: Hotel = made[0]
		var case: CrimeSceneCase = made[1]
		var cop: Cop = COP_SCENE.instantiate()
		add_child_autofree(cop)
		for room: int in hotel.things:
			if room != case.culprit().room:
				(hotel.things[room].suitcase as RoomThing).use(cop)
		for other: String in Hotel.LOOT_SPOTS:
			if other != spot and other != "suitcase":
				var body := hotel.loot_spots[other] as LootSpot
				assert_eq(body.prompt_key(cop), "PROMPT_SEARCH_" + other)
				body.use(cop)
		assert_false(hotel.loot_found, "%s: not in the others" % spot)
		(hotel.loot_spots[spot] as Node).call("use", cop)
		assert_true(hotel.loot_found, "%s: found there" % spot)
		assert_true(case.loot_found)
		var item := hotel.get_node("Loot") as Node3D
		assert_true(hotel.inside(item.global_position), "it falls inside the hotel")
		assert_eq(hotel.floor_of(item.global_position + Vector3.UP * 0.1), 1, "upstairs, where it was")


func test_the_level_gives_the_case_with_the_board() -> void:
	var level: HotelLevel = LEVEL.instantiate()
	level.case_seed = 3
	add_child_autofree(level)
	assert_eq(level.case.place, level.hotel)
	assert_eq(level.case.texts(), CrimeSceneCase.VARIANTS.hotel)
	assert_eq(level.case.board, level.board)
	assert_eq(level.hotel.guests[0].case, level.case, "the guests know the case")
