extends GutTest

## The inmates loose in the prison's blackout (carcel-corte-de-luz.md, step 3): out of the cells to hide, wander or
## go for the gate, frozen while a flashlight lights them, gone when they reach the gate.

const LEVEL := preload("res://scenes/levels/prison_blackout.tscn")

var prison: PrisonLevel
var cop: Cop


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)


func _at(x: float, z: float, y := 0.1) -> Vector3:
	return prison.global_transform * Vector3(x, y, z)


func _of(role: BlackoutInmate.Role) -> Array[BlackoutInmate]:
	return prison.blackout.inmates.filter(func(inmate: BlackoutInmate) -> bool: return inmate.role == role)


## The cop walks in (which starts the blackout) and stands at level (x, z) looking at `target`.
func _cop_at(x: float, z: float, target: Vector3) -> void:
	cop.global_position = _at(x, z)
	await wait_physics_frames(2)
	var flat := Vector3(target.x, cop.global_position.y, target.z)
	cop.look_at(flat, Vector3.UP)
	await wait_physics_frames(1)


func test_twelve_inmates_start_in_the_cells() -> void:
	assert_eq(prison.blackout.inmates.size(), BlackoutPlan.INMATES)
	for inmate in prison.blackout.inmates:
		assert_ne(prison.cell_at(inmate.global_position), -1, "%s in a cell" % inmate.name)


func test_the_seed_draws_the_roles() -> void:
	var gates := _of(BlackoutInmate.Role.GATE).size()
	assert_between(gates, BlackoutPlan.GATES_MIN, BlackoutPlan.GATES_MIN + 2)
	assert_eq(_of(BlackoutInmate.Role.HIDE).size(), (BlackoutPlan.INMATES - gates) / 2)
	var other := BlackoutPlan.new()
	add_child_autofree(other)
	other.setup(prison, 7)
	for i in other.inmates.size():
		assert_eq(other.inmates[i].role, prison.blackout.inmates[i].role, "same seed, same roles")
		assert_eq(other.inmates[i].route, prison.blackout.inmates[i].route)


func test_nothing_moves_until_a_cop_walks_in() -> void:
	var inmate: BlackoutInmate = _of(BlackoutInmate.Role.WANDER)[0]
	var was := inmate.global_position
	await wait_seconds(0.5)
	assert_false(prison.blackout.running)
	assert_almost_eq(inmate.global_position.distance_to(was), 0.0, 0.01)
	cop.global_position = _at(0, 12)
	await wait_physics_frames(3)
	assert_true(prison.blackout.running)
	await wait_seconds(0.6)
	assert_gt(inmate.global_position.distance_to(was), 0.3, "out of the cell")


func test_every_route_stays_in_the_building_or_goes_to_the_gate() -> void:
	for inmate in prison.blackout.inmates:
		for point in inmate.route:
			var at := _at(point.x, point.y)
			if inmate.role == BlackoutInmate.Role.GATE and point.y > PrisonLevel.BUILDING_FRONT:
				assert_true(point.y > BlackoutPlan.ESCAPE_Z or prison.inside_walls(at))
				continue
			assert_true(prison.in_block(at) or prison.in_canteen(at) or PrisonLevel.PUNISHMENT.has_point(point),
				"%s goes through %s" % [inmate.name, point])


func test_a_hiding_inmate_never_hides_in_their_own_cell() -> void:
	for inmate in _of(BlackoutInmate.Role.HIDE):
		var end := inmate.route[-1]
		var cell := prison.cell_at(_at(end.x, end.y))
		assert_ne(cell, prison.cell_at(inmate.global_position), inmate.name)


