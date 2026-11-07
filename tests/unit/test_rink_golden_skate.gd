extends GutTest

## The rink raid with the golden skate (allanamiento-pista.md, step 6): the Golden Skate painted white is always on
## the skate rack and solves the case in the patrol car's trunk; it goes "clang" every time a cop picks it up, the first
## time a clue; the rack's shelf bends on its side.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink(case_seed := 5) -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.story_id = "golden_skate"
	rink.case_seed = case_seed
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func test_the_golden_skate_is_on_the_rack_and_solves_the_case() -> void:
	for case_seed in range(1, 9):
		var other := _rink(case_seed)
		await wait_physics_frames(1)
		assert_eq(Rink.SPOTS[other.hidden_spots[0]].id, "on_skate_rack", "seed %d: on the rack" % case_seed)
		assert_eq(other.hidden_spots.size(), 3)
		assert_eq(other.hidden_spots.count(other.hidden_spots[0]), 1, "seed %d: the extras go elsewhere" % case_seed)
		other.queue_free()
	var rink := _rink()
	await wait_physics_frames(10)
	assert_has(rink.raid.suspicions, "golden_skate")
	assert_eq(rink.main.scene_file_path, "res://scenes/props/rink_golden_skate.tscn")
	assert_eq(rink.main.mass, 4.0)
	rink.main.global_position = rink.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(rink.car.is_delivered(rink.main))
	assert_true(rink.raid.mark(rink.raid.suspicions.find("golden_skate")))
	rink.car.enter(rink.get_node("Cop"))
	assert_true(rink.raid.case_solved)


func test_picking_it_up_goes_clang_and_the_first_time_is_a_clue() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as GoldenSkateRig
	assert_not_null(rig.sag, "the shelf bends")
	assert_eq(rig.clangs, 0, "nobody touched it")
	var cop: Cop = rink.get_node("Cop")
	var grabber: Node = cop.get_node("Grabber")
	cop.global_position = rink.main.global_position + Vector3(0, -0.9, 1.0)
	await wait_physics_frames(2)
	for i in 2:
		grabber.grab(rink.main)
		await wait_physics_frames(3)
		grabber.release()
		await wait_physics_frames(3)
	assert_eq(rig.clangs, 2, "clang every time")
	assert_eq(rink.raid.clues_found.count(tr("CLUE_HEAVY_SKATE")), 1, "one clue")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_GOLDEN_SKATE_B", "BRIEF_GOLDEN_SKATE_C", "BRIEF_GOLDEN_SKATE_D", "OBJ_FIND_GOLDEN_SKATE",
			"OBJ_EXTRA_WHITE_PAINT", "OBJ_EXTRA_TROPHY_CLIPPING", "COPITO_CLUE_golden_skate", "CLUE_HEAVY_SKATE",
			"RINK_CLANG"]:
		assert_ne(tr(key), key, key)
