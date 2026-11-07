extends GutTest

## The pawn shop as a place to raid (docs/diseno/allanamiento-empenos.md, step 1): the shop on its lot, the locked
## stock room with its key in the counter's till, the glass cases and the armor that break, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/pawn_shop.tscn")
const PROP_MODEL := preload("res://assets/models/cookie_jar.glb")


func _shop(case_seed := 5) -> PawnShop:
	var place: PawnShop = SCENE.instantiate()
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	return place


func _prop(place: PawnShop, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", PROP_MODEL, Vector3(0.22, 0.22, 0.22), 2.0)
	prop.gravity_scale = 0.0
	place.add_child(prop)
	prop.global_position = place.to_global(at)
	prop.linear_velocity = place.global_basis * velocity
	return prop


func test_the_shop_has_its_door_till_and_spots() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	assert_true(place.stock_door.locked)
	assert_true(place.till.has_key, "the stock room's key is in the counter's till")
	assert_eq(PawnShop.SPOTS.size(), 12)
	assert_eq(PawnShop.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in PawnShop.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), PawnShop.HALF_X, spot.id)
		assert_lt(absf(at.z), PawnShop.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_shop_stands_on_its_lot() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("pawn_shop").size.x > 0.0)
	assert_eq((place.get_node("City") as Node3D).transform, CityLayout.anchor("pawn_shop"))
	assert_true(PlaceDraw.PLACES.has("pawn_shop"), "--place=pawn_shop opens it")


func test_something_thrown_at_a_glass_case_breaks_only_that_one_once() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	_prop(place, PawnShop.CASES[1] + Vector3(0, 0.6, -2.5), Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_eq(place.cases_broken, [false, true, false] as Array[bool])
	assert_eq(place.fines, PawnShop.CASE_FINE)
	place.break_case(1)
	assert_eq(place.fines, PawnShop.CASE_FINE, "only once")


func test_something_slow_does_not_break_a_case() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	_prop(place, PawnShop.CASES[0] + Vector3(0, 0.6, -1.2), Vector3(0, 0, 1.0))
	await wait_physics_frames(60)
	assert_false(place.cases_broken[0])
	assert_eq(place.fines, 0)


func test_something_thrown_at_the_armor_knocks_it_apart() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	_prop(place, PawnShop.ARMOR_AT + Vector3(2.5, 1.2, 0), Vector3(-9.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(place.armor_down)
	assert_eq(place.fines, PawnShop.ARMOR_FINE)


func test_the_till_key_opens_the_stock_room() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	place.till.use(cop)
	assert_true(cop.has_key)
	place.stock_door.use(cop)
	assert_false(place.stock_door.locked)
