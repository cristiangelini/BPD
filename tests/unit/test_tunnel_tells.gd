extends GutTest

## The prison tunnel's false leads and tells: the gardener, the hamster, the nervous whistler and the owners who
## complain (carcel-tunel.md, step 4).

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


func _piles() -> Array:
	return plan.dirt.get_children().filter(func(bit: TunnelDirt) -> bool: return bit.kind == TunnelDirt.Kind.PILE)


func test_the_gardener_works_the_planters_and_drops_dirt_too() -> void:
	assert_eq(plan.gardener.activity, YardInmate.Activity.GARDEN)
	assert_eq(plan.gardener.stops.size(), TunnelPlan.PLANTERS.size())
	assert_false(plan.gang_members().has(plan.gardener), "not one of the gang")
	plan.start()
	plan.gardener._pile_left = 0.01
	plan.gardener._pause = 0.0
	await wait_seconds(0.2)
	assert_eq(_piles().size(), 1)


func test_the_gardener_greets_a_close_cop() -> void:
	plan.start()
	_cop_at(plan.gardener.global_position + Vector3(1.5, 0, 0))
	await wait_seconds(0.2)
	assert_eq(plan.gardener.said(), "GARDENER_HELLO")


func test_the_hamster_is_in_another_cell() -> void:
	for seed_value in [1, 7, 42, 99, 1234]:
		var other: PrisonLevel = LEVEL.instantiate()
		other.case_seed = seed_value
		add_child_autofree(other)
		assert_ne(other.tunnel.hamster_cell, other.tunnel.tunnel_cell)
		var at := other.tunnel.hamster.global_position + Vector3(0, 0.5, 0)
		assert_eq(other.cell_at(at), other.tunnel.hamster_cell, "the cage in its cell")


func test_the_hamster_scratches_like_the_digging() -> void:
	_cop_at(plan.hamster.global_position + Vector3(0, 0, 0.8))
	plan.start()
	plan._noise_left = 0.01
	await wait_seconds(0.1)
	assert_eq(plan.hamster.said(), "HAMSTER_SCRATCH")
	assert_eq(plan.hamster.prompt_key(cop), "PROMPT_HAMSTER")


func test_a_cop_by_the_tunnel_makes_the_gang_whistle() -> void:
	plan.start()
	await wait_physics_frames(2)
	var hideout := plan.tunnel_hideout()
	_cop_at(hideout.global_position - hideout.global_basis.z * 1.2)
	await wait_physics_frames(3)
	var whistled := plan.gang_members().filter(func(i: YardInmate) -> bool: return i.said() == "GANG_WHISTLE")
	assert_eq(whistled.size(), 1)
	assert_eq(whistled[0].route, [TunnelPlan.NERVOUS_TO], "off toward the building")


func test_nobody_whistles_with_the_cops_far_away() -> void:
	plan.start()
	_cop_at(prison.global_transform * Vector3(-10, 0, 17))
	await wait_physics_frames(5)
	for inmate in plan.gang_members():
		assert_ne(inmate.said(), "GANG_WHISTLE")


func test_an_owner_complains_about_their_hideout() -> void:
	var empty: CellHideout
	for hideout in plan.hideouts:
		if not hideout.has_tunnel and plan.inmates[hideout.cell].visible:
			empty = hideout
			break
	var at := empty.global_position - empty.global_basis.z * 0.9
	_cop_at(at)
	await wait_physics_frames(1)
	empty.use(cop)
	await wait_seconds(CellHideout.CHECK_TIME + 0.2)
	assert_eq(plan.inmates[empty.cell].said(), "OWNER_COMPLAIN_%d" % empty.kind)
