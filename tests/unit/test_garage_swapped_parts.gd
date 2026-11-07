extends GutTest

## The swapped parts story (allanamiento-taller.md, step 5): the crate of new parts with the invoices and the painted old
## parts hidden with the seed, the "new" disc on the counter that leaves rust on whoever grabs it (the clue the first
## time) and the crate in the trunk solving the case.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.story_id = "swapped_parts"
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_the_crate_and_its_extras_are_hidden() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.main, garage.hidden[0])
	assert_almost_eq((garage.main as RigidBody3D).mass, 12.0, 0.01)
	assert_eq(garage.extras.size(), 2, "the invoices and the old parts")
	assert_true(Garage.SPOTS[garage.hidden_spots[0]].heavy, "the crate lies where it fits")


func test_the_disc_waits_on_the_counter() -> void:
	var garage := _garage()
	await wait_physics_frames(30)
	var rig := garage.rig as SwappedPartsRig
	assert_almost_eq(rig.disc.global_position.y, SwappedPartsRig.DISC_AT.y, 0.05, "it rests on the counter")


func test_grabbing_the_disc_rusts_the_hand_and_is_a_clue_once() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var rig := garage.rig as SwappedPartsRig
	var cop: Cop = garage.get_node("Cop")
	var grabber: Node = cop.get_node("Grabber")
	rig.disc.hold(grabber.get_instance_id(), rig.disc.global_position)
	assert_has(rig.disc.stained, cop)
	assert_has(garage.raid.clues_found, tr("CLUE_RUSTY_PART"))
	var clues: int = garage.raid.clues_found.size()
	rig.disc.holders.clear()
	rig.disc.hold(grabber.get_instance_id(), rig.disc.global_position)
	assert_eq(garage.raid.clues_found.size(), clues, "the clue only once")


func test_the_crate_in_the_trunk_solves_the_case() -> void:
	var garage := _garage()
	await wait_physics_frames(10)
	garage.main.global_position = garage.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(garage.car.is_delivered(garage.main))
	assert_true(garage.raid.mark(garage.raid.suspicions.find("swapped_parts")))
	garage.car.enter(garage.get_node("Cop"))
	assert_true(garage.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_SWAPPED_PARTS_B", "BRIEF_SWAPPED_PARTS_C", "BRIEF_SWAPPED_PARTS_D", "OBJ_FIND_PARTS_CRATE",
			"OBJ_EXTRA_FAKE_INVOICES", "OBJ_EXTRA_OLD_PARTS", "GRASITA_CLUE_swapped_parts", "HINT_RUSTY_PART",
			"GARAGE_RUST", "CLUE_RUSTY_PART"]:
		assert_ne(tr(key), key)
