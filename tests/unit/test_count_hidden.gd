extends GutTest

## The prison's count, step 5 (carcel-recuento.md): the three missing inmates in three of the eight hideouts, snoring
## to a cop close by; found with E they're counted, unfound they run for the gate in turn.

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


func _empty_one() -> CountHideout:
	for hideout in plan.hideouts:
		if hideout.occupant == 0:
			return hideout
	return null


func test_three_of_eight_have_someone() -> void:
	assert_eq(plan.hideouts.size(), CountPlan.HIDEOUTS.size())
	var full := plan.hideouts.filter(func(hideout: CountHideout) -> bool: return hideout.occupant != 0)
	assert_eq(full.size(), CountPlan.HIDDEN)
	for number in plan.hidden:
		assert_eq(plan.hidden_in[number].occupant, number)
	for hideout in plan.hideouts:
		assert_true(prison.inside_walls(hideout.global_position), hideout.name)
		assert_eq(hideout.prompt_key(cop), "PROMPT_COUNT_SEARCH")


func test_a_full_one_snores_to_a_close_cop() -> void:
	var hideout: CountHideout = plan.hidden_in[plan.hidden[0]]
	cop.global_position = hideout.global_position + Vector3(1.5, 0.1, 0)
	await wait_seconds(0.2)
	assert_true(hideout.snoring())
	var empty := _empty_one()
	cop.global_position = empty.global_position + Vector3(1.5, 0.1, 0)
	await wait_seconds(0.2)
	assert_false(empty.snoring())


func test_e_on_the_right_one_finds_him_counted() -> void:
	var number := plan.hidden[1]
	var hideout: CountHideout = plan.hidden_in[number]
	watch_signals(plan)
	hideout.use(cop)
	assert_eq(hideout.occupant, 0)
	assert_eq(plan.found, 1)
	assert_true(plan.board.is_marked(number))
	var inmate := plan.inmate_with(number)
	assert_not_null(inmate, "out in the yard now")
	assert_true(inmate.marked)
	assert_eq((inmate.get_node("Number") as Label3D).text, "%02d" % number)
	assert_signal_emitted_with_parameters(plan, "found_one", [number])


func test_an_empty_one_is_nothing() -> void:
	_empty_one().use(cop)
	assert_eq(plan.found, 0)
	assert_eq(plan.board.counted(), 0)


func test_unfound_they_run_in_turn() -> void:
	plan.start()
	plan.time = CountPlan.RUN_FIRST - 0.01
	await wait_physics_frames(3)
	assert_eq(plan.runners.size(), 1)
	assert_eq(plan.runners[0].get_meta("number"), plan.hidden[0])
	assert_eq(plan.hidden_in[plan.hidden[0]].occupant, 0, "out of his hideout")
	assert_eq(plan.runners[0].route.back(), CountPlan.GATE)
	# The second was found in time: nobody runs then.
	plan.hidden_in[plan.hidden[1]].use(cop)
	plan.time = CountPlan.RUN_FIRST + CountPlan.RUN_EVERY - 0.01
	await wait_physics_frames(3)
	assert_eq(plan.runners.size(), 1)
	plan.time = CountPlan.RUN_FIRST + 2 * CountPlan.RUN_EVERY - 0.01
	await wait_physics_frames(3)
	assert_eq(plan.runners.size(), 2)


func test_at_the_gate_he_is_gone_and_accounted() -> void:
	var runner := plan.run(plan.hidden[0])
	runner._escape()
	assert_eq(plan.escaped, 1)
	assert_true(plan.board.is_escaped(plan.hidden[0]))
	assert_true((plan.board.get_node("Gone%d" % plan.hidden[0]) as Label3D).visible)
	assert_eq(plan.board.accounted(), 1)
	assert_eq(plan.board.counted(), 0)


func test_cuffed_into_a_cell_he_is_counted() -> void:
	var runner := plan.run(plan.hidden[2])
	plan._on_caught(runner)
	plan._on_caught(runner)
	assert_eq(plan.caught, 1)
	assert_true(plan.board.is_marked(plan.hidden[2]))


func test_all_counted_with_one_gone() -> void:
	for inmate in plan.inmates:
		inmate.use(cop)
	plan.hidden_in[plan.hidden[0]].use(cop)
	plan.hidden_in[plan.hidden[1]].use(cop)
	assert_false(plan.all_counted())
	plan.run(plan.hidden[2])._escape()
	assert_true(plan.all_counted(), "nobody left to find")
