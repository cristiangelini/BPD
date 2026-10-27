extends GutTest

## The hotel raid with the stolen robes (hotel-allanamiento.md, step 5): robes with other hotels' crests hanging in
## every room, and the bag of robes in the patrol car's trunk.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid(case_seed := 5) -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.story_id = "robes"
	raid.case_seed = case_seed
	raid.get_node("Cop").input_enabled = false
	raid.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_the_bag_hides_where_it_fits_and_solves_the_case() -> void:
	var raid := _raid()
	await wait_physics_frames(10)
	assert_has(raid.raid.suspicions, "robes")
	assert_eq(raid.main.scene_file_path, "res://scenes/props/robe_bag.tscn")
	assert_true(HotelRaid.SPOTS[raid.hidden_spots[0]].heavy, "the bag only goes where it fits")
	assert_true(HotelRaid.SPOTS[raid.hidden_spots[2]].heavy, "and the embroidery machine")
	assert_eq(raid.extras.size(), 2)
	raid.main.global_position = raid.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(raid.car.is_delivered(raid.main))
	assert_true(raid.raid.mark(raid.raid.suspicions.find("robes")))
	raid.car.enter(raid.get_node("Cop"))
	assert_true(raid.raid.case_solved)


func test_a_robe_with_another_crest_in_every_room() -> void:
	var raid := _raid()
	await wait_physics_frames(10)
	var rig := raid.rig as RobesRig
	assert_eq(rig.robes.size(), Hotel.GUEST_ROOMS.size() + 1, "one per room and one in the suite")
	for i in Hotel.GUEST_ROOMS.size():
		assert_eq(raid.hotel.room_of(rig.robes[i].global_position), Hotel.GUEST_ROOMS[i], "hanging inside its room")
	assert_eq(raid.hotel.room_of(rig.robes[-1].global_position), 0, "and in the suite")
	for robe in rig.robes:
		assert_true(robe.freeze, "still on its hook")
		assert_false(robe.has_method("deliver") or "full_value" in robe, "worth nothing")
	rig.robes[0].use(raid.get_node("Cop"))
	assert_eq(raid.raid.clues_found.size(), 1)
	assert_ne(raid.raid.clues_found[0].find(tr("ROBE_HOTEL_%d" % (5 % RobesRig.CRESTS))), -1, "another hotel's crest")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_ROBES_B", "BRIEF_ROBES_C", "BRIEF_ROBES_D", "OBJ_FIND_ROBES", "OBJ_EXTRA_BUYERS_LIST",
			"OBJ_EXTRA_EMBROIDERY", "PROMPT_ROBE", "CLUE_ROBES_CREST"]:
		assert_ne(tr(key), key, key)
	for i in RobesRig.CRESTS:
		assert_ne(tr("ROBE_HOTEL_%d" % i), "ROBE_HOTEL_%d" % i)
