extends GutTest

## The grandparents' club (infiltracion.md, step 2a): its lot in the city, the hall with the bingo tables, the stage
## and the dance floor, the back rooms with the locked office, and the cops starting at the station.

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub


func before_each() -> void:
	club = LEVEL.instantiate()
	club.get_node("Cop").input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)


func test_it_has_its_lot_and_play_can_open_it() -> void:
	assert_false(CityLayout.place("grandpa_club").is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=club"])), "club")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["club"]))


func test_the_hall_has_twelve_bingo_tables_and_the_bingo_cage() -> void:
	assert_eq(club.tables.size(), 12)
	assert_not_null(club.bingo_cage)
	assert_almost_eq(club.bingo_cage.global_position.distance_to(club.global_transform * GrandpaClub.BINGO_STAND), 1.3, 0.2,
		"on its stand")


func test_the_office_is_locked() -> void:
	assert_true(club.office_door.locked)


func test_the_tables_leave_the_entrance_and_the_dance_floor_clear() -> void:
	for table: Vector3 in club.tables:
		assert_false(GrandpaClub.DANCE_FLOOR.has_point(Vector2(table.x, table.z)), "not on the dance floor")
		assert_gt(absf(table.x - GrandpaClub.ENTRANCE_X), GameScale.DOOR_WIDTH, "not in front of the entrance")


func test_the_cops_start_at_the_station_by_the_disguises() -> void:
	var cop: Cop = club.get_node("Cop")
	var station := club.get_node("City").global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)
	var nearest := INF
	for body: Node in club.find_children("*", "RigidBody3D", true, false):
		if body is DisguisePiece:
			nearest = minf(nearest, cop.global_position.distance_to((body as Node3D).global_position))
	assert_lt(nearest, 10.0, "the disguises are in the guard room")
