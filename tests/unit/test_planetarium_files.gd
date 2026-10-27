extends GutTest

## The guides' files (escena-planetario.md, step 3): the culprit's glow paint (GuideTraits), PlanetariumGuide's parts,
## the helmet and the gloves in the dark, and CrimeSceneCase's planetarium variant (guard_part, file_text).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_always_glows() -> void:
	for seed_value in range(1, 30):
		var guides := GuideTraits.draw(seed_value)
		var plan := CrimePlan.draw(guides, seed_value, CrimeSceneCase.VARIANTS.planetarium.clues)
		assert_eq(plan.culprit, CrimePlan.culprit_of(GuideTraits.COUNT, seed_value))
		assert_true(guides[plan.culprit].glow, "seed %d: the culprit touched the fresh stars" % seed_value)
		var glowing := guides.filter(func(g: Dictionary) -> bool: return g.glow).size()
		assert_between(glowing, GuideTraits.GLOWING.x, GuideTraits.GLOWING.y)
		assert_eq(CrimePlan.suspects_left(guides, guides[plan.culprit], plan.clues, plan.traits).size(), 1,
			"the clues leave only them")


## A planetarium with its case set up, and a cop at hand.
func _planetarium_case(seed_value: int) -> Array:
	var planetarium := Planetarium.new()
	planetarium.case_seed = seed_value
	add_child_autofree(planetarium)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = planetarium
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [planetarium, case, cop]


func test_empty_hands_get_the_planet_then_the_helmet() -> void:
	var made := _planetarium_case(4)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.cooks, GuideTraits.draw(4), "the case's suspects are the guides")
	var guide: PlanetariumGuide
	for g in planetarium.guides:
		if not g.stubborn:
			guide = g
	assert_eq(guide.prompt_key(cop), "PROMPT_GUIDE_TALK")
	guide.use(cop)
	assert_string_contains(guide.said(), guide.planet_name())
	assert_eq(case.file_traits(guide.index).planet, guide.traits.planet, "the planet is in the file")
	assert_eq(guide.prompt_key(cop), "PROMPT_GUIDE_HELMET")
	guide.use(cop)
	assert_false(guide.part("helmet").visible, "the helmet comes off")
	assert_eq(case.file_traits(guide.index).hair, guide.traits.hair)
	assert_eq(guide.prompt_key(cop), "PROMPT_GUIDE_TALK", "then they talk about their planet again")


func test_the_glow_shows_only_in_the_dark() -> void:
	var made := _planetarium_case(5)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	for guide in planetarium.guides:
		assert_false(guide.part("glow_left").visible or guide.part("glow_right").visible, "lights on: nothing glows")
	planetarium.set_dark(true)
	for guide in planetarium.guides:
		assert_eq(guide.part("glow_left").visible, guide.traits.glow, "%s in the dark" % guide.traits.name)
		assert_eq(guide.part("glow_right").visible, guide.traits.glow)
		assert_eq(guide.prompt_key(cop), "PROMPT_GUIDE_GLOVES")
		guide.use(cop)
		assert_eq(guide.said(), "GUIDE_GLOW" if guide.traits.glow else "GUIDE_NO_GLOW")
		assert_eq(case.file_traits(guide.index).glow, guide.traits.glow, "the gloves are in the file")
	planetarium.set_dark(false)
	assert_false(planetarium.guides[case.plan.culprit].part("glow_left").visible, "lights back on: it fades")


func test_the_stubborn_guide_keeps_the_helmet_until_they_eat() -> void:
	var made := _planetarium_case(6)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var stubborn := planetarium.guides.filter(func(g: PlanetariumGuide) -> bool: return g.stubborn)
	assert_eq(stubborn.size(), 1, "one stubborn guide")
	var guide: PlanetariumGuide = stubborn[0]
	guide.use(cop)
	guide.use(cop)
	assert_eq(guide.said(), "GUIDE_HELMET_NO")
	assert_true(guide.helmet_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	guide.feed(bread)
	assert_true(guide.part("teeth").visible, "they show their teeth biting")
	assert_false(guide.helmet_on, "fed, they take it off")
	assert_true(case.file_parts[guide.index].teeth and case.file_parts[guide.index].hair)


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _planetarium_case(8)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var guide := planetarium.guides[2]
	assert_false(case.file_parts.has(2), "no file yet")
	guide.photographed(cop)
	assert_eq(guide.said(), "GUIDE_NO_FLASH")
	var text := case.file_text(2)
	assert_string_contains(text, guide.traits.name)
	assert_string_contains(text, tr("FILE_BOOT") % guide.traits.shoe, "the photo shows the moon boots")
	assert_string_contains(text, tr("FILE_GLOW_UNKNOWN"))
	assert_eq(guide.dusted(cop), tr("PRINTS_COOK") % guide.traits.name)
	var bread := Bread.new()
	add_child_autofree(bread)
	guide.feed(bread)
	guide.stubborn = false
	guide.use(cop)
	guide.use(cop)
	planetarium.set_dark(true)
	guide.use(cop)
	assert_true(case.files.has(2), "photo, prints, teeth, hair, gloves and planet: done")
	text = case.file_text(2)
	assert_string_contains(text, tr("FILE_PLANET") % guide.planet_name())
	assert_string_contains(text, tr("FILE_GLOW") if guide.traits.glow else tr("FILE_NO_GLOW"))
	for key in ["PROMPT_GUIDE_GLOVES", "GUIDE_HELMET_NO", "FILE_GLOW", "FILE_PLANET", "BRIEF_PLANETARIUM_A_meteorite",
			"HINT_GUIDE_LEFT", "HINT_FILE_glow", "FILE_PART_planet"]:
		assert_ne(tr(key), key, "%s is translated" % key)
