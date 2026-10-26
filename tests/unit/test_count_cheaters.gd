extends GutTest

## The prison's count, step 4 (carcel-recuento.md): two of the wanderers rub their chalk cross off on a wall now and
## then, and their numbers go back on the list.

const LEVEL := preload("res://scenes/levels/prison_count.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: CountPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 4
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.count
	plan.start()


func test_two_wanderers_cheat() -> void:
	assert_eq(plan.cheaters.size(), CountPlan.CHEATERS)
	for cheater in plan.cheaters:
		assert_true(cheater.cheater)
		assert_eq(cheater.activity, YardInmate.Activity.WANDER)
	assert_ne(plan.cheaters[0].rub_left, plan.cheaters[1].rub_left, "not both at once")
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 4
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	assert_eq(other.count.cheaters[0].number, plan.cheaters[0].number, "the seed picks them")


func test_unmarked_he_does_not_go() -> void:
	var cheater := plan.cheaters[0]
	cheater.rub_left = 0.05
	await wait_physics_frames(10)
	assert_eq(cheater.rubbing, 0.0)
	assert_eq(cheater.rub_left, 0.05, "the clock only runs once he's marked")


func test_marked_he_walks_to_a_wall_and_rubs_it_off() -> void:
	var cheater := plan.cheaters[0]
	cheater.use(cop)
	assert_true(plan.board.is_marked(cheater.number))
	watch_signals(plan)
	# Right by the east wall, so the walk is short.
	cheater.global_position = prison.global_transform * Vector3(PrisonLevel.HALF_X - 2.0, PrisonLevel.FLOOR_TOP, 14.0)
	cheater.rub_left = 0.01
	await wait_until(func() -> bool: return cheater.rubbing > 0.0, 3.0)
	var local := prison.global_transform.affine_inverse() * cheater.global_position
	assert_gt(local.x, PrisonLevel.HALF_X - 1.5, "at the east wall")
	assert_eq(cheater.said(), "COUNT_ITCHY")
	assert_true(cheater.marked, "still on while rubbing")
	await wait_until(func() -> bool: return not cheater.marked, CountInmate.RUB_TIME + 1.0)
	assert_false(plan.board.is_marked(cheater.number), "back on the list")
	assert_eq(plan.rubbed, 1)
	assert_signal_emitted_with_parameters(plan, "rubbed_one", [cheater.number])
	assert_eq(cheater.rub_left, CountInmate.RUB_EVERY)
	await wait_physics_frames(3)
	assert_true(cheater.is_walking(), "off wandering again")
	assert_eq(cheater.prompt_key(cop), "PROMPT_COUNT_CHALK", "to be chalked again")


func test_the_building_wall_too() -> void:
	var cheater := plan.cheaters[1]
	cheater.use(cop)
	cheater.global_position = prison.global_transform * Vector3(0.0, PrisonLevel.FLOOR_TOP, PrisonLevel.BUILDING_FRONT + 1.5)
	cheater.rub_now()
	await wait_until(func() -> bool: return cheater.rubbing > 0.0, 3.0)
	var local := prison.global_transform.affine_inverse() * cheater.global_position
	assert_lt(local.z, PrisonLevel.BUILDING_FRONT + 1.0)


func test_an_honest_one_keeps_his_cross() -> void:
	var honest: CountInmate = null
	for inmate in plan.inmates:
		if not inmate.cheater:
			honest = inmate
			break
	honest.use(cop)
	honest.rub_left = 0.01
	await wait_physics_frames(5)
	assert_eq(honest.rubbing, 0.0)
	assert_true(honest.marked)
