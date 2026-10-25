extends GutTest

## The politician protection case (proteccion-politico.md, step 6, decision 103): the speech is the clock, the pay
## counts stains and detained hecklers, and ten stains lose it.

const LEVEL := preload("res://scenes/levels/plaza_rally.tscn")

var rally: PlazaRally


func before_each() -> void:
	rally = LEVEL.instantiate()
	rally.case_seed = 7
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)


func test_the_comisario_tells_it_in_his_office() -> void:
	assert_false(rally.case.tip_given, "not before seeing him")
	rally.case.give_tip()
	assert_true(rally.case.tip_given)


func test_the_end_of_the_speech_solves_it() -> void:
	# Every heckler already in the patrol car: nobody runs off, so the shift ends.
	for heckler in rally.crowd.hecklers:
		OwnerEscort.of(heckler).board()
	rally.speech.start()
	rally.speech.left = 0.05
	await wait_physics_frames(10)
	assert_true(rally.case.speech_over)
	assert_true(rally.case.solved())
	assert_null(rally.case.chase)
	await wait_seconds(PoliticianCase.SHIFT_DELAY + 0.5)
	assert_true(rally.case.shift_over)


func test_a_loose_heckler_runs_off_when_the_speech_ends() -> void:
	rally.speech.start()
	rally.speech.left = 0.05
	await wait_physics_frames(10)
	assert_true(rally.case.solved())
	assert_not_null(rally.case.chase, "the last heckler gets away on the kick scooter")
	assert_false(rally.case.shift_over, "the chase comes first")


func test_the_pay_counts_stains_and_hecklers() -> void:
	rally.case.speech_over = true
	for i in 3:
		rally.politician.stain("egg", rally.politician.global_position + Vector3.UP)
	rally.crowd.detained = 2
	var pay := rally.case.report()
	assert_eq(pay.salary, PoliticianCase.SALARY - 3 * PoliticianCase.PER_STAIN + 2 * PoliticianCase.PER_HECKLER)
	assert_eq(pay.quota, PoliticianCase.QUOTA)
	assert_true(pay.approved)


func test_ten_stains_lose_it() -> void:
	for i in Politician.STAINS_MAX:
		rally.politician.stain("tomato", rally.politician.global_position + Vector3.UP)
	assert_true(rally.case.furious)
	assert_false(rally.case.solved())
	assert_eq(rally.case.report().salary, 0)
	assert_false(rally.speech.is_physics_processing(), "the speech stops")


func test_play_draws_it() -> void:
	var found := false
	for i in 400:
		if PlaceDraw.pick(i + 1, [], 1) == "plaza":
			found = true
			break
	assert_true(found)


func test_the_planilla_shows_stains_and_hecklers() -> void:
	rally.politician.stain("egg", rally.politician.global_position + Vector3.UP)
	var texts := rally.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, tr("OBJ_RALLY_STAINS") % [1, Politician.STAINS_MAX])
	assert_has(texts, tr("OBJ_RALLY_HECKLERS") % [0, RallyCrowd.HECKLERS])
