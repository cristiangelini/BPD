extends GutTest

## The birthday party raid's piñata full of bills (allanamiento-cumple.md, step 5): the printing plate hidden in a spot
## it fits with its extras, fake bills raining with the candies when the piñata breaks (a clue, once), and the plate in
## the trunk solving the case.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party(case_seed := 5) -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.story_id = "pinata_bills"
	party.case_seed = case_seed
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


func test_the_plate_is_hidden_where_it_fits_with_its_extras() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.main, party.hidden[0])
	assert_almost_eq((party.main as RigidBody3D).mass, 6.0, 0.01)
	assert_true(BirthdayRaid.SPOTS[party.hidden_spots[0]].heavy, "the plate in a spot it fits")
	assert_eq(party.extras.size(), 2, "the bag of bills and the Happy Bank stamp")
	assert_has(party.raid.suspicions, "pinata_bills")


func test_breaking_the_pinata_rains_fake_bills_a_clue() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as PinataBillsRig
	assert_eq(rig.bills.size(), 0, "nothing until it breaks")
	party.pinata.hits = BirthdayPinata.HITS - 1
	party.pinata.use(party.get_node("Cop"))
	assert_true(party.pinata.is_broken)
	assert_eq(rig.bills.size(), PinataBillsRig.BILLS)
	assert_has(party.raid.clues_found, tr("CLUE_PINATA_BILLS"))
	for bill in rig.bills:
		var at := bill.position
		assert_lt(Vector2(at.x - BirthdayRaid.PINATA_AT.x, at.z - BirthdayRaid.PINATA_AT.z).length(), 1.5, "under it")
		assert_almost_eq(at.y, BirthdayRaid.FLOOR_TOP + PinataBillsRig.LIFT, 0.01, "on the floor")


func test_the_plate_in_the_trunk_solves_the_case() -> void:
	var party := _party()
	await wait_physics_frames(10)
	var plate := party.main
	plate.global_position = party.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(party.car.is_delivered(plate))
	assert_true(party.raid.mark(party.raid.suspicions.find("pinata_bills")))
	party.car.enter(party.get_node("Cop"))
	assert_true(party.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_PINATA_BILLS_B", "BRIEF_PINATA_BILLS_C", "BRIEF_PINATA_BILLS_D", "OBJ_FIND_PINATA_PLATE",
			"OBJ_EXTRA_PINATA_BILLS", "OBJ_EXTRA_HAPPY_BANK_STAMP", "BIRTHDAY_PINATA_BILLS", "CLUE_PINATA_BILLS"]:
		assert_ne(tr(key), key)
