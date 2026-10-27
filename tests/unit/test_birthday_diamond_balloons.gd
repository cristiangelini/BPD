extends GutTest

## The birthday party as a raid with the diamond balloons' story (allanamiento-cumple.md, step 4): the suspicions, the
## bunch of balloons full of diamonds and its extras hidden with the seed, the arch balloon that hangs down and drops a
## diamond, the ones that drop glass pebbles, what Chispita lets slip and Tomasito's secret, his lawyer, and the
## balloons in the trunk solving the case.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party(case_seed := 5) -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.story_id = "diamond_balloons"
	party.case_seed = case_seed
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


## The bodies lying about the party (the stones a balloon drops are some).
func _stones(party: BirthdayRaid) -> int:
	return party.get_children().filter(func(child: Node) -> bool: return child is RigidBody3D).size()


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.raid.suspicions.size(), 3)
	assert_has(party.raid.suspicions, "diamond_balloons")
	for id: String in party.raid.suspicions:
		assert_has(BirthdayRaid.SUSPICION_POOL, id)
	assert_eq(party.raid.owner_npc, party.chispita)


func test_the_balloons_are_hidden_with_their_extras() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.main, party.hidden[0])
	assert_almost_eq((party.main as RigidBody3D).mass, 2.0, 0.01)
	assert_eq(party.extras.size(), 2, "the trick pump and the clients list")
	var other := _party(6)
	await wait_physics_frames(2)
	assert_ne(party.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_heavy_balloon_hangs_down_and_drops_a_diamond_once_a_clue() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as DiamondBalloonsRig
	assert_between(rig.heavy, 0, party.balloons.size() - 1)
	assert_false(rig.pebbles.has(rig.heavy))
	var look := party.balloons[rig.heavy].get_child(1) as Node3D
	assert_almost_eq(look.position.y, -DiamondBalloonsRig.DROOP, 0.001, "it hangs down")
	party.pop(rig.heavy)
	assert_eq(rig.diamonds, 1)
	assert_has(party.raid.clues_found, tr("CLUE_DIAMOND_BALLOON"))


func test_the_other_balloons_drop_glass_pebbles_or_nothing() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var rig := party.rig as DiamondBalloonsRig
	for i in party.balloons.size():
		if i == rig.heavy:
			continue
		var before := _stones(party)
		party.pop(i)
		var dropped := _stones(party) - before
		assert_eq(dropped > 0, rig.pebbles.has(i), "balloon %d" % i)
	assert_eq(rig.diamonds, 0, "no diamonds in them")
	assert_does_not_have(party.raid.clues_found, tr("CLUE_DIAMOND_BALLOON"))


func test_chispita_slips_and_tomasito_tells_where() -> void:
	var party := _party()
	await wait_physics_frames(2)
	assert_eq(party.chispita.slips.size(), 3)
	assert_true(party.chispita.ask(party.get_node("Cop")))
	assert_eq(party.raid.clues_found.size(), 1)
	var where := tr("LOC_" + BirthdayRaid.SPOTS[party.hidden_spots[5 % 3]].id)
	assert_eq(party.tomasito_secret, where)
	var cop: Cop = party.get_node("Cop")
	party.pinata_breaker = cop
	party.tomasito.use(cop)
	assert_has(party.raid.clues_found, tr("CLUE_TOMASITO") % where, "on the checklist")


func test_his_lawyer_fails_the_case() -> void:
	var party := _party()
	await wait_physics_frames(2)
	party.chispita.praise(-FloorBoss.MAX_COMPLAINT, "CHISPITA_SAW")
	assert_true(party.raid.case_failed)


func test_the_balloons_in_the_trunk_solve_the_case() -> void:
	var party := _party()
	await wait_physics_frames(10)
	var balloons := party.main
	balloons.global_position = party.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(party.car.is_delivered(balloons))
	assert_true(party.raid.mark(party.raid.suspicions.find("diamond_balloons")))
	assert_eq(party.raid.objective_facts().extras.size(), 2)
	party.car.enter(party.get_node("Cop"))
	assert_true(party.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_BIRTHDAY_TIP_B", "BRIEF_BIRTHDAY_TIP_D", "BRIEF_BIRTHDAY_TIP_E",
		"BRIEF_DIAMOND_BALLOONS_B", "BRIEF_DIAMOND_BALLOONS_C", "BRIEF_DIAMOND_BALLOONS_D", "OBJ_FIND_DIAMOND_BALLOONS",
		"OBJ_EXTRA_TRICK_PUMP", "OBJ_EXTRA_CLIENT_LIST", "OBJ_ENTER_BIRTHDAY", "OBJ_GUESS_BIRTHDAY", "OBJ_BROKEN_BIRTHDAY",
		"OBJ_COMPLAINT_BIRTHDAY", "CHISPITA_SLIP", "CLUE_TOMASITO", "CLUE_DIAMOND_BALLOON", "BIRTHDAY_GLASS_PEBBLES",
		"HINT_ESCAPE_birthday", "CRIME_owner_birthday", "CONFESS_owner_birthday", "CASE_FAILED_LAWYER_BIRTHDAY"]
	for id: String in BirthdayRaid.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_birthday"))
	assert_true(ChaseSuspect.MODELS.has("birthday"))
	assert_true(RaidEscape.PLACES.has("birthday"))
