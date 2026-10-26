extends GutTest

## The VIP inmate's run for his limo and his manager, step 5 (carcel-vip.md): with the 3 pieces he's out and running;
## walked into a cell he's back in his armchair; out the gate the limo takes him. After his day, his manager.

const LEVEL := preload("res://scenes/levels/prison_vip.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: VipPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 8
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.vip


func _three_pieces() -> void:
	for kind in VipPlan.PIECES:
		plan.pieces.append(VipPlan.PIECES[kind])
	plan.got_piece.emit(plan.pieces.size())


func test_two_pieces_arent_enough() -> void:
	plan.pieces.append(Contraband.Kind.FILE)
	plan.got_piece.emit(1)
	plan.pieces.append(Contraband.Kind.KEY)
	plan.got_piece.emit(2)
	assert_null(plan.runner)


func test_with_the_three_he_runs() -> void:
	watch_signals(plan)
	_three_pieces()
	assert_not_null(plan.runner)
	assert_signal_emitted(plan, "ran")
	assert_true(prison.cell_door(plan.cell).is_open)
	assert_false(plan.rulo.visible)
	assert_eq(plan.runner.role, BlackoutInmate.Role.GATE)
	assert_eq(prison.cell_at(plan.runner.global_position), plan.cell)
	var last := plan.runner.route[-1]
	assert_gt(last.y, PrisonLevel.HALF_Z, "his way ends out the gate")


func test_out_the_gate_the_limo_takes_him() -> void:
	watch_signals(plan)
	_three_pieces()
	var start_x := plan.limo.position.x
	plan.runner._next = plan.runner.route.size() - 1
	plan.runner.global_position = prison.global_transform * Vector3(0, PrisonLevel.FLOOR_TOP, PrisonLevel.HALF_Z - 1.2)
	await wait_seconds(1.0)
	assert_true(plan.escaped)
	assert_signal_emitted(plan, "escaped_rulo")
	assert_gt(plan.limo.position.x, start_x, "it drives off")


func test_walked_into_a_cell_hes_back_in_his_armchair() -> void:
	_three_pieces()
	var runner := plan.runner
	runner.cuffed(Handcuffs.SECONDS)
	runner.global_position = prison.global_transform * plan.cell_point(1.0)
	(runner.get_node("Escort") as BlackoutEscort).board()
	assert_null(plan.runner)
	assert_eq(plan.caught, 1)
	assert_eq(plan.pieces.size(), 0, "his pieces taken off him")
	assert_true(plan.rulo.visible)
	assert_true(plan.rulo.seated)
	assert_true(prison.cell_door(plan.cell).locked)
	assert_false(prison.cell_door(plan.cell).is_open)
	assert_true(plan.requests.is_processing())


func test_after_his_day_his_manager_takes_him() -> void:
	watch_signals(plan)
	plan.requests.all_done.emit()
	var manager := plan.manager
	assert_not_null(manager)
	manager._walk.custom_step(100.0)
	assert_true(manager.talking)
	assert_true(prison.cell_door(plan.cell).is_open)
	assert_eq(manager.with, plan.rulo)
	manager.talk_left = 0.0
	await wait_seconds(0.1)
	manager._walk.custom_step(100.0)
	await wait_physics_frames(1)
	assert_true(plan.released)
	assert_signal_emitted(plan, "released_rulo")
	assert_false(plan.rulo.visible)


func test_no_manager_while_hes_running() -> void:
	_three_pieces()
	plan.call_manager()
	assert_null(plan.manager)
