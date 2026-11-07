extends GutTest

## Lucho and the laughing gas at the dental office raid (allanamiento-dentista.md, step 4): he talks only for a candy
## from the jar, once per case (the doctor minds the candy if he sees it), and a gas tank knocked over or hit hard
## leaks: every cop near it laughs and can't grab anything for a while.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office() -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_lucho_waits_with_the_candies_in_the_jar() -> void:
	var office := _office()
	await wait_physics_frames(10)
	assert_eq(office.candies.size(), DentistRaid.CANDIES)
	for candy: Grabbable in office.candies:
		assert_true(candy.is_in_group(DentistKid.CANDY_GROUP))
		assert_lt(candy.position.distance_to(DentistRaid.JAR_AT), 0.3, "in the jar, on the reception")
	assert_eq(office.gas_tanks.size(), 2)
	for key: String in ["PROMPT_LUCHO", "PROMPT_LUCHO_CANDY", "LUCHO_IDLE_1", "LUCHO_WANTS_CANDY", "LUCHO_AGAIN",
			"LUCHO_THANKS", "LUCHO_NOTHING", "MOLINA_CANDY", "HINT_LAUGHING_GAS"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_without_a_candy_he_only_asks_for_one() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var cop: Cop = office.get_node("Cop")
	assert_eq(office.lucho.prompt_key(cop), "PROMPT_LUCHO")
	office.lucho.use(cop)
	assert_false(office.lucho.has_told)
	assert_eq(office.lucho.get_node("Bubble").text, "LUCHO_WANTS_CANDY")


func test_a_candy_gets_him_to_tell_once() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.lucho.clue = "LUCHO_TEST_CLUE"
	office.lucho.clue_speech = "LUCHO_TEST_SPEECH"
	watch_signals(office.lucho)
	var cop: Cop = office.get_node("Cop")
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(office.candies[0])
	assert_eq(office.lucho.prompt_key(cop), "PROMPT_LUCHO_CANDY")
	office.lucho.use(cop)
	assert_null(grabber.held, "he takes the candy")
	assert_true(office.lucho.has_told)
	assert_signal_emitted_with_parameters(office.lucho, "told", ["LUCHO_TEST_CLUE"])
	assert_eq(office.lucho.get_node("Bubble").text, "LUCHO_TEST_SPEECH")
	await wait_physics_frames(1)
	grabber.grab(office.candies[1])
	office.lucho.use(cop)
	assert_signal_emit_count(office.lucho, "told", 1, "once per case")
	assert_eq(office.lucho.get_node("Bubble").text, "LUCHO_THANKS")
	assert_eq(office.lucho.candies, 2)


func test_the_doctor_minds_a_candy_he_sees_lucho_get() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.molina.global_position = DentistRaid.LUCHO_AT + Vector3(2.0, 0, -1.0)
	office.molina.route = [office.molina.global_position, office.molina.global_position + Vector3(0, 0, 0.1)]
	office.molina.start_at(0)
	await wait_physics_frames(2)
	var cop: Cop = office.get_node("Cop")
	cop.get_node("Grabber").grab(office.candies[0])
	office.lucho.use(cop)
	assert_eq(office.molina.complaint, DentistRaid.SAW_CANDY)
	assert_eq(office.molina.get_node("Bubble").text, "MOLINA_CANDY")


func test_a_tank_knocked_over_leaks_and_the_cop_near_it_laughs() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var tank: LaughingGasTank = office.gas_tanks[0]
	var cop: Cop = office.get_node("Cop")
	cop.global_position = tank.global_position + Vector3(1.5, 0.1, 0)
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(office.candies[0])
	assert_false(tank.is_leaking())
	tank.rotation.z = PI / 2
	await wait_physics_frames(2)
	assert_true(tank.is_leaking())
	assert_true(cop.is_eating(), "laughing, no hands")
	assert_null(grabber.held, "it lets go of what it held")
	assert_false(grabber.try_grab(), "and can't grab")


func test_a_far_cop_does_not_laugh_and_the_leak_ends() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var tank: LaughingGasTank = office.gas_tanks[1]
	var cop: Cop = office.get_node("Cop")
	cop.global_position = tank.global_position + Vector3(0, 0.1, 6.0)
	tank.leak()
	tank.leak_left = 0.2
	await wait_physics_frames(3)
	assert_false(cop.is_eating())
	await wait_seconds(0.4)
	assert_false(tank.is_leaking(), "the gas runs out")


func test_a_hard_hit_opens_the_valve() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var tank: LaughingGasTank = office.gas_tanks[0]
	var thrown := ClubEvidence.make_item("Thrown", DentistRaid.JAR_MODEL, Vector3(0.3, 0.3, 0.3), 3.0)
	office.add_child(thrown)
	thrown.global_position = tank.global_position + Vector3(1.2, 0.5, 0)
	thrown.linear_velocity = Vector3(-9.0, 0, 0)
	await wait_physics_frames(30)
	assert_true(tank.leaks > 0)
