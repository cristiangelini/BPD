extends GutTest

## The "Heladería Pingüino Derretido" as a place to raid (docs/diseno/allanamiento-heladeria.md, step 1): the shop on
## its lot, the locked cold room with its key in the till, the counter's glass case that cracks and the penguin that
## falls when something hits them fast, the yard behind the kitchen's back door, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop(case_seed := 5) -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func _prop(shop: IceCreamShop, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", SoftServeMachine.MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	shop.add_child(prop)
	prop.position = at
	prop.linear_velocity = velocity
	return prop


func test_the_shop_has_its_door_and_spots() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_true(shop.cold_door.locked)
	assert_true(shop.till.has_key, "the cold room's key is in the till")
	assert_eq(IceCreamShop.SPOTS.size(), 12)
	assert_eq(IceCreamShop.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in IceCreamShop.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), IceCreamShop.HALF_X, spot.id)
		assert_lt(absf(at.z), IceCreamShop.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_shop_stands_on_its_lot() -> void:
	var shop := _shop()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("ice_cream").size.x > 0.0)
	assert_eq((shop.get_node("City") as Node3D).transform, CityLayout.anchor("ice_cream"))
	assert_eq(PlaceDraw.PLACES.ice_cream, "res://scenes/levels/ice_cream_shop.tscn")


func test_the_spots_hold_something_dropped_on_them() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var props: Array[Grabbable] = []
	for spot: Dictionary in IceCreamShop.SPOTS:
		props.append(_prop(shop, spot.at + Vector3(0, 0.3, 0), Vector3.ZERO))
	await wait_physics_frames(60)
	for i in props.size():
		var spot: Dictionary = IceCreamShop.SPOTS[i]
		assert_almost_eq(props[i].position.y, spot.at.y + 0.15, 0.2, "%s holds it" % spot.id)


func test_the_back_door_leads_to_the_yard() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	cop.position = Vector3(IceCreamShop.BACK_DOOR_X, 0.2, -3.5)
	for i in 90:
		cop.velocity = Vector3(0, cop.velocity.y, -GameScale.WALK_SPEED)
		cop.move_and_slide()
		await wait_physics_frames(1)
	assert_lt(cop.position.z, IceCreamShop.BACK_WALL_Z - 1.0, "out in the yard")


func test_something_thrown_hard_at_the_glass_case_cracks_it_once() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	_prop(shop, IceCreamShop.COUNTER_AT + Vector3(0, 1.2, 3.0), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_true(shop.case_broken)
	assert_eq(shop.fines, IceCreamShop.CASE_FINE)
	shop.crack_case()
	assert_eq(shop.fines, IceCreamShop.CASE_FINE, "only once")


func test_a_slow_prop_leaves_the_case_and_a_fast_one_knocks_the_penguin() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	_prop(shop, IceCreamShop.COUNTER_AT + Vector3(1.0, 1.4, 0.9), Vector3.ZERO)
	_prop(shop, IceCreamShop.PENGUIN_AT + Vector3(0, 1.4, 0.7), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_false(shop.case_broken, "a slow one doesn't crack it")
	assert_false(shop.penguin_down, "nor knock the penguin")
	_prop(shop, IceCreamShop.PENGUIN_AT + Vector3(-3.0, 1.2, 0), Vector3(9.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(shop.penguin_down)
	assert_eq(shop.fines, 0, "no fine for the penguin")


func test_the_till_key_opens_the_cold_room() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	shop.till.use(cop)
	assert_true(cop.has_key)
	shop.cold_door.use(cop)
	assert_false(shop.cold_door.locked)
