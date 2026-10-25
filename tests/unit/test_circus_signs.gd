extends GutTest

## The numbered signs on the clowns' backs (escena-circo.md, step 5a; ClownSign, Circus.stick_sign, the circus files
## in CrimeSceneCase).


func _case(seed_value := 7) -> CrimeSceneCase:
	var circus := Circus.new()
	circus.case_seed = seed_value
	add_child_autofree(circus)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = circus
	add_child_autofree(case)
	case.start()
	return case


func test_six_signs_wait_on_the_pad() -> void:
	var circus := Circus.new()
	add_child_autofree(circus)
	var signs := circus.find_children("Sign*", "ClownSign", false, false)
	assert_eq(signs.size(), ClownTraits.COUNT)
	var numbers := signs.map(func(sign: ClownSign) -> int: return sign.number)
	numbers.sort()
	assert_eq(numbers, range(ClownTraits.COUNT))


func test_without_a_sign_nothing_goes_to_a_file() -> void:
	var case := _case()
	var clown: CircusClown = (case.place as Circus).clowns[0]
	clown.honk()
	assert_true(case.file_parts.is_empty(), "no sign, no file")


func test_a_file_follows_its_sign() -> void:
	var case := _case()
	var circus := case.place as Circus
	var clown: CircusClown = circus.clowns[2]
	circus.stick_sign(0, clown)
	assert_true(clown.has_sign())
	assert_eq(circus.sign_of(2), 0)
	assert_eq(circus.wearer(0), 2)
	clown.honk()
	assert_true(case.file_parts[0].honk)
	assert_eq(case.file_traits(0).honk, clown.traits.honk)
	assert_eq(case.accused_index(0), 2, "accusing sign 1 points at him")


func test_what_shows_goes_to_the_file_when_the_sign_goes_on() -> void:
	var case := _case()
	var circus := case.place as Circus
	var clown: CircusClown = circus.clowns[1]
	clown.stubborn = false
	clown.ask_wig()
	clown.pull_shoe()
	circus.stick_sign(3, clown)
	assert_eq(case.file_traits(3).hair, clown.traits.hair, "his own hair is in sight")
	assert_eq(case.file_traits(3).shoe, clown.traits.shoe, "and his real foot")


func test_a_sign_moved_to_another_clown_mixes_the_file() -> void:
	var case := _case(9)
	var circus := case.place as Circus
	var first: CircusClown = circus.clowns[0]
	var second: CircusClown = circus.clowns[1]
	circus.stick_sign(5, first)
	first.honk()
	circus.drop_sign(first)
	assert_false(first.has_sign())
	assert_eq(circus.wearer(5), 0, "the last one who wore it")
	var dropped := circus.find_children("Sign*", "ClownSign", false, false).filter(
		func(sign: ClownSign) -> bool: return sign.number == 5)
	assert_eq(dropped.size(), 1, "the sign lies at his feet")
	circus.stick_sign(5, second)
	second.stubborn = false
	second.ask_wig()
	assert_eq(case.file_traits(5).honk, first.traits.honk, "the honk is still the first one's")
	assert_eq(case.file_traits(5).hair, second.traits.hair, "the hair is the second one's")
	assert_eq(case.accused_index(5), 1, "and the accusation points at whoever wears it now")


func test_the_board_cant_tie_a_clue_the_file_doesnt_know() -> void:
	var case := _case()
	var board := CrimeBoard.new()
	board.case = case
	add_child_autofree(board)
	case.board = board
	var circus := case.place as Circus
	circus.stick_sign(0, circus.clowns[0])
	var kind: String = case.plan.clues[0]
	board.clue_cards[kind] = BoardCard.new()
	assert_false(board.tie(kind, 0), "nothing to compare yet")
	board.clue_cards[kind].free()
