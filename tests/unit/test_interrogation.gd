extends GutTest

## Questioning the grandpa with R (investigacion.md, "Interrogar al abuelo").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 11
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_each_answer_lets_slip_a_hiding_spot_and_annoys_him() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(15)
	var grandpa := house.grandpa
	var cop: Cop = house.get_node("Cop")
	assert_eq(grandpa.slips.size(), 3)
	var start := grandpa.complaint
	assert_true(grandpa.ask(cop))
	assert_almost_eq(grandpa.complaint, start + Grandpa.ASKED, 0.01)
	assert_has(house.clues_found, grandpa.slips[0], "the slip goes to the checklist")
	assert_false(grandpa.ask(cop), "he needs a moment between questions")
	var spots: Array = house.evidence_spots.map(func(i: int) -> String: return tr("LOC_" + GrandpaHouse.SPOTS[i].id))
	for slip: String in grandpa.slips:
		assert_true(spots.any(func(where: String) -> bool: return slip.contains(where)), slip)


func test_after_three_answers_he_is_offended() -> void:
	var house := _house()
	await wait_physics_frames(15)
	var grandpa := house.grandpa
	var cop: Cop = house.get_node("Cop")
	for i in Grandpa.ASKS:
		grandpa._ask_wait = 0.0
		assert_true(grandpa.ask(cop))
	grandpa._ask_wait = 0.0
	assert_false(grandpa.ask(cop))
	assert_eq(grandpa.get_node("Bubble").text, "GRANDPA_OFFENDED")
	assert_eq(house.clues_found.size(), Grandpa.ASKS)


func test_r_key_asks_what_the_cop_looks_at() -> void:
	var house := _house()
	await wait_physics_frames(15)
	var cop: Cop = house.get_node("Cop")
	assert_false(cop.ask(), "nothing to ask out on the street")
	assert_true(InputMap.has_action("ask"))
