extends GutTest

## The park with the canal (politico-puente.md, step 1, decision 178): its block (3, 4) is grass with no buildings, the
## canal with its water, and the bridge over it, whole: 20 planks on stringers, 20 railing pieces, 4 pillars and a
## ramp up to each end. A cop walks up a ramp onto the deck, stands on it, and falls through a span whose planks are gone.

const LEVEL := preload("res://scenes/levels/bridge_park.tscn")

var park: BridgePark


func before_each() -> void:
	park = LEVEL.instantiate()
	park.case_seed = 7
	park.get_node("Cop").input_enabled = false
	add_child_autofree(park)
	await wait_physics_frames(2)


func _drop_cop(local: Vector3) -> Cop:
	var cop: Cop = park.get_node("Cop")
	cop.global_position = park.to_global(local)
	cop.velocity = Vector3.ZERO
	# Facing east, along the bridge.
	cop.rotation.y = -PI / 2
	return cop


## Steps the cop `frames` times wanting to go `wish` (forward is (0, -1)).
func _walk(cop: Cop, frames: int, wish := Vector2.ZERO) -> void:
	for i in frames:
		cop.step(1.0 / 60.0, wish, false, false, false)
		await wait_physics_frames(1)


func test_play_can_open_it() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=bridge"])), "bridge")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["bridge"]))


func test_the_park_fills_its_block_without_buildings() -> void:
	var block := Vector2i(3, 4)
	assert_eq(CityLayout.place("bridge_park").block, block)
	assert_true(CityLayout.is_park(block))
	assert_false(CityLayout.is_park(CityLayout.place("market").block), "a building's block is no park")
	for lot: Dictionary in CityLayout.fillers():
		assert_ne(lot.block, block, "no filler building in the park")
	assert_eq(CityLayout.lot("bridge_park").origin.distance_to(park.city.transform.affine_inverse().origin), 0.0,
		"the city is laid around the park")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = park.get_node("Cop")
	assert_gt(cop.global_position.distance_to(park.global_position), 40.0, "they drive here")


func test_the_bridge_is_whole() -> void:
	assert_eq(park.planks.size(), BridgePark.SPANS * BridgePark.PLANKS_PER_SPAN)
	assert_eq(park.rails.size(), BridgePark.SPANS * 2)
	assert_eq(park.pillars.size(), 4)
	for p in park.planks:
		assert_almost_eq(p.position.y + BridgePark.PLANK.y / 2, BridgePark.DECK_TOP, 0.001)
		assert_true(absf(p.position.x) < BridgePark.CANAL_HALF, "every plank is over the water")
	assert_eq(park.plank(3, 1), park.planks[7])
	assert_almost_eq(BridgePark.span_x(0), -9.0, 0.001)
	assert_almost_eq(BridgePark.span_x(9), 9.0, 0.001)


func test_the_water_is_in_the_canal_only() -> void:
	assert_true(park.in_water(park.to_global(Vector3(3, 0.5, 15))))
	assert_false(park.in_water(park.to_global(Vector3(3, 1.5, 15))), "over the water")
	assert_false(park.in_water(park.to_global(Vector3(15, 0.5, 0))), "on the bank")
	assert_not_null(park.water)


func test_a_cop_stands_on_the_deck() -> void:
	var cop := _drop_cop(Vector3(0.5, BridgePark.DECK_TOP + 0.3, 0))
	await _walk(cop, 60)
	assert_true(park.on_deck(cop.global_position), "the planks hold him")
	assert_false(park.in_water(cop.global_position))


func test_a_cop_walks_up_the_ramp_onto_the_bridge() -> void:
	var cop := _drop_cop(Vector3(-19.0, 0.2, 0))
	await _walk(cop, 20)
	await _walk(cop, 300, Vector2(0, -1))
	var local := park.to_local(cop.global_position)
	assert_gt(local.x, -BridgePark.CANAL_HALF, "past the canal's wall: %s" % local)
	assert_true(park.on_deck(cop.global_position), "up on the deck")


func test_where_a_span_lost_its_planks_a_cop_falls_into_the_water() -> void:
	var x := BridgePark.span_x(4)
	park.plank(4, 0).free()
	park.plank(4, 1).free()
	var cop := _drop_cop(Vector3(x, BridgePark.DECK_TOP + 0.3, 0))
	await _walk(cop, 60)
	assert_true(park.in_water(cop.global_position), "through the hole and into the canal")
