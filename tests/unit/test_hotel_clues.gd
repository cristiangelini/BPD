extends GutTest

## The hotel's clues in the suite (escena-hotel.md, step 4b): the safe's prints, the footprint on the bathroom mat, the
## hair and the bonbon on the pillow, doña Escoba's round and the "No molestar" card.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A seed whose case has all these clues.
func _seed_with(kinds: Array) -> int:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(GuestTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.hotel.clues)
		if kinds.all(func(kind: String) -> bool: return plan.clues.has(kind)):
			return seed_value
	return -1


func _hotel_case(kinds: Array) -> Array:
	var seed_value := _seed_with(kinds)
	assert_gt(seed_value, 0, "a seed with %s" % [kinds])
	var hotel := Hotel.new()
	hotel.case_seed = seed_value
	add_child_autofree(hotel)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hotel
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [hotel, case, cop]


## Doña Escoba's whole round, in steps of a tenth of a second.
func _walk_round(clues: HotelClues) -> void:
	clues.maid_walking = true
	for i in 3000:
		clues.walk_maid(0.1)
		if clues.suite_cleaned and clues._step == 0:
			return


func test_the_safe_keeps_the_prints_unless_a_cop_touches_it() -> void:
	var made := _hotel_case(["prints"])
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	var safe := hotel.clues.safe
	assert_eq(safe.prompt_key(made[2]), "PROMPT_EMPTY_SAFE")
	assert_eq(safe.dusted(made[2]), "PRINTS_SAFE")
	assert_has(case.clues_found, "prints")
	made = _hotel_case(["prints"])
	safe = (made[0] as Hotel).clues.safe
	safe.use(made[2])
	assert_eq(safe.dusted(made[2]), "PRINTS_SAFE_SMUDGED")
	assert_has((made[1] as CrimeSceneCase).ruined, "prints")


func test_the_maid_cleans_the_suite_and_the_hair_and_the_footprint_go() -> void:
	var made := _hotel_case(["hair", "footprint"])
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	assert_eq(case.items.hair.look, "hotel")
	assert_not_null(hotel.clues.footprint)
	_walk_round(hotel.clues)
	assert_true(hotel.clues.suite_cleaned)
	assert_has(case.ruined, "hair")
	assert_has(case.ruined, "footprint")
	assert_true(hotel.maid.position.distance_to(Hotel.MAID_AT) < 0.01, "and she goes back down the corridor")


func test_no_molestar_keeps_her_out() -> void:
	var made := _hotel_case(["hair", "footprint"])
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	hotel.clues.hanger.use(made[2])
	assert_true(hotel.clues.hanger.hung)
	assert_eq(hotel.clues.hanger.prompt_key(made[2]), "PROMPT_DND_TAKE")
	hotel.clues.maid_walking = true
	for i in 600:
		hotel.clues.walk_maid(0.1)
	assert_false(hotel.clues.suite_cleaned)
	assert_eq(case.ruined, [] as Array[String])
	assert_true(hotel.maid.position.x > Hotel.SUITE_X, "she never went in")


func test_the_bonbon_eaten_and_the_clue_lines() -> void:
	TranslationServer.set_locale("es")
	var made := _hotel_case(["bite"])
	var case: CrimeSceneCase = made[1]
	var bonbon: CrimeClueItem = case.items.bite
	assert_true(bonbon.is_food())
	bonbon.eat(made[2])
	assert_has(case.ruined, "bite")
	for kind: String in CrimeSceneCase.VARIANTS.hotel.clues:
		var line := case.clue_line(kind)
		assert_false(line.begins_with("CLUE_"), "%s has its line: %s" % [kind, line])
		assert_ne(tr("CLUE_HOTEL_RUINED_" + kind), "CLUE_HOTEL_RUINED_" + kind)
		assert_ne(tr("HINT_HOTEL_RUINED_" + kind), "HINT_HOTEL_RUINED_" + kind)
