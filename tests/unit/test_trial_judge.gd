extends GutTest

## The fast trial jailbreak, step 2 (fuga-juicio.md): the court sits, the judge calls every cop but the lawyer to the
## stand, asks about each detail of the alibi, the witness answers with one of the three signs, and three
## contradictions in a trial are guilty: a catch.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TEST_PATH := "user://test_partidas/fuga_juicio_jueza.json"

var level: JailbreakLevel
var guard: TrialGuard
var judge: TrialJudge
var cop: Cop
var partner: Cop


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "trial"
	level.case_seed = 6161
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as TrialGuard
	guard.set_physics_process(false)
	judge = level.judge
	cop = level.get_node("Cop")
	partner = COP_SCENE.instantiate()
	partner.name = "Partner"
	partner.input_enabled = false
	level.add_child(partner)
	partner.global_transform = level.cop_spawn(1)
	await wait_physics_frames(2)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


## The court sits with `cop` as the lawyer: the partner is the only witness.
func _court() -> void:
	guard.call_to_trial()
	cop.put_on_disguise("lawyer_jacket", 0.0)
	guard.phase = "court"
	await wait_physics_frames(2)


## She reacts to the answer and asks the next question.
func _react() -> void:
	for i in int(TrialJudge.REACT_TIME * 30) + 2:
		judge._physics_process(1.0 / 30.0)


func _sign_with(key: String) -> TrialSign:
	for sign_board in level.signs:
		if sign_board.answer_key() == key:
			return sign_board
	return null


func _wrong_sign() -> TrialSign:
	var right := TrialAlibi.answer(judge.alibi, judge.asking())
	for sign_board in level.signs:
		if sign_board.answer_key() != right:
			return sign_board
	return null


func test_the_court_sits_and_she_calls_the_witness() -> void:
	assert_eq(judge.state, "")
	await _court()
	assert_eq(judge.state, "calling")
	assert_eq(judge.witnesses, [partner.net_id()] as Array[String], "the lawyer doesn't testify")
	assert_true(judge.said().begins_with("TRIAL_JUDGE_CALL_"))
	var stand: TrialStand = level.get_node("TrialStand")
	assert_eq(stand.prompt_key(cop), "", "not the lawyer")
	assert_eq(stand.prompt_key(partner), "PROMPT_TAKE_STAND")
	stand.use(partner)
	assert_eq(judge.state, "asking")
	assert_almost_eq(partner.global_position.distance_to(judge.stand_spot.origin), 0.0, 0.2, "on the stand")
	assert_eq(judge.said(), "TRIAL_ASK_" + judge.asking())


func test_the_signs_show_the_lookalike_answers() -> void:
	await _court()
	assert_eq(level.signs[0].answer_key(), "", "blank until she asks")
	level.get_node("TrialStand").use(partner)
	var shown: Array[String] = []
	for sign_board in level.signs:
		shown.append(sign_board.answer_key())
		assert_eq(sign_board.prompt_key(partner), "PROMPT_TRIAL_ANSWER")
		assert_eq(sign_board.prompt_key(cop), "", "only the witness answers")
	assert_eq(shown, TrialAlibi.choices(judge.alibi, judge.asking()))
	assert_has(shown, TrialAlibi.answer(judge.alibi, judge.asking()))


func test_right_answers_through_every_detail() -> void:
	await _court()
	level.get_node("TrialStand").use(partner)
	var asked := {}
	for i in TrialJudge.QUESTIONS:
		asked[judge.asking()] = true
		_sign_with(TrialAlibi.answer(judge.alibi, judge.asking())).use(partner)
		assert_true(judge.said().begins_with("TRIAL_JUDGE_OK_"))
		assert_eq(level.signs[0].answer_key(), "", "the signs blank while she reacts")
		_react()
	assert_eq(asked.size(), TrialAlibi.DETAILS.size(), "one question for each detail")
	assert_eq(judge.contradictions, 0)
	assert_eq(judge.state, "done", "every witness heard")
	assert_eq(guard.times_caught, 0)


func test_a_wrong_answer_is_a_contradiction() -> void:
	await _court()
	level.get_node("TrialStand").use(partner)
	var first := judge.asking()
	_wrong_sign().use(partner)
	assert_eq(judge.contradictions, 1)
	assert_true(judge.said().begins_with("TRIAL_JUDGE_WRONG_"))
	_react()
	assert_ne(judge.asking(), first, "and on to the next question")


func test_three_contradictions_are_guilty() -> void:
	await _court()
	level.get_node("TrialStand").use(partner)
	for i in TrialJudge.CONTRADICTIONS:
		_wrong_sign().use(partner)
		if i < TrialJudge.CONTRADICTIONS - 1:
			_react()
	await wait_physics_frames(3)
	assert_eq(guard.times_caught, 1, "guilty: a catch")
	assert_eq(judge.said(), "TRIAL_JUDGE_GUILTY")
	assert_eq(judge.state, "", "waiting for the next trial")
	assert_eq(judge.alibi, level.alibi, "with the new alibi")
	assert_eq(level.trials, 1)
	assert_false(level.outside_cells(partner.global_position), "back in a cell")
