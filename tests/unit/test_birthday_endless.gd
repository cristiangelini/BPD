extends GutTest

## The birthday party raid's endless birthday (allanamiento-cumple.md, step 5): the album of the 52 parties hidden with
## its extras, Tomasito turning seven again (a clue), the kid actors asking for their pay, the choreography at cake
## time, and the album in the trunk solving the case.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party(case_seed := 5) -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.story_id = "endless_birthday"
	party.case_seed = case_seed
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


func test_the_album_is_hidden_with_its_extras() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.main, party.hidden[0])
	assert_almost_eq((party.main as RigidBody3D).mass, 1.0, 0.01)
	assert_eq(party.extras.size(), 2, "the box of 7 candles and the contracts")
	assert_has(party.raid.suspicions, "endless_birthday")
	assert_true(party.rig is EndlessBirthdayRig)


func test_tomasito_turns_seven_again_a_clue() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_does_not_have(party.raid.clues_found, tr("CLUE_ENDLESS_BIRTHDAY"))
	party.tomasito.use(party.get_node("Cop"))
	assert_eq(party.tomasito.said(), "TOMASITO_SEVEN_AGAIN")
	assert_has(party.raid.clues_found, tr("CLUE_ENDLESS_BIRTHDAY"))


func test_the_guests_ask_for_their_pay() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var kid := party.kids[1]
	var cop: Cop = party.get_node("Cop")
	kid.use(cop)
	assert_has(EndlessBirthdayRig.WAGES, kid.said())
	var first := kid.said()
	kid.use(cop)
	assert_has(EndlessBirthdayRig.WAGES, kid.said())
	assert_ne(kid.said(), first, "another line")


func test_they_hop_in_time_at_cake_time() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var cop: Cop = party.get_node("Cop")
	party.candles.button.use(cop)
	await wait_until(func() -> bool: return party.singing(), 10.0)
	await wait_seconds(0.2)
	var up := party.kids[1].position.y - BirthdayRaid.FLOOR_TOP
	assert_gt(up, 0.01, "off the floor")
	for kid in party.kids:
		assert_almost_eq(kid.position.y - BirthdayRaid.FLOOR_TOP, up, 0.001, "all at once")


func test_the_album_in_the_trunk_solves_the_case() -> void:
	var party := _party()
	await wait_physics_frames(10)
	var album := party.main
	album.global_position = party.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(party.car.is_delivered(album))
	assert_true(party.raid.mark(party.raid.suspicions.find("endless_birthday")))
	party.car.enter(party.get_node("Cop"))
	assert_true(party.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_ENDLESS_BIRTHDAY_B", "BRIEF_ENDLESS_BIRTHDAY_C", "BRIEF_ENDLESS_BIRTHDAY_D",
			"OBJ_FIND_BIRTHDAY_ALBUM", "OBJ_EXTRA_SEVEN_CANDLES", "OBJ_EXTRA_ACTOR_CONTRACTS", "TOMASITO_SEVEN_AGAIN",
			"CLUE_ENDLESS_BIRTHDAY", "BIRTHDAY_KID_WAGES_1", "BIRTHDAY_KID_WAGES_2", "BIRTHDAY_KID_WAGES_3"]:
		assert_ne(tr(key), key)
