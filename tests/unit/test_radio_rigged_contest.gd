extends GutTest

## The radio as a raid with the rigged contest's story (allanamiento-radio.md, step 5): the suspicions, the urn and its
## extras hidden with the seed, Tito winning again on air, the slip by the mailbox, what don Volumen lets slip and what
## doña Rosa heard, and the urn in the trunk solving the case.

const SCENE := preload("res://scenes/levels/radio_station.tscn")


func _radio(case_seed := 5) -> RadioStation:
	var radio: RadioStation = SCENE.instantiate()
	radio.story_id = "rigged_contest"
	radio.case_seed = case_seed
	radio.get_node("Cop").input_enabled = false
	radio.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(radio)
	return radio


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_eq(radio.raid.suspicions.size(), 3)
	assert_has(radio.raid.suspicions, "rigged_contest")
	for id: String in radio.raid.suspicions:
		assert_has(RadioStation.SUSPICION_POOL, id)
	assert_eq(radio.raid.owner_npc, radio.volumen)


func test_the_urn_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_eq(radio.main, radio.hidden[0])
	assert_almost_eq((radio.main as RigidBody3D).mass, 4.0, 0.01)
	assert_true(RadioStation.SPOTS[radio.hidden_spots[0]].heavy, "the urn in a spot it fits")
	assert_eq(radio.extras.size(), 2, "the blender and the winners list")
	var other := _radio(6)
	await wait_physics_frames(2)
	assert_ne(radio.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_tito_wins_again_on_air_and_the_slip_is_a_clue() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	var rig := radio.rig as RiggedContestRig
	rig.announce()
	assert_eq(rig.announced, 1)
	radio.set_on_air(false)
	rig.announce()
	assert_eq(rig.announced, 1, "off air nobody hears it")
	rig.slip.use(radio.get_node("Cop"))
	assert_has(radio.raid.clues_found, tr("CLUE_TITO_SLIP"))


func test_volumen_slips_and_rosa_heard_where() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	assert_eq(radio.volumen.slips.size(), 3)
	assert_true(radio.volumen.ask(radio.get_node("Cop")))
	assert_eq(radio.raid.clues_found.size(), 1)
	var where := tr("LOC_" + RadioStation.SPOTS[radio.hidden_spots[5 % 3]].id)
	assert_eq(radio.rosa.clue, tr("CLUE_ROSA") % where)
	radio.rosa.told.emit(radio.rosa.clue)
	assert_has(radio.raid.clues_found, radio.rosa.clue, "on the checklist")


func test_the_lawyer_loses_the_case() -> void:
	var radio := _radio()
	await wait_physics_frames(2)
	radio.volumen.scold(FloorBoss.MAX_COMPLAINT, "VOLUMEN_NOTICED")
	assert_true(radio.raid.case_failed)


func test_the_urn_in_the_trunk_solves_the_case() -> void:
	var radio := _radio()
	await wait_physics_frames(10)
	var urn := radio.main
	urn.global_position = radio.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(radio.car.is_delivered(urn))
	assert_true(radio.raid.mark(radio.raid.suspicions.find("rigged_contest")))
	assert_eq(radio.raid.objective_facts().extras.size(), 2)
	radio.car.enter(radio.get_node("Cop"))
	assert_true(radio.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_RADIO_TIP_B", "BRIEF_RADIO_TIP_D", "BRIEF_RADIO_TIP_E",
		"BRIEF_RIGGED_CONTEST_B", "BRIEF_RIGGED_CONTEST_C", "BRIEF_RIGGED_CONTEST_D", "OBJ_FIND_RAFFLE_URN",
		"OBJ_EXTRA_BLENDER", "OBJ_EXTRA_WINNERS_LIST", "OBJ_ENTER_RADIO", "OBJ_GUESS_RADIO", "OBJ_BROKEN_RADIO",
		"OBJ_COMPLAINT_RADIO", "VOLUMEN_SLIP", "CLUE_ROSA", "ROSA_CLUE_rigged_contest", "RADIO_TITO_WINS",
		"CLUE_TITO_SLIP", "HINT_ESCAPE_radio", "CRIME_owner_radio", "CONFESS_owner_radio", "CASE_FAILED_LAWYER_RADIO"]
	for id: String in RadioStation.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_radio"))
	assert_true(ChaseSuspect.MODELS.has("radio"))
	assert_true(RaidEscape.PLACES.has("radio"))


func test_don_volumen_gets_away_in_a_car() -> void:
	var radio := _radio(7)
	await wait_physics_frames(30)
	radio.raid.escape.flee()
	var chase := radio.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "radio")
