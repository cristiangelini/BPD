extends GutTest

## The parade's case (politico-descapotable.md, step 3, decision 222): the comisario tells the parade, the planilla
## shows how far round the plaza the car is and the huggers pulled off, the pay is the rally's, a hugger still up gets
## off when it ends, and a heckler still loose runs off on the kick scooter from their sidewalk.

const LEVEL := preload("res://scenes/levels/plaza_convertible.tscn")
const TEST_PATH := "user://test_partidas/politico_descapotable_caso.json"
const STEP := 1.0 / 60.0

var rally: PlazaRally
var huggers: ParadeHuggers
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
	huggers = rally.huggers
	huggers.set_physics_process(false)
	cop = rally.get_node("Cop")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _texts() -> Array:
	return rally.case.rows().map(func(row: Dictionary) -> String: return row.text)


func _hug() -> RallyFan:
	huggers._wait_left = 0.0
	for i in 3000:
		if huggers.state == ParadeHuggers.State.HUGGING:
			break
		huggers._physics_process(STEP)
	return huggers.hugger


func test_the_comisario_tells_the_parade() -> void:
	cop.input_enabled = true
	rally.case.tip_given = false
	rally.case.give_tip()
	cop.input_enabled = false
	assert_eq(rally.case.briefing.lines, PackedStringArray(["BRIEF_PARADE_A", "BRIEF_PARADE_B", "BRIEF_PARADE_C"]))


func test_the_planilla_shows_the_route_and_the_huggers() -> void:
	assert_has(_texts(), tr("OBJ_PARADE_ROUTE") % 0)
	assert_has(_texts(), tr("OBJ_PARADE_HUGGERS") % 0)
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME / 4
	await wait_physics_frames(2)
	assert_has(_texts(), tr("OBJ_PARADE_ROUTE") % 75)
	var fan := _hug()
	fan.use(cop)
	assert_eq(huggers.pulled, 1)
	assert_has(_texts(), tr("OBJ_PARADE_HUGGERS") % 1)


func test_at_the_end_the_hugger_gets_off_and_a_heckler_runs_off() -> void:
	rally.speech.start()
	var fan := _hug()
	assert_true(fan.hugging)
	rally.speech.left = 0.05
	await wait_physics_frames(10)
	huggers._physics_process(STEP)
	assert_false(fan.hugging, "off the car")
	assert_ne(huggers.state, ParadeHuggers.State.HUGGING)
	assert_true(rally.case.speech_over)
	assert_has(_texts(), "OBJ_PARADE_OVER")
	assert_eq((cop.get_node("Hud/Hint") as Label).text, "HINT_ESCAPE_HECKLER", "the last heckler runs off")
	assert_true(rally.case.runner in rally.crowd.hecklers)
	assert_not_null(rally.case.chase)


func test_the_pay_is_the_rallys() -> void:
	rally.speech.start()
	_hug()
	for i in int(ParadeHuggers.STAIN_EVERY / STEP) + 5:
		huggers._physics_process(STEP)
	assert_eq(rally.politician.stains, 1)
	rally.speech.left = 0.05
	await wait_physics_frames(10)
	assert_true(rally.case.solved())
	assert_eq(rally.case.report().salary, PoliticianCase.SALARY - PoliticianCase.PER_STAIN)
