extends GutTest

## The office's case (escena-oficina.md, step 4a): what was stolen and where it's hidden, the comisario's briefing, the
## planilla's rows and the level that gives the case with the station's board and stamp.

const LEVEL := preload("res://scenes/levels/forms_office.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _office_case(seed_value: int) -> Array:
	var office := FormsOffice.new()
	office.case_seed = seed_value
	add_child_autofree(office)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = office
	add_child_autofree(case)
	case.start()
	return [office, case]


func test_the_seed_draws_what_was_stolen_and_where() -> void:
	var loots := {}
	var spots := {}
	for seed_value in range(1, 30):
		var office: FormsOffice = _office_case(seed_value)[0]
		assert_has(FormsOffice.LOOTS, office.loot)
		assert_has(FormsOffice.LOOT_SPOTS, office.loot_spot)
		assert_eq(office.stapler.visible, office.loot != "stapler", "an empty glass case when the stapler was stolen")
		loots[office.loot] = true
		spots[office.loot_spot] = true
	assert_eq(loots.size(), FormsOffice.LOOTS.size(), "all three get stolen")
	assert_eq(spots.size(), FormsOffice.LOOT_SPOTS.size(), "and hidden everywhere")


func test_the_briefing_names_it_and_the_rows() -> void:
	var made := _office_case(5)
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var lines := case.briefing_lines()
	assert_eq(lines[0], "BRIEF_OFFICE_A_" + office.loot)
	for line in lines:
		assert_ne(tr(line), line, "%s is written" % line)
	assert_eq(office.loot_spots.briefcase, office.briefcases[case.plan.culprit], "the culprit's briefcase")
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_OFFICE_LOOT_" + office.loot, "an optional row for the loot")
	assert_has(texts, "OBJ_OFFICE_GO")
	for loot: String in FormsOffice.LOOTS:
		for key in ["BRIEF_OFFICE_A_", "OBJ_OFFICE_LOOT_", "HINT_LOOT_FOUND_"]:
			assert_ne(tr(key + loot), key + loot)
	for spot: String in FormsOffice.LOOT_SPOTS:
		for key in ["PROMPT_SEARCH_", "HINT_SEARCH_NOTHING_"]:
			assert_ne(tr(key + spot), key + spot)


## A seed whose loot hides in `spot`.
func _seed_hiding_in(spot: String) -> int:
	for seed_value in range(1, 100):
		if FormsOffice.LOOT_SPOTS[hash(["office loot spot", seed_value]) % FormsOffice.LOOT_SPOTS.size()] == spot:
			return seed_value
	return -1


func test_searching_finds_it_only_in_its_spot() -> void:
	for spot: String in FormsOffice.LOOT_SPOTS:
		var made := _office_case(_seed_hiding_in(spot))
		var office: FormsOffice = made[0]
		var case: CrimeSceneCase = made[1]
		var cop: Cop = COP_SCENE.instantiate()
		add_child_autofree(cop)
		for i in office.briefcases.size():
			if i != case.plan.culprit:
				assert_eq(office.briefcases[i].prompt_key(cop), "PROMPT_SEARCH_briefcase")
				office.briefcases[i].use(cop)
		for other: String in ["copier", "bin"]:
			if other != spot:
				(office.loot_spots[other] as LootSpot).use(cop)
		assert_false(office.loot_found, "%s: not in the others" % spot)
		(office.loot_spots[spot] as LootSpot).use(cop)
		assert_true(office.loot_found, "%s: found there" % spot)
		assert_true(case.loot_found)
		var item := office.get_node("Loot") as Node3D
		assert_true(office.inside(item.global_position), "it falls inside the office")
		assert_eq(office.floor_of(item.global_position + Vector3.UP * 0.1), 0, "downstairs")


func test_the_level_gives_the_case_with_the_board() -> void:
	var level: FormsOfficeLevel = LEVEL.instantiate()
	level.case_seed = 3
	add_child_autofree(level)
	assert_eq(level.case.place, level.office)
	assert_eq(level.case.texts(), CrimeSceneCase.VARIANTS.office)
	assert_eq(level.case.board, level.board)
	assert_eq(level.office.employees[0].case, level.case, "the employees know the case")
	assert_not_null(level.office.bags, "with evidence bags")
