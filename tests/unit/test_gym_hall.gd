extends GutTest

## The gym "Hierro Puro" (infiltracion-gimnasio.md, step 2, decision 172): on the city's gym lot, the reception, the
## treadmills, the weights, the ring and the bags, the locker room, the mirror wall and el Toro's locked office, and the
## cops starting at the station by the disguises.

const LEVEL := preload("res://scenes/levels/gym_hall.tscn")

var gym: GymHall


func before_each() -> void:
	gym = LEVEL.instantiate()
	gym.get_node("Cop").input_enabled = false
	add_child_autofree(gym)
	await wait_physics_frames(2)


func test_it_is_on_the_city_s_gym_lot_and_play_can_open_it() -> void:
	assert_false(CityLayout.place("gym").is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=gym"])), "gym")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["gym"]))
	var lot: Dictionary = CityLayout.place("gym")
	assert_almost_eq(lot.size.x, GymHall.HALF_X * 2, 0.01, "as wide as its lot")
	assert_almost_eq(lot.size.z, GymHall.HALF_Z * 2, 0.01, "and as deep")


func test_it_is_the_gym_infiltration_place() -> void:
	assert_true(gym is InfiltrationPlace)
	assert_eq(gym.variant, "gym")


func test_the_rooms_are_where_they_say() -> void:
	assert_true(gym.in_back_room(gym.global_transform * Vector3(6.0, 1.0, -6.5)), "the office at the back east")
	assert_true(gym.in_locker_room(gym.global_transform * Vector3(-6.0, 1.0, -6.5)), "the locker room at the back west")
	assert_false(gym.in_back_room(gym.global_transform * GymHall.TORO_AT + Vector3.UP), "el Toro calls it in the open")
	assert_false(gym.in_locker_room(gym.global_transform * Vector3(0, 1.0, 0)))
	assert_true(gym.is_inside(gym.global_transform * Vector3(0, 1.0, 0)))


func test_the_office_is_locked() -> void:
	assert_true(gym.office_door.locked)


func test_a_cop_can_step_on_a_treadmill() -> void:
	var cop: Cop = gym.get_node("Cop")
	var belt := GymHall.TREADMILLS[1] + Vector3(0, GymHall.FLOOR_TOP + GymHall.TREADMILL_BELT + 0.1, -0.2)
	cop.global_position = gym.global_transform * belt
	await wait_physics_frames(10)
	assert_eq(gym.treadmill_at(cop.global_position), 1)
	assert_eq(gym.treadmill_at(gym.global_transform * Vector3(0, 0.2, 0)), -1, "the floor isn't one")


func test_the_train_spots_are_inside_and_out_of_the_back_rooms() -> void:
	for spot: Vector3 in GymHall.TRAIN_SPOTS:
		var at := gym.global_transform * (spot + Vector3.UP)
		assert_true(gym.is_inside(at))
		assert_false(gym.in_back_room(at) or gym.in_locker_room(at), "%s is out in the gym" % spot)


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = gym.get_node("Cop")
	var station := gym.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_getaway_starts_on_the_street_out_of_the_entrance() -> void:
	var local := gym.global_transform.affine_inverse() * gym.getaway_at().origin
	assert_almost_eq(local.x, GymHall.ENTRANCE_X, 0.01)
	assert_gt(local.z, GymHall.HALF_Z + CityLayout.SIDEWALK, "past the sidewalk")


func test_the_sign_and_the_motto_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PLACE_GYM", "GYM_MOTTO"]:
		assert_ne(tr(key), key)
