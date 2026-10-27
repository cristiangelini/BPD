extends GutTest

## The karaoke's booth 4 story (allanamiento-karaoke.md, step 6): the box of pirated records and its extras hidden
## with the seed, the door "4" painted beside booth 3 and the singing behind it that a cop next to it hears (the clue,
## once).

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke(case_seed := 5) -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.story_id = "karaoke_booth4"
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_records_and_their_extras_are_hidden() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_has(place.raid.suspicions, "karaoke_booth4")
	assert_eq(place.main, place.hidden[0])
	assert_almost_eq(place.main.full_value, 1000.0, 0.01)
	assert_eq(place.extras.size(), 2, "the stamp and the list")
	assert_true(Karaoke.SPOTS[place.hidden_spots[0]].heavy, "the box is big")


func test_the_painted_door_is_beside_booth_3() -> void:
	var at := BoothFourRig.DOOR_AT
	assert_gt(at.z, Karaoke.BOOTH_Z[2] + Karaoke.BOOTH_DEPTH / 2, "past booth 3")
	assert_lt(at.z - (Karaoke.BOOTH_Z[2] + Karaoke.BOOTH_DEPTH / 2), GameScale.DOOR_WIDTH * 2, "right beside it")
	assert_lt(at.x, Karaoke.BOOTH_X, "on the west wall")


func test_a_cop_next_to_the_door_hears_the_singing_once() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: BoothFourRig = place.rig
	var cop: Cop = place.get_node("Cop")
	assert_false(rig.heard)
	assert_false(rig._voice.visible)
	cop.global_position = place.to_global(BoothFourRig.DOOR_AT + Vector3(1.0, 0.05, 0))
	await wait_physics_frames(2)
	assert_true(rig.heard)
	assert_true(rig._voice.visible, "la la laaa")
	assert_has(place.raid.clues_found, tr("KARAOKE_BOOTH4_CLUE"))
	var clues: int = place.raid.clues_found.size()
	cop.global_position = place.to_global(Vector3(3.0, Karaoke.FLOOR_TOP + 0.05, 2.0))
	await wait_physics_frames(2)
	assert_false(rig._voice.visible)
	cop.global_position = place.to_global(BoothFourRig.DOOR_AT + Vector3(1.0, 0.05, 0))
	await wait_physics_frames(2)
	assert_eq(place.raid.clues_found.size(), clues, "the clue is there once")


func test_every_story_can_be_drawn() -> void:
	assert_eq(Karaoke.STORIES.size(), Karaoke.SUSPICION_POOL.size(), "the six stories")
	for id: String in Karaoke.SUSPICION_POOL:
		assert_true(Karaoke.STORIES.has(id), id)
		assert_eq(Karaoke.pick_story(1, PackedStringArray(["--story=" + id])), id)


func test_the_booth_4_texts_exist() -> void:
	for key: String in ["BRIEF_KARAOKE_BOOTH4_B", "BRIEF_KARAOKE_BOOTH4_C", "BRIEF_KARAOKE_BOOTH4_D",
			"OBJ_FIND_PIRATE_DISCS", "OBJ_EXTRA_KARAOKE_STAMP", "OBJ_EXTRA_DISC_CLIENTS", "TOTO_CLUE_karaoke_booth4",
			"KARAOKE_BOOTH_4", "KARAOKE_BOOTH4_VOICE", "KARAOKE_BOOTH4_CLUE"]:
		assert_ne(tr(key), key, key)
