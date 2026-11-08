extends GutTest

## The "Juguetería El Trompo Loco" as a place to raid (docs/diseno/allanamiento-jugueteria.md, step 1): the store on
## its lot, the locked storeroom with its key in the till, the collectors' glass case that cracks and the block castle
## that falls when something hits them fast, the yard behind the workshop's back door, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/toy_store.tscn")


func _store(case_seed := 5) -> ToyStore:
	var store: ToyStore = SCENE.instantiate()
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func _prop(store: ToyStore, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", ToyStore.TOP_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	store.add_child(prop)
	prop.position = at
	prop.linear_velocity = velocity
	return prop


func test_the_store_has_its_door_and_spots() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_true(store.store_door.locked)
	assert_true(store.till.has_key, "the storeroom's key is in the till")
	assert_eq(ToyStore.SPOTS.size(), 12)
	assert_eq(ToyStore.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in ToyStore.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), ToyStore.HALF_X, spot.id)
		assert_lt(absf(at.z), ToyStore.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)


func test_the_store_stands_on_its_lot() -> void:
	var store := _store()
	await wait_physics_frames(1)
	assert_true(CityLayout.place("toy_store").size.x > 0.0)
	assert_eq((store.get_node("City") as Node3D).transform, CityLayout.anchor("toy_store"))
	assert_eq(PlaceDraw.PLACES.toy_store, "res://scenes/levels/toy_store.tscn")


func test_the_spots_hold_something_dropped_on_them() -> void:
	var store := _store()
	await wait_physics_frames(2)
	for item: Evidence in store.hidden:
		item.freeze = true
		item.position = Vector3(0, -20, 0)
	var props: Array[Grabbable] = []
	for spot: Dictionary in ToyStore.SPOTS:
		props.append(_prop(store, spot.at + Vector3(0, 0.3, 0), Vector3.ZERO))
	await wait_physics_frames(60)
	for i in props.size():
		var spot: Dictionary = ToyStore.SPOTS[i]
		assert_almost_eq(props[i].position.y, spot.at.y + 0.15, 0.2, "%s holds it" % spot.id)


func test_the_back_door_leads_to_the_yard() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	cop.position = Vector3(ToyStore.BACK_DOOR_X, 0.2, -3.5)
	for i in 90:
		cop.velocity = Vector3(0, cop.velocity.y, -GameScale.WALK_SPEED)
		cop.move_and_slide()
		await wait_physics_frames(1)
	assert_lt(cop.position.z, ToyStore.BACK_WALL_Z - 1.0, "out in the yard")


func test_something_thrown_hard_at_the_glass_case_cracks_it_once() -> void:
	var store := _store()
	await wait_physics_frames(2)
	_prop(store, ToyStore.CASE_AT + Vector3(-3.0, 1.0, 0), Vector3(9.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(store.case_broken)
	assert_eq(store.fines, ToyStore.CASE_FINE)
	store.crack_case()
	assert_eq(store.fines, ToyStore.CASE_FINE, "only once")


func test_a_slow_prop_leaves_them_and_a_fast_one_knocks_the_castle_down() -> void:
	var store := _store()
	await wait_physics_frames(2)
	_prop(store, ToyStore.CASE_AT + Vector3(-0.8, 1.4, 0.5), Vector3.ZERO)
	_prop(store, ToyStore.CASTLE_AT + Vector3(0.9, 1.4, 0), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_false(store.case_broken, "a slow one doesn't crack the case")
	assert_false(store.castle_down, "nor knock the castle down")
	_prop(store, ToyStore.CASTLE_AT + Vector3(-3.0, 1.2, 0), Vector3(6.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(store.castle_down)
	assert_eq(store.fines, ToyStore.CASTLE_FINE)


func test_the_till_key_opens_the_storeroom() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	store.till.use(cop)
	assert_true(cop.has_key)
	store.store_door.use(cop)
	assert_false(store.store_door.locked)
