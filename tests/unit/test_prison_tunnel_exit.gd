extends GutTest

## The prison tunnel found and sealed, and its far end outside the wall (carcel-tunel.md, step 5).

const LEVEL := preload("res://scenes/levels/prison_tunnel.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: TunnelPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.tunnel


func _cop_at(at: Vector3) -> void:
	cop.global_position = Vector3(at.x, prison.global_position.y + 0.2, at.z)


func _first_digging() -> YardInmate:
	plan.start()
	var first := plan.inmates[plan.gang[0]]
	var way := plan.cell_way()
	var last := way[way.size() - 1]
	first.global_position = prison.global_transform * Vector3(last.x, PrisonLevel.FLOOR_TOP + 0.1, last.y)
	first.walk([last])
	await wait_seconds(0.3)
	return first


## The tunnel through, with whoever was digging on their way along it.
func _through() -> YardInmate:
	var first := await _first_digging()
	plan.dug = TunnelPlan.LENGTH - 0.001
	await wait_physics_frames(3)
	return first


func _find_tunnel() -> void:
	var hideout := plan.tunnel_hideout()
	_cop_at(hideout.global_position - hideout.global_basis.z * 0.9)
	await wait_physics_frames(1)
	hideout.use(cop)
	await wait_seconds(CellHideout.CHECK_TIME + 0.2)


func test_two_bags_of_cement_by_the_gate() -> void:
	assert_eq(plan.bags.size(), TunnelPlan.BAG_SPOTS.size())
	for bag in plan.bags:
		var at := prison.global_transform.affine_inverse() * bag.global_position
		assert_gt(at.z, PrisonLevel.HALF_Z - 3.0, "by the gate")


func test_found_while_digging_they_run_for_the_gate() -> void:
	var first := await _first_digging()
	await _find_tunnel()
	assert_true(plan.is_found)
	assert_eq(plan.runners.size(), 1, "out of the tunnel, running")
	assert_true(plan.gone.has(first))
	assert_false(first.visible)
	assert_eq(plan.runners[0].route[plan.runners[0].route.size() - 1], LaundryPlan.GATE)
	var next := plan.gang_members().filter(func(i: YardInmate) -> bool: return i.trip == YardInmate.Trip.IN)
	assert_eq(next.size(), 1, "and the next one comes to dig")


func test_a_runner_walked_to_the_cell_counts_once() -> void:
	await _first_digging()
	await _find_tunnel()
	var runner := plan.runners[0]
	plan._on_caught(runner)
	plan._on_caught(runner)
	assert_eq(plan.caught, 1)


func test_pouring_the_cement_seals_it() -> void:
	await _first_digging()
	await _find_tunnel()
	var hideout := plan.tunnel_hideout()
	var bag := plan.bags[0]
	cop.get_node("Grabber").grab(bag)
	assert_eq(hideout.prompt_key(cop), "PROMPT_POUR_CEMENT")
	watch_signals(plan)
	hideout.use(cop)
	await wait_physics_frames(2)
	assert_true(plan.is_sealed)
	assert_true(hideout.sealed)
	assert_signal_emitted(plan, "sealed")
	assert_eq(plan.bags.size(), 1, "the bag's used up")
	var dug := plan.dug
	await wait_seconds(0.5)
	assert_eq(plan.dug, dug, "no more digging")


func test_without_cement_it_cant_be_sealed() -> void:
	await _first_digging()
	await _find_tunnel()
	var hideout := plan.tunnel_hideout()
	assert_eq(hideout.prompt_key(cop), "PROMPT_TUNNEL_NEEDS_CEMENT")
	hideout.use(cop)
	assert_false(plan.is_sealed)


func test_the_far_end_shows_close_to_through() -> void:
	await _first_digging()
	assert_false(plan.exit.is_showing())
	plan.dug = TunnelPlan.LENGTH - TunnelPlan.SHOW_AT + 0.01
	await wait_physics_frames(2)
	assert_true(plan.exit.is_showing())
	assert_false(plan.exit.is_open())
	assert_false(prison.inside_walls(plan.exit.global_position), "outside the wall")


func test_through_the_digger_peeks_out_at_the_far_end() -> void:
	var first := await _through()
	assert_true(plan.exit.is_open())
	assert_eq(plan.peeker, first)
	assert_eq(plan.exit.prompt_key(cop), "PROMPT_GRAB_ESCAPEE")


func test_a_cop_at_the_far_end_grabs_them() -> void:
	var first := await _through()
	plan.exit.use(cop)
	assert_eq(plan.caught, 1)
	assert_null(plan.peeker)
	assert_true(prison.in_punishment(first.global_position), "straight to the punishment cell")


func test_nobody_there_and_they_get_away() -> void:
	var first := await _through()
	watch_signals(plan)
	await wait_seconds(TunnelPlan.PEEK_TIME + 0.2)
	assert_eq(plan.escaped, 1)
	assert_signal_emitted_with_parameters(plan, "escaped_one", [1])
	assert_true(plan.gone.has(first))


func test_through_the_rest_follow_one_at_a_time() -> void:
	await _through()
	plan._release_left = 0.01
	await wait_physics_frames(3)
	var going := plan.inmates.filter(func(i: YardInmate) -> bool: return i.trip == YardInmate.Trip.IN)
	assert_eq(going.size(), 1)


func test_sealed_they_come_back_out() -> void:
	plan.start()
	plan.is_sealed = true
	var inmate := plan.inmates[plan.gang[0]]
	plan._on_reached_tunnel(inmate)
	assert_eq(inmate.trip, YardInmate.Trip.OUT)
	assert_null(plan.digger)
