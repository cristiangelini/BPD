extends GutTest

## "¡El truco!": the clowns swap spots and some signs fall (escena-circo.md, step 5b; ClownTrick).


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


func test_every_clown_ends_up_in_another_spot() -> void:
	var case := _case()
	var circus := case.place as Circus
	var trick := circus.trick
	var before := trick.spots.duplicate()
	var places := circus.clowns.map(func(c: CircusClown) -> Vector3: return c.position)
	trick.perform()
	assert_true(trick.running())
	var after := trick.spots.duplicate()
	after.sort()
	assert_eq(after, range(ClownTraits.COUNT), "still one clown per spot")
	for i in ClownTraits.COUNT:
		assert_ne(trick.spots[i], before[i], "clown %d moved" % i)
	trick._place(1.0)
	for i in ClownTraits.COUNT:
		var spot: int = trick.spots[i]
		assert_almost_eq(circus.clowns[i].position, places[spot], Vector3.ONE * 0.01,
			"clown %d stands where clown %d stood" % [i, spot])


func test_the_same_seed_does_the_same_trick() -> void:
	var a := (_case(4).place as Circus).trick
	var b := (_case(4).place as Circus).trick
	a.perform()
	b.perform()
	assert_eq(a.spots, b.spots)


func test_some_signs_fall_off_in_the_run() -> void:
	var fell := 0
	for seed_value in range(1, 30):
		var circus := _case(seed_value).place as Circus
		for clown in circus.clowns:
			circus.stick_sign(clown.index, clown)
		circus.trick.perform()
		fell += ClownTraits.COUNT - circus.signs.size()
	assert_gt(fell, 0, "some signs fall")
	assert_lt(fell, 29 * ClownTraits.COUNT / 2, "but most stay on")


func test_the_trick_comes_every_so_often_once_the_case_is_on() -> void:
	var case := _case()
	var trick := (case.place as Circus).trick
	trick._physics_process(ClownTrick.TRICK_EVERY)
	assert_eq(trick.rounds, 0, "not before the tip")
	case.give_tip()
	trick._physics_process(ClownTrick.TRICK_EVERY - ClownTrick.WARNING + 0.1)
	assert_eq((case.place as Circus).ringmaster.said(), "RINGMASTER_TRICK", "the ringmaster calls it")
	trick._physics_process(ClownTrick.WARNING)
	assert_eq(trick.rounds, 1)
	trick._physics_process(ClownTrick.RUN)
	assert_false(trick.running(), "they're done running")
