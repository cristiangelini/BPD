extends GutTest

## The biker gang's case (infiltracion-motos.md, step 5, decision 176): the infiltration case with the bar's texts, 3
## of its 6 pieces of evidence by the seed (the box of stolen car radios in the workshop, the stolen steering wheel on
## the counter, the map of the car parks on the workshop's wall, El Cromado's jacket on the coat rack, the sales book
## in the locked office, whose key is in his moped's tank, and two bikers' talk to record), the pleased bikers' tips
## and El Cromado to cuff.

const LEVEL := preload("res://scenes/levels/biker_bar.tscn")

var bar: BikerBar
var cop: Cop


## A bar whose seed has the evidence `kind`.
func _bar_with(kind: String) -> void:
	var case_seed := 1
	while true:
		bar = LEVEL.instantiate()
		bar.case_seed = case_seed
		bar.get_node("Cop").input_enabled = false
		add_child_autofree(bar)
		if bar.evidence.kinds.has(kind):
			break
		bar.free()
		case_seed += 1
	cop = bar.get_node("Cop")
	await wait_physics_frames(2)
	bar.dares.set_physics_process(false)
	bar.case.give_tip()


## Solving it leaves El Cromado in custody for the next shift's draw (RaidCase): not for the next test's.
func after_each() -> void:
	PlaceDraw.custody = {}


func test_the_biker_case_with_its_own_texts() -> void:
	await _bar_with("radios")
	assert_eq(bar.case.place, bar)
	assert_eq(bar.case.texts(), InfiltrationCase.VARIANTS["biker"])
	assert_eq(bar.case.rows()[0].text, "OBJ_BIKER_GET_IN")
	assert_eq(bar.evidence.kinds.size(), ClubEvidence.COUNT)
	for kind: String in bar.evidence.kinds:
		assert_has(BikerBar.EVIDENCE_KINDS, kind)


func test_grabbing_the_box_of_car_radios_in_the_workshop() -> void:
	await _bar_with("radios")
	var radios: Grabbable = bar.evidence.items["radios"]
	assert_true(bar.in_workshop(radios.global_position))
	cop.global_position = radios.global_position + Vector3(0, -0.2, 1.0)
	cop.get_node("Grabber").grab(radios)
	await wait_physics_frames(2)
	assert_has(bar.case.evidence_found, "radios")


func test_grabbing_the_steering_wheel_on_the_counter() -> void:
	await _bar_with("wheel")
	var wheel: Grabbable = bar.evidence.items["wheel"]
	assert_true(bar.in_bar(wheel.global_position))
	cop.global_position = wheel.global_position + Vector3(1.0, -1.1, 0)
	cop.get_node("Grabber").grab(wheel)
	await wait_physics_frames(2)
	assert_has(bar.case.evidence_found, "wheel")


func test_the_office_key_is_in_the_moped_tank() -> void:
	await _bar_with("radios")
	var key: KeyPot = bar.get_node("KeyTank")
	assert_true(bar.in_workshop(key.global_position))
	assert_lt(Vector2(key.position.x - BikerBar.MOPED_AT.x, key.position.z - BikerBar.MOPED_AT.z).length(), 1.0,
		"on the moped")
	assert_eq(key.prompt_key(cop), "PROMPT_BIKER_TANK_KEY")
	assert_true(bar.office_door.locked)
	key.use(cop)
	assert_true(cop.has_key)


func test_photographing_the_map_of_the_car_parks() -> void:
	await _bar_with("map")
	var map: ClubEvidenceSpot = bar.get_node("Evidence_map")
	assert_true(bar.in_workshop(map.global_position))
	map.use(cop)
	assert_false(bar.case.evidence_found.has("map"), "E isn't a photo")
	map.photographed(cop)
	assert_has(bar.case.evidence_found, "map")


func test_searching_the_jacket_and_the_office_desk() -> void:
	await _bar_with("jacket")
	var jacket: ClubEvidenceSpot = bar.get_node("Evidence_jacket")
	assert_true(bar.in_bar(jacket.global_position), "on the coat rack")
	jacket.use(cop)
	assert_has(bar.case.evidence_found, "jacket")
	await _bar_with("ledger")
	var desk: ClubEvidenceSpot = bar.get_node("Evidence_ledger")
	assert_true(bar.in_back_room(desk.global_position), "in El Cromado's office")
	desk.use(cop)
	assert_has(bar.case.evidence_found, "ledger")


func test_the_recording_pair_stands_by_each_other() -> void:
	await _bar_with("recording")
	assert_eq(bar.evidence.talkers.size(), 2)
	for talker in bar.evidence.talkers:
		assert_ne(talker, bar.cromado)
		assert_true(talker.distracted, "busy talking")
	var apart := bar.evidence.talkers[0].global_position.distance_to(bar.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_a_pleased_biker_tips_the_evidence_not_found_yet() -> void:
	await _bar_with("radios")
	var kinds: Array = bar.evidence.kinds
	assert_eq(bar.dares.tip(), "BIKER_TIP_" + kinds[0])
	bar.case.found(kinds[0])
	assert_eq(bar.dares.tip(), "BIKER_TIP_" + kinds[1])
	for kind: String in kinds:
		bar.case.found(kind)
	assert_eq(bar.dares.tip(), "BIKER_RESPECT")


func test_cuffing_el_cromado_solves_it() -> void:
	await _bar_with("radios")
	for kind: String in bar.evidence.kinds.slice(0, 2):
		bar.case.found(kind)
	bar.cromado.cuffed(20.0)
	assert_true(bar.case.solved())
	assert_eq(bar.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(bar.case.custody().owner, "cromado")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_cromado"))
	assert_true(ChaseSuspect.MODELS.has("cromado"))


func test_cuffing_a_biker_gives_them_away() -> void:
	await _bar_with("radios")
	bar.members[0].cuffed(5.0)
	assert_true(bar.suspicion.found_out)


func test_the_case_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_GO_BIKER", "HINT_BIKER_IN", "HINT_CROMADO_CUFFED", "HINT_ESCAPE_cromado",
		"OBJ_BIKER_GET_IN", "OBJ_BIKER_EVIDENCE", "OBJ_BIKER_CUFF_CROMADO", "OBJ_BIKER_CATCH_CROMADO",
		"OBJ_BIKER_CAREFUL", "OBJ_BIKER_FOUND_OUT", "PROMPT_BIKER_TANK_KEY", "PROMPT_BIKER_map", "PROMPT_BIKER_jacket",
		"PROMPT_BIKER_ledger", "CRIME_owner_cromado", "CONFESS_owner_cromado"]
	keys.append_array(InfiltrationCase.VARIANTS["biker"].brief)
	for kind: String in BikerBar.EVIDENCE_KINDS:
		keys.append("EVIDENCE_BIKER_" + kind)
		keys.append("BIKER_TIP_" + kind)
	for i in 4:
		keys.append("BIKER_TALK_%d" % i)
	for i in 3:
		keys.append("CROMADO_SLIP_%d" % (i + 1))
		keys.append("CHASE_CROMADO_LINE_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
