extends GutTest

## The clown Chispita at the birthday party raid (allanamiento-cumple.md, step 2): his round, the complaint for the
## balloons and the cake he sees, cake time at the matchbox (dark hall, kids round the cake, him seeing nothing), the
## candles' rest after it, and the cop who sings along.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")


func _party() -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.case_seed = 5
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


func test_he_walks_his_round_and_speaks_as_chispita() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var start := party.chispita.global_position
	await wait_seconds(3.0)
	assert_gt(party.chispita.global_position.distance_to(start), 2.0, "he walks")
	assert_eq(party.chispita.voice, "CHISPITA")
	for key: String in ["CHISPITA_LINE_1", "CHISPITA_PRINTER", "CHISPITA_FIX_1", "CHISPITA_FIX_2", "CHISPITA_FIX_3",
			"CHISPITA_FIX_DONE", "CHISPITA_HURT", "CHISPITA_DOOR", "CHISPITA_SAW", "CHISPITA_NOTHING",
			"CHISPITA_OFFENDED", "CHISPITA_LAWYER", "CHISPITA_BALLOON", "CHISPITA_CRYING", "CHISPITA_SANG",
			"PROMPT_CANDLES", "PROMPT_SING", "HINT_CANDLES_RESTING"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_he_minds_the_balloons_and_the_cake() -> void:
	var party := _party()
	await wait_physics_frames(2)
	party.chispita.start_at(7)
	await wait_physics_frames(2)
	party.pop(3)
	assert_eq(party.chispita.complaint, BirthdayRaid.SAW_POP, "he saw it pop")
	party.break_cake()
	assert_eq(party.chispita.complaint, BirthdayRaid.SAW_POP + BirthdayRaid.SAW_CRYING, "the kids cry")
	assert_eq(party.complaint_bar.value, party.chispita.complaint)


func test_cake_time_darkens_the_hall_and_gathers_the_kids() -> void:
	var party := _party()
	await wait_physics_frames(2)
	party.chispita.fix_time = 1.5
	party.chispita.start_at(0)
	var cop: Cop = party.get_node("Cop")
	var before: Array[Vector3] = []
	for kid: PartyKid in party.kids:
		kid.wanders = false
		before.append(kid.position)
	var lamp: OmniLight3D = party._lamps[0]
	var bright := lamp.light_energy
	party.candles.button.use(cop)
	assert_true(party.candles.is_lit())
	assert_eq(party.candles.button.prompt, "PROMPT_SING")
	await wait_until(func() -> bool: return party.singing(), 10.0)
	assert_lt(party.chispita.global_position.distance_to(BirthdayRaid.SING_SPOT), 0.5, "at the head of the cake")
	await wait_physics_frames(2)
	assert_lt(lamp.light_energy, bright, "lights off")
	assert_true(party._flames.visible, "the candles burn")
	for kid: ClubMember in party.kids:
		assert_lt(Vector2(kid.position.x, kid.position.z).distance_to(Vector2(BirthdayRaid.CAKE_AT.x,
			BirthdayRaid.CAKE_AT.z)), 3.0, "round the cake")
		var to_cake := Vector3(BirthdayRaid.CAKE_AT.x - kid.position.x, 0, BirthdayRaid.CAKE_AT.z - kid.position.z)
		assert_gt((-kid.global_basis.z).dot(to_cake.normalized()), 0.9, "facing the cake")
	assert_false(party.chispita.can_see(party.to_global(Vector3(0, 1, 0))), "singing, he sees nothing")
	party.pop(5)
	assert_eq(party.chispita.complaint, 0.0, "not even a balloon")
	await wait_seconds(1.8)
	assert_false(party.singing())
	assert_false(party.candles.is_lit())
	assert_almost_eq(lamp.light_energy, bright, 0.001, "lights back on")
	assert_false(party._flames.visible)
	assert_gt(party.candles.rest_left, 0.0, "the candles rest")
	party.candles.button.use(cop)
	assert_false(party.candles.is_lit(), "not again until they rested")
	for i in party.kids.size():
		assert_eq(party.kids[i].position, before[i], "back where they were")


func test_a_cop_who_sings_along_calms_him_down_once() -> void:
	var party := _party()
	await wait_physics_frames(2)
	party.chispita.praise(-20.0, "CHISPITA_SAW")
	party.chispita.fix_time = 5.0
	party.chispita.start_at(0)
	var cop: Cop = party.get_node("Cop")
	party.candles.button.use(cop)
	await wait_until(func() -> bool: return party.singing(), 10.0)
	var before := party.chispita.complaint
	party.candles.button.use(cop)
	party.candles.button.use(cop)
	assert_almost_eq(party.chispita.complaint, before - BirthdayRaid.SANG, 0.01, "once a song")
	assert_eq(party.chispita.get_node("Bubble").text, "CHISPITA_SANG")
