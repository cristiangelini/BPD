extends GutTest

## The prison's count, step 3 (carcel-recuento.md): E chalks a cross on an inmate's back and crosses his number off the
## list; the cook and the plumber aren't on it, and chalking them is a mistake they wipe off.

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


func test_e_chalks_a_cross_and_crosses_him_off() -> void:
	var inmate := plan.inmates[0]
	assert_eq(inmate.prompt_key(cop), "PROMPT_COUNT_CHALK")
	watch_signals(plan)
	inmate.use(cop)
	assert_true(inmate.marked)
	assert_true(inmate.get_node("Cross").visible, "the cross on his back")
	assert_true(plan.board.is_marked(inmate.number))
	assert_eq(plan.board.counted(), 1)
	assert_signal_emitted_with_parameters(plan, "counted_one", [inmate.number])
	assert_ne(inmate.said(), "", "he says something")
	assert_eq(inmate.prompt_key(cop), "", "nothing more to do with him")


func test_chalking_twice_counts_once() -> void:
	var inmate := plan.inmates[1]
	inmate.use(cop)
	inmate.use(cop)
	plan._on_chalked(inmate, cop)
	assert_eq(plan.board.counted(), 1)


func test_a_worker_is_a_mistake_and_wipes_it_off() -> void:
	var cook := plan.workers[0]
	assert_true(cook.is_worker())
	cook.use(cop)
	assert_eq(plan.wrong, 1)
	assert_eq(plan.board.counted(), 0, "not on the list")
	assert_eq(cook.said(), "COUNT_COOK_OFFENDED")
	assert_true(cook.marked)
	await wait_seconds(CountPlan.WIPE_AFTER + 0.2)
	assert_false(cook.marked, "he wiped it off")
	assert_false(cook.get_node("Cross").visible)
	plan.workers[1].use(cop)
	assert_eq(plan.workers[1].said(), "COUNT_PLUMBER_OFFENDED")
	assert_eq(plan.wrong, 2)


func test_all_counted_needs_the_hidden_ones_too() -> void:
	for inmate in plan.inmates:
		inmate.use(cop)
	assert_eq(plan.board.counted(), CountPlan.LIST - CountPlan.HIDDEN)
	assert_false(plan.all_counted(), "the hidden ones are missing")
	for number in plan.hidden:
		plan.board.set_marked(number, true)
	assert_true(plan.all_counted())


func test_a_follower_does_not_decide() -> void:
	plan.follower = true
	plan.inmates[0].use(cop)
	assert_false(plan.inmates[0].marked)
	assert_eq(plan.board.counted(), 0)
