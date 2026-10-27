extends GutTest

## The divers' files (escena-acuario.md, step 3): the culprit's octopus ink (DiverTraits), AquariumDiver's parts and
## the glove, and CrimeSceneCase's aquarium variant (guard_part, file_text).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_always_has_ink() -> void:
	for seed_value in range(1, 30):
		var divers := DiverTraits.draw(seed_value)
		var plan := CrimePlan.draw(divers, seed_value, CrimeSceneCase.VARIANTS.aquarium.clues)
		assert_eq(plan.culprit, CrimePlan.culprit_of(DiverTraits.COUNT, seed_value))
		assert_true(divers[plan.culprit].ink, "seed %d: Doña Tinta inked the culprit" % seed_value)
		var inked := divers.filter(func(d: Dictionary) -> bool: return d.ink).size()
		assert_between(inked, DiverTraits.INKED.x, DiverTraits.INKED.y)
		assert_eq(CrimePlan.suspects_left(divers, divers[plan.culprit], plan.clues, plan.traits).size(), 1,
			"the clues leave only them")


## An aquarium with its case set up, and a cop at hand.
func _aquarium_case(seed_value: int) -> Array:
	var aquarium := Aquarium.new()
	aquarium.case_seed = seed_value
	add_child_autofree(aquarium)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = aquarium
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [aquarium, case, cop]


func test_empty_hands_get_the_tank_the_hood_then_the_glove() -> void:
	var made := _aquarium_case(4)
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.cooks, DiverTraits.draw(4), "the case's suspects are the divers")
	var diver: AquariumDiver
	for d in aquarium.divers:
		if not d.stubborn:
			diver = d
	assert_eq(diver.prompt_key(cop), "PROMPT_DIVER_TALK")
	diver.use(cop)
	assert_string_contains(diver.said(), diver.tank_name())
	assert_eq(case.file_traits(diver.index).tank, diver.traits.tank, "the tank is in the file")
	assert_eq(diver.prompt_key(cop), "PROMPT_DIVER_HOOD")
	diver.use(cop)
	assert_false(diver.part("hood").visible, "the hood comes off")
	assert_eq(case.file_traits(diver.index).hair, diver.traits.hair)
	assert_eq(diver.prompt_key(cop), "PROMPT_DIVER_GLOVE")
	diver.use(cop)
	assert_false(diver.part("glove_right").visible, "the glove comes off")
	assert_eq(diver.part("ink_right").visible, diver.traits.ink, "and the ink shows, if they have it")
	assert_false(diver.part("ink_left").visible, "the other glove stays on")
	assert_eq(diver.said(), "DIVER_INK" if diver.traits.ink else "DIVER_CLEAN_HAND")
	assert_eq(case.file_traits(diver.index).ink, diver.traits.ink)
	assert_eq(diver.prompt_key(cop), "PROMPT_DIVER_TALK", "then they talk about their tank again")


func test_the_stubborn_diver_keeps_the_hood_until_they_eat() -> void:
	var made := _aquarium_case(6)
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var stubborn := aquarium.divers.filter(func(d: AquariumDiver) -> bool: return d.stubborn)
	assert_eq(stubborn.size(), 1, "one stubborn diver")
	var diver: AquariumDiver = stubborn[0]
	diver.use(cop)
	diver.use(cop)
	assert_eq(diver.said(), "DIVER_HOOD_NO")
	assert_true(diver.hood_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	diver.feed(bread)
	assert_true(diver.part("teeth").visible, "they show their teeth biting")
	assert_false(diver.hood_on, "fed, they take it off")
	assert_true(case.file_parts[diver.index].teeth and case.file_parts[diver.index].hair)


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _aquarium_case(8)
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var diver := aquarium.divers[2]
	assert_false(case.file_parts.has(2), "no file yet")
	diver.photographed(cop)
	assert_eq(diver.said(), "DIVER_NO_FLASH")
	var text := case.file_text(2)
	assert_string_contains(text, diver.traits.name)
	assert_string_contains(text, tr("FILE_FLIPPER") % diver.traits.shoe, "the photo shows the flippers")
	assert_string_contains(text, tr("FILE_LENSES") if diver.traits.glasses else tr("FILE_NO_LENSES"))
	assert_string_contains(text, tr("FILE_INK_UNKNOWN"))
	assert_eq(diver.dusted(cop), tr("PRINTS_COOK") % diver.traits.name)
	var bread := Bread.new()
	add_child_autofree(bread)
	diver.feed(bread)
	diver.stubborn = false
	diver.use(cop)
	diver.use(cop)
	diver.use(cop)
	assert_true(case.files.has(2), "photo, prints, teeth, hair, ink and tank: done")
	text = case.file_text(2)
	assert_string_contains(text, tr("FILE_TANK") % diver.tank_name())
	assert_string_contains(text, tr("FILE_INK") if diver.traits.ink else tr("FILE_NO_INK"))
	for key in ["PROMPT_DIVER_GLOVE", "DIVER_HOOD_NO", "FILE_INK", "FILE_TANK", "BRIEF_AQUARIUM_A", "HINT_DIVER_LEFT"]:
		assert_ne(tr(key), key, "%s is translated" % key)
