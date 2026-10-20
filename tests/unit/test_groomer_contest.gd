extends GutTest

## The pet salon as a full case with the rigged contest (docs/diseno/peluqueria.md, step 5): the suspicions, the
## clues, Ramiro's slips, the poodle lady, the photos, Bizcocho guarding his cup and the delivery in the trunk.

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer(case_seed := 5) -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.story_id = "contest"
	groomer.case_seed = case_seed
	groomer.get_node("Cop").input_enabled = false
	groomer.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func test_three_salon_suspicions_with_the_contest_among_them() -> void:
	var groomer := _groomer()
	await wait_physics_frames(2)
	assert_eq(groomer.raid.suspicions.size(), CaseSuspicions.COUNT)
	assert_has(groomer.raid.suspicions, "contest")
	for id: String in Groomer.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id)
	var notes := groomer.find_children("*", "ClueNote", false, false).filter(func(note: ClueNote) -> bool:
		return note.prompt == "PROMPT_NOTE").map(func(note: ClueNote) -> String: return note.text)
	assert_eq(notes.size(), CaseSuspicions.COUNT, "one note for each suspicion")
	var texts := CaseObjectives.rows(groomer.raid.objective_facts()).map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_ENTER_GROOMER")


func test_the_cup_in_the_trunk_solves_the_case() -> void:
	var groomer := _groomer()
	await wait_physics_frames(10)
	var cup := groomer.main
	assert_eq(cup.scene_file_path, "res://scenes/props/dog_trophy.tscn")
	assert_true(Groomer.SPOTS[groomer.hidden_spots[0]].heavy, "the cup only goes where it fits")
	cup.global_position = groomer.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(groomer.car.is_delivered(cup))
	assert_true(groomer.raid.mark(groomer.raid.suspicions.find("contest")))
	assert_eq(groomer.raid.objective_facts().extras.size(), 2, "the score cards and the comb")
	groomer.car.enter(groomer.get_node("Cop"))
	assert_true(groomer.raid.case_solved)


func test_ramiro_lets_slip_and_the_lady_tells_where_things_are() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(2)
	assert_true(groomer.ramiro.ask(cop))
	assert_eq(groomer.raid.clues_found.size(), 1)
	groomer.lady.take(groomer.poodle)
	assert_eq(groomer.raid.clues_found.size(), 2)
	assert_ne(groomer.lady.clue_speech.find(tr("LOC_" + Groomer.SPOTS[groomer.hidden_spots[5 % 3]].id)), -1)


func test_the_photos_all_show_the_champion() -> void:
	var groomer := _groomer()
	await wait_physics_frames(2)
	var rig := groomer.rig as ContestRig
	assert_eq(rig.photos.size(), 3)
	rig.photos[0].use(groomer.get_node("Cop"))
	rig.photos[1].use(groomer.get_node("Cop"))
	assert_eq(groomer.raid.clues_found, [tr("CLUE_CONTEST_PHOTOS")] as Array[String], "the same clue, once")


func test_bizcocho_barks_at_a_cop_near_his_cup_unless_someone_holds_him() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as ContestRig
	var cup := groomer.main
	rig.champion.global_position = cup.global_position + Vector3(1.0, 0.1, 0)
	cop.global_position = cup.global_position + Vector3(-1.0, 0.1, 0)
	await wait_physics_frames(5)
	assert_eq(rig.loud_barks, 1)
	assert_eq(groomer.ramiro.complaint, DogGroomer.DOG_BARKED, "every bark reaches Ramiro")
	cop.get_node("Grabber").grab(rig.champion)
	rig._since_loud = ContestRig.LOUD_EVERY
	await wait_physics_frames(5)
	assert_eq(rig.loud_barks, 1, "held, he keeps quiet")
	assert_lt(rig.champion.areas[0].get_center().distance_to(Vector2(cup.global_position.x, cup.global_position.z)), 0.1,
		"he wanders around his cup")


func test_ramiro_calling_his_lawyer_fails_the_case() -> void:
	var groomer := _groomer()
	await wait_physics_frames(2)
	groomer.ramiro._set_complaint(DogGroomer.MAX_COMPLAINT)
	assert_true(groomer.raid.case_failed)
	assert_eq(groomer.get_node("%CaseFailed").text, "CASE_FAILED_LAWYER_GROOMER")
