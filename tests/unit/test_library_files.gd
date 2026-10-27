extends GutTest

## The readers' files (escena-biblioteca.md, step 3): the culprit's gold dust (ReaderTraits), LibraryReader's parts
## and the flashlight on their hands, and CrimeSceneCase's library variant (guard_part, file_text).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_always_has_gold_dust() -> void:
	for seed_value in range(1, 30):
		var readers := ReaderTraits.draw(seed_value)
		var plan := CrimePlan.draw(readers, seed_value, CrimeSceneCase.VARIANTS.library.clues)
		assert_eq(plan.culprit, CrimePlan.culprit_of(ReaderTraits.COUNT, seed_value))
		assert_true(readers[plan.culprit].dust, "seed %d: the Golden Book left its dust on the culprit" % seed_value)
		var dusted := readers.filter(func(r: Dictionary) -> bool: return r.dust).size()
		assert_between(dusted, ReaderTraits.DUSTED.x, ReaderTraits.DUSTED.y)
		assert_eq(CrimePlan.suspects_left(readers, readers[plan.culprit], plan.clues, plan.traits).size(), 1,
			"the clues leave only them")


## A library with its case set up, and a cop at hand.
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


func test_empty_hands_get_the_whisper_then_the_nightcap() -> void:
	var made := _library_case(4)
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.cooks, ReaderTraits.draw(4), "the case's suspects are the readers")
	var reader: LibraryReader
	for r in library.readers:
		if not r.stubborn:
			reader = r
	assert_eq(reader.prompt_key(cop), "PROMPT_READER_TALK")
	reader.use(cop)
	assert_string_contains(reader.said(), reader.genre_name())
	assert_eq(case.file_traits(reader.index).genre, reader.traits.genre, "the kind of book is in the file")
	assert_eq(reader.prompt_key(cop), "PROMPT_READER_CAP")
	reader.use(cop)
	assert_false(reader.part("nightcap").visible, "the nightcap comes off")
	assert_eq(case.file_traits(reader.index).hair, reader.traits.hair)
	assert_eq(reader.prompt_key(cop), "PROMPT_READER_TALK", "then they whisper again")


func test_the_stubborn_reader_keeps_the_nightcap_until_they_eat() -> void:
	var made := _library_case(6)
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var stubborn := library.readers.filter(func(r: LibraryReader) -> bool: return r.stubborn)
	assert_eq(stubborn.size(), 1, "one stubborn reader")
	var reader: LibraryReader = stubborn[0]
	reader.use(cop)
	reader.use(cop)
	assert_eq(reader.said(), "READER_CAP_NO")
	assert_true(reader.cap_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	reader.feed(bread)
	assert_true(reader.part("teeth").visible, "they show their teeth biting")
	assert_false(reader.cap_on, "fed, they take it off")
	assert_true(case.file_parts[reader.index].teeth and case.file_parts[reader.index].hair)


func test_the_flashlight_shows_the_gold_dust() -> void:
	var made := _library_case(9)
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	assert_false(library.readers[0].hands_lit(), "no flashlight on, no light")
	for reader in library.readers:
		assert_false(reader.part("dust_left").visible, "the dust doesn't show without the light")
		reader.light_hands(true)
		assert_eq(reader.part("dust_left").visible, reader.traits.dust)
		assert_eq(reader.part("dust_right").visible, reader.traits.dust)
		assert_eq(reader.said(), "READER_DUST_SHINES" if reader.traits.dust else "READER_CLEAN_HANDS")
		assert_eq(case.file_traits(reader.index).dust, reader.traits.dust, "lit, the hands go to the file")
		reader.light_hands(false)
		assert_false(reader.part("dust_left").visible, "the light off, the dust hides again")


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _library_case(8)
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var reader := library.readers[2]
	assert_false(case.file_parts.has(2), "no file yet")
	reader.photographed(cop)
	assert_eq(reader.said(), "READER_NO_FLASH")
	var text := case.file_text(2)
	assert_string_contains(text, reader.traits.name)
	assert_string_contains(text, tr("FILE_SLIPPER") % reader.traits.shoe, "the photo shows the slippers")
	assert_string_contains(text, tr("FILE_DUST_UNKNOWN"))
	assert_eq(reader.dusted(cop), tr("PRINTS_COOK") % reader.traits.name)
	var bread := Bread.new()
	add_child_autofree(bread)
	reader.feed(bread)
	reader.stubborn = false
	reader.use(cop)
	reader.use(cop)
	reader.light_hands(true)
	assert_true(case.files.has(2), "photo, prints, teeth, hair, dust and book: done")
	text = case.file_text(2)
	assert_string_contains(text, tr("FILE_GENRE") % reader.genre_name())
	assert_string_contains(text, tr("FILE_DUST") if reader.traits.dust else tr("FILE_NO_DUST"))
	for key in ["PROMPT_READER_CAP", "READER_CAP_NO", "FILE_DUST", "FILE_GENRE", "READER_NO_FLASH"]:
		assert_ne(tr(key), key, "%s is translated" % key)
