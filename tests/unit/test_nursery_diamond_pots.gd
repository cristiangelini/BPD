extends GutTest

## The nursery raid with the diamond pots (allanamiento-vivero.md, step 7): the pot with diamonds solves the case in
## the trunk, it sparkles while the sprinklers run and a cop near it then gets the clue, and some yard pots go "clinc"
## when the sprinklers start.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery(case_seed := 5) -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.story_id = "diamond_pots"
	nursery.case_seed = case_seed
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_the_pot_with_diamonds_solves_the_case() -> void:
	var nursery := _nursery()
	await wait_physics_frames(10)
	assert_has(nursery.raid.suspicions, "diamond_pots")
	assert_eq(nursery.main.scene_file_path, "res://scenes/props/diamond_pot.tscn")
	assert_eq(nursery.extras.size(), 2, "the loupe and the empty bag")
	nursery.main.global_position = nursery.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(nursery.car.is_delivered(nursery.main))
	assert_true(nursery.raid.mark(nursery.raid.suspicions.find("diamond_pots")))
	nursery.car.enter(nursery.get_node("Cop"))
	assert_true(nursery.raid.case_solved)


func test_it_sparkles_with_the_sprinklers_and_a_cop_near_it_notices() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as DiamondPotsRig
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.main.global_position + Vector3(2.0, 0.1, 0)
	await wait_seconds(DiamondPotsRig.CHECK_EVERY * 2.5)
	assert_false(rig.noticed, "dry, it doesn't sparkle")
	nursery.irrigation.start()
	await wait_seconds(DiamondPotsRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(nursery.raid.clues_found.count(tr("CLUE_DIAMOND_SHINE")), 1, "one clue")


func test_yard_pots_clink_when_the_sprinklers_start() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as DiamondPotsRig
	nursery.irrigation.start()
	assert_eq(rig.clincs, DiamondPotsRig.CLINCS)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_DIAMOND_POTS_B", "BRIEF_DIAMOND_POTS_C", "BRIEF_DIAMOND_POTS_D",
			"OBJ_FIND_DIAMOND_POT", "OBJ_EXTRA_LOUPE", "OBJ_EXTRA_EMPTY_BAG", "CLUE_DIAMOND_SHINE", "NURSERY_SPARKLE",
			"NURSERY_CLINC", "BROTECITO_CLUE_diamond_pots"]:
		assert_ne(tr(key), key, key)
