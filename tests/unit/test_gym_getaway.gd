extends GutTest

## El Toro's getaway (infiltracion-gimnasio.md, step 5, decision 172): found out, he jogs off down the sidewalk at
## 13 km/h and the chase on foot starts in the middle of the case; caught, it's solved with the evidence they have.
## In Play the gym is one of the five infiltrations.

const LEVEL := preload("res://scenes/levels/gym_hall.tscn")

var gym: GymHall


func before_each() -> void:
	Campaign.current = null
	gym = LEVEL.instantiate()
	gym.get_node("Cop").input_enabled = false
	add_child_autofree(gym)
	await wait_physics_frames(2)
	gym.routine.set_process(false)
	gym.case.give_tip()


func test_found_out_el_toro_jogs_off() -> void:
	gym.suspicion.raise(gym.members[0], 100.0)
	assert_not_null(gym.case.chase)
	assert_eq(gym.case.chase.suspect_id, SuspectCar.TORO_JOG)
	assert_eq(gym.case.chase.who, "toro")
	assert_false(gym.toro.visible, "he left the gym")


func test_it_is_a_chase_on_foot_down_the_sidewalk() -> void:
	assert_true(ChaseCase.ON_FOOT.has(SuspectCar.TORO_JOG))
	assert_true(ChaseCase.CLOSE_BY.has(SuspectCar.TORO_JOG))
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.TORO_JOG], 13.0 / 3.6, 0.01)
	assert_eq(SuspectCar.LANES[SuspectCar.TORO_JOG], ChaseRoute.SIDEWALK_LANE)


func test_el_toro_is_the_one_jogging() -> void:
	gym.suspicion.raise(gym.members[0], 100.0)
	var jog: SuspectCar = gym.case.chase.truck
	assert_eq(jog.kind, SuspectCar.TORO_JOG)
	assert_not_null(jog.get_node("Rider"))
	assert_true(jog.get_collision_mask_value(SuspectCar.COPS_LAYER), "a cop in front stops him")


func test_caught_it_counts_as_solved_with_the_evidence() -> void:
	gym.case.found(gym.evidence.kinds[0])
	gym.suspicion.raise(gym.members[0], 100.0)
	gym.case._on_chase_ended(true)
	assert_true(gym.case.solved())
	assert_eq(gym.case.report().salary, InfiltrationCase.SALARY / 3)


func test_play_draws_the_gym_among_the_infiltrations() -> void:
	assert_has(PlaceDraw.INFILTRATIONS, "gym")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "gym":
			drawn = true
			break
	assert_true(drawn)
