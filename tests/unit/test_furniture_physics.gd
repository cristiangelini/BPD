extends GutTest

## The furniture store's toys (docs/diseno/allanamiento-muebleria.md, step 1b): the mattresses bounce a cop who lands
## on them, the tower of chairs comes down when pushed and a wardrobe tips over only when two cops pull it together.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _store() -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


## Drops the store's cop from `at` and returns how high it got after it first touched down.
func _drop(store: FurnitureStore, at: Vector3) -> float:
	var cop: Cop = store.get_node("Cop")
	cop.global_position = at
	cop.velocity = Vector3.ZERO
	var landed := false
	var highest := -INF
	for i in 120:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
		if not landed and cop.is_on_floor():
			landed = true
		elif landed:
			highest = maxf(highest, cop.global_position.y)
	return highest


func test_a_cop_landing_on_a_mattress_bounces_up() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var bed: Vector3 = FurnitureStore.BEDS[0].at
	var top := bed.y + 0.62
	var highest := await _drop(store, bed + Vector3(0, 2.6, 0.3))
	assert_gt(highest, top + 1.0, "back up over the mattress")
	assert_lt(highest, top + FurnitureStore.BOUNCE_HEIGHT + 0.3, "but no higher than the cap")


func test_a_cop_landing_on_the_floor_stays_down() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var highest := await _drop(store, Vector3(0, 2.6, 0))
	assert_lt(highest, FurnitureStore.FLOOR_TOP + 0.3)


func test_walking_into_the_tower_brings_the_chairs_down() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var tower := store.chair_tower
	var cop: Cop = store.get_node("Cop")
	cop.global_position = FurnitureStore.TOWER_AT + Vector3(-0.5, 0.1, 0)
	await wait_physics_frames(5)
	assert_true(tower.has_fallen)
	assert_eq(tower.chairs.size(), ChairTower.CHAIRS)
	for chair in tower.chairs:
		assert_gt(chair.linear_velocity.x + (chair.global_position.x - FurnitureStore.TOWER_AT.x), 0.0,
			"%s goes away from the cop" % chair.name)
	await wait_physics_frames(120)
	for chair in tower.chairs:
		var at := chair.global_position
		assert_true(absf(at.x) < FurnitureStore.HALF_X and absf(at.z) < FurnitureStore.HALF_Z and at.y > 0.0,
			"%s stays in the shop" % chair.name)


func test_a_slow_prop_leaves_the_tower_standing() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var prop := ClubEvidence.make_item("Slow", FurnitureStore.BOX_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	store.add_child(prop)
	prop.global_position = FurnitureStore.TOWER_AT + Vector3(0.45, 0.3, 0)
	await wait_physics_frames(30)
	assert_false(store.chair_tower.has_fallen)
	store.chair_tower.knock_over(Vector3.LEFT)
	assert_true(store.chair_tower.has_fallen, "a hard push does")


func test_one_cop_alone_cant_tip_a_wardrobe() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var wardrobe := store.wardrobes[0]
	assert_eq(wardrobe.prompt_key(cop), "PROMPT_PULL_WARDROBE")
	wardrobe.use(cop)
	wardrobe.use(cop)
	assert_false(wardrobe.is_tipped, "the same cop twice is still one cop")


func test_two_cops_pulling_together_tip_it_over() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var other: Cop = COP_SCENE.instantiate()
	other.input_enabled = false
	store.add_child(other)
	other.get_node("Grabber").input_enabled = false
	var tipped := []
	store.wardrobe_tipped.connect(func(index: int) -> void: tipped.append(index))
	var wardrobe := store.wardrobes[1]
	wardrobe.use(store.get_node("Cop"))
	wardrobe.use(other)
	assert_true(wardrobe.is_tipped)
	assert_eq(tipped, [1])
	await wait_seconds(TippingWardrobe.TIP_SECONDS + 0.2)
	assert_almost_eq(absf(wardrobe.global_basis.y.y), 0.0, 0.05, "lying down")
	assert_eq(wardrobe.prompt_key(other), "")
	var front: Vector3 = wardrobe.global_basis.z
	assert_almost_eq(wardrobe.global_position.y, FurnitureStore.FLOOR_TOP + TippingWardrobe.SIZE.z / 2, 0.05, "turned about its front edge")
	assert_lt(front.y, -0.9, "on its front, the open side down")
