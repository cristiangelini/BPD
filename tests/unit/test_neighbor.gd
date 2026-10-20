extends GutTest

## The vecina chismosa (investigacion.md, "Más personajes en la casa"): her tupperware for a clue.

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 11
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


## The cop stands at her window, looking in.
func _at_window(house: GrandpaHouse) -> Cop:
	var cop: Cop = house.get_node("Cop")
	cop.global_position = house.neighbor.to_global(Vector3(0, 0.1, 1.2))
	cop.rotation.y = house.neighbor.rotation.y
	return cop


func test_she_lives_next_door_and_the_tupperware_is_in_a_drawer() -> void:
	var house := _house()
	await wait_physics_frames(5)
	assert_lt(house.neighbor.global_position.x, -GrandpaHouse.HALF_X - 2.0, "outside, west of the grandpa's house")
	assert_not_null(house.tupperware)
	var in_drawer := false
	for dresser in house.dressers:
		for drawer in dresser.drawers:
			in_drawer = in_drawer or drawer.contents.has(house.tupperware)
	assert_true(in_drawer)


func test_talking_to_her_adds_the_errand_to_the_checklist() -> void:
	var house := _house()
	await wait_physics_frames(5)
	var cop := _at_window(house)
	await wait_physics_frames(2)
	assert_eq(cop.current_prompt(), "PROMPT_NEIGHBOR")
	assert_false(house.objective_facts().tupper_asked)
	assert_true(cop.use())
	assert_true(house.neighbor.was_asked)
	var texts := CaseObjectives.rows(house.objective_facts()).map(func(r: Dictionary) -> String: return r.text)
	assert_has(texts, "OBJ_EXTRA_TUPPER")


func test_the_tupperware_at_her_window_buys_a_clue() -> void:
	var house := _house()
	await wait_physics_frames(5)
	var tupper := house.tupperware
	tupper.global_position = house.neighbor.to_global(Vector3(0, 1.3, 0.3))
	await wait_physics_frames(5)
	assert_true(house.neighbor.returned)
	assert_false(is_instance_valid(tupper), "she takes it in")
	assert_true(house.objective_facts().tupper_returned)
	assert_has(house.clues_found, house.neighbor.clue)
	var spot: String = GrandpaHouse.SPOTS[house.evidence_spots[house.case_seed % house.story.evidence.size()]].id
	assert_string_contains(house.neighbor.clue, tr("LOC_" + spot))


func test_she_calls_cops_that_come_close() -> void:
	var house := _house()
	await wait_physics_frames(5)
	_at_window(house)
	await wait_physics_frames(3)
	assert_eq(house.neighbor._bubble.text, "NEIGHBOR_PSST")


func test_the_errand_row_only_shows_once_she_asked() -> void:
	var facts := {"door_open": false, "found": false, "delivered": false, "all_in_car": false, "cage_delivered": false,
		"safe_delivered": false, "cards_delivered": 0, "cards_total": 5, "broken": 0, "fines": 0, "complaint": 0.0}
	var texts := CaseObjectives.rows(facts).map(func(r: Dictionary) -> String: return r.text)
	assert_does_not_have(texts, "OBJ_EXTRA_TUPPER")
	facts.tupper_asked = true
	facts.tupper_returned = true
	for row in CaseObjectives.rows(facts):
		if row.text == "OBJ_EXTRA_TUPPER":
			assert_true(row.done)
			assert_true(row.optional)
