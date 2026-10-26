extends GutTest

## El profe Fito at the gym raid (allanamiento-gimnasio.md, step 2): his round, the class he gives to the mirror when a
## cop puts on his song (seeing nothing, the members bouncing along), the stereo's rest after it, the dumbbells and
## treadmills he can't stand to see, and the cop who dances with them.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym() -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.case_seed = 5
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func test_he_walks_his_round_and_speaks_as_the_profe() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var start := gym.coach.global_position
	await wait_seconds(3.0)
	assert_gt(gym.coach.global_position.distance_to(start), 2.0, "he walks")
	assert_eq(gym.coach.voice, "COACH")
	for key: String in ["COACH_LINE_1", "COACH_PRINTER", "COACH_FIX_1", "COACH_FIX_DONE", "COACH_HURT", "COACH_DOOR",
			"COACH_SAW", "COACH_NOTHING", "COACH_OFFENDED", "COACH_LAWYER", "COACH_DUMBBELL", "COACH_TREADMILL",
			"COACH_MIRROR", "COACH_DANCE", "PROMPT_STEREO", "HINT_STEREO_RESTING"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_his_song_takes_him_to_the_mirror_and_the_members_bounce() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	gym.coach.fix_time = 1.5
	gym.coach.start_at(4)
	var cop: Cop = gym.get_node("Cop")
	var before: Array[Vector3] = []
	for member: ClubMember in gym.members:
		before.append(member.position)
	gym.stereo.button.use(cop)
	assert_true(gym.stereo.is_playing())
	assert_eq(gym.coach.errand(), "printer", "he goes to give his class")
	await wait_until(func() -> bool: return gym.in_class(), 10.0)
	assert_lt(gym.coach.global_position.distance_to(GymRaid.CLASS_SPOT), 0.5, "in front of the mirror")
	assert_false(gym.coach.can_see(gym.coach.global_position + Vector3(0, 1, 3)), "his back to the hall")
	await wait_physics_frames(10)
	for member: ClubMember in gym.members:
		assert_almost_eq(member.rotation.y, 0.0, 0.01, "facing the mirror")
	await wait_seconds(1.8)
	assert_false(gym.in_class())
	assert_false(gym.stereo.is_playing())
	assert_gt(gym.stereo.rest_left, 0.0, "the stereo rests")
	gym.stereo.button.use(cop)
	assert_false(gym.stereo.is_playing(), "not again until it rested")
	await wait_physics_frames(2)
	for i in gym.members.size():
		assert_almost_eq(gym.members[i].position.y, before[i].y, 0.001, "back on the floor")
	assert_eq((gym.coach.get_node("Model") as Node3D).position.y, 0.0, "he stops bouncing")


func test_a_cop_who_dances_in_the_class_calms_him_down_once() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	gym.coach.praise(-20.0, "COACH_SAW")
	assert_eq(gym.coach.complaint, 20.0)
	gym.coach.fix_time = 5.0
	gym.coach.start_at(4)
	gym.stereo.button.use(gym.get_node("Cop"))
	await wait_until(func() -> bool: return gym.in_class(), 10.0)
	var cop: Cop = gym.get_node("Cop")
	cop.global_position = Vector3(0, 0.2, 2.0)
	var before := gym.coach.complaint
	for i in 3:
		cop.velocity.y = 4.0
		await wait_physics_frames(1)
	assert_almost_eq(gym.coach.complaint, before - GymRaid.DANCED, 1.0, "once a class")
	assert_eq(gym.coach.get_node("Bubble").text, "COACH_DANCE")


func test_a_dumbbell_he_sees_on_the_floor_goes_on_the_complaint_once() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	gym.coach.global_position = Vector3(-4.0, GymHall.FLOOR_TOP, 2.0)
	gym.coach.route = [Vector3(-4.0, GymHall.FLOOR_TOP, 2.0), Vector3(-4.0, GymHall.FLOOR_TOP, 2.1)]
	gym.coach.start_at(0)
	var dumbbell := gym.dumbbells[0]
	dumbbell.global_position = Vector3(-4.0, GymHall.FLOOR_TOP + 0.1, 0.5)
	await wait_physics_frames(20)
	assert_eq(gym.coach.complaint, GymRaid.SAW_DUMBBELL)
	assert_eq(gym.coach.get_node("Bubble").text, "COACH_DUMBBELL")
	await wait_physics_frames(20)
	assert_eq(gym.coach.complaint, GymRaid.SAW_DUMBBELL, "once while it stays there")


func test_a_broken_treadmill_he_sees_goes_on_the_complaint() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	gym.coach.global_position = Vector3(4.0, GymHall.FLOOR_TOP, 2.5)
	gym.coach.route = [Vector3(4.0, GymHall.FLOOR_TOP, 2.5), Vector3(4.0, GymHall.FLOOR_TOP, 2.6)]
	gym.coach.start_at(0)
	await wait_physics_frames(2)
	gym.break_treadmill(2)
	assert_eq(gym.coach.complaint, GymRaid.SAW_TREADMILL)
	assert_eq(gym.coach.get_node("Bubble").text, "COACH_TREADMILL")
