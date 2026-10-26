extends GutTest

## Fixing the bridge (politico-puente.md, step 4, decision 178): the spare planks by the pickup, a carried plank let go
## of over a hole fits in, one just falling off doesn't, a sunk pillar needs two cops pushing, the water floats planks
## and slows cops, and E on the deputy holds him back by the coat.

const LEVEL := preload("res://scenes/levels/bridge_park.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")

var park: BridgePark


func before_each() -> void:
	park = LEVEL.instantiate()
	park.case_seed = 7
	park.get_node("Cop").input_enabled = false
	add_child_autofree(park)
	await wait_physics_frames(3)


func _break_now(kind: String, index: int) -> void:
	park.breaks.warn(kind, index)
	park.breaks.warnings[-1][2] = 0.02
	await wait_physics_frames(3)


func test_twelve_spare_planks_by_the_pickup() -> void:
	assert_eq(park.repairs.spares.size(), BridgeRepairs.SPARES)
	for spare in park.repairs.spares:
		assert_lt(park.to_local(spare.global_position).distance_to(BridgeRepairs.PILE_AT), 4.0)
		assert_eq(spare.mass, LoosePlank.KG)


func test_a_carried_plank_let_go_over_the_hole_fits_in() -> void:
	watch_signals(park.repairs)
	await _break_now("span", 3)
	var spare := park.repairs.spares[0]
	spare.was_held = true
	spare.global_position = park.to_global(BridgePark.plank_at(3, 1) + Vector3(0.3, 0.3, 0.2))
	spare.linear_velocity = Vector3.ZERO
	await wait_physics_frames(3)
	assert_signal_emitted_with_parameters(park.repairs, "fitted", [3, 1])
	assert_not_null(park.plank(3, 1))
	assert_false(is_instance_valid(spare) and not spare.is_queued_for_deletion(), "the loose one became the deck's")
	assert_false(park.breaks.whole(3), "one plank still missing")


func test_the_planks_falling_off_dont_fit_back_by_themselves() -> void:
	await _break_now("span", 6)
	await wait_physics_frames(10)
	assert_null(park.plank(6, 0))
	assert_null(park.plank(6, 1))


func test_one_cop_cant_straighten_a_pillar_two_can() -> void:
	await _break_now("pillar", 1)
	var pillar: BridgePillar = park.pillars[1]
	assert_true(pillar.sunk())
	assert_eq(pillar.prompt_key(park.get_node("Cop")), "PROMPT_PUSH_PILLAR")
	var a: Cop = park.get_node("Cop")
	a.global_position = pillar.global_position + Vector3(0.6, -0.5, 0)
	pillar.use(a)
	await wait_seconds(0.5)
	assert_eq(pillar.pushed, 0.0, "alone it doesn't move")
	var b: Cop = COP_SCENE.instantiate()
	b.input_enabled = false
	add_child_autofree(b)
	b.global_position = pillar.global_position + Vector3(-0.6, -0.5, 0)
	pillar.use(b)
	await wait_seconds(0.5)
	assert_gt(pillar.pushed, 0.05, "two push it")
	pillar.pushed = 0.99
	await wait_physics_frames(5)
	assert_false(pillar.sunk(), "straight again")
	assert_true(pillar.turners.is_empty())


func test_the_water_floats_planks_and_slows_cops() -> void:
	var spare := park.repairs.spares[1]
	spare.global_position = park.to_global(Vector3(-4, 0.4, 12))
	var cop: Cop = park.get_node("Cop")
	cop.global_position = park.to_global(Vector3(-4, 0.1, 15))
	await wait_seconds(1.5)
	var y := park.to_local(spare.global_position).y
	assert_almost_eq(y, BridgePark.WATER_TOP, 0.35, "it floats at the surface")
	assert_lt(cop.wade, 0.6, "wading slows him")
	cop.global_position = park.to_global(Vector3(-20, 0.1, -5))
	await wait_physics_frames(3)
	assert_eq(cop.wade, 1.0, "out of the water he walks as always")


func test_e_on_the_deputy_holds_him_by_the_coat() -> void:
	var cop: Cop = park.get_node("Cop")
	assert_eq(park.politician.prompt_key(cop), "PROMPT_TALK_POLITICIAN", "before he starts he only shakes hands")
	park.ceremony.start()
	assert_eq(park.politician.prompt_key(cop), "PROMPT_GRAB_COAT")
	park.politician.use(cop)
	assert_almost_eq(park.ceremony.hold_left, BridgeCoat.HOLD, 0.01)
	assert_string_starts_with(park.politician.said(), "BRIDGE_LUSTRE_COAT_")
