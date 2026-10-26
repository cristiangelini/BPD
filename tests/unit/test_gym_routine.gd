extends GutTest

## El Toro's routine (infiltracion-gimnasio.md, step 3, decision 172): every so often he whistles an exercise (squats,
## jumps, treadmill or weight); a cop in the gym not doing it in front of a member raises their suspicion, the
## exercise spends stamina, and running out of it is giving up, which raises it more.

const LEVEL := preload("res://scenes/levels/gym_hall.tscn")

var gym: GymHall
var routine: GymRoutine
var cop: Cop


func before_each() -> void:
	gym = LEVEL.instantiate()
	cop = gym.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(gym)
	await wait_physics_frames(2)
	routine = gym.routine
	cop.global_position = gym.global_transform * Vector3(0.0, 0.2, 3.0)
	await wait_physics_frames(2)
	cop.input_enabled = true


## Lets the grace after the whistle pass and judges.
func _judge() -> void:
	routine.since_start = GymRoutine.GRACE + 0.1
	routine.judge()


func test_the_first_routine_comes_after_a_warning() -> void:
	assert_false(routine.is_routine())
	routine._lead(GymRoutine.FIRST - GymRoutine.WARNING + 0.1)
	assert_false(routine.is_routine())
	assert_eq(gym.toro.said(), "TORO_ROUTINE_SOON")
	routine._lead(GymRoutine.WARNING)
	assert_true(routine.is_routine())
	assert_has(GymRoutine.EXERCISES, routine.exercise)
	assert_eq(gym.toro.said(), "TORO_ROUTINE_" + routine.exercise.to_upper())
	assert_almost_eq(routine.next_left, GymRoutine.BREAK, 0.01, "one every 40 s")


func test_the_same_seed_draws_the_same_exercises() -> void:
	var other: GymHall = LEVEL.instantiate()
	other.case_seed = gym.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in 4:
		routine.start_routine()
		other.routine.start_routine()
		assert_eq(other.routine.exercise, routine.exercise)


func test_not_doing_it_is_wrong() -> void:
	routine.start_routine("jumps")
	watch_signals(routine)
	_judge()
	assert_eq(routine.bad_seconds, 1)
	assert_signal_emitted_with_parameters(routine, "missed", [cop, GymRoutine.NOT_DOING])


func test_squatting_every_two_seconds_is_right() -> void:
	routine.start_routine("squats")
	cop.step(1.0 / 60.0, Vector2.ZERO, false, true, false)
	routine._track(0.0)
	watch_signals(routine)
	_judge()
	assert_eq(routine.good_seconds, 1)
	assert_signal_not_emitted(routine, "missed")
	routine._track(GymRoutine.EVERY + 0.1)
	_judge()
	assert_eq(routine.bad_seconds, 1, "staying down isn't a squat")


func test_jumping_is_right_for_jumps() -> void:
	routine.start_routine("jumps")
	cop.step(1.0 / 60.0, Vector2.ZERO, false, false, true)
	await wait_physics_frames(3)
	assert_true(routine.doing(cop))
	_judge()
	assert_eq(routine.good_seconds, 1)


func test_running_on_a_treadmill_is_right_and_off_it_is_not() -> void:
	routine.start_routine("treadmill")
	cop.is_running = true
	assert_false(routine.doing(cop), "running on the floor isn't the treadmill")
	var belt := GymHall.TREADMILLS[0] + Vector3(0, GymHall.FLOOR_TOP + GymHall.TREADMILL_BELT + 0.05, -0.4)
	cop.global_position = gym.global_transform * belt
	cop.is_running = true
	assert_true(routine.doing(cop))
	cop.is_running = false
	assert_false(routine.doing(cop), "standing on it isn't running")


func test_holding_a_dumbbell_is_right_for_the_weight() -> void:
	routine.start_routine("weight")
	assert_false(routine.doing(cop))
	var dumbbell: Grabbable = gym.get_node("Dumbbell0")
	assert_true(dumbbell.is_in_group("gym_dumbbells"))
	assert_almost_eq(dumbbell.mass, GymRoutine.DUMBBELL_KG, 0.01)
	cop.global_position = dumbbell.global_position + Vector3(1.0, -0.8, 0)
	cop.get_node("Grabber").grab(dumbbell)
	assert_true(routine.doing(cop))


func test_the_dumbbells_lie_on_the_rack() -> void:
	await wait_physics_frames(30)
	for i in GymHall.DUMBBELLS.size():
		var dumbbell: Node3D = gym.get_node("Dumbbell%d" % i)
		var local := gym.global_transform.affine_inverse() * dumbbell.global_position
		assert_almost_eq(local.x, GymHall.RACK_AT.x, 0.3, "on the rack")
		assert_gt(local.y, GymHall.FLOOR_TOP + 0.6, "not on the floor")


func test_the_exercise_spends_stamina_and_a_rested_cop_makes_it() -> void:
	routine.start_routine("squats")
	cop.stamina = GameScale.RUN_STAMINA
	var dt := 0.1
	for i in int(GymRoutine.ROUTINE / dt):
		cop.step(dt, Vector2.ZERO, false, i % 10 < 5, false)
		routine._track(dt)
		routine._spend(dt)
	assert_lt(cop.stamina, GameScale.RUN_STAMINA * 0.5, "tiring")
	assert_gt(cop.stamina, 0.0, "but a rested cop lasts the 10 s")


func test_running_out_of_breath_is_giving_up() -> void:
	routine.start_routine("squats")
	cop.stamina = 0.0
	watch_signals(routine)
	_judge()
	assert_true(routine.gave_up)
	assert_true(cop.is_staggered(), "panting")
	assert_signal_emitted_with_parameters(routine, "missed", [cop, GymRoutine.GAVE_UP])
	_judge()
	assert_signal_emit_count(routine, "missed", 1, "once per routine")


func test_the_members_who_see_it_get_suspicious() -> void:
	cop.put_on_disguise("gym_headband", 0.0)
	cop.put_on_disguise("gym_tank", 0.0)
	var seen := gym.members.filter(func(m: ClubMember) -> bool: return m.sees_cop(cop))
	if seen.is_empty():
		var member := gym.members[0]
		cop.global_position = member.global_position - member.global_basis.z * 2.0 + Vector3.UP * 0.1
		seen = [member]
	var before: float = seen[0].suspicion
	routine.start_routine("jumps")
	_judge()
	assert_gt(seen[0].suspicion, before)


func test_outside_the_gym_nothing_counts() -> void:
	cop.global_position = gym.global_transform * Vector3(0, 0.2, GymHall.HALF_Z + 4.0)
	routine.start_routine("jumps")
	watch_signals(routine)
	_judge()
	assert_signal_not_emitted(routine, "missed")


func test_the_members_squat_along() -> void:
	var member := gym.members[0]
	var floor_y := member.position.y
	routine.start_routine("squats")
	routine.since_start = 0.5
	routine._move_members()
	assert_lt(member.position.y, floor_y - 0.1)
	routine.routine_left = 0.0
	routine._move_members()
	assert_almost_eq(member.position.y, floor_y, 0.001, "back on the spot")


func test_the_routine_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["TORO_ROUTINE_SOON", "GYM_GOOD", "GYM_GAVE_UP"]
	for exercise: String in GymRoutine.EXERCISES:
		for start: String in ["TORO_ROUTINE_", "GYM_EX_", "GYM_HOW_", "GYM_NOT_DOING_", "HINT_GYM_"]:
			keys.append(start + exercise.to_upper())
	for key in keys:
		assert_ne(tr(key), key)
