extends GutTest

## The doll factory's poodle hair (docs/diseno/fabrica.md, step 6): pink tufts toward the hidden bag make cops sneeze
## (the story's clue, once), the hair machine sticks pink hair on cops close by, the belt's dolls are hairy, and the bag
## in the trunk solves the case.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory(case_seed := 5) -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.story_id = "poodle_hair"
	factory.case_seed = case_seed
	factory.get_node("Cop").input_enabled = false
	factory.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(factory)
	return factory


func test_the_tufts_lead_from_the_hair_machine_to_the_bag() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var rig := factory.rig as PoodleHairRig
	assert_eq(rig.tufts.size(), PoodleHairRig.TUFTS)
	var bag: Vector3 = DollFactory.SPOTS[factory.hidden_spots[0]].at
	var machine: Vector3 = DollFactory.MACHINES[1].stand
	assert_lt(Vector2(rig.tufts[-1].x, rig.tufts[-1].z).distance_to(Vector2(bag.x, bag.z)),
		Vector2(rig.tufts[0].x, rig.tufts[0].z).distance_to(Vector2(bag.x, bag.z)), "the last tuft is closer to the bag")
	assert_lt(Vector2(rig.tufts[0].x, rig.tufts[0].z).distance_to(Vector2(machine.x, machine.z)), 2.5)
	assert_almost_eq(factory.main.mass, 3.0, 0.01)
	assert_eq(factory.extras.size(), 2, "the comb and the invoice")


func test_a_cop_on_the_tufts_sneezes_and_finds_the_clue() -> void:
	var factory := _factory()
	var cop: Cop = factory.get_node("Cop")
	await wait_physics_frames(5)
	var rig := factory.rig as PoodleHairRig
	cop.global_position = factory.to_global(rig.tufts[PoodleHairRig.TUFTS / 2]) + Vector3(0, 0.1, 0)
	await wait_physics_frames(3)
	assert_true(rig.was_sneezed)
	rig.sneeze(cop)
	assert_eq(factory.raid.clues_found, [tr("CLUE_POODLE_HAIR")] as Array[String], "the clue only once")


func test_the_hair_machine_gives_pink_hair_and_the_dolls_are_hairy() -> void:
	var factory := _factory()
	var cop: Cop = factory.get_node("Cop")
	await wait_physics_frames(5)
	cop.global_position = factory.to_global(DollFactory.MACHINES[1].stand) + Vector3(0, 0.1, 0)
	await wait_physics_frames(3)
	assert_true(cop.model.has_node("BeltHair"))
	var doll: FactoryDoll = DollFactory.BELT_DOLL_SCENE.instantiate()
	factory.fed_doll.emit(doll)
	factory.add_child(doll)
	assert_true(doll.has_node("BeltHair"))


func test_the_bag_in_the_trunk_solves_the_case() -> void:
	var factory := _factory()
	await wait_physics_frames(10)
	factory.main.global_position = factory.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(factory.car.is_delivered(factory.main))
	assert_true(factory.raid.mark(factory.raid.suspicions.find("poodle_hair")))
	factory.car.enter(factory.get_node("Cop"))
	assert_true(factory.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_POODLE_HAIR_B", "BRIEF_POODLE_HAIR_C", "BRIEF_POODLE_HAIR_D", "OBJ_FIND_POODLE_HAIR",
			"OBJ_EXTRA_GOLD_COMB", "OBJ_EXTRA_FAKE_INVOICE", "NILDA_CLUE_poodle_hair", "CLUE_POODLE_HAIR", "HINT_SNEEZE"]:
		assert_ne(tr(key), key)
