extends GutTest

## The supermarket as a place to raid (docs/diseno/allanamiento-super.md, step 1): the store on its lot with its
## gondolas, fridge, checkouts, the locked office with its key in checkout 1's till, the pyramid of cans that falls with
## nothing, the fridge's glass that cracks and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super(case_seed := 5) -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func _prop(store: Supermarket, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", Supermarket.CAN_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	store.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_supermarket_has_its_door_till_and_spots() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_true(store.office_door.locked)
	assert_true(store.till.has_key, "the office's key is in checkout 1's till")
	assert_eq(Supermarket.SPOTS.size(), 12)
	assert_eq(Supermarket.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in Supermarket.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), Supermarket.HALF_X, spot.id)
		assert_lt(absf(at.z), Supermarket.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_supermarket_stands_on_its_lot() -> void:
	var store := _super()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("supermarket").size.x > 0.0)
	assert_eq((store.get_node("City") as Node3D).transform, CityLayout.anchor("supermarket"))
	assert_true(PlaceDraw.PLACES.has("supermarket"), "--place=supermarket opens it")


func test_the_pyramid_stands_until_something_bumps_it() -> void:
	var store := _super()
	assert_eq(store.cans.size(), 21, "six rows, 6 to 1")
	await wait_physics_frames(60)
	assert_false(store.pyramid_fallen, "it stands on its own")
	assert_eq(store.fines, 0)
	_prop(store, Supermarket.OFFER_AT + Vector3(-1.0, 1.3, 0), Vector3(6.0, 0, 0))
	await wait_physics_frames(60)
	assert_true(store.pyramid_fallen)
	assert_eq(store.fines, Supermarket.PYRAMID_FINE)
	store.topple_pyramid()
	assert_eq(store.fines, Supermarket.PYRAMID_FINE, "only once")


func test_something_thrown_hard_at_the_fridge_cracks_its_glass_once() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var glass := Vector3(-7.0, 1.0, Supermarket.FRIDGE_Z + 1.5)
	_prop(store, glass, Vector3(0, 0, -9.0))
	await wait_physics_frames(30)
	assert_true(store.fridge_cracked)
	assert_eq(store.fines, Supermarket.FRIDGE_FINE)
	store.break_fridge()
	assert_eq(store.fines, Supermarket.FRIDGE_FINE, "only once")


func test_a_slow_prop_doesnt_crack_the_fridge() -> void:
	var store := _super()
	await wait_physics_frames(2)
	_prop(store, Vector3(-3.0, 0.6, Supermarket.FRIDGE_Z + 0.7), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_false(store.fridge_cracked)


func test_the_till_key_opens_the_office() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	store.till.use(cop)
	assert_true(cop.has_key)
	store.office_door.use(cop)
	assert_false(store.office_door.locked)
