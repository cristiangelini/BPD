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


func test_sixteen_grandparents_at_the_tables_and_chela_on_the_stage() -> void:
	assert_eq(club.members.size(), GrandpaClub.MEMBERS)
	var seats := club.seats().map(func(seat: Array) -> Vector3: return seat[0])
	for member: ClubMember in club.members:
		assert_true(seats.any(func(at: Vector3) -> bool: return at.distance_to(member.position) < 0.01), "on a seat")
	assert_true(club.chela.is_chela())
	assert_gt(club.chela.position.y, GrandpaClub.STAGE_HEIGHT, "up on the stage")


func test_the_same_seed_seats_them_the_same() -> void:
	var other: GrandpaClub = LEVEL.instantiate()
	other.case_seed = club.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in club.members.size():
		assert_eq(other.members[i].position, club.members[i].position)
		assert_eq(other.members[i].look, club.members[i].look)


func test_a_grandparent_tells_a_different_bit_of_gossip_each_time() -> void:
	var member: ClubMember = club.members[0]
	var cop: Cop = club.get_node("Cop")
	member.use(cop)
	var first := member.said()
	assert_true(first.begins_with("CLUB_GOSSIP_"))
	member.use(cop)
	assert_ne(member.said(), first)


## A cop walking into the doorway from the sidewalk.
func _walk_in(cop: Cop) -> void:
	cop.global_position = club.global_transform * Vector3(GrandpaClub.ENTRANCE_X, 0.1, GrandpaClub.HALF_Z + 1.0)
	cop.global_rotation.y = 0.0
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		club.doorman._physics_process(1.0 / 60.0)


func test_the_doorman_pushes_out_a_cop_without_a_disguise() -> void:
	var cop: Cop = club.get_node("Cop")
	await _walk_in(cop)
	assert_eq(club.doorman.said(), "DOORMAN_NO_0")
	var inside_z := (club.global_transform.affine_inverse() * cop.global_position).z
	assert_gt(inside_z, GrandpaClub.HALF_Z - 0.5, "he didn't get in")


func test_the_doorman_lets_a_disguised_cop_in() -> void:
	var cop: Cop = club.get_node("Cop")
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("mustache", 0.0)
	await _walk_in(cop)
	assert_eq(club.doorman.said(), "DOORMAN_WELCOME")
	for i in 60:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		club.doorman._physics_process(1.0 / 60.0)
	var inside_z := (club.global_transform.affine_inverse() * cop.global_position).z
	assert_lt(inside_z, GrandpaClub.HALF_Z - 1.5, "he's in the hall")
