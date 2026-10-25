extends GutTest

## The riot's inmates (carcel-motin.md, step 2, decision 104): twenty at the canteen's tables, some already angry,
## their anger frozen until the first cop walks through the gate, then drifting down when left alone.

const LEVEL := preload("res://scenes/levels/prison.tscn")

var prison: PrisonLevel
var riot: PrisonRiot


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	riot = prison.riot
	await wait_physics_frames(2)


func test_twenty_inmates_at_the_tables() -> void:
	assert_eq(riot.inmates.size(), PrisonRiot.INMATES)
	for inmate in riot.inmates:
		assert_true(prison.in_canteen(inmate.global_position), "%s in the canteen" % inmate.name)


func test_some_start_angry() -> void:
	assert_eq(riot.angry, PrisonRiot.ANGRY_AT_START)
	assert_true(riot.inmates[0].get_node("Steam").visible, "the angry ones steam")


func test_the_same_seed_puts_them_in_the_same_places() -> void:
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 7
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	assert_eq(other.riot.inmates[3].global_position.distance_to(riot.inmates[3].global_position), 0.0)


func test_nothing_moves_until_a_cop_comes_in() -> void:
	var anger := riot.inmates[0].anger
	await wait_physics_frames(20)
	assert_false(riot.running)
	assert_eq(riot.inmates[0].anger, anger)


func test_the_first_cop_through_the_gate_starts_it() -> void:
	watch_signals(riot)
	var cop: Cop = prison.get_node("Cop")
	cop.global_position = prison.to_global(Vector3(0, 0.1, PrisonLevel.HALF_Z - 2.0))
	await wait_physics_frames(3)
	assert_signal_emitted(riot, "started")
	assert_true(riot.inmates[0].active)


## The first inmate who starts angry and isn't a ringleader (the first inmate always leads a table, and a
## ringleader neither calms down nor shouts like the rest).
func _angry_follower() -> PrisonInmate:
	for inmate in riot.inmates:
		if inmate.is_angry() and not inmate.ringleader:
			return inmate
	return null


func test_left_alone_they_calm_down() -> void:
	riot.start()
	var inmate := _angry_follower()
	var before := riot.angry
	watch_signals(riot)
	inmate._quiet_left = 0.0
	inmate.anger = PrisonInmate.ANGRY + 0.01
	await wait_physics_frames(10)
	assert_false(inmate.is_angry())
	assert_signal_emitted_with_parameters(riot, "angry_changed", [before - 1])


func test_upset_they_stay_upset_a_while() -> void:
	riot.start()
	var inmate := riot.inmates[PrisonRiot.INMATES - 1]
	inmate.raise(PrisonInmate.MAX_ANGER)
	await wait_physics_frames(10)
	assert_eq(inmate.anger, PrisonInmate.MAX_ANGER, "not before CALM_AFTER")
	assert_true(inmate.is_angry())


func test_angry_ones_shout() -> void:
	riot.start()
	await wait_physics_frames(2)
	assert_string_starts_with(_angry_follower().said(), "INMATE_SHOUT_")
