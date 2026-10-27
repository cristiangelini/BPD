extends GutTest

## The birthday party raid's bouncy castle of watches (allanamiento-cumple.md, step 5): the bag always inside the
## castle's floor with its extras elsewhere, the "clinc" when a cop bounces on it (a clue), the cake knife landing on
## it letting the air out and the bag spilling, the kids blowing it up again, and the bag in the trunk solving the case.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party(case_seed := 5) -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.story_id = "watch_castle"
	party.case_seed = case_seed
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


func test_the_bag_is_inside_the_castle_and_the_extras_elsewhere() -> void:
	for case_seed in [5, 6, 7]:
		var party := _party(case_seed)
		await wait_physics_frames(2)
		assert_eq(BirthdayRaid.SPOTS[party.hidden_spots[0]].id, "in_bouncy_castle", "seed %d" % case_seed)
		assert_does_not_have(party.hidden_spots.slice(1), party.hidden_spots[0])
		assert_almost_eq((party.main as RigidBody3D).mass, 8.0, 0.01)
		assert_eq(party.extras.size(), 2, "the blower and the invoice")
		var rig := party.rig as WatchCastleRig
		assert_true(rig.inside)
		assert_false(party.main.visible, "inside the floor")
		assert_eq(party.main.collision_layer, 0)


func test_bouncing_goes_clinc_a_clue() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(BirthdayRaid.CASTLE_AT + Vector3(0, BirthdayRaid.CASTLE_FLOOR + 0.05, 0))
	cop.velocity = Vector3.ZERO
	await wait_physics_frames(3)
	assert_eq(cop.velocity.y, BirthdayRaid.BOUNCE)
	assert_has(party.raid.clues_found, tr("CLUE_WATCH_CASTLE"))


func test_the_kids_leave_the_knife_alone() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as WatchCastleRig
	var kid := party.kids[1]
	kid.position = party.to_local(rig.knife.global_position) + Vector3(0.2, 0, 0)
	kid.position.y = BirthdayRaid.FLOOR_TOP
	rig.knife.global_position = party.to_global(kid.position + Vector3(0.2, 0.05, 0))
	party._items_left = 0.0
	await wait_physics_frames(3)
	assert_null(kid.carrying)


func test_the_knife_lets_the_air_out_and_the_bag_spills() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as WatchCastleRig
	rig.knife.global_position = party.to_global(BirthdayRaid.CASTLE_AT + Vector3(0, 1.2, 0))
	await wait_until(func() -> bool: return party.castle_flat, 3.0)
	assert_true(party.castle_flat)
	assert_false(rig.inside)
	assert_true(party.main.visible)
	assert_false(party.main.freeze, "free to grab")
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(BirthdayRaid.CASTLE_AT + Vector3(0, BirthdayRaid.CASTLE_FLOOR + 0.1, 0))
	cop.velocity = Vector3.ZERO
	party._bounce()
	assert_lte(cop.velocity.y, 0.0, "a flat castle bounces nobody")
	rig.flat_left = 0.01
	await wait_physics_frames(2)
	assert_false(party.castle_flat, "the kids blow it up again")
	assert_eq(party.kids[1].said(), "BIRTHDAY_KID_INFLATE")


func test_the_bag_in_the_trunk_solves_the_case() -> void:
	var party := _party()
	await wait_physics_frames(10)
	(party.rig as WatchCastleRig).deflate()
	var bag := party.main
	bag.global_position = party.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(party.car.is_delivered(bag))
	assert_true(party.raid.mark(party.raid.suspicions.find("watch_castle")))
	party.car.enter(party.get_node("Cop"))
	assert_true(party.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_WATCH_CASTLE_B", "BRIEF_WATCH_CASTLE_C", "BRIEF_WATCH_CASTLE_D", "OBJ_FIND_CASTLE_WATCHES",
			"OBJ_EXTRA_PARTY_BLOWER", "OBJ_EXTRA_WATCH_INVOICE", "BIRTHDAY_CLINC", "CLUE_WATCH_CASTLE",
			"BIRTHDAY_CASTLE_PSSS", "BIRTHDAY_KID_INFLATE"]:
		assert_ne(tr(key), key)
