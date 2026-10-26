extends GutTest

## The fast trial jailbreak, step 3 (fuga-juicio.md): the lawyer objects once for each witness, every witness heard
## with fewer than three contradictions is innocent and they're free to walk out, and alone the lawyer testifies
## without the file.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TEST_PATH := "user://test_partidas/fuga_juicio_veredicto.json"

var level: JailbreakLevel
var guard: TrialGuard
var judge: TrialJudge
var cop: Cop
var lot: Transform3D


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
	judge.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _partner() -> Cop:
	var partner: Cop = COP_SCENE.instantiate()
	partner.name = "Partner"
	partner.input_enabled = false
	level.add_child(partner)
	partner.global_transform = level.cop_spawn(1)
	await wait_physics_frames(2)
	return partner


func _court() -> void:
	guard.call_to_trial()
	cop.put_on_disguise("lawyer_jacket", 0.0)
	guard.phase = "court"
	await wait_physics_frames(2)


func _react() -> void:
	for i in int(TrialJudge.REACT_TIME * 30) + 2:
		judge._physics_process(1.0 / 30.0)


func _answer(witness: Cop, right: bool) -> void:
	var key := TrialAlibi.answer(judge.alibi, judge.asking())
	for sign_board in level.signs:
		if (sign_board.answer_key() == key) == right:
			sign_board.use(witness)
			return


func test_the_lawyer_objects_once_for_each_witness() -> void:
	var partner := await _partner()
	await _court()
	level.get_node("TrialStand").use(partner)
	assert_eq(judge.prompt_key(partner), "", "the witness can't object")
	assert_eq(judge.prompt_key(cop), "PROMPT_OBJECTION")
	var first := judge.asking()
	judge.use(cop)
	assert_true(judge.said().begins_with("TRIAL_JUDGE_SUSTAINED_"))
	_react()
	assert_ne(judge.asking(), first, "that question didn't count")
	assert_eq(judge.contradictions, 0)
	assert_eq(judge.prompt_key(cop), "", "only once for this witness")


func test_innocent_they_walk_out() -> void:
	var partner := await _partner()
	await _court()
	level.get_node("TrialStand").use(partner)
	_answer(partner, false)
	_react()
	_answer(partner, true)
	_react()
	_answer(partner, false)
	_react()
	assert_eq(judge.contradictions, 2)
	assert_eq(judge.state, "done")
	assert_eq(judge.said(), "TRIAL_JUDGE_INNOCENT")
	assert_eq(guard.phase, "free")
	assert_false(level.outside_cells(lot * Vector3(0, 0.1, StationRooms.HALF_Z + 3.0)), "the street is fine now")
	partner.global_position = lot * Vector3(0, 0.1, StationRooms.HALF_Z + 3.0)
	assert_eq(guard.alarm(), 0.0)
	assert_eq(guard.times_caught, 0)


func test_alone_the_lawyer_testifies_without_the_file() -> void:
	await _court()
	assert_eq(judge.witnesses, [cop.net_id()] as Array[String], "the lawyer is the witness")
	assert_true(level.file_label.visible, "the file while called")
	level.get_node("TrialStand").use(cop)
	await wait_physics_frames(2)
	assert_false(level.file_label.visible, "put away on the stand")
	for i in TrialJudge.QUESTIONS:
		_answer(cop, true)
		_react()
	assert_eq(guard.phase, "free")
	await wait_physics_frames(2)
	assert_true(level.file_label.visible, "and back after")
