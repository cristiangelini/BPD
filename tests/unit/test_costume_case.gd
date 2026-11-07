extends GutTest

## The costume shop's case (allanamiento-disfraces.md, step 5): RaidCase with the shop's suspicions, the first story
## (the bear of the loot) with its two hidden extras, the bear by the counter that drops a bill when grabbed or when it
## falls, the clues Don Fantoche and Mimí give, the shop's checklist rows and Don Fantoche's lawyer losing the case.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = seed
	place.story_id = "bear_loot"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_case_draws_the_story_among_three_suspicions() -> void:
	var place := _shop()
	assert_true(CostumeShop.STORIES.has(CostumeShop.pick_story(7, PackedStringArray())))
	assert_eq(CostumeShop.pick_story(7, PackedStringArray(["--story=bear_loot"])), "bear_loot")
	assert_eq(place.raid.suspicions.size(), 3)
	assert_true(place.raid.suspicions.has("bear_loot"), "the true story is among them")
	for id: String in place.raid.suspicions:
		assert_true(CostumeShop.SUSPICION_POOL.has(id))
	for id: String in CostumeShop.SUSPICION_POOL:
		assert_ne(tr("SUSPECT_" + id), "SUSPECT_" + id, id)
		assert_ne(tr("CLUE_SUSPECT_" + id), "CLUE_SUSPECT_" + id, id)
	assert_eq(place.find_children("*", "ClueNote", false, false).size(), 3, "a note for each suspicion")


func test_the_bear_stands_by_the_counter_and_the_extras_are_hidden() -> void:
	var place := _shop()
	await wait_physics_frames(3)
	var rig := place.rig as BearLootRig
	assert_eq(place.main, rig.bear)
	assert_almost_eq(rig.bear.mass, 12.0, 0.01, "heavy as a wardrobe")
	assert_eq(rig.bear.full_value, 1000.0)
	assert_lt(rig.bear.position.distance_to(BearLootRig.BEAR_AT), 0.1)
	assert_eq(place.extras.size(), 2, "the rental list and the clown mask")
	assert_ne(place.hidden_spots[0], place.hidden_spots[1])
	for i in place.extras.size():
		assert_lt(place.extras[i].position.distance_to(CostumeShop.SPOTS[place.hidden_spots[i]].at), 0.1)
	assert_eq(place.raid.main_evidence, place.main)


func test_the_bear_drops_a_bill_when_grabbed_or_fallen() -> void:
	var place := _shop()
	await wait_physics_frames(3)
	var rig := place.rig as BearLootRig
	assert_eq(rig.bills.size(), 0, "standing still, it keeps them")
	rig.bear.hold(1, rig.bear.global_position + Vector3.UP)
	await wait_physics_frames(2)
	assert_eq(rig.bills.size(), 1, "a grab drops one")
	await wait_physics_frames(2)
	assert_eq(rig.bills.size(), 1, "just one for that grab")
	rig.bear.let_go(1)
	rig.bear.global_rotation = Vector3(0, 0, PI / 2)
	await wait_physics_frames(2)
	assert_eq(rig.bills.size(), 2, "falling over drops another")
	for i in 20:
		rig.drop_bill()
	assert_eq(rig.bills.size(), BearLootRig.MAX_BILLS)


func test_fantoche_and_mimi_give_the_hiding_spots() -> void:
	var place := _shop()
	assert_eq(place.owner_boss.slips.size(), 2, "one slip for each hidden thing")
	for i in place.hidden.size():
		var at := tr("LOC_" + CostumeShop.SPOTS[place.hidden_spots[i]].id)
		assert_true(place.owner_boss.slips.any(func(slip: String) -> bool: return slip.contains(at)), at)
	var where := tr("LOC_" + CostumeShop.SPOTS[place.hidden_spots[5 % 2]].id)
	assert_string_contains(place.niece.clue, where)
	place.niece.use(place.get_node("Cop"))
	assert_true(place.raid.clues_found.has(place.niece.clue), "what Mimí saw goes on the checklist")


func test_the_checklist_rows_and_the_lawyer() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var facts := place._place_facts()
	assert_eq(facts.enter_key, "OBJ_ENTER_COSTUME")
	assert_eq(facts.broken, 0)
	assert_eq(facts.extras, [], "the extras show once the story is known")
	place.mirror_cracked = true
	assert_eq(place._place_facts().broken, 1)
	assert_true(place.raid.mark(place.raid.suspicions.find("bear_loot")))
	assert_eq((place._place_facts().extras as Array).size(), 2)
	place.owner_boss.blame(FloorBoss.MAX_COMPLAINT, "FANTOCHE_LAWYER")
	assert_true(place.raid.case_failed, "Don Fantoche's lawyer loses the case")
	for key: String in ["BRIEF_COSTUME_TIP_B", "BRIEF_COSTUME_TIP_D", "BRIEF_COSTUME_TIP_E", "BRIEF_BEAR_LOOT_B",
			"BRIEF_BEAR_LOOT_C", "BRIEF_BEAR_LOOT_D", "OBJ_FIND_BEAR_LOOT", "OBJ_EXTRA_RENTAL_LIST",
			"OBJ_EXTRA_CLOWN_MASK", "OBJ_GUESS_COSTUME", "OBJ_BROKEN_COSTUME", "OBJ_COMPLAINT_COSTUME",
			"CASE_FAILED_LAWYER_COSTUME", "FANTOCHE_SLIP", "CLUE_MIMI", "MIMI_CLUE_bear_loot"]:
		assert_ne(tr(key), key, key)
