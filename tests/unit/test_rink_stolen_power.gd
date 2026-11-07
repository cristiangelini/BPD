extends GutTest

## The rink raid with the stolen power (allanamiento-pista.md, step 6): the cable hooked to the street pole solves the
## case in the patrol car's trunk; every time the resurfacer starts the hall's lights flicker, the first time a clue;
## the mirror ball spins on its own with its colored spots.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink(case_seed := 5) -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.story_id = "stolen_power"
	rink.case_seed = case_seed
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func test_the_cable_solves_the_case() -> void:
	var rink := _rink()
	await wait_physics_frames(10)
	assert_has(rink.raid.suspicions, "stolen_power")
	assert_eq(rink.main.scene_file_path, "res://scenes/props/rink_power_cable.tscn")
	assert_eq(rink.main.mass, 5.0)
	assert_true(Rink.SPOTS[rink.hidden_spots[0]].heavy, "the coil only fits in a big spot")
	assert_eq(rink.extras.size(), 2, "the bills and the pliers")
	rink.main.global_position = rink.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(rink.car.is_delivered(rink.main))
	assert_true(rink.raid.mark(rink.raid.suspicions.find("stolen_power")))
	rink.car.enter(rink.get_node("Cop"))
	assert_true(rink.raid.case_solved)


func test_the_lights_flicker_every_time_the_resurfacer_starts_and_the_first_time_is_a_clue() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as StolenPowerRig
	var lamp := rink.hall_lights[0]
	var bright := lamp.light_energy
	assert_eq(rink.hall_lights.size(), 8)
	assert_eq(rig.flickers, 0, "parked, steady lights")
	rink.resurfacer.start()
	var dimmed := false
	for i in 30:
		await wait_physics_frames(2)
		dimmed = dimmed or lamp.light_energy < bright
	assert_true(dimmed, "the lights go off and on")
	await wait_seconds(StolenPowerRig.FLICKER_TIME)
	assert_eq(lamp.light_energy, bright, "and then they're back")
	rink.resurfacer.run_left = 0.0
	await wait_physics_frames(2)
	rink.resurfacer.start()
	await wait_physics_frames(2)
	assert_eq(rig.flickers, 2, "every start")
	assert_eq(rink.raid.clues_found.count(tr("CLUE_RINK_LIGHTS_FLICKER")), 1, "one clue")


func test_the_mirror_ball_spins_on_its_own() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var rig := rink.rig as StolenPowerRig
	assert_eq(rig.spots.size(), StolenPowerRig.SPOT_COLORS.size(), "colored spots")
	var turn := rink.mirror_ball.rotation.y
	await wait_physics_frames(10)
	assert_ne(rink.mirror_ball.rotation.y, turn, "it spins")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_STOLEN_POWER_B", "BRIEF_STOLEN_POWER_C", "BRIEF_STOLEN_POWER_D", "OBJ_FIND_POWER_CABLE",
			"OBJ_EXTRA_ZERO_BILLS", "OBJ_EXTRA_PLIERS", "COPITO_CLUE_stolen_power", "CLUE_RINK_LIGHTS_FLICKER",
			"RINK_FLICKER"]:
		assert_ne(tr(key), key, key)
