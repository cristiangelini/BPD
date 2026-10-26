extends GutTest

## The costume party's "Salón Gala" (infiltracion-fiesta.md, step 2, decision 171): its lot in the city, the dance
## floor, the photo steps with a spot for every guest and cop, the coat check, the restroom, the locked office and the
## cops starting at the station by the disguises.

const LEVEL := preload("res://scenes/levels/party_hall.tscn")

var hall: PartyHall


func before_each() -> void:
	hall = LEVEL.instantiate()
	hall.get_node("Cop").input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)


func test_it_has_its_lot_and_play_can_open_it() -> void:
	assert_false(CityLayout.place("party_hall").is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=party"])), "party")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["party"]))


func test_it_is_the_party_infiltration_place() -> void:
	assert_true(hall is InfiltrationPlace)
	assert_eq(hall.variant, "party")


func test_the_photo_steps_have_room_for_everyone() -> void:
	assert_gte(hall.photo_spots.size(), PartyHall.MINGLE_SPOTS.size(), "a spot for each guest and cop")
	for spot: Vector3 in hall.photo_spots:
		assert_true(hall.on_steps(hall.global_transform * (spot + Vector3.UP * 0.1)), "up on the steps")
	assert_false(hall.on_steps(hall.global_transform * Vector3(0, 0.2, 0)), "the dance floor isn't")


func test_each_step_is_higher_than_the_one_in_front() -> void:
	var front := hall.photo_spots[0]
	var back := hall.photo_spots[hall.photo_spots.size() - 1]
	assert_lt(back.z, front.z)
	assert_almost_eq(back.y - front.y, PartyHall.STEP_RISE * (PartyHall.STEPS - 1), 0.001)


func test_the_mingle_spots_are_inside_and_clear_of_the_rooms() -> void:
	for spot: Vector3 in PartyHall.MINGLE_SPOTS:
		var at := hall.global_transform * (spot + Vector3.UP)
		assert_true(hall.is_inside(at))
		assert_false(hall.in_back_room(at) or hall.in_coat_check(at) or hall.in_restroom(at) or hall.on_steps(at),
			"%s is out in the hall" % spot)


func test_the_rooms_are_where_they_say() -> void:
	assert_true(hall.in_back_room(hall.global_transform * Vector3(9.0, 1.0, -8.5)), "the office at the back")
	assert_true(hall.in_coat_check(hall.global_transform * Vector3(-9.0, 1.0, 8.5)), "the coat check by the door")
	assert_true(hall.in_restroom(hall.global_transform * Vector3(10.0, 1.0, 8.5)), "and the restroom")
	assert_false(hall.in_back_room(hall.global_transform * Vector3(0, 1.0, 0)), "the dance floor isn't any")


func test_the_office_is_locked() -> void:
	assert_true(hall.office_door.locked)


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = hall.get_node("Cop")
	var station := hall.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_getaway_starts_on_the_street_out_of_the_entrance() -> void:
	var local := hall.global_transform.affine_inverse() * hall.getaway_at().origin
	assert_almost_eq(local.x, PartyHall.ENTRANCE_X, 0.01)
	assert_gt(local.z, PartyHall.HALF_Z + CityLayout.SIDEWALK, "past the sidewalk")


func test_the_sign_and_the_banner_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PLACE_PARTY_HALL", "PARTY_BANNER"]:
		assert_ne(tr(key), key)
