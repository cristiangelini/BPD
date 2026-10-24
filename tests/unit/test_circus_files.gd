extends GutTest

## Taking off what hides each clown and the files for the board (escena-circo.md, step 4; CircusClown, ClownSponge,
## CrimeSceneCase's circus variant).


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


func test_the_circus_case_draws_clowns_and_their_clues() -> void:
	var case := _case()
	assert_eq(case.texts(), CrimeSceneCase.VARIANTS.circus)
	assert_eq(case.cooks, ClownTraits.draw(7), "the case's suspects are the circus's clowns")
	var traits: Dictionary = CrimeSceneCase.VARIANTS.circus.clues
	for seed_value in range(1, 120):
		var clowns := ClownTraits.draw(seed_value)
		var plan := CrimePlan.draw(clowns, seed_value, traits)
		assert_eq(CrimePlan.suspects_left(clowns, clowns[plan.culprit], plan.clues, traits), [plan.culprit],
			"the clues leave only him (seed %d)" % seed_value)


func test_the_sponge_cleans_the_face_and_then_the_photo_counts() -> void:
	var case := _case()
	var clown: CircusClown = (case.place as Circus).clowns[1]
	(case.place as Circus).stick_sign(1, clown)
	clown.photographed(null)
	assert_eq(clown.said(), "CLOWN_PHOTO_MAKEUP", "with the makeup they're all the same")
	assert_false(case.file_parts[1].photo if case.file_parts.has(1) else false)
	for i in CircusClown.SCRUBS - 1:
		clown.scrub()
	assert_true(clown.makeup_on, "not clean yet")
	clown.scrub()
	assert_false(clown.makeup_on)
	assert_eq(clown.part("glasses").visible, clown.traits.glasses as bool, "his glasses show, if he wears them")
	clown.photographed(null)
	assert_true(case.file_parts[1].photo)


func test_every_part_of_a_clowns_file() -> void:
	var case := _case(11)
	var clown: CircusClown = (case.place as Circus).clowns[2]
	(case.place as Circus).stick_sign(4, clown)
	clown.stubborn = false
	clown.spare_gloves = 1
	clown.honk()
	assert_eq(clown.said(), "CLOWN_HONK_" + str(clown.traits.honk))
	clown.ask_wig()
	assert_true(clown.part("hair").visible, "his own hair")
	clown.pull_shoe()
	assert_false(clown.part("shoe_right").visible, "his real foot")
	assert_eq(clown.dusted(null), "PRINTS_GLOVE", "gloves on, no prints")
	clown.pull_glove()
	assert_true(clown.gloves_on, "another glove under the first")
	clown.pull_glove()
	assert_false(clown.gloves_on)
	assert_ne(clown.dusted(null), "PRINTS_GLOVE")
	var box: DonutBox = preload("res://scenes/props/donut_box.tscn").instantiate()
	add_child_autofree(box)
	clown.feed(box)
	assert_true(clown.part("teeth").visible, "he shows his teeth biting")
	for i in CircusClown.SCRUBS:
		clown.scrub()
	clown.photographed(null)
	assert_has(case.files, 4, "photo, prints, teeth, hair, foot and honk: the file of his sign is done")
	var text := case.file_text(4)
	assert_string_contains(text, tr("FILE_SIGN") % 5)
	assert_string_contains(text, tr("FILE_SHOE") % clown.traits.shoe)
	assert_string_contains(text, tr("FILE_HONK") % tr("HONK_" + str(clown.traits.honk)))


func test_the_stubborn_clown_keeps_his_wig_until_he_eats() -> void:
	var case := _case(5)
	var circus := case.place as Circus
	var stubborn: Array = circus.clowns.filter(func(c: CircusClown) -> bool: return c.stubborn)
	assert_eq(stubborn.size(), 1, "one of them, by the seed")
	var clown: CircusClown = stubborn[0]
	clown.ask_wig()
	assert_true(clown.wig_on)
	var box: DonutBox = preload("res://scenes/props/donut_box.tscn").instantiate()
	add_child_autofree(box)
	clown.feed(box)
	assert_false(clown.wig_on, "a donut and off it comes")


func test_the_sponges_wait_in_the_bucket() -> void:
	var circus := Circus.new()
	add_child_autofree(circus)
	var sponges := circus.find_children("Sponge*", "ClownSponge", false, false)
	assert_eq(sponges.size(), Circus.SPONGES)
	assert_true(circus.in_tent((sponges[0] as Node3D).global_position))