func test_a_lit_inmate_freezes_and_walks_on_in_the_dark() -> void:
	var inmate: BlackoutInmate = _of(BlackoutInmate.Role.WANDER)[0]
	prison.blackout.start()
	inmate.global_position = _at(BlackoutPlan.WEST_AISLE, 0.0)
	inmate.route = [Vector2(BlackoutPlan.WEST_AISLE, 6.0)] as Array[Vector2]
	inmate.loop = false
	await _cop_at(BlackoutPlan.WEST_AISLE, 7.0, inmate.global_position)
	cop.belt.flashlight.toggle()
	await wait_seconds(0.3)
	assert_true(inmate.frozen)
	assert_ne(inmate.said(), "", "a line when the light hits")
	var was := inmate.global_position
	await wait_seconds(0.5)
	assert_almost_eq(inmate.global_position.distance_to(was), 0.0, 0.02, "frozen")
	cop.belt.flashlight.toggle()
	await wait_seconds(BlackoutInmate.UNFREEZE + 0.4)
	assert_false(inmate.frozen)
	assert_gt(inmate.global_position.distance_to(was), 0.2, "walks again in the dark")


func test_walls_keep_the_light_off() -> void:
	var inmate: BlackoutInmate = prison.blackout.inmates[0]
	prison.blackout.start()
	await _cop_at(0.0, 12.0, inmate.global_position)
	cop.belt.flashlight.toggle()
	await wait_physics_frames(1)
	assert_false(prison.blackout.lit(inmate), "the canteen's wall is in between")


func test_one_reaching_the_gate_escapes() -> void:
	var inmate: BlackoutInmate = _of(BlackoutInmate.Role.GATE)[0]
	watch_signals(prison.blackout)
	prison.blackout.start()
	inmate.delay = 0.0
	inmate.global_position = _at(BlackoutPlan.YARD.x, BlackoutPlan.YARD.y)
	inmate.route = [BlackoutPlan.GATE] as Array[Vector2]
	await wait_seconds(3.5)
	assert_true(inmate.is_escaped)
	assert_false(inmate.visible)
	assert_eq(prison.blackout.escaped, 1)
	assert_signal_emitted(prison.blackout, "inmate_escaped")
	assert_false(prison.blackout.loose().has(inmate))


func test_a_hiding_inmate_crouches_at_the_end() -> void:
	var inmate: BlackoutInmate = _of(BlackoutInmate.Role.HIDE)[0]
	prison.blackout.start()
	var end := inmate.route[-1]
	inmate.route = [end] as Array[Vector2]
	inmate.global_position = _at(end.x, end.y)
	await wait_physics_frames(3)
	assert_true(inmate.hidden)
	assert_false(inmate.is_escaped)


func test_a_cuffed_inmate_stays_put() -> void:
	var inmate: BlackoutInmate = _of(BlackoutInmate.Role.WANDER)[0]
	prison.blackout.start()
	inmate.cuffed(Handcuffs.SECONDS)
	var was := inmate.global_position
	await wait_seconds(0.5)
	assert_almost_eq(inmate.global_position.distance_to(was), 0.0, 0.01)


func test_the_lines_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["HINT_BLACKOUT_STARTED", "HINT_INMATE_ESCAPED", "BLACKOUT_FROZEN_1", "BLACKOUT_FROZEN_4"]:
		assert_ne(tr(key), key)


func test_a_wanderer_goes_round_the_canteen_and_not_back_to_the_cell() -> void:
	var inmate: BlackoutInmate = _of(BlackoutInmate.Role.WANDER)[0]
	assert_true(inmate.loop)
	inmate._next = inmate.route.size() - 1
	inmate._advance()
	assert_eq(inmate._next, inmate.loop_from)
	var first := inmate.route[inmate.loop_from]
	assert_true(prison.in_canteen(_at(first.x, first.y)))


func test_the_ones_for_the_gate_leave_one_after_another() -> void:
	var delays: Array = _of(BlackoutInmate.Role.GATE).map(func(inmate: BlackoutInmate) -> float: return inmate.delay)
	delays.sort()
	for i in range(1, delays.size()):
		assert_gt(delays[i] - delays[i - 1], BlackoutPlan.GATE_EVERY - 2 * BlackoutPlan.GATE_JITTER - 0.01)
