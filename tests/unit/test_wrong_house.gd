extends GutTest

## The wrong house (docs/diseno/casa-equivocada.md, step 1): two twin houses on one lot, the same in everything but
## their lost digit, with the guilty one drawn from the seed.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")


func _place(case_seed := 77) -> WrongHouse:
	var place: WrongHouse = SCENE.instantiate()
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	add_child_autofree(place)
	return place


func _open(place: WrongHouse, from: Vector3, to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	return place.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func test_the_guilty_house_comes_from_the_seed_or_the_command_line() -> void:
	var seen := {}
	for case_seed in range(1, 30):
		var side := WrongHouse.pick_guilty(case_seed, PackedStringArray())
		assert_eq(side, WrongHouse.pick_guilty(case_seed, PackedStringArray()), "same seed, same house")
		seen[side] = true
	assert_eq(seen.size(), 2, "either can be the guilty one")
	assert_eq(WrongHouse.pick_guilty(3, PackedStringArray(["--guilty=left"])), WrongHouse.LEFT)
	assert_eq(WrongHouse.pick_guilty(3, PackedStringArray(["--guilty=right"])), WrongHouse.RIGHT)


func test_the_twins_have_the_same_locked_door_pots_and_ornaments() -> void:
	var place := _place()
	await wait_physics_frames(30)
	assert_eq(place.doors.size(), 2)
	for house in 2:
		assert_true(place.doors[house].locked, "the front door is locked")
		assert_eq(place.pots[house].size(), WrongHouse.POTS.size())
		var keys: int = place.pots[house].filter(func(pot: KeyPot) -> bool: return pot.has_key).size()
		assert_eq(keys, 1, "one pot has the key")
		assert_eq(place.ornaments[house].size(), place.ornaments[0].size(), "the same ornaments in both")
		for ornament: Ornament in place.ornaments[house]:
			assert_false(ornament.is_broken, "%s survives standing still" % ornament.name)
			assert_eq(WrongHouse.house_of(ornament.position), house, "each ornament is in its own house")
	assert_gt(place.ornaments[0].size(), 50)
	assert_eq(place.broken, [0, 0] as Array[int])


func test_each_house_opens_from_the_street_to_the_yard() -> void:
	var place := _place()
	await wait_physics_frames(2)
	for house in 2:
		var x := WrongHouse.house_x(house)
		var entrance := x + WrongHouse.ENTRANCE_U
		var ways := [
			# Front garden to the living, through the doorway (the door itself is on another layer once open).
			[Vector3(entrance, 1.0, WrongHouse.FRONT_Z - 0.5), Vector3(entrance, 1.0, WrongHouse.FRONT_Z - 3.0)],
			# Living to the stair hall, and the hall to the bathroom and the laundry.
			[Vector3(x + WrongHouse.STAIR_U - 1.0, 1.0, 3.0), Vector3(x + WrongHouse.STAIR_U - 1.0, 1.0, 0.0)],
			[Vector3(x - 1.5, 1.0, WrongHouse.SIDE_DOOR_Z), Vector3(x - 4.0, 1.0, WrongHouse.SIDE_DOOR_Z)],
			[Vector3(x + 1.0, 1.0, WrongHouse.SIDE_DOOR_Z), Vector3(x + 3.5, 1.0, WrongHouse.SIDE_DOOR_Z)],
			# Laundry to the back yard.
			[Vector3(x + WrongHouse.BACK_DOOR_U, 1.0, -3.0), Vector3(x + WrongHouse.BACK_DOOR_U, 1.0, -6.0)],
		]
		for way: Array in ways:
			assert_true(_open(place, way[0], way[1]), "house %d open from %s to %s" % [house, way[0], way[1]])
		assert_false(_open(place, Vector3(-1.0, 1.0, 3.0), Vector3(1.0, 1.0, 3.0)), "the party wall")


func test_the_stairs_go_up_to_the_hole_upstairs() -> void:
	var place := _place()
	await wait_physics_frames(2)
	var space := place.get_world_3d().direct_space_state
	var up := GameScale.FLOOR_HEIGHT
	for house in 2:
		var x := WrongHouse.house_x(house) + WrongHouse.STAIR_U
		var middle := Vector3(x, up + 1.0, WrongHouse.STAIR_FOOT_Z - WrongHouse.STAIR_RUN / 2)
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(middle, middle + Vector3.DOWN * 4, 1))
		assert_false(hit.is_empty(), "a ramp under the hole")
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, WrongHouse.FLOOR_TOP + up / 2, 0.2, "halfway up")
		var landing := Vector3(x, up + 1.0, WrongHouse.BACK_Z + 0.6)
		hit = space.intersect_ray(PhysicsRayQueryParameters3D.create(landing, landing + Vector3.DOWN * 2, 1))
		assert_false(hit.is_empty(), "a floor upstairs past the top step")


func test_a_wagon_waits_in_each_side_passage_and_the_lot_is_in_the_city() -> void:
	var place := _place()
	await wait_physics_frames(2)
	assert_eq(place.wagons.size(), 2)
	assert_lt(place.wagons[0].position.x, -WrongHouse.HALF_U * 2, "west of the west house")
	assert_gt(place.wagons[1].position.x, WrongHouse.HALF_U * 2, "east of the east house")
	for wagon: StaticBody3D in place.wagons:
		assert_lt(absf(wagon.position.x) + WrongHouse.WAGON_SIZE.x / 2, WrongHouse.LOT_X, "inside the lot")
	var lot := CityLayout.place("wrong_house")
	assert_almost_eq(lot.size.x, WrongHouse.LOT_X * 2, 0.01)
	assert_almost_eq(lot.size.z, WrongHouse.LOT_Z * 2, 0.01)
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=wrong_house"])), "wrong_house")
