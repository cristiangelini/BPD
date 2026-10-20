extends GutTest

## The comisario gives the case and Q opens the checklist (allanamiento.md, "Charla del comisario y planilla").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _facts() -> Dictionary:
	return {"door_open": false, "found": false, "delivered": false, "all_in_car": false,
		"broken": 0, "fines": 0, "complaint": 0.0}


func _house(player: bool) -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.get_node("Cop").input_enabled = player
	house.get_node("Cop/Grabber").input_enabled = player
	add_child_autofree(house)
	return house


func test_the_first_step_is_getting_in_then_each_one_in_order() -> void:
	var facts := _facts()
	assert_eq(CaseObjectives.next_step(CaseObjectives.rows(facts)), 0)
	facts.door_open = true
	assert_eq(CaseObjectives.next_step(CaseObjectives.rows(facts)), 1)
	facts.found = true
	assert_eq(CaseObjectives.next_step(CaseObjectives.rows(facts)), 2)
	facts.delivered = true
	assert_eq(CaseObjectives.next_step(CaseObjectives.rows(facts)), 3)
	facts.all_in_car = true
	assert_eq(CaseObjectives.next_step(CaseObjectives.rows(facts)), -1, "the extra is optional")


func test_the_checklist_shows_fines_and_complaint() -> void:
	TranslationServer.set_locale("es")
	var facts := _facts()
	facts.broken = 3
	facts.fines = 60
	facts.complaint = 41.6
	var texts := CaseObjectives.rows(facts).map(func(r: Dictionary) -> String: return r.text)
	assert_has(texts, "Adornos rotos: 3 (multa: 60)")
	assert_has(texts, "Denuncia del abuelo: 42%")


func test_a_player_hears_the_comisario_and_cannot_move_meanwhile() -> void:
	var house := _house(true)
	await wait_physics_frames(2)
	var cop: Cop = house.get_node("Cop")
	assert_false(house.briefing.visible, "he waits in his office")
	(house.get_node("City") as City).comisario.use(cop)
	assert_true(house.briefing.visible)
	assert_true(cop.is_busy())
	for i in GrandpaHouse.TIP_BRIEFING.size():
		house.briefing.advance()
	assert_false(house.briefing.visible)
	assert_false(cop.is_busy())
	assert_true(house.checklist.is_open(), "the checklist opens after the comisario")


func test_without_a_player_there_is_no_briefing() -> void:
	var house := _house(false)
	await wait_physics_frames(2)
	assert_false(house.briefing.visible)
	assert_false(house.get_node("Cop").is_busy())


func test_q_toggles_the_checklist_and_it_follows_the_case() -> void:
	TranslationServer.set_locale("es")
	var house := _house(false)
	await wait_physics_frames(2)
	assert_false(house.checklist.is_open())
	var press := InputEventAction.new()
	press.action = "checklist"
	press.pressed = true
	Input.parse_input_event(press)
	await wait_process_frames(2)
	assert_true(house.checklist.is_open())
	await wait_seconds(0.3)
	assert_eq(house.checklist.row_texts()[0], "[ ] " + tr("OBJ_ENTER"))
	house.get_node("FrontDoor").is_open = true
	await wait_seconds(0.3)
	assert_eq(house.checklist.row_texts()[0], "[x] " + tr("OBJ_ENTER"))


func test_the_extras_in_the_trunk_tick_their_rows() -> void:
	TranslationServer.set_locale("es")
	var house := _house(false)
	await wait_physics_frames(30)
	house.mark(house.suspicions.find("bingo"))
	var safe: Evidence = house.evidence[2]
	assert_eq(safe.full_value, 800.0, "the takings")
	safe.global_position = house.car.to_global(Vector3(0.5, 0.7, -1.7))
	var card: Evidence = house.drawer_evidence[0]
	card.global_position = house.car.to_global(Vector3(-0.5, 0.6, -1.7))
	await wait_physics_frames(10)
	var facts := house.objective_facts()
	var extras: Array = facts.extras
	assert_false(extras[0].done, "the bingo cage stays in the house")
	assert_true(extras[1].done, "the takings")
	var texts := CaseObjectives.rows(facts).map(func(r: Dictionary) -> String: return r.text)
	assert_has(texts, "Extra: cartones de bingo (1 de 5), en los cajones")
