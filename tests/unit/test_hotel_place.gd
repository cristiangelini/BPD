extends GutTest

## The city's hotel on its lot (escena-hotel.md, step 1; Hotel, HotelLevel).

const LEVEL := preload("res://scenes/levels/hotel.tscn")


func test_the_hotel_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("hotel").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["hotel"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=hotel"])), "hotel")
	var lot: Vector3 = CityLayout.place("hotel").size
	assert_eq(Vector2(lot.x, lot.z), Hotel.SIZE, "the lot is the hotel's size")
	assert_eq(lot.y, Hotel.TALL, "and as tall")


func test_six_guest_rooms_and_the_thirteen_upstairs() -> void:
	var hotel := Hotel.new()
	add_child_autofree(hotel)
	assert_true(hotel is CrimeScenePlace)
	assert_eq(hotel.variant, "hotel")
	assert_eq(Hotel.GUEST_ROOMS.size(), 6)
	assert_false(Hotel.GUEST_ROOMS.has(Hotel.HIDDEN_ROOM), "no guest sleeps in the 13")
	for number: int in Hotel.ROOMS:
		var middle := hotel.to_global(Hotel.room_middle(number) + Vector3.UP * 0.5)
		assert_eq(hotel.room_of(middle), number, "the middle of the %d is in it" % number)
		assert_eq(hotel.floor_of(middle), 1, "upstairs")
	assert_eq(hotel.room_of(hotel.to_global(Hotel.SUITE_BED_AT + Vector3.UP)), 0, "the suite's bed is in the suite")
	assert_eq(hotel.room_of(hotel.to_global(Hotel.SAFE_AT)), 0, "and the safe")
	assert_eq(hotel.room_of(hotel.to_global(Vector3(5, Hotel.UP + 0.5, 0))), -1, "the corridor is no room")
	assert_eq(hotel.room_of(hotel.to_global(Hotel.DESK_AT + Vector3.UP)), -1, "and downstairs neither")
	assert_eq(hotel.floor_of(hotel.to_global(Hotel.DESK_AT + Vector3.UP)), 0)
	assert_true(hotel.at_scene(hotel.to_global(Vector3(0, 0, 8.5))), "under the awning is at the scene")
	assert_false(hotel.inside(hotel.to_global(Vector3(0, 0, 8.5))), "but out of the building")
	assert_false(hotel.at_scene(hotel.to_global(Vector3(0, 0, Hotel.SIZE.y))), "the street is out")
	for i in Hotel.GUEST_ROOMS.size():
		assert_not_null(hotel.find_child("Room%d" % Hotel.GUEST_ROOMS[i], false, false), "the door says its number")
	assert_null(hotel.find_child("Room13", false, false), "the 13's door says nothing")


## Casts a ray from one point to another of the hotel and says whether nothing is in the way.
func _open(hotel: Hotel, from: Vector3, to: Vector3, except: Array[RID] = []) -> bool:
	var space := hotel.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(hotel.to_global(from), hotel.to_global(to))
	query.exclude = except
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var hotel := Hotel.new()
	add_child_autofree(hotel)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	var up := Vector3(0, Hotel.UP + 0.6, 0)
	assert_true(_open(hotel, Vector3(0, 0, 8.5) + knee, Vector3(0, 0, 5) + knee), "in by the front door")
	assert_true(_open(hotel, Vector3(-3, 0, Hotel.DOOR_DINING_Z) + knee, Vector3(-8, 0, Hotel.DOOR_DINING_Z) + knee),
		"into the dining room")
	assert_false(_open(hotel, Vector3(-3, 0, -3) + knee, Vector3(-8, 0, -3) + knee), "which has a wall")
	assert_true(_open(hotel, Vector3(Hotel.STAIR_X, 0, Hotel.STAIR_TOP_Z) + up,
		Vector3(Hotel.STAIR_X, 0, 0) + up), "off the stairs into the corridor")
	var wardrobe: Array[RID] = [hotel.wardrobe.get_rid()]
	for number: int in Hotel.ROOMS:
		var room: Dictionary = Hotel.ROOMS[number]
		var inward := -1.0 if room.side == "n" else 1.0
		var except: Array[RID] = []
		if number == Hotel.HIDDEN_ROOM:
			except = wardrobe
		assert_true(_open(hotel, Vector3(room.door, 0, 0) + up, Vector3(room.door, 0, inward * 3.0) + up, except),
			"into the %d" % number)
	assert_false(_open(hotel, Vector3(3.5, 0, 0) + up, Vector3(3.5, 0, -3) + up), "the wardrobe hides the 13")
	assert_true(_open(hotel, Vector3(-5, 0, Hotel.DOOR_SUITE_Z) + up, Vector3(-9, 0, Hotel.DOOR_SUITE_Z) + up),
		"into the suite")
	assert_false(_open(hotel, Vector3(-5, 0, -4) + up, Vector3(-9, 0, -4) + up), "the suite has a wall")
	assert_true(_open(hotel, Vector3(-9, 0, Hotel.DOOR_SUITE_BATH_Z) + up,
		Vector3(-12, 0, Hotel.DOOR_SUITE_BATH_Z) + up), "into its bathroom")


func test_one_cop_can_drag_the_wardrobe() -> void:
	assert_lt(Hotel.WARDROBE_KG * GameScale.GRAVITY, Grabbable.max_force_per_holder(), "one cop is enough")
	assert_gt(Hotel.WARDROBE_KG, GameScale.COP_CARRY_KG, "but it's heavy")


func test_the_level_puts_the_hotel_on_its_lot() -> void:
	var level: HotelLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("hotel")
	assert_almost_eq(level.hotel.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.hotel.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_ne(tr("SIGN_HOTEL_LIFT"), "SIGN_HOTEL_LIFT")
