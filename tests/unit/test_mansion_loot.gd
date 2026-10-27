extends GutTest

## Where the mansion's stolen thing is hidden (escena-mansion.md, step 5c): the coat rack, the piano or the dusty trunk
## in the bookcase's passage, drawn with the seed; searching finds it only there.

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const ROOMS := {"coat_rack": "hall", "piano": "lounge"}


func _mansion_case(seed_value: int) -> Array:
	var mansion := Mansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = mansion
	add_child_autofree(case)
	case.start()
	return [mansion, case]


func test_the_seed_hides_it_in_every_spot() -> void:
	var spots := {}
	for seed_value in range(1, 20):
		var mansion: Mansion = _mansion_case(seed_value)[0]
		assert_has(Mansion.LOOT_SPOTS, mansion.loot_spot)
		spots[mansion.loot_spot] = true
	assert_eq(spots.size(), Mansion.LOOT_SPOTS.size())


func test_each_spot_is_where_it_goes() -> void:
	var mansion: Mansion = _mansion_case(1)[0]
	for spot: String in ROOMS:
		assert_eq(mansion.room_at(mansion.loot_spots[spot].global_position), ROOMS[spot], spot)
	assert_eq(mansion.passage_at(mansion.loot_spots.dusty_trunk.global_position), "bookcase", "the trunk is in the passage")
	assert_not_null(mansion.get_node("Trunk"))


func test_searching_finds_it_only_in_its_spot() -> void:
	for seed_value in [2, 5, 9]:
		var made := _mansion_case(seed_value)
		var mansion: Mansion = made[0]
		var case: CrimeSceneCase = made[1]
		var cop: Cop = COP_SCENE.instantiate()
		add_child_autofree(cop)
		for spot: String in Mansion.LOOT_SPOTS:
			var body := mansion.loot_spots[spot] as LootSpot
			assert_eq(body.prompt_key(cop), "PROMPT_SEARCH_" + spot)
			if spot != mansion.loot_spot:
				body.use(cop)
		assert_false(mansion.loot_found, "nothing in the other two")
		(mansion.loot_spots[mansion.loot_spot] as LootSpot).use(cop)
		assert_true(mansion.loot_found)
		assert_true(case.loot_found)
		var item := mansion.get_node("Loot") as Node3D
		var where := mansion.room_at(item.global_position)
		var spot_room: String = ROOMS.get(mansion.loot_spot, "")
		if spot_room != "":
			assert_eq(where, spot_room, "it falls in the room")
		else:
			assert_eq(mansion.passage_at(item.global_position), "bookcase", "it falls in the passage")


func test_every_search_text_is_translated() -> void:
	for locale in ["es", "en", "pt"]:
		var translation := TranslationServer.get_translation_object(locale)
		for spot: String in Mansion.LOOT_SPOTS:
			for key: String in ["PROMPT_SEARCH_" + spot, "HINT_SEARCH_NOTHING_" + spot]:
				assert_ne(String(translation.get_message(key)), "", "%s in %s" % [key, locale])
		for loot: String in Mansion.LOOTS:
			assert_ne(String(translation.get_message("HINT_LOOT_FOUND_" + loot)), "", loot)
