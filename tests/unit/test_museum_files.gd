extends GutTest

## The guards' files and their bathroom alibis (escena-museo.md, step 3): GuardTraits' liars and details, the
## bathroom's details (Museum, HandDryer), MuseumGuard's parts and CrimeSceneCase.guard_part.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_always_lies_and_one_or_two_more_do() -> void:
	for seed_value in range(1, 30):
		var guards := GuardTraits.draw(seed_value)
		var culprit := CrimePlan.culprit_of(GuardTraits.COUNT, seed_value)
		var plan := CrimePlan.draw(guards, seed_value, CrimeSceneCase.VARIANTS.museum.clues)
		assert_eq(plan.culprit, culprit, "culprit_of is the plan's culprit")
		assert_true(guards[culprit].liar, "seed %d: the culprit lies" % seed_value)
		var liars := guards.filter(func(g: Dictionary) -> bool: return g.liar).size()
		assert_between(liars, 1 + GuardTraits.OTHER_LIARS.x, 1 + GuardTraits.OTHER_LIARS.y)
		var truth := GuardTraits.bathroom(seed_value)
		assert_eq(truth.size(), GuardTraits.TRUE_DETAILS)
		for guard in guards:
			assert_eq(truth.has(guard.detail), not guard.liar, "the honest ones tell a true detail, the liars a false one")
		assert_eq(CrimePlan.suspects_left(guards, guards[culprit], plan.clues, plan.traits).size(), 1,
			"the 4 clues leave only him")


func test_the_bathroom_shows_its_true_details() -> void:
	for seed_value in [2, 5, 9]:
		var museum := Museum.new()
		museum.case_seed = seed_value
		add_child_autofree(museum)
		var truth := GuardTraits.bathroom(seed_value)
		assert_eq(museum.bathroom_details, truth)
		assert_eq(museum.has_node("Detail_tap"), truth.has("tap"), "a drop on the tap only if it drips")
		assert_eq(museum.has_node("Detail_spider"), truth.has("spider"))
		assert_eq(museum.has_node("Detail_lavender"), truth.has("lavender"))
		assert_true(museum.has_node("Detail_paper") and museum.has_node("Detail_mirror"), "roll and mirror, always")
		var cop: Cop = autofree(COP_SCENE.instantiate())
		museum.dryer.use(cop)
		assert_eq(museum.dryer.said(), "DRYER_BROKEN" if truth.has("dryer") else "DRYER_WORKS")


## A museum with its case set up, and a cop at hand.
func _museum_case(seed_value: int) -> Array:
	var museum := Museum.new()
	museum.case_seed = seed_value
	add_child_autofree(museum)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = museum
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [museum, case, cop]


func test_empty_hands_get_the_alibi_then_the_cap_then_the_mustache() -> void:
	var made := _museum_case(4)
	var museum: Museum = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var guard: MuseumGuard
	for g in museum.guards:
		if not g.stubborn and not g.traits.mustache:
			guard = g
	if guard == null:
		for g in museum.guards:
			if not g.stubborn:
				guard = g
	assert_eq(guard.prompt_key(cop), "PROMPT_GUARD_TALK")
	guard.use(cop)
	assert_string_contains(guard.said(), tr("ALIBI_" + str(guard.traits.detail)))
	assert_true(case.file_parts[guard.index].alibi, "the alibi is in his file")
	assert_eq(case.file_traits(guard.index).liar, guard.traits.liar)
	assert_eq(guard.prompt_key(cop), "PROMPT_GUARD_CAP")
	guard.use(cop)
	assert_false(guard.part("cap").visible, "the cap comes off")
	assert_eq(case.file_traits(guard.index).hair, guard.traits.hair)
	assert_eq(guard.prompt_key(cop), "PROMPT_GUARD_MUSTACHE")
	guard.use(cop)
	assert_eq(guard.part("mustache").visible, guard.traits.mustache, "a fake one comes off, a real one stays")
	assert_eq(guard.said(), "GUARD_MUSTACHE_REAL" if guard.traits.mustache else "GUARD_MUSTACHE_FAKE")
	assert_eq(case.file_traits(guard.index).mustache, guard.traits.mustache)
	assert_eq(guard.prompt_key(cop), "PROMPT_GUARD_TALK", "then the alibi again")


func test_the_stubborn_guard_keeps_the_cap_until_he_eats() -> void:
	var made := _museum_case(6)
	var museum: Museum = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var stubborn := museum.guards.filter(func(g: MuseumGuard) -> bool: return g.stubborn)
	assert_eq(stubborn.size(), 1, "one stubborn guard")
	var guard: MuseumGuard = stubborn[0]
	guard.use(cop)
	guard.use(cop)
	assert_eq(guard.said(), "GUARD_CAP_NO")
	assert_true(guard.cap_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	guard.feed(bread)
	assert_false(guard.cap_on, "fed, he takes it off")
	assert_true(case.file_parts[guard.index].teeth and case.file_parts[guard.index].hair)


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _museum_case(8)
	var museum: Museum = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var guard := museum.guards[1]
	assert_false(case.file_parts.has(1), "no file yet")
	guard.photographed(cop)
	assert_eq(guard.said(), "GUARD_NO_FLASH")
	var text := case.file_text(1)
	assert_string_contains(text, guard.traits.name)
	assert_string_contains(text, tr("FILE_SHOE") % guard.traits.shoe, "the photo shows his shoes")
	assert_string_contains(text, tr("FILE_MUSTACHE_UNKNOWN"))
	assert_eq(guard.dusted(cop), tr("PRINTS_COOK") % guard.traits.name)
	var bread := Bread.new()
	add_child_autofree(bread)
	guard.feed(bread)
	guard.stubborn = false
	guard.use(cop)
	guard.use(cop)
	guard.use(cop)
	assert_true(case.files.has(1), "photo, prints, teeth, hair, mustache and alibi: done")
	text = case.file_text(1)
	assert_string_contains(text, tr("FILE_ALIBI") % tr("ALIBI_SHORT_" + str(guard.traits.detail)))
	assert_string_contains(text, tr("FILE_MUSTACHE_REAL") if guard.traits.mustache else tr("FILE_MUSTACHE_FAKE"))
