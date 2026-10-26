extends GutTest

## The prison tunnel's gang: their turns digging, the tunnel that grows, the dirt, the footprints and the noise
## (carcel-tunel.md, step 3).

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


func after_each() -> void:
	Engine.time_scale = 1.0


func _dirt(kind: TunnelDirt.Kind) -> Array:
	return plan.dirt.get_children().filter(func(bit: TunnelDirt) -> bool: return bit.kind == kind)


## The first of the gang straight into the tunnel, without the walk.
func _first_digging() -> YardInmate:
	plan.start()
	var first := plan.inmates[plan.gang[0]]
	var way := plan.cell_way()
	var last := way[way.size() - 1]
	first.global_position = prison.global_transform * Vector3(last.x, PrisonLevel.FLOOR_TOP + 0.1, last.y)
	first.walk([last])
	await wait_seconds(0.3)
	return first


func test_the_gang_never_plays_basketball() -> void:
	for i in plan.gang:
		var inmate := plan.inmates[i]
		assert_eq(inmate.activity, YardInmate.Activity.WANDER, inmate.name)
		assert_true(inmate.drops_dirt)
	for inmate in plan.inmates:
		if not plan.gang.has(plan.inmates.find(inmate)):
			assert_false(inmate.drops_dirt, inmate.name)


func test_the_first_of_the_gang_walks_all_the_way_into_the_tunnel() -> void:
	Engine.time_scale = 4.0
	plan.start()
	var first := plan.inmates[plan.gang[0]]
	assert_eq(first.trip, YardInmate.Trip.IN)
	for i in 40:
		if first.in_tunnel:
			break
		await wait_seconds(1.0)
	assert_true(first.in_tunnel, "through the canteen, the block and into the cell")
	assert_false(first.visible, "out of sight")
	assert_eq(plan.digger, first)


func test_the_tunnel_grows_only_while_someone_digs() -> void:
	plan.start()
	await wait_seconds(0.5)
	assert_eq(plan.dug, 0.0, "nobody's in it yet")
	await _first_digging()
	await wait_seconds(1.0)
	assert_gt(plan.dug, 0.0)
	assert_almost_eq(plan.left_to_dig(), TunnelPlan.LENGTH - plan.dug, 0.001)


func test_a_sealed_tunnel_stops_growing() -> void:
	await _first_digging()
	plan.is_sealed = true
	var dug := plan.dug
	await wait_seconds(0.5)
	assert_eq(plan.dug, dug)


func test_at_the_end_of_a_turn_they_swap() -> void:
	var first := await _first_digging()
	plan.shift_left = 0.01
	await wait_seconds(0.2)
	assert_null(plan.digger)
	assert_true(first.visible, "out of the tunnel")
	assert_eq(first.trip, YardInmate.Trip.OUT)
	var second := plan.inmates[plan.gang[1]]
	assert_eq(second.trip, YardInmate.Trip.IN, "the next one goes")


func test_coming_out_leaves_dirty_footprints() -> void:
	await _first_digging()
	plan.shift_left = 0.01
	await wait_seconds(2.0)
	assert_gt(_dirt(TunnelDirt.Kind.PRINT).size(), 0)


func test_the_gang_shakes_dirt_out_in_the_yard() -> void:
	plan.start()
	var other := plan.inmates[plan.gang[1]]
	other._pile_left = 0.01
	await wait_seconds(0.2)
	assert_eq(_dirt(TunnelDirt.Kind.PILE).size(), 1)


func test_stepping_on_a_pile_dirties_the_feet() -> void:
	plan.start()
	var walker := plan.inmates[TunnelPlan.HOOP_SPOTS.size()]
	if plan.gang.has(TunnelPlan.HOOP_SPOTS.size()):
		walker = plan.inmates[0]
	plan._on_dropped_dirt(null, walker.global_position)
	await wait_physics_frames(2)
	assert_gt(walker.prints_left, 0.0)


func test_a_cop_close_by_hears_the_digging() -> void:
	await _first_digging()
	var hideout := plan.tunnel_hideout()
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 15)
	plan._noise_left = 0.01
	await wait_seconds(0.1)
	assert_eq(hideout.said(), "", "too far away")
	cop.global_position = hideout.global_position - hideout.global_basis.z * 1.5
	cop.global_position.y = prison.global_position.y + 0.2
	plan._noise_left = 0.01
	await wait_seconds(0.1)
	assert_eq(hideout.said(), "TUNNEL_SCRATCH")


func test_the_tunnel_gets_through() -> void:
	await _first_digging()
	watch_signals(plan)
	plan.dug = TunnelPlan.LENGTH - 0.01
	await wait_seconds(0.2)
	assert_eq(plan.left_to_dig(), 0.0)
	assert_signal_emitted(plan, "dug_through")
