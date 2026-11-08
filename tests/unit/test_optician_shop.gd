extends GutTest

## The optician's shop as a place to raid (docs/diseno/allanamiento-optica.md, step 1a): the shop on its lot with the
## salon, the exam room, the waiting room, the locked workshop with its key in the till, the display cases and the
## mirror that break when something hits them fast and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/optician_shop.tscn")


func _shop(case_seed := 5) -> OpticianShop:
	var shop: OpticianShop = SCENE.instantiate()
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func _prop(shop: OpticianShop, at: Vector3, velocity: Vector3, size := Vector3(0.3, 0.3, 0.3)) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", OpticianShop.CASE_BOX_MODEL, size, 2.0)
	shop.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_shop_has_its_pieces_door_and_spots() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.displays.size(), 3)
	assert_not_null(shop.carousel)
	assert_not_null(shop.exam_chair)
	assert_eq(shop.goods.size(), OpticianShop.GOODS.size())
	assert_true(shop.workshop_door.locked)
	assert_true(shop.till.has_key, "the workshop's key is in the counter's till")
	assert_eq(OpticianShop.SPOTS.size(), 12)
	assert_eq(OpticianShop.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 5)
	for spot: Dictionary in OpticianShop.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), OpticianShop.HALF_X, spot.id)
		assert_lt(absf(at.z), OpticianShop.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_shop_stands_on_its_lot_on_the_west_column() -> void:
	var shop := _shop()
	await wait_physics_frames(1)
	var place := CityLayout.place("optician")
	assert_eq(place.block, Vector2i(-1, 3))
	assert_eq((shop.get_node("City") as Node3D).transform, CityLayout.anchor("optician"))


func test_something_dropped_in_a_wall_display_stays_inside() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var spot: Vector3 = OpticianShop.SPOTS[0].at
	var prop := _prop(shop, spot + Vector3(0, 0.6, 0), Vector3.ZERO, Vector3(0.25, 0.25, 0.25))
	await wait_physics_frames(60)
	assert_almost_eq(prop.global_position.z, spot.z, 0.4, "between its sides")
	assert_almost_eq(prop.global_position.y, spot.y + 0.125, 0.1, "on its bottom")


func test_the_high_shelf_is_out_of_reach_from_the_floor_and_holds_things() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var spot: Vector3 = OpticianShop.SPOTS[11].at
	assert_eq(OpticianShop.SPOTS[11].id, "on_high_shelf")
	assert_gt(spot.y, 2.4, "too high to reach without the chair")
	var prop := _prop(shop, spot + Vector3(0, 0.3, 0), Vector3.ZERO, Vector3(0.2, 0.1, 0.2))
	await wait_physics_frames(60)
	assert_almost_eq(prop.global_position.y, spot.y + 0.05, 0.08, "it stays on the shelf")


func test_something_thrown_hard_at_a_display_case_breaks_it_once() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var display_case: Vector3 = OpticianShop.GOODS[0].at + Vector3(0, 0.6, 0)
	_prop(shop, display_case + Vector3(0, 0, 2.0), Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_eq(shop.broken, [0] as Array[int])
	assert_eq(shop.fines, OpticianShop.GOOD_FINE)
	assert_not_null(shop.goods[0].get_node_or_null("Crack0"), "the glass shows its cracks")
	shop.break_good(0)
	assert_eq(shop.fines, OpticianShop.GOOD_FINE, "only once")


func test_a_slow_prop_doesnt_break_the_mirror() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	_prop(shop, OpticianShop.GOODS[2].at + Vector3(-0.6, 2.3, 0), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_eq(shop.broken.size(), 0)
	assert_eq(shop.fines, 0)


func test_the_till_key_opens_the_workshop() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	shop.till.use(cop)
	assert_true(cop.has_key)
	shop.workshop_door.use(cop)
	assert_false(shop.workshop_door.locked)
