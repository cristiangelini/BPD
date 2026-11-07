extends GutTest

## The cinema's stolen film story (allanamiento-cine.md, step 6): the can with the festival's film hidden with its
## extras, spectators crying every few seconds, and "PROPIEDAD DEL FESTIVAL" in the screen's corner, read up front.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.story_id = "stolen_film"
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_the_film_is_hidden_with_its_extras() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_has(cinema.raid.suspicions, "stolen_film")
	assert_eq(cinema.main, cinema.hidden[0])
	assert_almost_eq((cinema.main as RigidBody3D).mass, 5.0, 0.01)
	assert_eq(cinema.extras.size(), 2, "the badge and the statuette")


func test_the_spectators_cry_while_the_film_runs() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as StolenFilmRig
	rig._until_cry = 0.1
	await wait_seconds(0.4)
	assert_eq(rig.crying, 1)
	assert_eq(cinema.spectators[0].said(), tr("CINEMA_CRY_1"))
	cinema.cut_film()
	rig._until_cry = 0.1
	await wait_seconds(0.4)
	assert_eq(rig.crying, 1, "nobody cries at a white screen")
	assert_false(rig.mark.visible, "nor is the mark on it")


func test_the_mark_is_read_up_front_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as StolenFilmRig
	assert_true(rig.mark.visible)
	assert_lt(rig.mark.position.z, Cinema.SCREEN_AT.z, "on the screen's face")
	var cop: Cop = cinema.get_node("Cop")
	cop.global_position = cinema.to_global(StolenFilmRig.READ_AT + Vector3(0.5, Cinema.FLOOR_TOP + 0.1, 0))
	await wait_physics_frames(6)
	assert_true(rig.read_by_cops.has(cop))
	assert_has(cinema.raid.clues_found, tr("CLUE_FESTIVAL_MARK"))
	var clues: int = cinema.raid.clues_found.size()
	rig.read_mark(cop)
	assert_eq(cinema.raid.clues_found.size(), clues, "the clue only once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_STOLEN_FILM_B", "BRIEF_STOLEN_FILM_C", "BRIEF_STOLEN_FILM_D", "OBJ_FIND_FESTIVAL_FILM",
			"OBJ_EXTRA_FESTIVAL_BADGE", "OBJ_EXTRA_STATUETTE", "CHICHO_CLUE_stolen_film", "CINEMA_FESTIVAL_MARK",
			"HINT_FESTIVAL_MARK", "CLUE_FESTIVAL_MARK"]:
		assert_ne(tr(key), key)
	for key: String in StolenFilmRig.CRIES:
		assert_ne(tr(key), key)
