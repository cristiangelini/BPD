extends GutTest

## The wrong house as a case (docs/diseno/casa-equivocada.md, step 8): the same RaidCase as the other raids, with its
## own tip, suspicions among its six stories, its checklist rows, the door and story clues on the checklist, the
## fines on the shift pay and doña Chola's lawyer.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")

var place: WrongHouse
var cop: Cop


func _open(story := "bills", seed_value := 77) -> void:
	place = SCENE.instantiate()
	place.case_seed = seed_value
	place.story_id = story
	cop = place.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(place)
	await wait_physics_frames(2)


func test_the_raid_draws_three_of_its_own_stories_with_the_true_one() -> void:
	await _open("parrot")
	var raid := place.raid
	assert_eq(raid.story_id, "wh_parrot")
	assert_eq(raid.suspicions.size(), 3)
	assert_has(raid.suspicions, "wh_parrot")
	for id in raid.suspicions:
		assert_true(WrongHouse.STORIES.has(id.trim_prefix("wh_")), id)
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id, "named")
	assert_eq(raid.main_evidence, place.main)
	assert_eq(raid.find_key, "OBJ_FIND_WH_PARROT")


func test_door_and_story_clues_go_on_the_checklist() -> void:
	await _open("bills")
	place.paper.use(cop)
	(place.rig as WhBillsRig).bill_clue.use(cop)
	assert_eq(place.raid.clues_found, [place.paper.text, tr("CLUE_WH_FAKE_BILL")])


func test_fines_come_off_the_shift_pay_double_at_dona_cholas() -> void:
	await _open()
	place._on_ornament_broken(Vector3.ZERO, place.guilty)
	place._on_ornament_broken(Vector3.ZERO, place.chola_house())
	assert_eq(place.raid.fines, Ornament.FINE * (1 + WrongHouse.CHOLA_FINES))
	var facts := place.raid.objective_facts()
	assert_eq(facts.broken, 2)
	assert_eq(facts.complaint, place.chola.complaint)
	assert_eq(facts.complaint_key, "OBJ_COMPLAINT_WH")


func test_going_into_the_right_house_ticks_the_first_row() -> void:
	await _open()
	assert_false(place.raid.objective_facts().door_open)
	cop.set_physics_process(false)
	cop.global_position = WrongHouse.at(place.guilty, Vector3(-3.5, 0.2, 4.0))
	await wait_physics_frames(2)
	assert_true(place.raid.objective_facts().door_open)
	assert_true(place.neighbor.off_guard, "and he's caught off guard")


func test_dona_chola_calling_her_lawyer_loses_the_case() -> void:
	await _open()
	place.chola.lawyer_called.emit()
	assert_true(place.raid.case_failed)
	assert_eq(place.raid.failed_label.text, "CASE_FAILED_LAWYER_CHOLA")


func test_the_main_evidence_in_the_trunk_at_the_station_solves_it() -> void:
	await _open("letters")
	place.raid.give_tip()
	var car := place.car
	car.global_transform = place.station_parking.translated_local(Vector3.UP * 0.05)
	await wait_physics_frames(3)
	var bag := place.main
	bag.global_position = car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(20)
	assert_true(car.is_delivered(bag))
	assert_true(place.raid.mark(place.raid.suspicions.find("wh_letters")))
	assert_eq(place.raid.objective_facts().extras.size(), 1, "the extras show once it's guessed")
	car.enter(cop)
	assert_true(place.raid.case_solved)
