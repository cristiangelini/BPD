extends GutTest

## The furniture store as a place to raid (docs/diseno/allanamiento-muebleria.md, step 1a): the shop on its lot with
## the three showroom setups, the locked stockroom with its key in the till, the lamps and the mirror that break when
## something hits them fast and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store(case_seed := 5) -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func _prop(store: FurnitureStore, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", FurnitureStore.BOX_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	store.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_store_has_its_pieces_door_and_spots() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.sofas.size(), 2)
	assert_eq(store.beds.size(), 2)
	assert_eq(store.wardrobes.size(), 2)
	assert_eq(store.goods.size(), FurnitureStore.GOODS.size())
	assert_true(store.stock_door.locked)
	assert_true(store.till.has_key, "the stockroom's key is in the counter's till")
	assert_eq(FurnitureStore.SPOTS.size(), 12)
	assert_eq(FurnitureStore.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in FurnitureStore.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), FurnitureStore.HALF_X, spot.id)
		assert_lt(absf(at.z), FurnitureStore.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_store_stands_on_its_lot() -> void:
	var store := _store()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("furniture").size.x > 0.0)
	assert_eq((store.get_node("City") as Node3D).transform, CityLayout.anchor("furniture"))


func test_something_hidden_under_a_bed_lies_on_the_floor() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var prop := _prop(store, FurnitureStore.SPOTS[6].at + Vector3(0, 0.2, 0), Vector3.ZERO)
	await wait_physics_frames(60)
	assert_lt(prop.global_position.y, 0.3, "under the bed's frame, not on the mattress")


func test_something_dropped_in_a_wardrobe_stays_inside() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var prop := _prop(store, FurnitureStore.SPOTS[0].at + Vector3(0, 0.6, 0), Vector3.ZERO)
	await wait_physics_frames(60)
	assert_almost_eq(prop.global_position.x, FurnitureStore.SPOTS[0].at.x, 0.3, "between its sides")
	assert_almost_eq(prop.global_position.y, FurnitureStore.SPOTS[0].at.y + 0.15, 0.1, "on its bottom")


func test_something_thrown_hard_at_a_lamp_breaks_it_once() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var lamp: Vector3 = FurnitureStore.GOODS[0].at + Vector3(0, 1.0, 0)
	_prop(store, lamp + Vector3(2.0, 0, 0), Vector3(-9.0, 0, 0))
	await wait_physics_frames(30)
	assert_eq(store.broken, [0] as Array[int])
	assert_eq(store.fines, FurnitureStore.GOOD_FINE)
	assert_almost_eq(store.goods[0].rotation.x, PI / 2, 0.01, "the lamp lies on the floor")
	store.break_good(0)
	assert_eq(store.fines, FurnitureStore.GOOD_FINE, "only once")


func test_a_slow_prop_doesnt_break_the_mirror() -> void:
	var store := _store()
	await wait_physics_frames(2)
	_prop(store, FurnitureStore.GOODS[2].at + Vector3(0, 2.3, 0.6), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_eq(store.broken.size(), 0)
	assert_eq(store.fines, 0)


func test_the_till_key_opens_the_stockroom() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	store.till.use(cop)
	assert_true(cop.has_key)
	store.stock_door.use(cop)
	assert_false(store.stock_door.locked)
