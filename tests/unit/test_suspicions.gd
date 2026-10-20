extends GutTest

## The cops guess the story among three suspicions (historias.md, "Resolver con las pruebas").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house(story: CaseStory) -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 9
	house.story = story
	house.get_node("Cop").input_enabled = false
	house.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(house)
	return house


func test_three_different_suspicions_with_the_true_one_among_them() -> void:
	var positions := {}
	for case_seed in range(1, 60):
		var picked := CaseSuspicions.draw(case_seed, "turtles")
		assert_eq(picked.size(), CaseSuspicions.COUNT)
		assert_has(picked, "turtles")
		var unique := {}
		for id in picked:
			unique[id] = true
			assert_has(CaseSuspicions.POOL, id)
			assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id)
			assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id)
		assert_eq(unique.size(), CaseSuspicions.COUNT, "no suspicion twice")
		positions[picked.find("turtles")] = true
	assert_eq(positions.size(), CaseSuspicions.COUNT, "the true one isn't always in the same row")
	assert_eq(CaseSuspicions.draw(5, "bingo"), CaseSuspicions.draw(5, "bingo"), "same seed, same suspicions")


func test_each_place_draws_from_its_own_pool() -> void:
	var pool := ["ring", "sneeze", "sourdough", "wedding"]
	for case_seed in range(1, 20):
		var picked := CaseSuspicions.draw(case_seed, "ring", pool)
		assert_has(picked, "ring")
		for id in picked:
			assert_has(pool, id)


func test_the_house_runs_its_case_through_the_shared_raid() -> void:
	var house := _house(GrandpaHouse.BINGO)
	assert_not_null(house.raid)
	assert_eq(house.suspicions, house.raid.suspicions)
	assert_eq(house.raid.main_evidence, house.main_evidence())
	assert_true(house.objective_facts().has("tupper_asked"), "the house's own facts reach the checklist")


func test_the_checklist_hides_what_to_bring_until_the_right_mark() -> void:
	var house := _house(GrandpaHouse.BINGO)
	await wait_physics_frames(5)
	var texts := CaseObjectives.rows(house.objective_facts()).map(func(r: Dictionary) -> String: return r.text)
	assert_has(texts, "OBJ_GUESS")
	assert_has(texts, "OBJ_FIND_PROOF")
	assert_does_not_have(texts, "OBJ_EXTRA_CAGE", "the extras would give the story away")
	assert_true(house.mark(house.suspicions.find("bingo")))
	texts = CaseObjectives.rows(house.objective_facts()).map(func(r: Dictionary) -> String: return r.text)
	assert_has(texts, "OBJ_FIND")
	assert_has(texts, "OBJ_EXTRA_CAGE")


func test_a_wrong_mark_halves_the_salary_and_a_second_fails_the_case() -> void:
	var house := _house(GrandpaHouse.TURTLES)
	await wait_physics_frames(5)
	var wrong: Array = range(3).filter(func(i: int) -> bool: return house.suspicions[i] != "turtles")
	assert_false(house.mark(wrong[0]))
	assert_false(house.case_failed)
	assert_eq(house.get_node("Cop/Hud/Hint").text, "HINT_SUSPECT_WRONG")
	assert_false(house.mark(wrong[0]), "the same wrong one can't be marked twice")
	assert_eq(house.wrong_marks.size(), 1)
	assert_eq(ShiftReport.pay(true, [], 0, 1).salary, ShiftReport.SALARY / 2)
	assert_false(house.mark(wrong[1]))
	assert_true(house.case_failed)
	assert_eq(house.get_node("%CaseFailed").text, "CASE_FAILED_WRONG")


func test_the_case_is_not_solved_until_the_story_is_known() -> void:
	var house := _house(GrandpaHouse.BINGO)
	await wait_physics_frames(30)
	house.main_evidence().global_position = house.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	house.car.enter(house.get_node("Cop"))
	assert_false(house.case_solved, "the evidence waits in the trunk")
	house.mark(house.suspicions.find("bingo"))
	assert_true(house.case_solved, "it counts once they guess right")


func test_each_suspicion_has_its_clue_in_the_house() -> void:
	TranslationServer.set_locale("es")
	var house := _house(GrandpaHouse.BINGO)
	await wait_physics_frames(5)
	var texts := []
	for child in house.get_node("Evidence").get_children():
		if child is ClueNote:
			texts.append((child as ClueNote).text)
	for id in house.suspicions:
		assert_has(texts, tr("CLUE_SUSPECT_" + id))
