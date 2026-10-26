extends GutTest

## The prison's count, step 2 (carcel-recuento.md): the inmates with their numbers out in the yard, the hidden ones
## missing, the cook and the plumber among them and the list on its board.

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


func test_the_list_and_who_is_out() -> void:
	assert_not_null(plan)
	assert_eq(plan.board.numbers.size(), CountPlan.LIST)
	assert_eq(plan.hidden.size(), CountPlan.HIDDEN)
	assert_eq(plan.inmates.size(), CountPlan.LIST - CountPlan.HIDDEN)
	var numbers: Array = plan.number_of.values()
	for number in plan.hidden:
		assert_false(numbers.has(number), "a hidden one is not in the yard")
	numbers.append_array(plan.hidden)
	numbers.sort()
	assert_eq(numbers, plan.board.numbers, "every number on the list once")


func test_each_wears_his_number() -> void:
	for inmate in plan.inmates:
		var label := inmate.get_node("Number") as Label3D
		assert_eq(label.text, "%02d" % plan.number_of[inmate])
		assert_eq((inmate.get_node("NumberBack") as Label3D).text, label.text)
		assert_true(prison.inside_walls(inmate.global_position), inmate.name)
		assert_eq(plan.inmate_with(plan.number_of[inmate]), inmate)
	assert_null(plan.inmate_with(plan.hidden[0]))


func test_the_workers_have_no_number() -> void:
	assert_eq(plan.workers.size(), 2)
	for worker in plan.workers:
		assert_null(worker.get_node_or_null("Number"))
		assert_ne(worker.model, YardInmate.MODEL)
		assert_false(plan.number_of.has(worker))


func test_the_board_counts_and_crosses() -> void:
	var board := plan.board
	var label := board.get_node("Total") as Label3D
	assert_eq(label.text, tr("COUNT_BOARD_TOTAL") % [0, CountPlan.LIST])
	board.set_marked(7, true)
	board.set_marked(7, true)
	assert_eq(board.counted(), 1)
	assert_true((board.get_node("Cross7") as Label3D).visible)
	board.set_marked(7, false)
	assert_eq(board.counted(), 0)
	assert_false((board.get_node("Cross7") as Label3D).visible)


func test_the_seed_picks_the_hidden_ones() -> void:
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 4
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	assert_eq(other.count.hidden, plan.hidden)
	assert_eq(other.count.inmates[0].spot, plan.inmates[0].spot)


func test_they_move_when_a_cop_walks_in() -> void:
	assert_false(plan.started)
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 15)
	await wait_physics_frames(3)
	assert_true(plan.started)
	var walking := plan.inmates.filter(func(inmate: YardInmate) -> bool: return inmate.is_walking())
	assert_gt(walking.size(), CountPlan.WANDERERS, "the wanderers and the ring walk")
	assert_true(plan.workers[0].is_walking())


func test_play_can_open_it() -> void:
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["prison_count"]))
	assert_eq(PlaceDraw.pick(1, ["--place=prison_count"]), "prison_count")
