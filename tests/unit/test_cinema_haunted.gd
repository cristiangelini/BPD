extends GutTest

## The cinema's haunted story (allanamiento-cine.md, step 6): the ghost projector hidden with its extras, a ghost that
## crosses the screen every 30 s of film while everybody screams, and the speaker behind the screen that is the clue.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.story_id = "haunted_cinema"
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_the_projector_is_hidden_with_its_extras() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_has(cinema.raid.suspicions, "haunted_cinema")
	assert_eq(cinema.main, cinema.hidden[0])
	assert_almost_eq((cinema.main as RigidBody3D).mass, 3.0, 0.01)
	assert_eq(cinema.extras.size(), 2, "the sheet and the record")


func test_a_ghost_crosses_the_screen_and_everybody_screams() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as HauntedCinemaRig
	assert_false(rig.ghost.visible)
	rig._until_ghost = 0.1
	await wait_seconds(0.5)
	assert_eq(rig.crossings, 1)
	assert_true(rig.ghost.visible, "on the screen")
	assert_almost_eq(rig.ghost.position.z, Cinema.SCREEN_AT.z - 0.08, 0.01)
	for spectator in cinema.spectators:
		assert_eq(spectator.said(), tr("CINEMA_SCREAM"))
	await wait_seconds(HauntedCinemaRig.GHOST_SECONDS)
	assert_false(rig.ghost.visible, "gone")
	cinema.cut_film()
	rig._until_ghost = 0.1
	await wait_seconds(0.5)
	assert_eq(rig.crossings, 1, "no ghost on a white screen")


func test_the_speaker_behind_the_screen_is_a_clue_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as HauntedCinemaRig
	assert_gt(rig.speaker.position.z, Cinema.SCREEN_AT.z, "behind the screen")
	assert_lt(rig.speaker.position.z, Cinema.LOBBY_Z)
	var cop: Cop = cinema.get_node("Cop")
	cop.global_position = rig.speaker.global_position + Vector3(1.0, 0.2, 0)
	await wait_physics_frames(6)
	assert_true(rig.heard_by.has(cop))
	assert_has(cinema.raid.clues_found, tr("CLUE_GHOST_SPEAKER"))
	var clues: int = cinema.raid.clues_found.size()
	rig.hear(cop)
	assert_eq(cinema.raid.clues_found.size(), clues, "the clue only once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_HAUNTED_CINEMA_B", "BRIEF_HAUNTED_CINEMA_C", "BRIEF_HAUNTED_CINEMA_D",
			"OBJ_FIND_GHOST_PROJECTOR", "OBJ_EXTRA_HOLEY_SHEET", "OBJ_EXTRA_SCREAM_DISC", "CHICHO_CLUE_haunted_cinema",
			"HINT_GHOST_SPEAKER", "CLUE_GHOST_SPEAKER", "CINEMA_GHOST_OOH", "CINEMA_SCREAM"]:
		assert_ne(tr(key), key)
