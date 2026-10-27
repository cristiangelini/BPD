extends GutTest

## The mansion case's clues (escena-mansion.md, step 5b; MansionClues): the prints on the safe, the footprint in a
## passage, the hair on the armour, the bitten chocolate, the bells and Lorenzo, and how each one is ruined.


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


## A mansion and its case where this clue is (or isn't) one of the four.
func _with(kind: String, has_it := true) -> Array:
	for seed_value in range(1, 60):
		if (CrimePlan.draw(MemberTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.mansion.clues).clues
				.has(kind)) == has_it:
			return _mansion_case(seed_value)
	fail_test("no seed for " + kind)
	return []


func test_each_clue_is_where_it_goes_only_when_it_is_one_of_the_four() -> void:
	for seed_value in [1, 2, 3, 4, 5]:
		var made := _mansion_case(seed_value)
		var mansion: Mansion = made[0]
		var case: CrimeSceneCase = made[1]
		var clues := case.plan.clues
		assert_eq(mansion.clues.safe.has_prints, clues.has("prints"))
		assert_eq(mansion.room_at(mansion.clues.safe.global_position), "study")
		assert_eq(case.items.has("hair"), clues.has("hair"))
		assert_eq(case.items.has("bite"), clues.has("bite"))
		assert_eq(case.flour_print != null, clues.has("footprint"))
		assert_eq(mansion.butler.knows, clues.has("bells"))
		assert_eq(mansion.parrot.knows, clues.has("witness"))
		for room: String in Mansion.BELL_ROOMS:
			assert_eq(mansion.room_at(mansion.clues.cords[room].global_position), room, "a cord in " + room)


func test_the_prints_on_the_safe_and_the_cop_who_touches_it_first() -> void:
	var made := _with("prints")
	var case: CrimeSceneCase = made[1]
	var safe: SafeDoor = made[0].clues.safe
	assert_eq(safe.dusted(null), "PRINTS_SAFE")
	assert_has(case.clues_found, "prints")
	made = _with("prints")
	case = made[1]
	safe = made[0].clues.safe
	var cop: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	add_child_autofree(cop)
	safe.use(cop)
	assert_has(case.ruined, "prints")
	assert_eq(safe.dusted(null), "PRINTS_SAFE_SMUDGED")


func test_the_footprint_is_in_a_passage_where_the_cops_walk() -> void:
	var made := _with("footprint")
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var footprint := case.flour_print
	assert_ne(mansion.clues.footprint_in, "")
	assert_eq(mansion.passage_at(footprint.global_position), mansion.clues.footprint_in)
	assert_eq(footprint.shoe, case.culprit().shoe)
	assert_false(footprint.photo_clues().is_empty(), "a photo can catch it")
	footprint.wipe()
	assert_has(case.ruined, "footprint", "stepped on")


func test_pushing_the_armour_over_loses_the_hair_on_it() -> void:
	var made := _with("hair")
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var hair: CrimeClueItem = case.items.hair
	assert_eq(mansion.room_at(hair.global_position), "hall")
	assert_eq(mansion.armour.prompt_key(null), "PROMPT_ARMOUR")
	mansion.armour.use(null)
	assert_true(mansion.armour.fallen)
	assert_true(hair.spoiled)
	assert_has(case.ruined, "hair")
	await wait_seconds(MansionArmour.FALL_SECONDS + 0.2)
	assert_almost_eq(mansion.armour.rotation.x, PI / 2, 0.01, "face down on the floor")


func test_a_hair_already_taken_is_safe_from_the_armour() -> void:
	var made := _with("hair")
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var hair: CrimeClueItem = case.items.hair
	hair.global_position += Vector3(3, 0, 0)
	mansion.armour.push_over()
	assert_false(hair.spoiled)
	assert_does_not_have(case.ruined, "hair")


func test_the_bitten_chocolate_is_on_the_dining_table() -> void:
	var made := _with("bite")
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var bite: CrimeClueItem = case.items.bite
	assert_eq(mansion.room_at(bite.global_position), "dining")
	assert_true(bite.is_food())
	var cop: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	add_child_autofree(cop)
	bite.eat(cop)
	assert_has(case.ruined, "bite")


func test_ceferino_confesses_and_then_tells_the_bell() -> void:
	TranslationServer.set_locale("es")
	var made := _with("bells")
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var butler := mansion.butler
	assert_eq(butler.prompt_key(null), "PROMPT_MANSION_BUTLER")
	butler.use(null)
	assert_string_starts_with(butler.said(), "BUTLER_LINE_", "first, it was him")
	assert_eq(butler.prompt_key(null), "PROMPT_BUTLER_BELLS")
	butler.use(null)
	assert_has(case.clues_found, "bells")
	assert_string_contains(butler.said(), tr("MANSION_ROOM_" + case.culprit().room))


func test_pulling_a_cord_mixes_up_the_bells() -> void:
	var made := _with("bells")
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	mansion.clues.cords.lounge.use(null)
	assert_has(case.ruined, "bells")
	mansion.butler.use(null)
	mansion.butler.use(null)
	assert_eq(mansion.butler.said(), "BUTLER_BELLS_MIXED")
	assert_does_not_have(case.clues_found, "bells")


func test_without_the_bells_clue_they_all_rang() -> void:
	var made := _with("bells", false)
	var butler: MansionButler = made[0].butler
	butler.use(null)
	butler.use(null)
	assert_eq(butler.said(), "BUTLER_BELLS_ALL")


func test_lorenzo_tells_for_a_chocolate_and_a_shout_offends_him() -> void:
	var made := _with("witness")
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var parrot := mansion.parrot
	parrot.feed(mansion.chocolates)
	assert_has(case.clues_found, "witness")
	assert_eq(parrot.said(), "PARROT_SAW_GLASSES" if case.culprit().glasses else "PARROT_SAW_NO_GLASSES")
	made = _with("witness")
	mansion = made[0]
	case = made[1]
	var cop: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	add_child_autofree(cop)
	cop.global_position = mansion.parrot.global_position + Vector3(2, 0, 0)
	case.shouted_by(cop)
	assert_true(mansion.witness_offended())
	assert_has(case.ruined, "witness")
	assert_string_starts_with(mansion.parrot.said(), "PARROT_INSULT_")
	mansion.parrot.feed(mansion.chocolates)
	assert_does_not_have(case.clues_found, "witness", "he won't tell now")


func test_every_new_text_is_translated() -> void:
	var keys := ["PROMPT_SAFE", "HINT_SAFE_TOUCHED", "HINT_SAFE_EMPTY", "PRINTS_SAFE", "PRINTS_SAFE_SMUDGED",
		"PROMPT_ARMOUR", "PROMPT_ARMOUR_FALLEN", "HINT_ARMOUR_CRASH", "PROMPT_BELL_CORD", "HINT_BELL_RANG",
		"PROMPT_BUTLER_BELLS", "BUTLER_BELLS", "BUTLER_BELLS_ALL", "BUTLER_BELLS_MIXED", "PROMPT_PARROT_FEED",
		"PARROT_SAW_GLASSES", "PARROT_SAW_NO_GLASSES", "PARROT_SAW_NOTHING", "HINT_CLUE_EATEN_bite_mansion"]
	for i in MansionParrot.INSULTS:
		keys.append("PARROT_INSULT_%d" % i)
	for locale in ["es", "en", "pt"]:
		var translation := TranslationServer.get_translation_object(locale)
		for key: String in keys:
			assert_ne(String(translation.get_message(key)), "", "%s in %s" % [key, locale])
