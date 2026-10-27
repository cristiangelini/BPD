extends GutTest

## The gym raid's power treadmills story (allanamiento-gimnasio.md, step 5): running on a treadmill makes the lights
## flicker (the clue, once), the treadmills start on their own and throw off whoever is on them, and the cable box, the
## upside-down meter and the wiring plan are hidden.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym(case_seed := 5) -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.story_id = "power_treadmills"
	gym.case_seed = case_seed
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func _on_treadmill(gym: GymRaid, index: int) -> Vector3:
	return gym.to_global(GymHall.TREADMILLS[index] + Vector3(0, GymHall.FLOOR_TOP + GymHall.TREADMILL_BELT + 0.05, 0))


func test_running_on_a_treadmill_flickers_the_lights_and_the_first_time_is_the_clue() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as PowerTreadmillsRig
	var cop: Cop = gym.get_node("Cop")
	cop.global_position = _on_treadmill(gym, 2)
	for i in 70:
		cop.is_running = true
		await wait_physics_frames(1)
	assert_eq(rig.flickers, 1, "after a second of running")
	assert_has(gym.raid.clues_found, tr("CLUE_LIGHTS_FLICKER"))
	var clues: int = gym.raid.clues_found.size()
	rig.flicker()
	assert_eq(gym.raid.clues_found.size(), clues, "the clue only once")


func test_a_broken_treadmill_doesnt_steal_power() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as PowerTreadmillsRig
	gym.break_treadmill(2)
	var cop: Cop = gym.get_node("Cop")
	cop.global_position = _on_treadmill(gym, 2)
	for i in 70:
		cop.is_running = true
		await wait_physics_frames(1)
	assert_eq(rig.flickers, 0)


func test_the_treadmills_start_on_their_own_and_throw_off_the_cop() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as PowerTreadmillsRig
	assert_false(rig.running)
	var cop: Cop = gym.get_node("Cop")
	cop.global_position = _on_treadmill(gym, 3)
	await wait_physics_frames(2)
	rig.start_running()
	await wait_physics_frames(3)
	assert_true(rig.running)
	assert_true(cop.is_staggered(), "thrown off")
	for i in 60:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_eq(GymHall.treadmill_index(gym.to_local(cop.global_position)), -1, "off the belt, backwards")
	assert_lt(gym.to_local(cop.global_position).z, GymHall.TREADMILLS[3].z, "behind it")


func test_the_cable_box_is_hidden_with_its_extras() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.main, gym.hidden[0])
	assert_almost_eq((gym.main as RigidBody3D).mass, 8.0, 0.01)
	assert_true(GymRaid.SPOTS[gym.hidden_spots[0]].heavy)
	assert_eq(gym.extras.size(), 2)
	for key: String in ["BRIEF_POWER_TREADMILLS_B", "BRIEF_POWER_TREADMILLS_C", "BRIEF_POWER_TREADMILLS_D",
			"OBJ_FIND_CABLE_BOX", "OBJ_EXTRA_POWER_METER", "OBJ_EXTRA_WIRING_PLAN", "LULA_CLUE_power_treadmills",
			"CLUE_LIGHTS_FLICKER", "GYM_TREADMILL_ROAR"]:
		assert_ne(tr(key), key)
