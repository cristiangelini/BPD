extends GutTest

## The mime troupe's case (infiltracion-mimos.md, step 5, decision 170): the same infiltration case as the club and
## the choir with the theater's texts, 3 of its 6 pieces of evidence by the seed, and cuffing Maestra Pausa solves it.

const LEVEL := preload("res://scenes/levels/mime_theater.tscn")

var theater: MimeTheater
var cop: Cop


## A theater whose seed draws `kind`.
func _theater_with(kind: String) -> void:
	var case_seed := 1
	while not ClubEvidence.draw(case_seed, MimeTheater.EVIDENCE_KINDS).has(kind):
		case_seed += 1
	theater = LEVEL.instantiate()
	theater.case_seed = case_seed
	cop = theater.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(theater)
	await wait_physics_frames(2)
	theater.rehearsal.set_process(false)
	theater.case.give_tip()


func test_the_mime_case_with_its_own_texts() -> void:
	await _theater_with("box")
	assert_eq(theater.case.place, theater)
	assert_eq(theater.case.texts(), InfiltrationCase.VARIANTS["mime"])
	assert_eq(theater.case.rows()[0].text, "OBJ_MIME_GET_IN")
	assert_eq(theater.evidence.kinds.size(), ClubEvidence.COUNT)


func test_a_mime_cop_inside_gets_in() -> void:
	await _theater_with("box")
	cop.put_on_disguise("mime_beret", 0.0)
	cop.put_on_disguise("mime_shirt", 0.0)
	cop.global_position = theater.global_transform * Vector3(0, 0.1, 5.0)
	await wait_physics_frames(2)
	assert_true(theater.case.got_in)


func test_grabbing_the_invisible_box() -> void:
	await _theater_with("box")
	var box: Grabbable = theater.evidence.items["box"]
	cop.global_position = box.global_position + Vector3(0, -0.2, 1.0)
	cop.get_node("Grabber").grab(box)
	await wait_physics_frames(2)
	assert_has(theater.case.evidence_found, "box")


func test_grabbing_the_bag_of_watches_on_the_trunk() -> void:
	await _theater_with("watches")
	var bag: Grabbable = theater.evidence.items["watches"]
	var local := theater.global_transform.affine_inverse() * bag.global_position
	assert_almost_eq(Vector2(local.x, local.z), Vector2(MimeTheater.TRUNK_AT.x, MimeTheater.TRUNK_AT.z), Vector2.ONE * 0.1)
	cop.global_position = bag.global_position + Vector3(0, -0.8, 1.0)
	cop.get_node("Grabber").grab(bag)
	await wait_physics_frames(2)
	assert_has(theater.case.evidence_found, "watches")


func test_photographing_the_dummy_and_the_map() -> void:
	for kind: String in ["dummy", "map"]:
		await _theater_with(kind)
		var spot: ClubEvidenceSpot = theater.get_node("Evidence_" + kind)
		spot.use(cop)
		assert_false(theater.case.evidence_found.has(kind), "E isn't a photo")
		spot.photographed(cop)
		assert_has(theater.case.evidence_found, kind)
		theater.queue_free()
		await wait_physics_frames(1)


func test_the_dressing_room_key_is_in_a_prop_room_pot() -> void:
	await _theater_with("ledger")
	var pot: KeyPot = theater.get_node("KeyPot")
	assert_true(pot.has_key)
	assert_true(theater.in_back_room(pot.global_position + Vector3.UP * 0.2))
	var ledger: Node3D = theater.evidence.items["ledger"]
	assert_lt((theater.global_transform.affine_inverse() * ledger.global_position).x, MimeTheater.ROOMS_SPLIT_X,
		"the ledger is in the dressing room")


func test_the_recording_mimes_stand_side_by_side() -> void:
	await _theater_with("recording")
	assert_eq(theater.evidence.talkers.size(), 2)
	var apart := theater.evidence.talkers[0].global_position.distance_to(theater.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_cuffing_pausa_solves_it() -> void:
	await _theater_with("box")
	theater.case.found("box")
	theater.case.found("ledger")
	theater.pausa.cuffed(20.0)
	assert_true(theater.case.solved())
	assert_eq(theater.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(theater.case.custody().owner, "pausa")


func test_cuffing_a_mime_gives_them_away() -> void:
	await _theater_with("box")
	theater.members[0].cuffed(20.0)
	assert_true(theater.suspicion.found_out)
