extends GutTest

## The doll factory's knockoff Captain Galaxy (docs/diseno/fabrica.md, step 6): every second doll on the belt comes out
## with an astronaut helmet, the rejects in the dumpster are the story's clue, the 15 kg mold jams the belt and in the
## trunk it solves the case.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory(case_seed := 5) -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.story_id = "fake_captain"
	factory.case_seed = case_seed
	factory.get_node("Cop").input_enabled = false
	factory.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(factory)
	return factory


func test_every_second_belt_doll_is_a_captain() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	for i in 4:
		var doll := Node3D.new()
		factory.add_child(doll)
		factory.fed_doll.emit(doll)
	var captains := factory.get_children().filter(func(n: Node) -> bool: return n.has_node("CaptainHelmet"))
	assert_eq(captains.size(), 2)


func test_the_mold_is_the_main_evidence_and_jams_the_belt() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	assert_almost_eq((factory.main as RigidBody3D).mass, 15.0, 0.01)
	assert_gte(factory.main.mass, ConveyorBelt.JAM_MASS)
	assert_eq(factory.extras.size(), 2, "the labels and the photos")


func test_a_reject_in_the_dumpster_is_the_clue() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var rig := factory.rig as FakeCaptainRig
	assert_eq(rig.rejects.size(), FakeCaptainRig.REJECTS)
	for reject: ClueNote in rig.rejects:
		assert_lt(Vector2(reject.position.x, reject.position.z).distance_to(
			Vector2(DollFactory.DUMPSTER_AT.x, DollFactory.DUMPSTER_AT.z)), 1.0, "in the dumpster")
	rig.rejects[0].use(factory.get_node("Cop"))
	rig.rejects[1].use(factory.get_node("Cop"))
	assert_eq(factory.raid.clues_found, [tr("CLUE_REJECT_CAPTAINS")] as Array[String])


func test_the_mold_in_the_trunk_solves_the_case() -> void:
	var factory := _factory()
	await wait_physics_frames(10)
	factory.main.global_position = factory.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(factory.car.is_delivered(factory.main))
	assert_true(factory.raid.mark(factory.raid.suspicions.find("fake_captain")))
	factory.car.enter(factory.get_node("Cop"))
	assert_true(factory.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_FAKE_CAPTAIN_B", "BRIEF_FAKE_CAPTAIN_C", "BRIEF_FAKE_CAPTAIN_D", "OBJ_FIND_STOLEN_MOLD",
			"OBJ_EXTRA_FAKE_LABELS", "OBJ_EXTRA_PROTOTYPE_PHOTOS", "NILDA_CLUE_fake_captain", "CLUE_REJECT_CAPTAINS",
			"PROMPT_REJECT_CAPTAIN"]:
		assert_ne(tr(key), key)
