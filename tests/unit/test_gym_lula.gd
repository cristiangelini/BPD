extends GutTest

## Lula at the gym raid (allanamiento-gimnasio.md, step 3): she jogs on treadmill 1 and only tells what she saw to a
## cop who runs 5 s in a row on the treadmill beside hers, once per cop; stopping starts over and a broken treadmill
## doesn't count.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym() -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.case_seed = 5
	gym.story_id = "silver_dumbbells"
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func _beside(gym: GymRaid) -> Vector3:
	var treadmill := GymHall.TREADMILLS[GymRaid.BESIDE_LULA]
	return gym.to_global(treadmill + Vector3(0, GymHall.FLOOR_TOP + GymHall.TREADMILL_BELT + 0.05, -0.5))


func test_she_jogs_on_her_treadmill_and_no_member_takes_the_next_one() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var local := gym.to_local(gym.lula.global_position)
	assert_eq(GymHall.treadmill_index(local + Vector3.UP * 0.05), GymRaid.LULA_TREADMILL)
	for member: ClubMember in gym.members:
		var on := GymHall.treadmill_index(member.position + Vector3.UP * 0.05)
		assert_ne(on, GymRaid.LULA_TREADMILL, member.name)
		assert_ne(on, GymRaid.BESIDE_LULA, member.name)
	for key: String in ["PROMPT_LULA", "LULA_IDLE_1", "LULA_RUN_WITH_ME", "LULA_START", "LULA_NOTHING", "LULA_AGAIN"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_e_on_her_only_gets_an_invitation_to_run() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	gym.lula.use(gym.get_node("Cop"))
	assert_eq(gym.lula.get_node("Bubble").text, "LULA_RUN_WITH_ME")
	assert_false(gym.lula.has_told)


func test_running_beside_her_five_seconds_makes_her_talk_once() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	gym.lula.clue = "the clue"
	gym.lula.clue_speech = "LULA_TEST_SPEECH"
	watch_signals(gym.lula)
	var cop: Cop = gym.get_node("Cop")
	cop.global_position = _beside(gym)
	await wait_physics_frames(2)
	cop.is_running = true
	gym.lula.run_beside(cop, true, GymReceptionist.RUN_TIME - 1.0)
	assert_false(gym.lula.has_told, "not yet")
	gym.lula.run_beside(cop, false, 0.1)
	gym.lula.run_beside(cop, true, GymReceptionist.RUN_TIME - 1.0)
	assert_false(gym.lula.has_told, "stopping starts over")
	gym.lula.run_beside(cop, true, 1.1)
	assert_true(gym.lula.has_told)
	assert_signal_emitted_with_parameters(gym.lula, "told", ["the clue"])
	assert_eq(gym.lula.get_node("Bubble").text, "LULA_TEST_SPEECH")
	gym.lula.run_beside(cop, true, GymReceptionist.RUN_TIME + 1.0)
	assert_signal_emit_count(gym.lula, "told", 1)
	gym.lula.use(cop)
	assert_eq(gym.lula.get_node("Bubble").text, "LULA_AGAIN")


func test_the_raid_counts_a_cop_running_on_the_next_treadmill() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var cop: Cop = gym.get_node("Cop")
	cop.global_position = _beside(gym)
	for i in 10:
		cop.is_running = true
		await wait_physics_frames(1)
	assert_gt(gym.lula.run_time(cop), 0.0, "she counts it")
	cop.global_position = _beside(gym) + Vector3(-3.0, 0, 0)
	for i in 3:
		cop.is_running = true
		await wait_physics_frames(1)
	assert_eq(gym.lula.run_time(cop), 0.0, "not on the right treadmill")


func test_a_broken_treadmill_beside_her_doesnt_count() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	gym.break_treadmill(GymRaid.BESIDE_LULA)
	var cop: Cop = gym.get_node("Cop")
	cop.global_position = _beside(gym)
	for i in 10:
		cop.is_running = true
		await wait_physics_frames(1)
	assert_eq(gym.lula.run_time(cop), 0.0)
