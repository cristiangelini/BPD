extends GutTest

## The birthday party raid's gifts that come back (allanamiento-cumple.md, step 5): the resale notebook hidden with
## its extras, the gift with the alarm tag beeping at the front door (a clue), Chispita slipping the gifts into his
## case one at a time, and the notebook in the trunk solving the case.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party(case_seed := 5) -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.story_id = "returning_gifts"
	party.case_seed = case_seed
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


func test_the_notebook_is_hidden_with_its_extras() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.main, party.hidden[0])
	assert_almost_eq((party.main as RigidBody3D).mass, 0.5, 0.01)
	assert_eq(party.extras.size(), 2, "the tagged gift and the wrapping paper")
	assert_has(party.raid.suspicions, "returning_gifts")
	assert_eq(party.gifts.size(), BirthdayRaid.GIFTS)


func test_the_gift_beeps_at_the_door_a_clue() -> void:
	var party := _party()
	await wait_physics_frames(10)
	var rig := party.rig as ReturningGiftsRig
	assert_does_not_have(party.raid.clues_found, tr("CLUE_RETURNING_GIFTS"), "quiet on the table")
	rig.beeper.global_position = party.to_global(ReturningGiftsRig.door_at() + Vector3(0.5, 0.3, -0.5))
	await wait_physics_frames(2)
	assert_has(party.raid.clues_found, tr("CLUE_RETURNING_GIFTS"))


func test_chispita_slips_the_gifts_into_his_case_one_at_a_time() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as ReturningGiftsRig
	assert_eq(party.gifts.filter(func(gift: Node3D) -> bool: return gift.visible).size(), BirthdayRaid.GIFTS)
	rig.take_left = 0.01
	await wait_physics_frames(2)
	assert_eq(rig.taken, 1)
	assert_false(party.gifts[-1].visible, "the one on top first")
	assert_eq(party.chispita.get_node("Bubble").text, "CHISPITA_GIFT_TAKE")
	assert_eq(party.chispita.complaint, 0.0, "his complaint stays")
	for i in BirthdayRaid.GIFTS:
		rig.take_gift()
	await wait_physics_frames(2)
	assert_eq(party.gifts.filter(func(gift: Node3D) -> bool: return gift.visible).size(), 0, "all gone")


func test_the_notebook_in_the_trunk_solves_the_case() -> void:
	var party := _party()
	await wait_physics_frames(10)
	var notebook := party.main
	notebook.global_position = party.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(party.car.is_delivered(notebook))
	assert_true(party.raid.mark(party.raid.suspicions.find("returning_gifts")))
	party.car.enter(party.get_node("Cop"))
	assert_true(party.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_RETURNING_GIFTS_B", "BRIEF_RETURNING_GIFTS_C", "BRIEF_RETURNING_GIFTS_D",
			"OBJ_FIND_RESALE_NOTEBOOK", "OBJ_EXTRA_TAGGED_GIFT", "OBJ_EXTRA_WRAPPING_ROLL", "BIRTHDAY_GIFT_BEEP",
			"CLUE_RETURNING_GIFTS", "CHISPITA_GIFT_TAKE"]:
		assert_ne(tr(key), key)
