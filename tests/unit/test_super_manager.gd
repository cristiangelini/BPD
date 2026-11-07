extends GutTest

## Don Ofertón, the supermarket's manager (docs/diseno/allanamiento-super.md, step 3): the floor boss on his round with
## the complaint meter, the price buttons that send him to a checkout with his back to the store, the third call he
## sees through, what he notices and the loudspeaker that tells everyone where the cops are.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super() -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_he_walks_his_round() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_eq(store.manager.voice, "OFERTON")
	var from := store.manager.global_position
	await wait_physics_frames(90)
	assert_gt(store.manager.global_position.distance_to(from), 0.5)
	for point: Vector3 in Supermarket.MANAGER_ROUTE:
		assert_lt(absf(point.x), Supermarket.HALF_X)
		assert_lt(absf(point.z), Supermarket.HALF_Z)


func test_a_price_button_sends_him_to_that_checkout() -> void:
	var store := _super()
	await wait_physics_frames(2)
	store.manager.fix_time = 1.0
	var cop: Cop = store.get_node("Cop")
	store.price_call.buttons[1].use(cop)
	assert_eq(store.price_call.checkout, 1)
	assert_eq(store.manager.errand(), "printer")
	var spot := store.to_global(store.cashier_spot(1))
	await wait_until(func() -> bool: return store.manager.is_fixing(), 20.0)
	assert_true(store.manager.is_fixing(), "he looks up the price")
	assert_lt(Vector2(store.manager.global_position.x - spot.x, store.manager.global_position.z - spot.z).length(), 0.6)
	assert_false(store.manager.can_see(store.to_global(Vector3(0, 1, 0))), "his back to the store")
	await wait_until(func() -> bool: return not store.manager.is_fixing(), 3.0)
	assert_false(store.price_call.is_jammed)
	store.price_call.buttons[0].use(cop)
	assert_eq(store.price_call.checkout, 1, "the buttons rest a while")


func test_the_third_call_he_sees_through() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	for i in PriceCall.CATCH_ON - 1:
		store.price_call.rest_left = 0.0
		store.price_call.call_from(cop, 0)
		store.price_call.fix()
	store.price_call.rest_left = 0.0
	var before := store.manager.complaint
	store.price_call.call_from(cop, 2)
	assert_false(store.price_call.is_jammed, "no price lookup")
	assert_almost_eq(store.manager.complaint, before + Supermarket.CAUGHT_ON, 0.01)


func test_the_pyramid_falling_in_his_sight_raises_the_complaint() -> void:
	var store := _super()
	await wait_physics_frames(2)
	store.manager.global_position = store.to_global(Vector3(3.0, Supermarket.FLOOR_TOP, 5.6))
	store.manager.route = [Vector3(3.0, Supermarket.FLOOR_TOP, 5.6)]
	await wait_physics_frames(2)
	store.topple_pyramid()
	assert_almost_eq(store.manager.complaint, Supermarket.SAW_PYRAMID, 0.01)


func test_the_loudspeaker_says_the_aisle() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_eq(Supermarket.aisle_of(Vector3(-7.5, 0, 0)), 1)
	assert_eq(Supermarket.aisle_of(Vector3(2.5, 0, 0)), 3)
	assert_eq(Supermarket.aisle_of(Vector3(7.0, 0, -2)), 4)
	assert_eq(Supermarket.aisle_of(Vector3(0, 0, 8)), 0, "by the checkouts")
	var cop: Cop = store.get_node("Cop")
	cop.global_position = store.to_global(Vector3(-2.5, 0.1, 0))
	assert_eq(store.announce(cop), tr("OFERTON_SPEAKER_AISLE") % 2)
