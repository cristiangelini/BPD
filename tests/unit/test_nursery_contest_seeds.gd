extends GutTest

## The nursery raid with the contest seeds (allanamiento-vivero.md, step 7): the box of seeds solves the case in the
## trunk, the giant tomatoes are a clue near a cop, and a giant pumpkin grows and rolls after every watering.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery(case_seed := 5) -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.story_id = "contest_seeds"
	nursery.case_seed = case_seed
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_the_box_of_seeds_solves_the_case() -> void:
	var nursery := _nursery()
	await wait_physics_frames(10)
	assert_has(nursery.raid.suspicions, "contest_seeds")
	assert_eq(nursery.main.scene_file_path, "res://scenes/props/seed_box.tscn")
	assert_eq(nursery.extras.size(), 2, "the ribbon and the jar")
	nursery.main.global_position = nursery.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(nursery.car.is_delivered(nursery.main))
	assert_true(nursery.raid.mark(nursery.raid.suspicions.find("contest_seeds")))
	nursery.car.enter(nursery.get_node("Cop"))
	assert_true(nursery.raid.case_solved)


func test_the_giant_tomatoes_are_a_clue_near_a_cop() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as ContestSeedsRig
	assert_false(rig.noticed)
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = rig.tomato.global_position + Vector3(-1.2, 0.1, 0.6)
	await wait_seconds(ContestSeedsRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(nursery.raid.clues_found.count(tr("CLUE_GIANT_TOMATOES")), 1, "one clue")


func test_a_pumpkin_grows_and_rolls_after_each_watering() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as ContestSeedsRig
	var irrigation := nursery.irrigation
	irrigation.set_physics_process(false)
	irrigation.start()
	await wait_physics_frames(2)
	assert_eq(rig.grown, 0, "not while it waters")
	irrigation.tick(NurseryIrrigation.RUN_SECONDS)
	await wait_physics_frames(10)
	assert_eq(rig.grown, 1)
	var pumpkin := rig.pumpkins[0]
	assert_gt(pumpkin.global_position.x, nursery.to_global(ContestSeedsRig.PUMPKIN_AT).x, "it rolls east")
	for i in ContestSeedsRig.PUMPKINS:
		rig.grow_pumpkin()
	assert_eq(rig.pumpkins.size(), ContestSeedsRig.PUMPKINS, "the oldest goes")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_CONTEST_SEEDS_B", "BRIEF_CONTEST_SEEDS_C", "BRIEF_CONTEST_SEEDS_D",
			"OBJ_FIND_SEED_BOX", "OBJ_EXTRA_PRIZE_RIBBON", "OBJ_EXTRA_SUPERBROTE", "CLUE_GIANT_TOMATOES",
			"NURSERY_TOMATOES", "BROTECITO_CLUE_contest_seeds"]:
		assert_ne(tr(key), key, key)
