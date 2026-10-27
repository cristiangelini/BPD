extends GutTest

## The raid on the Hotel Gran Siesta (hotel-allanamiento.md, step 1): the crime scene's building with locked rooms,
## the master key on the board, the vases and lamps that break, and the hiding spots.

const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")


func _raid() -> HotelRaid:
	var raid: HotelRaid = LEVEL.instantiate()
	raid.case_seed = 7
	raid.get_node("Cop").input_enabled = false
	add_child_autofree(raid)
	return raid


func test_it_opens_from_play_with_the_crime_scenes_building_empty() -> void:
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["hotel_raid"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=hotel_raid"])), "hotel_raid")
	var raid := _raid()
	await wait_physics_frames(2)
	assert_false(raid.hotel.crime_scene)
	assert_eq(raid.hotel.guests.size(), 0, "no guests in bathrobes")
	assert_null(raid.hotel.concierge, "don Bostezo comes in step 2")
	assert_not_null(raid.hotel.wardrobe, "the 13 is the same one, behind the wardrobe")
	var city: Node3D = raid.get_node("City")
	var lot := CityLayout.place("hotel")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the hotel is at the origin of its scene")
	assert_lt(raid.car.global_position.distance_to(raid.station_parking.origin), 0.2)


func test_rooms_and_suite_are_locked_and_the_master_key_opens_them_into_the_room() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	assert_eq(raid.doors.size(), Hotel.GUEST_ROOMS.size() + 1, "six rooms and the suite; the 13 has no door")
	assert_false(raid.doors.has(Hotel.HIDDEN_ROOM))
	var cop: Cop = raid.get_node("Cop")
	for number: int in raid.doors:
		assert_true((raid.doors[number] as FrontDoor).locked, "the %d is locked" % number)
	assert_eq(raid.doors[11].prompt_key(cop), "PROMPT_DOOR_LOCKED")
	assert_eq(raid.key_board.prompt_key(cop), "PROMPT_HOTEL_KEY_BOARD")
	watch_signals(raid.key_board)
	raid.key_board.use(cop)
	assert_true(cop.has_key, "the master key")
	assert_signal_emitted(raid.key_board, "taken")
	assert_eq(raid.key_board.prompt_key(cop), "", "one is enough")
	for number: int in raid.doors:
		(raid.doors[number] as FrontDoor).use(cop)
	await wait_seconds(FrontDoor.SWING_TIME + 0.2)
	for number: int in raid.doors:
		var door: FrontDoor = raid.doors[number]
		assert_false(door.locked)
		var panel: Vector3 = door.get_node("Panel").global_position
		assert_eq(raid.hotel.room_of(panel), number, "the %d's door swings into it" % number)


func test_the_ram_breaks_a_room_door() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	var door: FrontDoor = raid.doors[15]
	for i in FrontDoor.RAM_HITS:
		door.ram_hit()
	assert_true(door.is_broken)
	assert_false(door.locked)


func test_vases_and_lamps_are_fines() -> void:
	var raid := _raid()
	await wait_physics_frames(30)
	assert_eq(raid.vases.size(), HotelRaid.VASES.size())
	assert_eq(raid.lamps.size(), Hotel.ROOMS.size(), "a lamp on every nightstand, the 13's too")
	for item: Ornament in raid.vases + raid.lamps:
		assert_false(item.is_broken, "%s survives standing still" % item.name)
	raid.vases[0].hit(Ornament.BREAK_SPEED + 1.0)
	raid.lamps[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(raid.broken_goods, 2)
	assert_eq(raid.fines, Ornament.FINE * 2)


func test_twelve_spots_each_on_a_surface() -> void:
	var raid := _raid()
	await wait_physics_frames(2)
	assert_eq(HotelRaid.SPOTS.size(), 12)
	var heavy := HotelRaid.SPOTS.filter(func(s: Dictionary) -> bool: return s.heavy).size()
	assert_eq(heavy, 6, "half take the heavy evidence")
	var space := raid.get_world_3d().direct_space_state
	for spot: Dictionary in HotelRaid.SPOTS:
		var at: Vector3 = spot.at
		assert_true(raid.hotel.inside(at), "%s is in the hotel" % spot.id)
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2, 1)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)
	assert_eq(raid.hotel.room_of(HotelRaid.SPOTS[3].at), Hotel.HIDDEN_ROOM, "one is in the 13")


func test_the_texts_are_translated() -> void:
	for key: String in ["PROMPT_HOTEL_KEY_BOARD", "HINT_HOTEL_KEY"]:
		assert_ne(tr(key), key, key)
