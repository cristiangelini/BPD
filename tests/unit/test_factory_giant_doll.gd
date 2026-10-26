extends GutTest

## The doll factory's giant doll (docs/diseno/fabrica.md, step 6): the jeweler's safe hides inside the giant parade
## doll and can't be reached until its zipper is opened from behind, the footprints to its back are the story's clue,
## and the safe in the trunk solves the case.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory(case_seed := 5) -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.story_id = "giant_doll"
	factory.case_seed = case_seed
	factory.get_node("Cop").input_enabled = false
	factory.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(factory)
	return factory


func test_the_safe_waits_inside_the_doll_until_its_zipper_opens() -> void:
	var factory := _factory()
	var cop: Cop = factory.get_node("Cop")
	await wait_physics_frames(10)
	var rig := factory.rig as GiantDollRig
	assert_eq(factory.main, rig.safe)
	assert_almost_eq(rig.safe.mass, 25.0, 0.01)
	assert_eq(rig.safe.collision_layer, 0, "out of reach while the dress is closed")
	assert_lt(Vector2(rig.safe.global_position.x, rig.safe.global_position.z).distance_to(
		Vector2(GiantDollRig.DOLL_AT.x, GiantDollRig.DOLL_AT.z)), 0.3, "it stays inside the dress")
	cop.global_position = GiantDollRig.DOLL_AT + Vector3(-1.5, 0.1, 0)
	assert_eq(rig.doll.prompt_key(cop), "", "no zipper from the front")
	cop.global_position = GiantDollRig.DOLL_AT + Vector3(1.5, 0.1, 0)
	assert_eq(rig.doll.prompt_key(cop), "PROMPT_GIANT_ZIPPER")
	rig.doll.use(cop)
	assert_true(rig.doll.is_open)
	assert_eq(rig.safe.collision_layer, 4)
	assert_eq(rig.doll.prompt_key(cop), "")


func test_the_footprints_go_to_its_back_and_are_the_clue() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var rig := factory.rig as GiantDollRig
	assert_gt(rig.footprints, 10)
	assert_gt(GiantDollRig.TRAIL[-1].x, GiantDollRig.DOLL_AT.x, "the trail ends behind the doll")
	rig.steps.use(factory.get_node("Cop"))
	assert_eq(factory.raid.clues_found, [tr("CLUE_GIANT_STEPS")] as Array[String])


func test_the_safe_in_the_trunk_solves_the_case() -> void:
	var factory := _factory()
	await wait_physics_frames(10)
	assert_eq(factory.extras.size(), 2, "the plan and the key")
	(factory.rig as GiantDollRig).doll.open()
	factory.main.global_position = factory.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(factory.car.is_delivered(factory.main))
	assert_true(factory.raid.mark(factory.raid.suspicions.find("giant_doll")))
	factory.car.enter(factory.get_node("Cop"))
	assert_true(factory.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_GIANT_DOLL_B", "BRIEF_GIANT_DOLL_C", "BRIEF_GIANT_DOLL_D", "OBJ_FIND_JEWELERS_SAFE",
			"OBJ_EXTRA_PARADE_PLAN", "OBJ_EXTRA_SAFE_KEY", "NILDA_CLUE_giant_doll", "CLUE_GIANT_STEPS",
			"PROMPT_GIANT_STEPS", "PROMPT_GIANT_ZIPPER"]:
		assert_ne(tr(key), key)
