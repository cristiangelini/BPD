extends GutTest

## Food flying in the riot (carcel-motin.md, step 2b, decision 104): angry inmates throw mash, jelly, chicken and
## yogurt at the cops or at each other, and food on an inmate upsets them, so the riot spreads.

const LEVEL := preload("res://scenes/levels/prison.tscn")

var prison: PrisonLevel
var riot: PrisonRiot
var cop: Cop


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	riot = prison.riot
	cop = prison.get_node("Cop")
	await wait_physics_frames(2)


func test_an_angry_inmate_throws_food() -> void:
	var inmate := riot.inmates[0]
	watch_signals(inmate)
	riot.start()
	inmate._throw_left = 0.0
	await wait_physics_frames(2)
	assert_signal_emitted(inmate, "threw")
	var food: RallyThrowable = get_signal_parameters(inmate, "threw")[1]
	assert_true(food.kind in PrisonInmate.FOODS)


func test_a_calm_inmate_doesnt_throw() -> void:
	var inmate := riot.inmates[PrisonRiot.INMATES - 1]
	watch_signals(inmate)
	riot.start()
	inmate._throw_left = 0.0
	await wait_physics_frames(2)
	assert_signal_not_emitted(inmate, "threw")


func test_they_throw_at_a_cop_nearby_or_at_each_other() -> void:
	var inmate := riot.inmates[0]
	assert_true(riot.target_for(inmate) is PrisonInmate, "no cop near: another inmate")
	cop.global_position = inmate.global_position + Vector3(3, 0, 0)
	var at_cop := 0
	for i in 40:
		at_cop += 1 if riot.target_for(inmate) == cop else 0
	assert_between(at_cop, 10, 39, "the cop, more often than not")


func test_food_on_an_inmate_upsets_them() -> void:
	riot.start()
	var inmate := riot.inmates[PrisonRiot.INMATES - 1]
	var before := inmate.anger
	var food := RallyThrowable.new()
	food.kind = "mash"
	prison.add_child(food)
	food.burst_on(inmate)
	assert_almost_eq(inmate.anger, minf(before + PrisonInmate.HIT_ANGER, PrisonInmate.MAX_ANGER), 0.01)
	assert_not_null(inmate.get_node_or_null("RallyStain"), "and stains them")
	assert_string_starts_with(inmate.said(), "INMATE_HIT_")


func test_two_hits_make_anyone_angry() -> void:
	var inmate := riot.inmates[PrisonRiot.INMATES - 1]
	inmate.hit_by_food(null)
	inmate.hit_by_food(null)
	assert_true(inmate.is_angry(), "the riot spreads")


func test_food_on_a_cop_counts_toward_slipping() -> void:
	var food := RallyThrowable.new()
	food.kind = "jelly"
	prison.add_child(food)
	food.global_position = cop.global_position + Vector3.UP
	food.burst_on(cop)
	assert_eq(cop.stats.get("food_hits", 0), 1)
	assert_eq(cop.stats.get("rally_blocks", 0), 0, "not the rally's award")
