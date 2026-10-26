extends GutTest

## The mimes' "Teatro del Silencio" (infiltracion-mimos.md, step 2, decision 170): its lot in the city, the seats with
## the aisle, the stage with a mark for each mime and cop, the locked dressing room and the cops starting at the
## station by the disguises.

const LEVEL := preload("res://scenes/levels/mime_theater.tscn")

var theater: MimeTheater


func before_each() -> void:
	theater = LEVEL.instantiate()
	theater.get_node("Cop").input_enabled = false
	add_child_autofree(theater)
	await wait_physics_frames(2)


func test_it_has_its_lot_and_play_can_open_it() -> void:
	assert_false(CityLayout.place("mime_theater").is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=mime"])), "mime")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["mime"]))


func test_it_is_the_mime_infiltration_place() -> void:
	assert_true(theater is InfiltrationPlace)
	assert_eq(theater.variant, "mime")


func test_the_stage_has_a_mark_for_each_mime_and_cop() -> void:
	assert_eq(theater.marks.size(), MimeTheater.ROW_ZS.size() * MimeTheater.MARKS_PER_ROW)
	for mark: Vector3 in theater.marks:
		assert_true(MimeTheater.STAGE.has_point(Vector2(mark.x, mark.z)), "on the stage")
		assert_true(theater.on_stage(theater.global_transform * (mark + Vector3.UP * 0.1)))


func test_the_aisle_and_the_entrance_are_clear() -> void:
	for x: float in MimeTheater.SEAT_XS:
		assert_gt(absf(x - MimeTheater.ENTRANCE_X) - MimeTheater.SEAT_SIZE.x / 2, GameScale.DOOR_WIDTH / 2,
			"the seats leave the aisle as wide as the door")
	assert_gt(MimeTheater.SEAT_ZS.min() - MimeTheater.SEAT_SIZE.z, MimeTheater.BENCH_AT.z + 0.6,
		"the front row leaves room for Maestra Pausa's bench")


func test_the_back_rooms_are_behind_the_stage() -> void:
	var back := theater.global_transform * Vector3(-6.0, 1.0, -8.5)
	assert_true(theater.in_back_room(back))
	assert_true(theater.is_inside(back))
	assert_false(theater.in_back_room(theater.global_transform * Vector3(0, 1.0, 2.0)), "the hall isn't")


func test_the_dressing_room_is_locked() -> void:
	assert_true(theater.dressing_door.locked)


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = theater.get_node("Cop")
	var station := theater.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_getaway_starts_on_the_street_out_of_the_entrance() -> void:
	var local := theater.global_transform.affine_inverse() * theater.getaway_at().origin
	assert_almost_eq(local.x, MimeTheater.ENTRANCE_X, 0.01)
	assert_gt(local.z, MimeTheater.HALF_Z + CityLayout.SIDEWALK, "past the sidewalk")
