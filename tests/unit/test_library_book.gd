extends GutTest

## The hidden Golden Book (escena-biblioteca.md, step 4): its spot drawn with the seed, the search of the shelves, the
## cart and the cushion (LibrarySpot), the card catalog (CardCatalog) and the book back in its display case.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _library_case(seed_value: int) -> Array:
	var library := Library.new()
	library.case_seed = seed_value
	add_child_autofree(library)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = library
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [library, case, cop]


func test_the_spot_is_drawn_with_the_seed() -> void:
	var seen := {}
	for seed_value in range(1, 40):
		var made := _library_case(seed_value)
		var library: Library = made[0]
		assert_has(Library.BOOK_SPOTS, library.loot_spot)
		seen[library.loot_spot] = true
	assert_gt(seen.size(), 5, "the book hides in different spots from match to match")
	var again := _library_case(7)
	var once := _library_case(7)
	assert_eq((again[0] as Library).loot_spot, (once[0] as Library).loot_spot, "same seed, same spot")


func test_every_spot_has_its_body_and_prompt() -> void:
	var made := _library_case(3)
	var library: Library = made[0]
	var cop: Cop = made[2]
	for spot: String in Library.BOOK_SPOTS:
		var body := library.loot_spots[spot] as LibrarySpot
		assert_not_null(body, spot)
		assert_ne(tr(body.prompt_key(cop)), body.prompt_key(cop), "%s has its prompt" % spot)
		assert_ne(tr("HINT_LIBRARY_NOTHING_" + spot), "HINT_LIBRARY_NOTHING_" + spot, "%s has its nothing line" % spot)
	assert_eq((library.loot_spots["section_C"] as LibrarySpot).prompt_key(cop), "PROMPT_LIBRARY_SEARCH_shelf")
	assert_eq((library.loot_spots["cart"] as LibrarySpot).prompt_key(cop), "PROMPT_LIBRARY_SEARCH_cart")


func test_searching_takes_a_while_and_finds_the_book_only_in_its_spot() -> void:
	var made := _library_case(5)
	var library: Library = made[0]
	var cop: Cop = made[2]
	var wrong: String = Library.BOOK_SPOTS[(Library.BOOK_SPOTS.find(library.loot_spot) + 1) % Library.BOOK_SPOTS.size()]
	(library.loot_spots[wrong] as LibrarySpot).use(cop)
	assert_eq(cop._hint.text, "HINT_LIBRARY_SEARCHING")
	library.search(library.loot_spot, cop)
	assert_false(library.book_uncovered, "one search at a time")
	await wait_seconds(Library.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_LIBRARY_NOTHING_" + wrong)
	assert_false(library.book_uncovered)
	library.search(library.loot_spot, cop)
	await wait_seconds(Library.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_LIBRARY_BOOK_UNCOVERED")
	assert_true(library.book_uncovered)
	var spot := library.loot_spots[library.loot_spot] as Node3D
	assert_lt(library.book.position.distance_to(spot.position + spot.get_meta("out") as Vector3), 1.5,
		"the book lies in front of its spot")


func test_the_catalog_tells_the_section_or_that_all_is_in_order() -> void:
	var made := _library_case(2)
	var library: Library = made[0]
	library.loot_spot = "section_F"
	assert_string_contains(library.catalog_says(), "F")
	assert_eq(library.catalog_says(), tr("HINT_CATALOG_SWAPPED") % "F")
	library.loot_spot = "cushion"
	assert_eq(library.catalog_says(), tr("HINT_CATALOG_IN_ORDER"))
	assert_eq(library.catalog.prompt_key(made[2]), "PROMPT_CARD_CATALOG")


func test_the_book_back_in_its_case_is_the_extra() -> void:
	var made := _library_case(9)
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.briefing_lines()[0], "BRIEF_LIBRARY_A_golden_book")
	assert_ne(tr(case.briefing_lines()[0]), case.briefing_lines()[0], "the briefing names the Golden Book")
	var row: Dictionary = case.rows().filter(func(r: Dictionary) -> bool: return r.text == "OBJ_LIBRARY_LOOT_golden_book")[0]
	assert_true(row.optional)
	assert_false(row.done)
	library.uncover_book()
	assert_eq(library.book.prompt_key(cop), "PROMPT_GOLDEN_BOOK_RETURN")
	library.book.use(cop)
	assert_true(case.loot_found, "the case notes it for the salary")
	assert_eq(library.book.collision_layer, 0)
	assert_lt(library.book.position.distance_to(Library.CASE_AT), 1.2, "back in its display case")
	assert_ne(tr("HINT_LOOT_FOUND_golden_book"), "HINT_LOOT_FOUND_golden_book")
