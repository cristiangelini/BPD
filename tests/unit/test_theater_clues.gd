extends GutTest

## The theater's clues (escena-teatro.md, step 6): the prints on the mask's case and the usher's rag, the talc
## footprint that the first scene change shows and the next sweeps away, the wig's hair on a trapdoor, the bonbon in
## the box and the lady who wakes up, the scrap of sheet with the embroidery and the deep voice (TheaterClues).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _theater_case(seed_value: int) -> Array:
	var theater := Theater.new()
	theater.case_seed = seed_value
	add_child_autofree(theater)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = theater
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [theater, case, cop]


## The first case (from seed 1 up) whose clues have all of `kinds`.
func _with(kinds: Array[String]) -> Array:
	for seed_value in range(1, 200):
		var made := _theater_case(seed_value)
		var case: CrimeSceneCase = made[1]
		if kinds.all(func(kind: String) -> bool: return case.plan.clues.has(kind)):
			return made
	fail_test("no seed with %s" % [kinds])
	return []


func test_the_prints_on_the_case_until_the_usher_wipes_it() -> void:
	var made := _with(["prints"])
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var glass := theater.clues.case_glass
	assert_eq(glass.prompt_key(made[2]), "PROMPT_EMPTY_MASKCASE")
	assert_eq(glass.dusted(made[2]), "PRINTS_MASKCASE")
	assert_has(case.clues_found, "prints")
	made = _with(["prints"])
	theater = made[0]
	case = made[1]
	theater.clues.polish()
	assert_has(case.ruined, "prints", "the usher wiped the glass")
	assert_eq(theater.clues.case_glass.dusted(made[2]), "")


func test_the_talc_footprint_shows_with_the_first_turn_and_goes_with_the_next() -> void:
	var made := _with(["footprint"])
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var footprint := theater.clues.footprint
	assert_false(footprint.visible, "out of sight before the stage turns")
	assert_eq(footprint.photo_clues(), {})
	assert_eq(theater.room(footprint.global_position + Vector3.UP * 0.1), "stage")
	theater.performance.start_change()
	assert_true(footprint.visible, "the first turn shows it")
	assert_eq(footprint.photo_clues().keys(), [case.clue_line("footprint")])
	assert_string_contains(case.clue_line("footprint"), str(case.culprit().shoe))
	theater.performance.end_change()
	theater.performance.start_change()
	assert_false(footprint.visible, "the next change sweeps it away")
	assert_has(case.ruined, "footprint")


func test_the_wig_on_the_trapdoor_drops_the_hair_unless_bagged() -> void:
	var made := _with(["hair"])
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var hair := theater.clues.hair
	var trap := Theater.TRAPDOORS[TheaterClues.WIG_TRAPDOOR]
	assert_lt(Vector2(theater.to_local(hair.global_position).x, theater.to_local(hair.global_position).z)
		.distance_to(Vector2(trap.x, trap.z)), Theater.TRAPDOOR_SIZE / 2, "the hair lies on the trapdoor")
	assert_almost_eq(theater.clues.wig.position.y, trap.y + 0.08, 0.001, "by the wig")
	theater.performance.start_change()
	assert_has(case.ruined, "hair", "it dropped to the basement")
	assert_false(hair.visible)
	made = _with(["hair"])
	theater = made[0]
	case = made[1]
	theater.clues.hair.bag(made[2])
	theater.performance.start_change()
	assert_does_not_have(case.ruined, "hair", "bagged, it's safe")
	assert_has(case.clues_found, "hair")


func test_the_bonbon_turns_up_in_the_box_until_the_lady_wakes_up() -> void:
	var made := _with(["bite"])
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var bonbon := theater.clues.bonbon
	assert_false(bonbon.visible, "hidden in the box")
	assert_eq((theater.loot_spots["box"] as TheaterSpot).prompt_key(made[2]), "PROMPT_THEATER_SEARCH_box")
	assert_eq(theater.room(theater.loot_spots["box"].global_position), "hall", "the box is up in the hall")
	theater.searched("box", made[2])
	assert_true(bonbon.visible, "searching the box finds it")
	assert_eq(case.items["bite"], bonbon)
	theater.clues.box_lady_wakes()
	assert_has(case.ruined, "bite", "the lady in the box ate it")
	assert_false(bonbon.visible)


func test_the_scrap_of_sheet_and_the_deep_voice() -> void:
	TranslationServer.set_locale("es")
	var made := _with(["sheet", "voice"])
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var scrap := theater.clues.scrap
	assert_eq(scrap.prompt_key(cop), "PROMPT_SHEET_SCRAP")
	assert_eq(theater.room(scrap.global_position), "foyer", "on the mask's case")
	scrap.use(cop)
	assert_has(case.clues_found, "sheet")
	var embroidery := tr("EMBROIDERY_" + str(case.culprit().embroidery))
	assert_string_contains(cop._hint.text, embroidery)
	assert_string_contains(case.clue_line("sheet"), embroidery)
	for ghost in theater.ghosts:
		if not ghost.traits.deep:
			ghost.sing()
	assert_does_not_have(case.clues_found, "voice", "a high voice tells nothing")
	theater.ghosts[case.plan.culprit].sing()
	assert_has(case.clues_found, "voice", "the deep one does")
	assert_eq(theater.room(theater.bags.global_position), "foyer", "the evidence bags wait in the foyer")
	for kind: String in ["prints", "footprint", "hair", "bite", "voice", "sheet", "witness"]:
		assert_ne(case.clue_line(kind), "CLUE_THEATER_" + kind, "%s has its line" % kind)
		assert_ne(tr("CLUE_THEATER_RUINED_" + kind), "CLUE_THEATER_RUINED_" + kind)
		assert_ne(tr("HINT_THEATER_RUINED_" + kind), "HINT_THEATER_RUINED_" + kind)
