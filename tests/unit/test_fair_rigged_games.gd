extends GutTest

## The fun fair raid with the rigged games (allanamiento-parque.md, step 6): the giant magnet under the cans booth is
## the main evidence; while it's there the cans don't fall and the mallet creeps towards the booth.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair(case_seed := 5) -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.story_id = "rigged_games"
	fair.case_seed = case_seed
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_the_magnet_solves_the_case() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	assert_has(fair.raid.suspicions, "rigged_games")
	assert_eq(fair.main.scene_file_path, "res://scenes/props/fair_magnet.tscn")
	assert_eq(fair.extras.size(), 2, "the glued cans and the manual")
	fair.main.global_position = fair.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(fair.car.is_delivered(fair.main))
	assert_true(fair.raid.mark(fair.raid.suspicions.find("rigged_games")))
	fair.car.enter(fair.get_node("Cop"))
	assert_true(fair.raid.case_solved)


func test_the_cans_hold_until_the_magnet_is_taken_away() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	var rig := fair.rig as RiggedGamesRig
	for can in fair.cans_booth.cans:
		assert_true(can.freeze, "stuck to the shelf")
	rig.magnet.global_position = fair.to_global(Fair.CANS_AT + Vector3(0, 0.3, 4.0))
	await wait_physics_frames(3)
	assert_false(rig.active)
	for can in fair.cans_booth.cans:
		assert_false(can.freeze, "loose again")


func test_the_mallet_creeps_towards_the_booth_and_it_is_a_clue_once() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var mallet := fair.tester.mallet
	var start := mallet.global_position
	var booth := fair.to_global(RiggedGamesRig.MAGNET_AT)
	await wait_seconds(3.0)
	assert_lt(mallet.global_position.distance_to(booth), start.distance_to(booth) - RiggedGamesRig.CREPT)
	assert_eq(fair.raid.clues_found.count(tr("CLUE_MALLET_CREEPS")), 1)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_RIGGED_GAMES_B", "BRIEF_RIGGED_GAMES_C", "BRIEF_RIGGED_GAMES_D", "OBJ_FIND_MAGNET",
			"OBJ_EXTRA_GLUED_CANS", "OBJ_EXTRA_RIG_MANUAL", "NUBE_CLUE_rigged_games", "CLUE_MALLET_CREEPS",
			"FAIR_MAGNET_OFF"]:
		assert_ne(tr(key), key, key)
