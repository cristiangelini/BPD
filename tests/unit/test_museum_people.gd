extends GutTest

## The museum's people (escena-museo.md, step 2): the six guards alike (GuardTraits, MuseumGuard), Señora Pincel
## (MuseumDirector) and the living statue (LivingStatue).


func test_the_six_guards_are_drawn_with_the_seed_and_none_is_the_same() -> void:
	var guards := GuardTraits.draw(7)
	assert_eq(guards.size(), GuardTraits.COUNT)
	assert_eq(GuardTraits.draw(7), guards, "same seed, same guards")
	var seen := {}
	var fakes := 0
	for guard in guards:
		seen[GuardTraits.signature(guard)] = true
		assert_between(guard.shoe, GuardTraits.SHOE_MIN, GuardTraits.SHOE_MAX)
		assert_true(GuardTraits.HAIRS.has(guard.hair))
		if not guard.mustache:
			fakes += 1
	assert_eq(seen.size(), GuardTraits.COUNT, "no two the same in everything")
	assert_between(fakes, GuardTraits.FAKE_MUSTACHES.x, GuardTraits.FAKE_MUSTACHES.y, "one or two fake mustaches")


func test_some_seeds_have_two_fake_mustaches() -> void:
	var counts := {}
	for seed_value in range(1, 40):
		var fakes := 0
		for guard in GuardTraits.draw(seed_value):
			if not guard.mustache:
				fakes += 1
		counts[fakes] = true
	assert_true(counts.has(1) and counts.has(2), "both happen")


func test_the_museum_puts_the_guards_in_the_gallery_with_their_traits() -> void:
	var museum := Museum.new()
	museum.case_seed = 3
	add_child_autofree(museum)
	var traits := GuardTraits.draw(3)
	assert_eq(museum.guards.size(), GuardTraits.COUNT)
	for i in museum.guards.size():
		var guard := museum.guards[i]
		assert_eq(guard.traits, traits[i])
		assert_eq(museum.suspect(i), guard)
		assert_true(museum.in_gallery(guard.global_position), "%s is in the gallery" % guard.name)
		assert_eq(guard.part("glasses").visible, traits[i].glasses, "glasses only if he wears them")
		assert_true(guard.part("cap").visible, "the cap is on")
		assert_true(guard.part("mustache").visible, "and the mustache, real or not")
		assert_false(guard.part("teeth").visible)
	assert_null(museum.suspect(GuardTraits.COUNT))
	assert_true(museum.inside(museum.director.global_position), "the director is in the hall")
	assert_false(museum.inside(museum.statue.global_position), "the statue is out on the steps")
	assert_true(museum.at_scene(museum.statue.global_position))


func test_every_guard_says_he_was_in_the_bathroom_and_the_others_talk_too() -> void:
	TranslationServer.set_locale("es")
	var museum := Museum.new()
	add_child_autofree(museum)
	var cop: Cop = autofree(preload("res://scenes/player/cop.tscn").instantiate())
	var guard := museum.guards[2]
	assert_eq(guard.prompt_key(cop), "PROMPT_GUARD_TALK")
	guard.use(cop)
	var first := guard.said()
	guard.use(cop)
	assert_ne(guard.said(), first, "a different line each time")
	for i in MuseumGuard.LINES:
		assert_ne(tr("GUARD_LINE_%d" % i), "GUARD_LINE_%d" % i)
	museum.director.use(cop)
	assert_eq(museum.director.said(), "MUSEUM_DIRECTOR_LINE_0")
	museum.statue.use(cop)
	assert_eq(museum.statue.said(), "STATUE_STILL", "without a coin he doesn't move")
