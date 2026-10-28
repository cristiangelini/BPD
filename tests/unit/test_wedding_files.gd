extends GutTest

## The tuxedos' files (escena-boda.md, step 3): TuxedoGuest's sniff, top hat, bite, photo and prints, each into his
## file through CrimeSceneCase.guard_part with the wedding's parts, and what the card on the board says.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A wedding hall with its case set up, and a cop at hand.
func _wedding_case(seed_value: int) -> Array:
	var hall := WeddingHall.new()
	hall.case_seed = seed_value
	add_child_autofree(hall)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hall
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [hall, case, cop]


func test_the_case_draws_the_tuxedos_and_four_clues_leave_one() -> void:
	for seed_value in range(1, 20):
		var suspects := WeddingTraits.draw(seed_value)
		var plan := CrimePlan.draw(suspects, seed_value, CrimeSceneCase.VARIANTS.wedding.clues)
		assert_eq(CrimePlan.suspects_left(suspects, suspects[plan.culprit], plan.clues, plan.traits).size(), 1,
			"seed %d: the 4 clues leave only him" % seed_value)
	var made := _wedding_case(5)
	var case: CrimeSceneCase = made[1]
	assert_eq(case.cooks, WeddingTraits.draw(5), "the case's suspects are the hall's tuxedos")
	assert_eq(case.texts().parts, ["photo", "prints", "teeth", "hair", "cologne"])


func test_empty_hands_get_the_cologne_then_the_top_hat() -> void:
	var made := _wedding_case(4)
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var tuxedo: TuxedoGuest = hall.tuxedos.filter(func(t: TuxedoGuest) -> bool: return not t.stubborn)[0]
	assert_eq(hall.suspect(tuxedo.index), tuxedo)
	assert_eq(tuxedo.prompt_key(cop), "PROMPT_TUXEDO_SNIFF")
	tuxedo.use(cop)
	assert_string_contains(tuxedo.said(), tr("COLOGNE_" + str(tuxedo.traits.cologne)))
	assert_true(case.file_parts[tuxedo.index].cologne, "the cologne is in his file")
	assert_eq(case.file_traits(tuxedo.index).cologne, tuxedo.traits.cologne)
	assert_eq(tuxedo.prompt_key(cop), "PROMPT_TUXEDO_HAT")
	tuxedo.use(cop)
	assert_false(tuxedo.part("hat").visible, "the top hat comes off")
	assert_eq(case.file_traits(tuxedo.index).hair, tuxedo.traits.hair)
	assert_eq(tuxedo.prompt_key(cop), "PROMPT_WEDDING_TALK", "then his lines")
	tuxedo.use(cop)
	assert_string_contains(tuxedo.said(), "WEDDING_GROOM" if tuxedo.index == 0 else "WEDDING_GROOMSMAN")


func test_the_stubborn_one_keeps_the_hat_until_he_eats() -> void:
	var made := _wedding_case(6)
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var stubborn := hall.tuxedos.filter(func(t: TuxedoGuest) -> bool: return t.stubborn)
	assert_eq(stubborn.size(), 1, "one stubborn tuxedo")
	var tuxedo: TuxedoGuest = stubborn[0]
	tuxedo.use(cop)
	tuxedo.use(cop)
	assert_eq(tuxedo.said(), "TUXEDO_HAT_NO")
	assert_true(tuxedo.hat_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	tuxedo.feed(bread)
	assert_false(tuxedo.hat_on, "fed, he takes it off")
	assert_true(case.file_parts[tuxedo.index].teeth and case.file_parts[tuxedo.index].hair)


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _wedding_case(8)
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var tuxedo := hall.tuxedos[2]
	assert_false(case.file_parts.has(2), "no file yet")
	tuxedo.photographed(cop)
	assert_eq(tuxedo.said(), "TUXEDO_PHOTO")
	var text := case.file_text(2)
	assert_string_contains(text, tuxedo.traits.name)
	assert_string_contains(text, tr("FILE_SHOE") % tuxedo.traits.shoe, "the photo shows his shoes")
	assert_string_contains(text, tr("FILE_COLOGNE") % "?")
	assert_eq(tuxedo.dusted(cop), tr("PRINTS_COOK") % tuxedo.traits.name)
	var bread := Bread.new()
	add_child_autofree(bread)
	tuxedo.feed(bread)
	tuxedo.stubborn = false
	tuxedo.use(cop)
	tuxedo.use(cop)
	assert_true(case.files.has(2), "photo, prints, teeth, hair and cologne: done")
	text = case.file_text(2)
	assert_string_contains(text, tr("FILE_COLOGNE") % tr("COLOGNE_" + str(tuxedo.traits.cologne)))
	assert_string_contains(text, tr("FILE_HAIR") % tr("HAIR_" + str(tuxedo.traits.hair)))
