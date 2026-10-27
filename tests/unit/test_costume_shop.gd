extends GutTest

## The costume shop as a place to raid (docs/diseno/allanamiento-disfraces.md, step 1): the shop on its lot, the
## locked office with its key in the counter's till, the giant mirror and the mask display case that break, and the
## 12 hiding spots.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")
const PROP_MODEL := preload("res://assets/models/sale_basket.glb")


func _shop(case_seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	return place


func _prop(place: CostumeShop, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", PROP_MODEL, Vector3(0.22, 0.22, 0.22), 2.0)
	prop.gravity_scale = 0.0
	place.add_child(prop)
	prop.global_position = place.to_global(at)
	prop.linear_velocity = place.global_basis * velocity
	return prop


func test_the_shop_has_its_door_till_and_spots() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	assert_true(place.office_door.locked)
	assert_true(place.till.has_key, "the office's key is in the counter's till")
	assert_eq(CostumeShop.SPOTS.size(), 12)
	assert_eq(CostumeShop.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in CostumeShop.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), CostumeShop.HALF_X, spot.id)
		assert_lt(absf(at.z), CostumeShop.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_shop_stands_on_its_lot() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("costume_shop").size.x > 0.0)
	assert_eq((place.get_node("City") as Node3D).transform, CityLayout.anchor("costume_shop"))
	assert_true(PlaceDraw.PLACES.has("costume_shop"), "--place=costume_shop opens it")


func test_something_thrown_hard_at_the_mirror_breaks_it_once() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	_prop(place, CostumeShop.MIRROR_AT + Vector3(2.5, 0, 0), Vector3(-9.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(place.mirror_cracked)
	assert_eq(place.fines, CostumeShop.MIRROR_FINE)
	place.break_mirror()
	assert_eq(place.fines, CostumeShop.MIRROR_FINE, "only once")


func test_something_thrown_at_the_mask_case_breaks_it() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	_prop(place, CostumeShop.CASE_AT + Vector3(-2.5, 1.2, 0), Vector3(9.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(place.case_broken)
	assert_eq(place.fines, CostumeShop.CASE_FINE)


func test_the_till_key_opens_the_office() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	place.till.use(cop)
	assert_true(cop.has_key)
	place.office_door.use(cop)
	assert_false(place.office_door.locked)


func test_a_cop_walks_into_a_fitting_room() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(Vector3(CostumeShop.FITTING_X + 1.5, CostumeShop.FLOOR_TOP + 0.1,
		CostumeShop.FITTING_Z[1]))
	cop.global_rotation.y = place.global_rotation.y + PI / 2
	await wait_physics_frames(10)
	for i in 90:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	assert_lt(place.to_local(cop.global_position).x, CostumeShop.FITTING_X - 0.3, "through the curtain")
