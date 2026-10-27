extends GutTest

## The library's people (escena-biblioteca.md, step 2): the six readers alike in pajamas, Doña Sigilo and Tomasito
## (ReaderTraits, LibraryReader, Librarian, LibraryKid).


func test_the_six_readers_are_drawn_with_the_seed() -> void:
	var readers := ReaderTraits.draw(11)
	assert_eq(readers.size(), ReaderTraits.COUNT)
	assert_eq(ReaderTraits.draw(11), readers, "same seed, same readers")
	var looks := {}
	var genres := {}
	var dusted := 0
	for reader in readers:
		looks[ReaderTraits.signature(reader)] = true
		genres[reader.genre] = true
		dusted += 1 if reader.dust else 0
	assert_eq(looks.size(), ReaderTraits.COUNT, "no two look the same")
	assert_eq(genres.size(), ReaderTraits.GENRES.size(), "each reads another kind of book")
	assert_between(dusted, ReaderTraits.DUSTED.x, ReaderTraits.DUSTED.y, "two or three have gold dust")


func test_the_people_are_in_their_rooms() -> void:
	var library := Library.new()
	library.case_seed = 4
	add_child_autofree(library)
	assert_eq(library.readers.size(), ReaderTraits.COUNT)
	for reader in library.readers:
		assert_eq(library.room(reader.global_position), "reading", "%s reads in the reading room" % reader.traits.name)
	assert_eq(library.suspect(2), library.readers[2])
	assert_null(library.suspect(ReaderTraits.COUNT))
	assert_eq(library.room(library.librarian.global_position), "reading", "Doña Sigilo at her desk")
	assert_eq(library.room(library.kid.global_position), "children", "Tomasito asleep in the children's corner")


func test_a_reader_shows_their_own_traits() -> void:
	var library := Library.new()
	library.case_seed = 9
	add_child_autofree(library)
	for reader in library.readers:
		assert_eq(reader.part("glasses").visible, reader.traits.glasses)
		assert_false(reader.part("teeth").visible, "teeth only when they bite")
		assert_false(reader.part("dust_left").visible, "the dust only under the flashlight")
		assert_true(reader.part("nightcap").visible)


func test_a_reader_whispers_what_they_read() -> void:
	var library := Library.new()
	library.case_seed = 2
	add_child_autofree(library)
	var reader: LibraryReader = library.readers[0]
	reader.talk()
	assert_string_contains(reader.said(), reader.genre_name())
	reader.talk()
	assert_string_contains(reader.said(), reader.genre_name(), "every line says the kind of book")
	library.librarian.use(null)
	assert_eq(library.librarian.said(), "LIBRARIAN_LINE_0")
	library.kid.use(null)
	assert_eq(library.kid.said(), "KID_MUMBLE_0")
