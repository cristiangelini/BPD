extends GutTest

## The library's clues (escena-biblioteca.md, step 5): LibraryClues puts the prints on the display case's glass, the
## slipper print on the parquet, the hair on the armchair and the cookie in the hollow book (HollowBook); and
## CrimeSceneCase says each one on the planilla.

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
	cop.global_position = Vector3(0, 0, 30)
	return [library, case, cop]


## The first seed whose case has (or hasn't) the clue.
func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var readers := ReaderTraits.draw(seed_value)
		var plan := CrimePlan.draw(readers, seed_value, CrimeSceneCase.VARIANTS.library.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func test_each_clue_is_there_only_when_the_case_has_it() -> void:
	for seed_value in [1, 2, 3, 4, 5]:
		var made := _library_case(seed_value)
		var library: Library = made[0]
		var case: CrimeSceneCase = made[1]
		var clues := case.plan.clues
		assert_eq(library.clues.glass.has_prints, clues.has("prints"), "seed %d prints" % seed_value)
		assert_eq(library.has_node("WaxPrint"), clues.has("footprint"), "seed %d footprint" % seed_value)
		assert_eq(case.items.has("hair"), clues.has("hair"), "seed %d hair" % seed_value)
		assert_eq(library.clues.hollow_book.has_bite, clues.has("bite"), "seed %d bite" % seed_value)


func test_the_hollow_book_hides_the_bitten_cookie() -> void:
	var made := _library_case(_seed_with("bite"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var book := library.clues.hollow_book
	assert_eq(book.prompt_key(cop), "PROMPT_HOLLOW_BOOK_SHUT")
	book.use(cop)
	assert_eq(cop._hint.text, "HINT_HOLLOW_BOOK_COOKIE")
	assert_not_null(book.cookie)
	assert_eq(case.items.bite, book.cookie)
	book.cookie.bag(cop)
	assert_has(case.clues_found, "bite", "bagged, it's found")
	assert_string_contains(case.clue_line("bite"), tr("TEETH_" + str(case.culprit().teeth)))


func test_eating_the_cookie_ruins_the_bite() -> void:
	var made := _library_case(_seed_with("bite"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	library.clues.hollow_book.use(cop)
	library.clues.hollow_book.cookie.eat(cop)
	assert_true(library.clues.hollow_book.cookie.spoiled)
	assert_has(case.ruined, "bite")
	assert_eq(cop._hint.text, "HINT_LIBRARY_RUINED_bite")
	assert_ne(tr("HINT_CLUE_EATEN_bite_library"), "HINT_CLUE_EATEN_bite_library")
	var empty := _library_case(_seed_with("bite", false))
	(empty[0] as Library).clues.hollow_book.use(empty[2])
	assert_eq((empty[2] as Cop)._hint.text, "HINT_HOLLOW_BOOK_EMPTY")
	assert_null((empty[0] as Library).clues.hollow_book.cookie)


func test_prints_on_the_glass_until_touched_or_dusted() -> void:
	var seed_value := _seed_with("prints")
	var made := _library_case(seed_value)
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(library.clues.glass.prompt_key(cop), "PROMPT_EMPTY_GLASS")
	assert_eq(library.clues.glass.dusted(cop), "PRINTS_GLASS")
	assert_has(case.clues_found, "prints")
	library.clues.dust_the_case()
	assert_does_not_have(case.ruined, "prints", "found ones are safe")
	var touched := _library_case(seed_value)
	(touched[0] as Library).clues.glass.use(touched[2])
	assert_has((touched[1] as CrimeSceneCase).ruined, "prints")
	var dusted := _library_case(seed_value)
	(dusted[0] as Library).clues.dust_the_case()
	assert_has((dusted[1] as CrimeSceneCase).ruined, "prints", "Doña Sigilo's feather duster")
	assert_eq((dusted[0] as Library).clues.glass.dusted(dusted[2]), "")


func test_stepping_on_the_slipper_print_wipes_it() -> void:
	var made := _library_case(_seed_with("footprint"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var footprint: FlourPrint = library.get_node("WaxPrint")
	assert_eq(footprint.shoe, case.culprit().shoe)
	assert_true(library.inside(footprint.global_position))
	cop.global_position = footprint.global_position
	await wait_physics_frames(3)
	assert_has(case.ruined, "footprint")


func test_every_clue_has_its_lines() -> void:
	var made := _library_case(_seed_with("bookmark"))
	var case: CrimeSceneCase = made[1]
	for kind: String in CrimeSceneCase.VARIANTS.library.clues:
		assert_false(case.clue_line(kind).begins_with("CLUE_"), kind)
		if kind != "dust":
			assert_ne(tr("CLUE_LIBRARY_RUINED_" + kind), "CLUE_LIBRARY_RUINED_" + kind)
			assert_ne(tr("HINT_LIBRARY_RUINED_" + kind), "HINT_LIBRARY_RUINED_" + kind)
	assert_string_contains(case.clue_line("footprint"), str(case.culprit().shoe))
	assert_string_contains(case.clue_line("bookmark"), tr("GENRE_" + str(case.culprit().genre)))
