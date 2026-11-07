extends GutTest

## The dental office raid with the laughing gas story (allanamiento-dentista.md, step 6): the bundle of contraband tanks
## that takes two cops, its extras, the consulting rooms' tanks leaking on their own and the fish tank's giggling
## bubbles as the story's clue.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office(case_seed := 5) -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.story_id = "laughing_gas"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_bundle_takes_two_cops_and_is_hidden_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_has(office.raid.suspicions, "laughing_gas")
	assert_eq(office.main, office.hidden[0])
	assert_gt((office.main as RigidBody3D).mass, GameScale.COP_CARRY_KG, "too heavy for one cop")
	assert_true(DentistRaid.SPOTS[office.hidden_spots[0]].heavy)
	assert_eq(office.extras.size(), 2, "the balloons and the invoice")
	assert_true(office.rig is LaughingGasRig)


func test_the_rooms_tanks_leak_on_their_own() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as LaughingGasRig
	rig.since_leak = LaughingGasRig.LEAK_EVERY - 0.05
	await wait_physics_frames(6)
	assert_eq(rig.leaks, 1)
	var leaking := office.gas_tanks.filter(func(tank: LaughingGasTank) -> bool: return tank.is_leaking())
	assert_eq(leaking.size(), 1, "one of them")
	assert_lt(rig.since_leak, 1.0, "and the count starts over")


func test_a_guest_tank_leaks_with_the_hosts() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.rig.apply_net_state([false, true])
	assert_false(office.gas_tanks[0].is_leaking())
	assert_true(office.gas_tanks[1].is_leaking())
	assert_eq(office.rig.net_state(), [false, true])


func test_the_fish_tank_giggles_and_the_first_time_close_is_a_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as LaughingGasRig
	assert_false(rig.heard_giggles)
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(DentistRaid.TANK_AT + Vector3(-1.2, 0.1, 0))
	await wait_physics_frames(3)
	assert_true(rig.heard_giggles)
	assert_has(office.raid.clues_found, tr("CLUE_TANK_GIGGLES"))
	var clues: int = office.raid.clues_found.size()
	await wait_physics_frames(3)
	assert_eq(office.raid.clues_found.size(), clues, "only once")
	office.break_fish_tank()
	await wait_physics_frames(2)
	assert_false(rig.giggle.visible, "no fish tank, no giggles")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_LAUGHING_GAS_B", "BRIEF_LAUGHING_GAS_C", "BRIEF_LAUGHING_GAS_D", "OBJ_FIND_GAS_BUNDLE",
			"OBJ_EXTRA_GAS_BALLOONS", "OBJ_EXTRA_CARCAJADA_INVOICE", "LUCHO_CLUE_laughing_gas", "CLUE_TANK_GIGGLES",
			"TANK_GIGGLE"]:
		assert_ne(tr(key), key)
