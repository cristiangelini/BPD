extends GutTest

## The library's last three clues (escena-biblioteca.md, step 5b): the gold dust seen on someone's hands, the bookmark
## inside the Golden Book (lost if it goes back to its case unopened) and Tomasito, who tells what he saw when someone
## reads him a story.

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


func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 300):
		var readers := ReaderTraits.draw(seed_value)
		var plan := CrimePlan.draw(readers, seed_value, CrimeSceneCase.VARIANTS.library.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func test_gold_dust_on_any_hands_is_the_clue() -> void:
	var made := _library_case(_seed_with("dust"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	for reader in library.readers:
		if not reader.traits.dust:
			reader.light_hands(true)
	assert_does_not_have(case.clues_found, "dust", "clean hands tell nothing")
	for reader in library.readers:
		if reader.traits.dust:
			reader.light_hands(true)
			break
	assert_has(case.clues_found, "dust")


func test_the_bookmark_is_inside_the_golden_book() -> void:
	var made := _library_case(_seed_with("bookmark"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	library.uncover_book()
	library.book.use(cop)
	assert_eq(cop._hint.text, "HINT_GOLDEN_BOOK_BOOKMARK")
	assert_has(case.clues_found, "bookmark")
	var none := _library_case(_seed_with("bookmark", false))
	(none[0] as Library).uncover_book()
	(none[0] as Library).book.use(none[2])
	assert_eq((none[2] as Cop)._hint.text, "HINT_GOLDEN_BOOK_NO_BOOKMARK")


func test_back_in_its_case_unopened_the_bookmark_is_locked_in() -> void:
	var made := _library_case(_seed_with("bookmark"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	library.reveal_loot()
	assert_true(case.loot_found)
	assert_has(case.ruined, "bookmark")


func test_tomasito_tells_what_he_saw_after_a_story() -> void:
	var made := _library_case(_seed_with("witness"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var kid := library.kid
	cop.global_position = kid.global_position + Vector3(0.8, 0, 0)
	assert_eq(kid.prompt_key(cop), "PROMPT_KID_STORY")
	kid.use(cop)
	assert_true(kid.reading)
	assert_eq(kid.prompt_key(cop), "PROMPT_KID_LISTENING")
	await wait_seconds(LibraryKid.STORY_SECONDS + 0.3)
	assert_true(kid.heard)
	assert_string_contains(kid.said(), tr("GENRE_" + str(case.culprit().genre)))
	assert_has(case.clues_found, "witness")
	assert_eq(kid.prompt_key(cop), "PROMPT_KID", "then he just mumbles")


func test_walking_off_stops_the_story() -> void:
	var made := _library_case(_seed_with("witness"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var kid := library.kid
	cop.global_position = kid.global_position + Vector3(0.8, 0, 0)
	kid.use(cop)
	cop.global_position = kid.global_position + Vector3(LibraryKid.STORY_REACH + 1.0, 0, 0)
	await wait_physics_frames(3)
	assert_false(kid.reading)
	assert_does_not_have(case.clues_found, "witness")
	var unaware := _library_case(_seed_with("witness", false))
	var other: LibraryKid = (unaware[0] as Library).kid
	other.reading = true
	other.story_read()
	assert_eq(other.said(), "KID_STORY_DONE")
