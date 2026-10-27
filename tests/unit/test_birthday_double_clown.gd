extends GutTest

## The birthday party raid's double clown (allanamiento-cumple.md, step 5): the second costume hidden with its extras,
## the horn honking in the restroom where Chispita isn't (a clue for a cop who hears it), the two Chispitas swapping
## with other shoes, and the costume in the trunk solving the case.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party(case_seed := 5) -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.story_id = "double_clown"
	party.case_seed = case_seed
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


func test_the_costume_is_hidden_with_its_extras() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.main, party.hidden[0])
	assert_almost_eq((party.main as RigidBody3D).mass, 3.0, 0.01)
	assert_eq(party.extras.size(), 2, "the second nose and the photo")
	assert_has(party.raid.suspicions, "double_clown")


func test_the_horn_honks_in_the_restroom_a_clue_for_who_hears_it() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as DoubleClownRig
	var cop: Cop = party.get_node("Cop")
	party.chispita.global_position = party.to_global(Vector3(-8, BirthdayRaid.FLOOR_TOP, -6))
	cop.global_position = party.to_global(Vector3(-8, BirthdayRaid.FLOOR_TOP + 0.1, -4))
	rig.honk()
	assert_does_not_have(party.raid.clues_found, tr("CLUE_DOUBLE_CLOWN"), "too far to hear it")
	cop.global_position = party.to_global(DoubleClownRig.HONK_AT + Vector3(-3, -1, 0))
	rig.honk_left = 0.01
	await wait_physics_frames(2)
	assert_has(party.raid.clues_found, tr("CLUE_DOUBLE_CLOWN"))
	assert_almost_eq(rig.honk_left, DoubleClownRig.HONK_EVERY, 0.1, "again in a while")


func test_no_honk_where_chispita_stands() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as DoubleClownRig
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(DoubleClownRig.HONK_AT + Vector3(-3, -1, 0))
	party.chispita.global_position = party.to_global(DoubleClownRig.HONK_AT + Vector3(-1, -1.2, 0))
	rig.honk()
	assert_does_not_have(party.raid.clues_found, tr("CLUE_DOUBLE_CLOWN"))


func test_they_swap_and_the_one_back_has_other_shoes() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as DoubleClownRig
	var shoes: Node3D = party.chispita.find_child("shoes", true, false)
	assert_not_null(shoes)
	assert_eq(shoes.scale, Vector3.ONE)
	rig.swap_left = 0.01
	await wait_physics_frames(2)
	assert_eq(rig.twin, 1)
	assert_eq(shoes.scale, DoubleClownRig.SMALL_SHOES, "smaller shoes")
	assert_eq(party.chispita.get_node("Bubble").text, "CHISPITA_BACK")
	rig.swap()
	assert_eq(shoes.scale, Vector3.ONE, "the first one is back")


func test_the_costume_in_the_trunk_solves_the_case() -> void:
	var party := _party()
	await wait_physics_frames(10)
	var costume := party.main
	costume.global_position = party.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(party.car.is_delivered(costume))
	assert_true(party.raid.mark(party.raid.suspicions.find("double_clown")))
	party.car.enter(party.get_node("Cop"))
	assert_true(party.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_DOUBLE_CLOWN_B", "BRIEF_DOUBLE_CLOWN_C", "BRIEF_DOUBLE_CLOWN_D", "OBJ_FIND_CLOWN_COSTUME",
			"OBJ_EXTRA_CLOWN_NOSE", "OBJ_EXTRA_TWIN_PHOTO", "BIRTHDAY_HONK", "CLUE_DOUBLE_CLOWN", "CHISPITA_BACK"]:
		assert_ne(tr(key), key)
	assert_eq(BirthdayRaid.STORIES.size(), BirthdayRaid.SUSPICION_POOL.size(), "every suspicion has its story")
