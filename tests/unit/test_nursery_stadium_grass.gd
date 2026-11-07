extends GutTest

## The nursery raid with the stadium grass (allanamiento-vivero.md, step 7): the 12 kg roll solves the case in the
## trunk, the patch with white lines is a clue near a cop and the roll sings like the crowd when the sprinklers start.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery(case_seed := 5) -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.story_id = "stadium_grass"
	nursery.case_seed = case_seed
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_the_roll_of_grass_solves_the_case() -> void:
	var nursery := _nursery()
	await wait_physics_frames(10)
	assert_has(nursery.raid.suspicions, "stadium_grass")
	assert_eq(nursery.main.scene_file_path, "res://scenes/props/grass_roll.tscn")
	assert_true(Nursery.SPOTS[nursery.hidden_spots[0]].heavy, "it's in a spot for heavy things")
	assert_eq(nursery.extras.size(), 2, "the ticket and the mower")
	nursery.main.global_position = nursery.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(nursery.car.is_delivered(nursery.main))
	assert_true(nursery.raid.mark(nursery.raid.suspicions.find("stadium_grass")))
	nursery.car.enter(nursery.get_node("Cop"))
	assert_true(nursery.raid.case_solved)


func test_the_painted_lines_are_a_clue_near_a_cop() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as StadiumGrassRig
	assert_false(rig.noticed, "nobody near the patch")
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = rig.patch.global_position + Vector3(1.0, 0.1, 0)
	await wait_seconds(StadiumGrassRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(nursery.raid.clues_found.count(tr("CLUE_STADIUM_LINES")), 1, "one clue")


func test_the_roll_sings_when_the_sprinklers_start() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as StadiumGrassRig
	assert_eq(rig.chants, 0)
	nursery.irrigation.start()
	assert_eq(rig.chants, 1)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_STADIUM_GRASS_B", "BRIEF_STADIUM_GRASS_C", "BRIEF_STADIUM_GRASS_D",
			"OBJ_FIND_GRASS_ROLL", "OBJ_EXTRA_STADIUM_TICKET", "OBJ_EXTRA_HAND_MOWER", "CLUE_STADIUM_LINES",
			"NURSERY_LINES", "NURSERY_CHANT", "BROTECITO_CLUE_stadium_grass"]:
		assert_ne(tr(key), key, key)
