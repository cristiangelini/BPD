extends GutTest

## The courier at the birthday party (politico-cumple.md, step 3, decision 221): the cake shop's courier stands in the
## crowd with a pink cap and laughs when the deputy goes to a cake; cuffed and walked to the patrol car he pays 100 more,
## as do the two good cakes blown; still loose at the end, he runs off on the kick scooter.

const LEVEL := preload("res://scenes/levels/plaza_birthday.tscn")
const TEST_PATH := "user://test_partidas/politico_cumple_repartidor.json"
const STEP := 1.0 / 60.0

var rally: PlazaRally
var cop: Cop


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	rally = LEVEL.instantiate()
	rally.case_seed = 4242
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)
	rally.crowd.set_physics_process(false)
	rally.party.set_physics_process(false)
	cop = rally.get_node("Cop")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _end_speech() -> void:
	rally.speech.start()
	rally.speech.left = 0.05
	await wait_physics_frames(10)


func _pay_without_extras() -> int:
	return PoliticianCase.SALARY + PoliticianCase.PER_HECKLER * rally.case.detained() \
		- PoliticianCase.PER_STAIN * rally.politician.stains


func test_the_courier_in_the_crowd_with_his_cap() -> void:
	var courier := rally.courier
	assert_not_null(courier)
	assert_true(courier.courier)
	assert_false(courier.heckler)
	assert_eq(courier.look, "repartidor")
	assert_not_null(courier.get_node_or_null("Cap"), "the cake shop's pink cap")
	assert_lt(courier.global_position.distance_to(rally.city_plaza() + PlazaRally.COURIER_FROM_PLAZA), 0.3)
	assert_eq(courier.prompt_key(cop), "PROMPT_TALK_FAN", "he talks like anyone")


func test_he_laughs_when_the_deputy_goes_to_a_cake() -> void:
	assert_eq(rally.courier.said(), "")
	rally.party.going.emit(rally.party.next_cake())
	assert_string_starts_with(rally.courier.said(), "BIRTHDAY_COURIER_LAUGH_")
	for fan in rally.crowd.fans:
		assert_false(fan.said().begins_with("BIRTHDAY_COURIER_LAUGH_"), "only him")


func test_cuffed_and_in_the_patrol_car_he_pays_100() -> void:
	cop.belt_select(0)
	var cuffs: Handcuffs = cop.belt.held_tool()
	assert_eq(cuffs.cuff_body(rally.courier, rally.courier.global_position + Vector3.UP), rally.courier)
	assert_string_starts_with(rally.courier.said(), "BIRTHDAY_COURIER_CUFFED_")
	assert_eq(rally.courier.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	rally.courier.use(cop)
	OwnerEscort.of(rally.courier).board()
	assert_true(rally.case.courier_detained())
	assert_false(rally.case.courier_loose())
	rally.party.going.emit(rally.party.next_cake())
	assert_false(rally.courier.said().begins_with("BIRTHDAY_COURIER_LAUGH_"), "no laughing in the car")
	var rows: Array = rally.case.rows().filter(func(row: Dictionary) -> bool: return row.text == "OBJ_COURIER_CATCH")
	assert_eq(rows.size(), 1)
	assert_true(rows[0].done)
	await _end_speech()
	assert_ne(rally.case.runner, rally.courier, "a heckler runs off instead")
	assert_eq(rally.case.report().salary, _pay_without_extras() + PoliticianCase.PER_COURIER)


func test_the_two_good_cakes_blown_pay_100() -> void:
	for cake in rally.cakes:
		if not cake.rigged:
			cake.blow()
	assert_eq(rally.party.good_blown(), 2)
	rally.courier.cuffed(Handcuffs.SECONDS)
	await _end_speech()
	assert_eq(rally.case.report().salary, _pay_without_extras() + PoliticianCase.PER_GOOD_CAKES)


func test_one_good_cake_pays_nothing_more() -> void:
	for cake in rally.cakes:
		if not cake.rigged:
			cake.blow()
			break
	rally.courier.cuffed(Handcuffs.SECONDS)
	await _end_speech()
	assert_eq(rally.case.report().salary, _pay_without_extras())


func test_loose_at_the_end_the_courier_runs_off_on_the_scooter() -> void:
	await _end_speech()
	assert_eq(rally.case.runner, rally.courier)
	assert_eq(rally.case.chase.who, ChaseSuspect.COURIER)
	assert_false(rally.courier.visible, "he left on it")
	assert_eq(rally.case.snapshot().runner, PoliticianCase.COURIER_RUNNER)
	var texts: Array = rally.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_COURIER_CATCH_SCOOTER")
	var detained := rally.case.detained()
	rally.case._on_chase_ended(true)
	assert_true(rally.case.courier_detained(), "caught, he counts")
	assert_eq(rally.case.detained(), detained, "but not as a heckler")


func test_off_the_scooter_he_keeps_his_look_and_lines() -> void:
	var suspect := ChaseSuspect.new()
	suspect.kind = ChaseSuspect.COURIER
	assert_eq(ChaseSuspect.model_for(ChaseSuspect.COURIER), preload("res://assets/models/npc_repartidor.glb"))
	for key in suspect.lines():
		assert_ne(tr(key), key, key)
	suspect.free()


func test_a_guests_cakes_follow_the_snapshot() -> void:
	var rigged: BirthdayCake
	for cake in rally.cakes:
		if cake.rigged:
			rigged = cake
	var state: Array = rally.case.snapshot().cakes
	assert_eq(state.size(), 3)
	rigged.follow([false, true, false, true])
	assert_true(rigged.blown)
	assert_true(rigged.sprung)
	assert_false(rigged.lit)
