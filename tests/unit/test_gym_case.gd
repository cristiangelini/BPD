extends GutTest

## The gym's case (infiltracion-gimnasio.md, step 4, decision 172): the infiltration case with the gym's texts, 3 of
## its 6 pieces of evidence by the seed (the notebook and the whiteboard in the locked office, whose key is in a gym
## bag in the locker room; the painted safe that takes two cops to lift; the members' video; el Toro's shake; the
## truck's ticket in a locker), and cuffing el Toro solves it.

const LEVEL := preload("res://scenes/levels/gym_hall.tscn")

var gym: GymHall
var cop: Cop


## A gym whose seed has the evidence `kind`.
func _gym_with(kind: String) -> void:
	var case_seed := 1
	while true:
		gym = LEVEL.instantiate()
		gym.case_seed = case_seed
		gym.get_node("Cop").input_enabled = false
		add_child_autofree(gym)
		if gym.evidence.kinds.has(kind):
			break
		gym.free()
		case_seed += 1
	cop = gym.get_node("Cop")
	await wait_physics_frames(2)
	gym.routine.set_process(false)
	gym.case.give_tip()


func test_the_gym_case_with_its_own_texts() -> void:
	await _gym_with("notebook")
	assert_eq(gym.case.place, gym)
	assert_eq(gym.case.texts(), InfiltrationCase.VARIANTS["gym"])
	assert_eq(gym.case.rows()[0].text, "OBJ_GYM_GET_IN")
	assert_eq(gym.evidence.kinds.size(), ClubEvidence.COUNT)
	for kind: String in gym.evidence.kinds:
		assert_has(GymHall.EVIDENCE_KINDS, kind)


func test_grabbing_the_notebook_in_the_office() -> void:
	await _gym_with("notebook")
	var notebook: Grabbable = gym.evidence.items["notebook"]
	assert_true(gym.in_back_room(notebook.global_position), "in el Toro's office")
	cop.global_position = notebook.global_position + Vector3(0, -0.8, 1.0)
	cop.get_node("Grabber").grab(notebook)
	await wait_physics_frames(2)
	assert_has(gym.case.evidence_found, "notebook")


func test_the_office_key_is_in_the_bag_in_the_locker_room() -> void:
	await _gym_with("notebook")
	var bag: KeyPot = gym.get_node("KeyBag")
	assert_true(gym.in_locker_room(bag.global_position))
	assert_eq(bag.prompt_key(cop), "PROMPT_GYM_BAG")
	assert_true(gym.office_door.locked)
	bag.use(cop)
	assert_true(cop.has_key)


func test_grabbing_the_shake_on_the_ring() -> void:
	await _gym_with("shake")
	var shake: Grabbable = gym.evidence.items["shake"]
	var local := gym.global_transform.affine_inverse() * shake.global_position
	assert_true(GymHall.RING.grow(0.1).has_point(Vector2(local.x, local.z)), "on the ring")
	cop.global_position = shake.global_position + Vector3(0, -0.8, 1.0)
	cop.get_node("Grabber").grab(shake)
	await wait_physics_frames(2)
	assert_has(gym.case.evidence_found, "shake")


func test_the_painted_safe_counts_once_lifted() -> void:
	await _gym_with("safe")
	var safe: Grabbable = gym.evidence.items["safe"]
	assert_almost_eq(safe.mass, GymHall.SAFE_KG, 0.01)
	assert_gt(safe.mass, GameScale.COP_CARRY_KG, "one cop can't lift it")
	await wait_physics_frames(10)
	assert_false(gym.case.evidence_found.has("safe"), "grabbing it isn't enough")
	safe.freeze = true
	safe.global_position += gym.global_basis.y * (GymHall.SAFE_LIFT + 0.1)
	await wait_physics_frames(2)
	assert_has(gym.case.evidence_found, "safe")


func test_photographing_the_whiteboard_and_searching_the_locker() -> void:
	await _gym_with("whiteboard")
	var board: ClubEvidenceSpot = gym.get_node("Evidence_whiteboard")
	assert_true(gym.in_back_room(board.global_position))
	board.use(cop)
	assert_false(gym.case.evidence_found.has("whiteboard"), "E isn't a photo")
	board.photographed(cop)
	assert_has(gym.case.evidence_found, "whiteboard")
	await _gym_with("ticket")
	var locker: ClubEvidenceSpot = gym.get_node("Evidence_ticket")
	assert_true(gym.in_locker_room(locker.global_position))
	locker.use(cop)
	assert_has(gym.case.evidence_found, "ticket")


func test_the_recording_members_train_by_each_other() -> void:
	await _gym_with("recording")
	assert_eq(gym.evidence.talkers.size(), 2)
	assert_false(gym.evidence.talkers.has(gym.toro))
	var apart := gym.evidence.talkers[0].global_position.distance_to(gym.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_cuffing_el_toro_solves_it() -> void:
	await _gym_with("notebook")
	for kind: String in gym.evidence.kinds.slice(0, 2):
		gym.case.found(kind)
	gym.toro.cuffed(20.0)
	assert_true(gym.case.solved())
	assert_eq(gym.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(gym.case.custody().owner, "toro")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_toro"))
	assert_true(ChaseSuspect.MODELS.has("toro"))


func test_cuffing_a_member_gives_them_away() -> void:
	await _gym_with("notebook")
	gym.members[0].cuffed(5.0)
	assert_true(gym.suspicion.found_out)


func test_the_case_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_GO_GYM", "HINT_GYM_IN", "HINT_TORO_CUFFED", "HINT_ESCAPE_toro",
		"OBJ_GYM_GET_IN", "OBJ_GYM_EVIDENCE", "OBJ_GYM_CUFF_TORO", "OBJ_GYM_CATCH_TORO", "OBJ_GYM_CAREFUL",
		"OBJ_GYM_FOUND_OUT", "PROMPT_GYM_BAG", "PROMPT_GYM_whiteboard", "PROMPT_GYM_ticket", "CRIME_owner_toro",
		"CONFESS_owner_toro"]
	keys.append_array(InfiltrationCase.VARIANTS["gym"].brief)
	for kind: String in GymHall.EVIDENCE_KINDS:
		keys.append("EVIDENCE_GYM_" + kind)
	for i in 4:
		keys.append("GYM_TALK_%d" % i)
	for i in 3:
		keys.append("TORO_SLIP_%d" % (i + 1))
		keys.append("CHASE_TORO_LINE_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
