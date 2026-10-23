extends GutTest

## Deputy Lustre's walks off the stage (proteccion-politico.md, step 5, decision 103): he leaves the lectern to greet
## the crowd, a cop leads him back by the hand and the speech goes on from the lectern.

const LEVEL := preload("res://scenes/levels/plaza_rally.tscn")

var rally: PlazaRally
var cop: Cop
var walks: PoliticianWalks


func before_each() -> void:
	rally = LEVEL.instantiate()
	rally.case_seed = 7
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	cop = rally.get_node("Cop")
	walks = PoliticianWalks.of(rally.politician)
	await wait_physics_frames(2)


func test_he_walks_off_during_the_speech() -> void:
	watch_signals(walks)
	rally.speech.start()
	walks._walk_left = 0.0
	await wait_physics_frames(2)
	assert_signal_emitted(walks, "walked_off")
	assert_true(rally.politician.off_stage())
	assert_eq(rally.politician.said(), "POLITICIAN_OFF")


func test_he_stays_put_before_the_speech() -> void:
	walks._walk_left = 0.0
	await wait_physics_frames(3)
	assert_false(rally.politician.off_stage(), "he only walks off while speaking")


func test_he_goes_down_the_ramp_to_the_crowd() -> void:
	walks.walk_off()
	await wait_until(func() -> bool: return walks.state == PoliticianWalks.State.GREETING, 25.0)
	assert_eq(walks.state, PoliticianWalks.State.GREETING)
	assert_lt(rally.politician.global_position.y, rally.stage_top.y - 0.5, "down on the plaza")


func test_off_the_stage_e_takes_him_by_the_hand() -> void:
	walks.walk_off()
	assert_eq(rally.politician.prompt_key(cop), "PROMPT_LEAD_POLITICIAN")
	rally.politician.use(cop)
	assert_eq(walks.state, PoliticianWalks.State.LED)
	assert_string_starts_with(rally.politician.said(), "POLITICIAN_LED_")
	assert_eq(rally.politician.prompt_key(cop), "PROMPT_LET_GO_POLITICIAN")
	rally.politician.use(cop)
	assert_eq(walks.state, PoliticianWalks.State.WALKING, "let go, he goes greeting again")


func test_led_onto_the_stage_he_goes_back_to_the_lectern() -> void:
	watch_signals(walks)
	walks.walk_off()
	rally.politician.use(cop)
	cop.global_position = walks.podium + Vector3(0, 0, -1)
	rally.politician.global_position = walks.podium + Vector3(1, 0, 0)
	await wait_until(func() -> bool: return walks.state == PoliticianWalks.State.SPEAKING, 5.0)
	assert_signal_emitted(walks, "back")
	assert_eq(rally.politician.said(), "POLITICIAN_BACK")
	assert_almost_eq(rally.politician.global_position.distance_to(walks.podium), 0.0, 0.05)
	assert_eq(cop.stats.get("politician_returns", 0), 1)


func test_off_the_stage_the_speech_lines_wait() -> void:
	rally.speech.start()
	walks.walk_off()
	rally.speech._line_left = 0.0
	await wait_physics_frames(2)
	assert_false(rally.politician.said().begins_with("SPEECH_LUSTRE_"), "he greets instead")
	assert_lt(rally.speech.left, PoliticianSpeech.SPEECH_TIME, "the clock goes on")


func test_the_award_counts_trips_back() -> void:
	var awards := ShiftReport.awards([{"politician_returns": 2}])
	assert_eq(awards.map(func(award: Dictionary) -> String: return award.key).has("AWARD_POLITICIAN_RETURNS"), true)
