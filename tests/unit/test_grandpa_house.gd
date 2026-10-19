extends GutTest

## The grandpa's house and the seeded hiding spot draw (docs/diseno/allanamiento.md).

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")
const TICK := 1.0 / 60.0


func _house(case_seed: int) -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = case_seed
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_same_seed_gives_the_same_draw() -> void:
	var heavy := [false, false, true, true]
	assert_eq(HidingDraw.draw(77, heavy, [false, true], 3), HidingDraw.draw(77, heavy, [false, true], 3))


func test_draw_is_always_valid() -> void:
	var spot_heavy: Array = GrandpaHouse.SPOTS.map(func(s: Dictionary) -> bool: return s.heavy)
	var tin_spots := {}
	for case_seed in range(1, 301):
		var result := HidingDraw.draw(case_seed, spot_heavy, [false, true, false, false], 3)
		var spots: Array = result.spots
		assert_eq(spots.size(), 4)
		assert_eq(_as_keys(spots).size(), spots.size(), "every item gets its own spot")
		assert_true(spot_heavy[spots[1]], "the heavy item only goes where it fits")
		assert_between(result.key_pot, 0, 2)
		tin_spots[spots[0]] = true
	assert_eq(tin_spots.size(), GrandpaHouse.SPOTS.size(), "over many cases the tin visits every spot")


func _as_keys(values: Array) -> Dictionary:
	var keys := {}
	for v in values:
		keys[v] = true
	return keys


func test_house_has_twelve_spots_and_three_pots() -> void:
	assert_eq(GrandpaHouse.SPOTS.size(), 12)
	assert_eq(GrandpaHouse.POTS.size(), 3)


func test_evidence_waits_at_its_drawn_spot() -> void:
	var house := _house(1234)
	await wait_physics_frames(30)
	assert_eq(house.evidence.size(), 2)
	for i in house.evidence.size():
		var spot: Vector3 = GrandpaHouse.SPOTS[house.evidence_spots[i]].at
		var item := house.evidence[i]
		assert_lt(Vector2(item.global_position.x - spot.x, item.global_position.z - spot.z).length(), 0.1,
			"%s stays at its spot" % item.name)
		assert_gt(item.global_position.y, spot.y, "%s rests on its spot, not inside it" % item.name)
	assert_true(house.evidence[0] is Evidence)
	assert_eq((house.evidence[0] as Evidence).value, 1000.0, "the tin starts undamaged")


func test_cop_walks_up_the_stairs() -> void:
	var house := _house(5)
	var cop: Cop = house.get_node("Cop")
	cop.global_position = Vector3(GrandpaHouse.STAIR_X - 0.1, 0.1, 1.0)
	for i in 20:
		cop.step(TICK, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	for i in 150:
		cop.step(TICK, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.y, GameScale.FLOOR_HEIGHT - 0.1, "the cop reaches the upper floor")


func test_every_room_is_reachable_from_the_front_door() -> void:
	# A sealed room is an island on the navigation mesh (the grandpa got stuck in the living room once).
	var house := _house(5)
	await wait_physics_frames(10)
	var map := house.get_world_3d().navigation_map
	var from := Vector3(0, 0, 8.5)
	for level in 2:
		for x: float in [-4.5, 4.5]:
			for z: float in [7.5, 1.0, -5.5]:
				var to := Vector3(x, level * GameScale.FLOOR_HEIGHT, z)
				var path := NavigationServer3D.map_get_path(map, from, to, true)
				assert_false(path.is_empty(), "path to %s" % to)
				if not path.is_empty():
					assert_lt(path[path.size() - 1].distance_to(to), 0.6, "reaches %s" % to)
