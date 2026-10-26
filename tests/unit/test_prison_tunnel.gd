extends GutTest

## The prison's tunnel: yard time, the cells' hideouts and the one the tunnel is behind (carcel-tunel.md, step 2).

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


func _local(node: Node3D) -> Vector3:
	return prison.global_transform.affine_inverse() * node.global_position


func _cop_by(hideout: CellHideout) -> void:
	var at := hideout.global_position - hideout.global_basis.z * 0.9
	cop.global_position = Vector3(at.x, prison.global_position.y + PrisonLevel.FLOOR_TOP + 0.1, at.z)


func test_the_tunnel_opens_from_play() -> void:
	assert_eq(prison.variant, "tunnel")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["prison_tunnel"]))
	assert_eq(PlaceDraw.pick(1, ["--place=prison_tunnel"]), "prison_tunnel")


func test_the_block_and_its_cells_are_open() -> void:
	assert_true(prison.block_gate.is_open)
	assert_eq(prison.cell_doors.size(), PrisonLevel.CELLS * 2)
	for door in prison.cell_doors:
		assert_true(door.is_open)


func test_four_hideouts_in_each_cell() -> void:
	assert_eq(plan.hideouts.size(), PrisonLevel.CELLS * 2 * CellHideout.Kind.size())
	for hideout in plan.hideouts:
		var at := hideout.global_position
		at.y = prison.global_position.y + 0.5
		assert_eq(prison.cell_at(at), hideout.cell, "%s in its cell" % hideout.name)


func test_one_hideout_hides_the_tunnel() -> void:
	var with_tunnel := plan.hideouts.filter(func(h: CellHideout) -> bool: return h.has_tunnel)
	assert_eq(with_tunnel.size(), 1)
	assert_eq(with_tunnel[0], plan.tunnel_hideout())
	assert_eq(plan.tunnel_hideout().cell, plan.tunnel_cell)


func test_the_seed_draws_the_tunnel_and_the_gang() -> void:
	var cells := {}
	for seed_value in [1, 7, 42, 99, 1234, 5]:
		var other: PrisonLevel = LEVEL.instantiate()
		other.case_seed = seed_value
		add_child_autofree(other)
		cells[[other.tunnel.tunnel_cell, other.tunnel.tunnel_kind]] = true
		assert_eq(other.tunnel.gang.size(), TunnelPlan.GANG)
		if seed_value == 7:
			assert_eq(other.tunnel.tunnel_cell, plan.tunnel_cell, "same seed, same cell")
			assert_eq(other.tunnel.gang, plan.gang, "and the same gang")
	assert_gt(cells.size(), 1, "not always the same place")


func test_twelve_inmates_in_the_yard() -> void:
	assert_eq(plan.inmates.size(), TunnelPlan.INMATES)
	for inmate in plan.inmates:
		var at := _local(inmate)
		assert_gt(at.z, PrisonLevel.BUILDING_FRONT, "%s in the yard" % inmate.name)
		assert_true(prison.inside_walls(inmate.global_position))


func test_yard_time_starts_when_a_cop_walks_in() -> void:
	await wait_physics_frames(5)
	assert_false(plan.running)
	var walker: YardInmate = plan.inmates[TunnelPlan.HOOP_SPOTS.size()]
	var from := walker.global_position
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 15)
	await wait_seconds(1.0)
	assert_true(plan.running)
	assert_true(walker.busy)
	assert_gt(walker.global_position.distance_to(from), 0.5, "the ring walkers go round")


func test_checking_an_empty_hideout_finds_nothing() -> void:
	var empty: CellHideout = plan.hideouts.filter(func(h: CellHideout) -> bool: return not h.has_tunnel)[0]
	_cop_by(empty)
	await wait_physics_frames(1)
	watch_signals(plan)
	empty.use(cop)
	await wait_seconds(CellHideout.CHECK_TIME + 0.2)
	assert_true(empty.checked)
	assert_false(empty.is_open())
	assert_signal_emitted(plan, "checked_empty")
	assert_false(plan.is_found)
	assert_eq(empty.prompt_key(cop), "PROMPT_HIDEOUT_CHECKED")


func test_walking_away_stops_the_check() -> void:
	var hideout := plan.tunnel_hideout()
	_cop_by(hideout)
	await wait_physics_frames(1)
	hideout.use(cop)
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 15)
	await wait_seconds(CellHideout.CHECK_TIME + 0.2)
	assert_false(hideout.checked)
	assert_false(plan.is_found)


func test_the_right_hideout_shows_the_hole() -> void:
	var hideout := plan.tunnel_hideout()
	_cop_by(hideout)
	await wait_physics_frames(1)
	watch_signals(plan)
	hideout.use(cop)
	await wait_seconds(CellHideout.CHECK_TIME + 0.2)
	assert_true(hideout.is_open())
	assert_true(plan.is_found)
	assert_signal_emitted_with_parameters(plan, "found", [hideout])


func test_every_kind_can_hide_the_tunnel() -> void:
	for hideout in plan.hideouts.filter(func(h: CellHideout) -> bool: return h.cell == 0):
		hideout.set_checked(true)
		assert_true(hideout.is_open(), CellHideout.Kind.keys()[hideout.kind])
