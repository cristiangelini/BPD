extends GutTest

## The prison's talent show, step 2 (carcel-talentos.md): the stage, the jury table, the benches with the inmates and
## the host, and the show drawn from the seed.

const LEVEL := preload("res://scenes/levels/prison_talent.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: TalentPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.talent


func test_the_canteen_is_set_up_for_the_show() -> void:
	assert_not_null(plan)
	assert_eq(plan.chairs.size(), 4)
	assert_eq(plan.inmates.size(), TalentPlan.INMATES)
	assert_eq(prison.tables.size(), 3, "the west tables made room")
	assert_false(plan.stage.is_open, "the curtain starts closed")
	for inmate in plan.inmates:
		assert_true(inmate.seated)
		assert_true(prison.inside_walls(inmate.global_position), inmate.name)


func test_the_show_always_has_the_three_tricks_and_two_others() -> void:
	assert_eq(plan.acts.size(), TalentPlan.SHOW)
	for act in TalentPlan.TRICKS:
		assert_has(plan.acts, act)
	var seen := {}
	for act in plan.acts:
		assert_false(seen.has(act), "no act twice")
		seen[act] = true


func test_the_same_seed_draws_the_same_show() -> void:
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 7
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	assert_eq(other.talent.acts, plan.acts)


func test_a_cop_sits_on_the_jury_and_stands_up() -> void:
	var chair := plan.chairs[0]
	assert_eq(chair.prompt_key(cop), "PROMPT_JURY_SIT")
	chair.use(cop)
	await wait_physics_frames(2)
	assert_eq(cop.seated_in, chair)
	assert_eq(plan.jury_seated(), 1)
	assert_lt(cop.global_position.distance_to(chair.global_position), 0.2)
	assert_eq(chair.prompt_key(cop), "PROMPT_JURY_STAND")
	chair.stand_up()
	assert_null(cop.seated_in)
	assert_eq(plan.jury_seated(), 0)


func test_the_curtain_opens_and_closes() -> void:
	plan.stage.set_curtain(true, true)
	assert_true(plan.stage.is_open)
	plan.stage.set_curtain(false, true)
	assert_false(plan.stage.is_open)


func test_the_host_is_up_on_the_stage() -> void:
	var local := prison.global_transform.affine_inverse() * plan.host.global_position
	assert_almost_eq(local.y, PrisonLevel.FLOOR_TOP + TalentStage.SIZE.y, 0.05)
	assert_false(plan.host.seated)


func test_play_can_open_it() -> void:
	assert_true(PlaceDraw.PLACES.has("prison_talent"))
