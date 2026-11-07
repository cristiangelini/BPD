extends GutTest

## The cinema as a raid with the pirate copies' story (allanamiento-cine.md, step 5): the suspicions, the box of copies
## and its extras hidden with the seed, the neighbor taping the film with a red light blinking in the back row, what
## doña Bobina lets slip and what Chicho saw, and the box in the trunk solving the case.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.story_id = "pirate_copies"
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_eq(cinema.raid.suspicions.size(), 3)
	assert_has(cinema.raid.suspicions, "pirate_copies")
	for id: String in cinema.raid.suspicions:
		assert_has(Cinema.SUSPICION_POOL, id)
	assert_eq(cinema.raid.owner_npc, cinema.bobina)


func test_the_box_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_eq(cinema.main, cinema.hidden[0])
	assert_almost_eq((cinema.main as RigidBody3D).mass, 8.0, 0.01)
	assert_true(Cinema.SPOTS[cinema.hidden_spots[0]].heavy, "the box in a spot it fits")
	assert_eq(cinema.extras.size(), 2, "the camcorder and the covers")
	var other := _cinema(6)
	await wait_physics_frames(2)
	assert_ne(cinema.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_red_light_in_the_back_row_is_a_clue_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as PirateCopiesRig
	assert_has(cinema.spectators, rig.taper)
	assert_gte(rig.taper.seat, (Cinema.ROWS - 2) * Cinema.SEATS_PER_ROW, "at the back")
	assert_eq(rig.taper.look, Cinema.SPECTATORS, "a face of their own")
	rig.taper.use(cinema.get_node("Cop"))
	assert_eq(rig.taper.said(), "CINEMA_TAPER_LINE")
	var cop: Cop = cinema.get_node("Cop")
	cop.global_position = rig.taper.global_position + Vector3(0, 0.2, -1.0)
	await wait_physics_frames(6)
	assert_true(rig.spotted_by.has(cop))
	assert_has(cinema.raid.clues_found, tr("CLUE_RED_LIGHT"))
	var clues: int = cinema.raid.clues_found.size()
	rig.spot(cop)
	assert_eq(cinema.raid.clues_found.size(), clues, "the clue only once")


func test_bobina_slips_and_chicho_saw_where() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_eq(cinema.bobina.slips.size(), 3)
	assert_true(cinema.bobina.ask(cinema.get_node("Cop")))
	assert_eq(cinema.raid.clues_found.size(), 1)
	var where := tr("LOC_" + Cinema.SPOTS[cinema.hidden_spots[5 % 3]].id)
	assert_eq(cinema.chicho.clue, tr("CLUE_CHICHO") % where)
	cinema.chicho.told.emit(cinema.chicho.clue)
	assert_has(cinema.raid.clues_found, cinema.chicho.clue, "on the checklist")


func test_the_lawyer_loses_the_case() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	cinema.bobina.scold(FloorBoss.MAX_COMPLAINT, "BOBINA_NOTICED")
	assert_true(cinema.raid.case_failed)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var cinema := _cinema()
	await wait_physics_frames(10)
	var box := cinema.main
	box.global_position = cinema.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(cinema.car.is_delivered(box))
	assert_true(cinema.raid.mark(cinema.raid.suspicions.find("pirate_copies")))
	assert_eq(cinema.raid.objective_facts().extras.size(), 2)
	cinema.car.enter(cinema.get_node("Cop"))
	assert_true(cinema.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_CINEMA_TIP_B", "BRIEF_CINEMA_TIP_D", "BRIEF_CINEMA_TIP_E",
		"BRIEF_PIRATE_COPIES_B", "BRIEF_PIRATE_COPIES_C", "BRIEF_PIRATE_COPIES_D", "OBJ_FIND_PIRATE_BOX",
		"OBJ_EXTRA_CAMCORDER", "OBJ_EXTRA_COVERS", "OBJ_ENTER_CINEMA", "OBJ_GUESS_CINEMA", "OBJ_BROKEN_CINEMA",
		"OBJ_COMPLAINT_CINEMA", "BOBINA_SLIP", "CLUE_CHICHO", "CHICHO_CLUE_pirate_copies", "CINEMA_TAPER_LINE",
		"HINT_RED_LIGHT", "CLUE_RED_LIGHT", "HINT_ESCAPE_cinema", "CRIME_owner_cinema", "CONFESS_owner_cinema",
		"CASE_FAILED_LAWYER_CINEMA"]
	for id: String in Cinema.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_cinema"))
	assert_true(ChaseSuspect.MODELS.has("cinema"))
	assert_true(RaidEscape.PLACES.has("cinema"))


func test_dona_bobina_gets_away_in_a_car() -> void:
	var cinema := _cinema(7)
	await wait_physics_frames(30)
	cinema.raid.escape.flee()
	var chase := cinema.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "cinema")
