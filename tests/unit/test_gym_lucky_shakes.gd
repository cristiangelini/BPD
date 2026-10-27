extends GutTest

## The gym raid's lucky shakes story (allanamiento-gimnasio.md, step 5): the shake on the reception with the clover
## makes a cop say their thoughts out loud (the first sip is the clue), and the jar, the lottery list and the golden
## blender are hidden.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym(case_seed := 5) -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.story_id = "lucky_shakes"
	gym.case_seed = case_seed
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func test_the_shake_waits_on_the_reception() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as LuckyShakesRig
	assert_almost_eq(gym.to_local(rig.shake.global_position).distance_to(LuckyShakesRig.SHAKE_AT), 0.0, 0.01)
	assert_eq(rig.shake.prompt_key(gym.get_node("Cop")), "PROMPT_SHAKE")


func test_drinking_it_says_your_thoughts_and_the_first_sip_is_the_clue() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as LuckyShakesRig
	var cop: Cop = gym.get_node("Cop")
	rig.shake.use(cop)
	var thought: Label3D = cop.get_node("Thought")
	assert_eq(thought.text, "GYM_THOUGHT_0")
	assert_has(gym.raid.clues_found, tr("CLUE_SHAKE_CLOVER"))
	var clues: int = gym.raid.clues_found.size()
	await wait_seconds(GymShake.THINK_TIME + 0.2)
	assert_false(is_instance_valid(thought), "only a while")
	rig.shake.use(cop)
	assert_eq((cop.get_node("Thought") as Label3D).text, "GYM_THOUGHT_1", "another thought each time")
	assert_eq(gym.raid.clues_found.size(), clues, "the clue only once")


func test_the_jar_is_hidden_with_its_extras() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.main, gym.hidden[0])
	assert_almost_eq((gym.main as RigidBody3D).mass, 1.0, 0.01)
	assert_eq(gym.extras.size(), 2)
	var keys: Array[String] = ["BRIEF_LUCKY_SHAKES_B", "BRIEF_LUCKY_SHAKES_C", "BRIEF_LUCKY_SHAKES_D",
		"OBJ_FIND_SHAKE_JAR", "OBJ_EXTRA_LOTTERY_LIST", "OBJ_EXTRA_GOLD_BLENDER", "LULA_CLUE_lucky_shakes",
		"CLUE_SHAKE_CLOVER", "PROMPT_SHAKE"]
	for i in GymShake.THOUGHTS:
		keys.append("GYM_THOUGHT_%d" % i)
	for key: String in keys:
		assert_ne(tr(key), key)
