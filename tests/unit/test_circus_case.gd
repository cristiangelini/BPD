extends GutTest

## The circus case (escena-circo.md, step 6a): what was stolen and where it's hidden, drawn with the seed; searching
## the spots; the comisario's briefing and the planilla; and the circus level that gives the case.


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


func test_the_loot_and_its_spot_come_from_the_seed() -> void:
	var a := _case(11).place as Circus
	var b := _case(11).place as Circus
	assert_has(Circus.LOOTS, a.loot)
	assert_has(Circus.LOOT_SPOTS, a.loot_spot)
	assert_eq(a.loot, b.loot, "same seed, same loot")
	assert_eq(a.loot_spot, b.loot_spot, "same seed, same spot")


func test_every_loot_turns_up_with_some_seed() -> void:
	var seen := {}
	for seed_value in range(1, 40):
		seen[(_case(seed_value).place as Circus).loot] = true
	assert_eq(seen.size(), Circus.LOOTS.size())


func test_the_caravan_to_search_is_the_culprits() -> void:
	var case := _case()
	var circus := case.place as Circus
	var door := (circus.loot_spots.caravan as Node3D).position
	var caravan: Vector3 = Circus.CARAVANS[case.plan.culprit]
	assert_almost_eq(door.x, caravan.x - 0.9, 0.01)


func test_the_wrong_spot_has_nothing() -> void:
	var case := _case()
	var circus := case.place as Circus
	for spot in Circus.LOOT_SPOTS:
		if spot != circus.loot_spot:
			circus.search(spot, null)
	assert_false(circus.loot_found)
	assert_false(case.loot_found)
	assert_null(circus.get_node_or_null("Loot"))


func test_the_right_spot_has_the_loot() -> void:
	var case := _case()
	var circus := case.place as Circus
	circus.search(circus.loot_spot, null)
	assert_true(circus.loot_found)
	assert_true(case.loot_found, "the case notes it")
	assert_not_null(circus.get_node_or_null("Loot"))
	circus.search(circus.loot_spot, null)
	assert_eq(circus.find_children("Loot*", "", false, false).size(), 1, "only once")


func test_the_briefing_says_what_was_stolen() -> void:
	var case := _case()
	var circus := case.place as Circus
	var lines := case.briefing_lines()
	assert_eq(lines[0], "BRIEF_CIRCUS_A_" + circus.loot)
	assert_eq(lines.size(), 3)


func test_the_pastry_briefing_stays_the_same() -> void:
	var contest := PastryContest.new()
	add_child_autofree(contest)
	var case := CrimeSceneCase.new()
	case.place = contest
	add_child_autofree(case)
	case.start()
	assert_eq(case.briefing_lines(), PackedStringArray(["BRIEF_CRIME_A", "BRIEF_CRIME_B", "BRIEF_CRIME_C"]))


func test_the_planilla_has_an_optional_loot_row() -> void:
	var case := _case()
	var circus := case.place as Circus
	var row := _row(case, "OBJ_CIRCUS_LOOT_" + circus.loot)
	assert_false(row.is_empty())
	assert_true(row.optional)
	assert_false(row.done)
	circus.search(circus.loot_spot, null)
	assert_true(_row(case, "OBJ_CIRCUS_LOOT_" + circus.loot).done)
	assert_eq(case.rows()[0].text, "OBJ_CIRCUS_GO")


func test_the_snapshot_brings_the_loot() -> void:
	var case := _case()
	(case.place as Circus).search((case.place as Circus).loot_spot, null)
	var state := case.snapshot()
	assert_true(state.loot)
	var other := _case()
	other.apply_snapshot(state)
	assert_true((other.place as Circus).loot_found, "the other side sees it too")


func test_the_level_gives_the_circus_case() -> void:
	var level: CircusLevel = load("res://scenes/levels/circus.tscn").instantiate()
	level.case_seed = 7
	add_child_autofree(level)
	assert_not_null(level.case)
	assert_eq(level.case.place, level.circus)
	assert_eq(level.circus.variant, "circus")
	assert_not_null(level.board)
	assert_eq(level.board.case, level.case)
	assert_not_null(level.stamp)


func _row(case: CrimeSceneCase, text: String) -> Dictionary:
	for row in case.rows():
		if row.text == text:
			return row
	return {}
