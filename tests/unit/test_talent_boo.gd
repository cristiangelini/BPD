extends GutTest

## The prison's talent show, step 4 (carcel-talentos.md): a vote with nobody at the jury table offends the audience,
## who throw food at the cops until it's over or every one of them is calmed with E.

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


func _skip() -> void:
	plan.phase_left = 0.0
	await wait_physics_frames(2)


## Through the first act's vote with the table as it is.
func _first_vote() -> void:
	plan.start()
	for i in 4:
		await _skip()


func test_an_empty_jury_table_starts_a_food_fight() -> void:
	watch_signals(plan)
	await _first_vote()
	assert_signal_emitted(plan, "fight_started")
	assert_eq(plan.angry_ones().size(), TalentPlan.ANGRY)
	assert_eq(plan.host.said(), "TALENT_OFFENDED")
	for inmate in plan.angry_ones():
		assert_false(inmate.seated, "stood up")
		assert_eq(inmate.prompt_key(cop), "PROMPT_CALM_AUDIENCE")


func test_a_cop_at_the_table_keeps_them_happy() -> void:
	plan.start()
	plan.chairs[0].use(cop)
	for i in 4:
		await _skip()
	assert_eq(plan.fight_left, 0.0)
	assert_true(plan.angry_ones().is_empty())


func test_they_throw_food_at_a_cop_in_the_canteen() -> void:
	await _first_vote()
	cop.global_position = prison.global_transform * Vector3(-3.0, 0.2, 0.0)
	for inmate in plan.angry_ones():
		plan._throw_left[inmate] = 0.0
	await wait_physics_frames(2)
	var food := prison.get_node("TalentPlan").get_children().filter(func(n: Node) -> bool:
		return n is RallyThrowable)
	assert_gt(food.size(), 0)


func test_calming_every_one_ends_it() -> void:
	watch_signals(plan)
	await _first_vote()
	for inmate in plan.angry_ones():
		inmate.use(cop)
		assert_true(inmate.seated)
	assert_eq(plan.fight_left, 0.0)
	assert_signal_emitted(plan, "fight_ended")


func test_it_ends_by_itself() -> void:
	await _first_vote()
	plan.fight_left = 0.01
	await wait_physics_frames(3)
	assert_true(plan.angry_ones().is_empty())
	assert_eq(plan.fights, 1)
