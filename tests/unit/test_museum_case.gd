extends GutTest

## The museum's case (escena-museo.md, step 4a): what was stolen and where it's hidden, the comisario's briefing, the
## planilla's rows and the level that gives the case with the station's board and stamp.

const LEVEL := preload("res://scenes/levels/museum.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _museum_case(seed_value: int) -> Array:
	var museum := Museum.new()
	museum.case_seed = seed_value
	add_child_autofree(museum)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = museum
	add_child_autofree(case)
	case.start()
	return [museum, case]


func test_the_seed_draws_what_was_stolen_and_where() -> void:
	var loots := {}
	var spots := {}
	for seed_value in range(1, 30):
		var made := _museum_case(seed_value)
		var museum: Museum = made[0]
		assert_true(Museum.LOOTS.has(museum.loot))
		assert_true(Museum.LOOT_SPOTS.has(museum.loot_spot))
		loots[museum.loot] = true
		spots[museum.loot_spot] = true
	assert_eq(loots.size(), Museum.LOOTS.size(), "all three get stolen")
	assert_eq(spots.size(), Museum.LOOT_SPOTS.size(), "and hidden everywhere")


func test_the_briefing_names_it_and_the_locker_to_search_is_the_culprits() -> void:
	TranslationServer.set_locale("es")
	var made := _museum_case(5)
	var museum: Museum = made[0]
	var case: CrimeSceneCase = made[1]
	var lines := case.briefing_lines()
	assert_eq(lines[0], "BRIEF_CITY_MUSEUM_A_" + museum.loot)
	assert_ne(tr(lines[0]), lines[0])
	var locker := museum.loot_spots.locker as Node3D
	assert_almost_eq(locker.position.z, Museum.LOCKERS[case.plan.culprit].z, 0.01, "the culprit's locker")
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_MUSEUM_LOOT_" + museum.loot, "an optional row for the loot")
	assert_has(texts, "OBJ_MUSEUM_GO")


func test_searching_finds_it_only_in_its_spot() -> void:
	var made := _museum_case(9)
	var museum: Museum = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	for spot: String in Museum.LOOT_SPOTS:
		if spot != museum.loot_spot:
			var body := museum.loot_spots[spot] as LootSpot
			assert_eq(body.prompt_key(cop), "PROMPT_SEARCH_" + spot)
			body.use(cop)
	assert_false(museum.loot_found, "nothing in the other two")
	(museum.loot_spots[museum.loot_spot] as LootSpot).use(cop)
	assert_true(museum.loot_found)
	assert_true(case.loot_found)
	var item := museum.get_node("Loot") as Node3D
	assert_not_null(item)
	assert_true(museum.inside(item.global_position), "it falls in the room, not in a wall")


func test_the_level_gives_the_case_with_the_board() -> void:
	var level: MuseumLevel = LEVEL.instantiate()
	level.case_seed = 3
	add_child_autofree(level)
	assert_not_null(level.case)
	assert_eq(level.case.place, level.museum)
	assert_eq(level.case.texts(), CrimeSceneCase.VARIANTS.museum)
	assert_eq(level.case.board, level.board)
	assert_eq(level.museum.guards[0].case, level.case, "the guards know the case")
