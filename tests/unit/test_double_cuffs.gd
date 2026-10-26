extends GutTest

## Cuffing at the double's rally (politico-doble.md, step 3, decision 220): the cuffed double is caught for good (his
## mustache falls off), leaves the lectern and is walked to the patrol car for 150 more; the real deputy cuffed is
## offended, three stains on his image, and the cuffs open at once; a double still loose when the speech ends runs off
## on the kick scooter instead of a heckler.

const LEVEL := preload("res://scenes/levels/plaza_double.tscn")
const TEST_PATH := "user://test_partidas/politico_doble_esposas.json"
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
	cop = rally.get_node("Cop")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _end_speech() -> void:
	rally.speech.start()
	rally.speech.left = 0.05
	await wait_physics_frames(10)


## The double at the lectern, as after a swap.
func _double_at_lectern() -> void:
	rally.swap.set_physics_process(false)
	PoliticianWalks.of(rally.politician).walk_off()
	for i in 4000:
		rally.swap._physics_process(STEP)
		if rally.swap.state == DoubleSwap.State.SPEAKING:
			return


func test_the_cuffed_double_is_caught_for_good() -> void:
	_double_at_lectern()
	assert_eq(rally.speech.impostor, rally.double)
	cop.belt_select(0)
	var cuffs: Handcuffs = cop.belt.held_tool()
	assert_eq(cuffs.cuff_body(rally.double, rally.double.global_position + Vector3.UP), rally.double)
	assert_true(rally.double.caught)
	assert_true(rally.double.is_cuffed())
	assert_false(rally.double.tells.get_node("mustache").visible, "his mustache falls off")
	assert_true(rally.double.said().begins_with("DOUBLE_CAUGHT_"))
	assert_eq(rally.swap.state, DoubleSwap.State.CAUGHT)
	assert_null(rally.speech.impostor, "off the lectern")
	assert_false(PoliticianWalks.of(rally.double).is_physics_processing())
	PoliticianWalks.of(rally.politician).state = PoliticianWalks.State.SPEAKING
	PoliticianWalks.of(rally.politician).walk_off()
	assert_eq(rally.swap.state, DoubleSwap.State.CAUGHT, "no more sneaking")


func test_walked_to_the_patrol_car_he_pays_150() -> void:
	rally.double.disguise(false)
	rally.double.cuffed(Handcuffs.SECONDS)
	assert_eq(rally.double.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	rally.double.use(cop)
	assert_eq(OwnerEscort.of(rally.double).escorted_by, cop)
	var texts: Array = rally.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_DOUBLE_CATCH")
	assert_false(rally.case.double_detained())
	OwnerEscort.of(rally.double).board()
	assert_true(rally.case.double_detained())
	assert_false(rally.case.double_loose())
	await _end_speech()
	assert_true(rally.case.solved())
	var pay := rally.case.report()
	assert_eq(pay.salary, PoliticianCase.SALARY + PoliticianCase.PER_DOUBLE + PoliticianCase.PER_HECKLER
		* rally.case.detained() - PoliticianCase.PER_STAIN * rally.politician.stains)
	assert_ne(rally.case.runner, rally.double, "he's in the car: a heckler runs off instead")


func test_cuffing_the_real_deputy_offends_him() -> void:
	cop.belt_select(0)
	var cuffs: Handcuffs = cop.belt.held_tool()
	cuffs.cuff_body(rally.politician, rally.politician.global_position + Vector3.UP)
	assert_eq(rally.politician.stains, PlazaRally.WRONG_CUFF_STAINS)
	assert_true(rally.politician.said().begins_with("POLITICIAN_WRONG_CUFF_"))
	assert_false(rally.politician.is_cuffed(), "the cuffs open at once")
	assert_null(OwnerEscort.of(rally.politician))
	assert_ne(rally.politician.prompt_key(cop), "PROMPT_ESCORT_OWNER")


func test_at_the_plain_rally_the_cuffs_cost_nothing() -> void:
	var plain: PlazaRally = preload("res://scenes/levels/plaza_rally.tscn").instantiate()
	plain.case_seed = 4242
	plain.get_node("Cop").input_enabled = false
	add_child_autofree(plain)
	await wait_physics_frames(2)
	plain.politician.cuffed(Handcuffs.SECONDS)
	assert_eq(plain.politician.stains, 0)
	assert_false(plain.politician.is_cuffed())


func test_loose_at_the_end_the_double_runs_off_on_the_scooter() -> void:
	await _end_speech()
	assert_eq(rally.case.runner, rally.double)
	assert_not_null(rally.case.chase)
	assert_eq(rally.case.chase.who, ChaseSuspect.DOUBLE)
	assert_false(rally.double.visible, "he left on it")
	var texts: Array = rally.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_DOUBLE_CATCH_SCOOTER")
	var detained := rally.case.detained()
	rally.case._on_chase_ended(true)
	assert_true(rally.case.double_detained(), "caught, he counts")
	assert_eq(rally.case.detained(), detained, "but not as a heckler")


func test_off_the_scooter_he_keeps_his_look_and_lines() -> void:
	var suspect := ChaseSuspect.new()
	suspect.kind = ChaseSuspect.DOUBLE
	assert_eq(ChaseSuspect.model_for(ChaseSuspect.DOUBLE), preload("res://assets/models/npc_politico.glb"))
	for key in suspect.lines():
		assert_ne(tr(key), key, key)
	suspect.free()
