extends GutTest

## The church choir's case (infiltracion-coro.md, step 5a, decision 101): the same infiltration case as the club with
## the chapel's texts, 3 of its 6 pieces of evidence by the seed, and cuffing Maestro Ernesto solves it.

const LEVEL := preload("res://scenes/levels/church_choir.tscn")

var chapel: ChurchChoir
var cop: Cop


## A chapel whose seed draws `kind`.
func _chapel_with(kind: String) -> void:
	var case_seed := 1
	while not ClubEvidence.draw(case_seed, ChurchChoir.EVIDENCE_KINDS).has(kind):
		case_seed += 1
	chapel = LEVEL.instantiate()
	chapel.case_seed = case_seed
	cop = chapel.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(chapel)
	await wait_physics_frames(2)
	chapel.singing.set_process(false)
	chapel.case.give_tip()


func test_the_choir_case_with_its_own_texts() -> void:
	await _chapel_with("box")
	assert_eq(chapel.case.place, chapel)
	assert_eq(chapel.case.texts(), InfiltrationCase.VARIANTS["choir"])
	assert_eq(chapel.case.rows()[0].text, "OBJ_CHOIR_GET_IN")
	assert_eq(chapel.evidence.kinds.size(), ClubEvidence.COUNT)


func test_a_robed_cop_inside_gets_in() -> void:
	await _chapel_with("box")
	cop.put_on_disguise("robe", 0.0)
	cop.global_position = chapel.global_transform * Vector3(0, 0.1, 5.0)
	await wait_physics_frames(2)
	assert_true(chapel.case.got_in)


func test_grabbing_the_collection_box() -> void:
	await _chapel_with("box")
	var box: Grabbable = chapel.evidence.items["box"]
	cop.global_position = box.global_position + Vector3(0, -0.8, 1.0)
	cop.get_node("Grabber").grab(box)
	await wait_physics_frames(2)
	assert_has(chapel.case.evidence_found, "box")


func test_photographing_the_new_car() -> void:
	await _chapel_with("car")
	var spot: ClubEvidenceSpot = chapel.get_node("Evidence_car")
	spot.use(cop)
	assert_false(chapel.case.evidence_found.has("car"), "E isn't a photo")
	spot.photographed(cop)
	assert_has(chapel.case.evidence_found, "car")


func test_the_recording_talkers_stand_side_by_side() -> void:
	await _chapel_with("recording")
	assert_eq(chapel.evidence.talkers.size(), 2)
	var apart := chapel.evidence.talkers[0].global_position.distance_to(chapel.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_cuffing_ernesto_solves_it() -> void:
	await _chapel_with("box")
	chapel.case.found("box")
	chapel.case.found("ledger")
	chapel.ernesto.cuffed(20.0)
	assert_true(chapel.case.solved())
	assert_eq(chapel.case.report().salary, InfiltrationCase.SALARY * 2 / 3)


func test_cuffing_a_chorister_gives_them_away() -> void:
	await _chapel_with("box")
	chapel.members[0].cuffed(20.0)
	assert_true(chapel.suspicion.found_out)
