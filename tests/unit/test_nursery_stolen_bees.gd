extends GutTest

## The nursery raid with the stolen bees (allanamiento-vivero.md, step 7): the hive solves the case in the trunk, its
## buzz is a clue near a cop, and the bees chase a cop who runs near the hive and push it a little.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery(case_seed := 5) -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.story_id = "stolen_bees"
	nursery.case_seed = case_seed
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_the_hive_solves_the_case() -> void:
	var nursery := _nursery()
	await wait_physics_frames(10)
	assert_has(nursery.raid.suspicions, "stolen_bees")
	assert_eq(nursery.main.scene_file_path, "res://scenes/props/beehive.tscn")
	assert_true(Nursery.SPOTS[nursery.hidden_spots[0]].heavy, "it's in a spot for heavy things")
	assert_eq(nursery.extras.size(), 2, "the suit and the honey")
	nursery.main.global_position = nursery.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(nursery.car.is_delivered(nursery.main))
	assert_true(nursery.raid.mark(nursery.raid.suspicions.find("stolen_bees")))
	nursery.car.enter(nursery.get_node("Cop"))
	assert_true(nursery.raid.case_solved)


func test_the_buzz_is_a_clue_near_a_cop() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as StolenBeesRig
	assert_false(rig.heard)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.main.global_position + Vector3(1.5, 0.1, 0)
	await wait_seconds(StolenBeesRig.CHECK_EVERY * 2.5)
	assert_true(rig.heard)
	assert_eq(nursery.raid.clues_found.count(tr("CLUE_BUZZING")), 1, "one clue")


func test_the_bees_chase_a_running_cop_and_push_it() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as StolenBeesRig
	var cop: Cop = nursery.get_node("Cop")
	cop.set_physics_process(false)
	cop.global_position = nursery.main.global_position + Vector3(4.0, 0.0, 0)
	cop.is_running = false
	await wait_physics_frames(5)
	assert_null(rig.chasing, "a walking cop is left alone")
	cop.is_running = true
	await wait_seconds(1.5)
	assert_eq(rig.chasing, cop)
	assert_gt(rig.stings, 0, "they caught up and pushed it")
	cop.is_running = false
	await wait_physics_frames(2)
	assert_null(rig.chasing, "walking again, they go home")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_STOLEN_BEES_B", "BRIEF_STOLEN_BEES_C", "BRIEF_STOLEN_BEES_D", "OBJ_FIND_BEEHIVE",
			"OBJ_EXTRA_BEEKEEPER_SUIT", "OBJ_EXTRA_HONEY_JAR", "CLUE_BUZZING", "NURSERY_BUZZ", "HINT_NURSERY_BEES",
			"BROTECITO_CLUE_stolen_bees"]:
		assert_ne(tr(key), key, key)
