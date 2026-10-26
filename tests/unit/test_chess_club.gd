extends GutTest

## The chess club "El Peón Dormido" (infiltracion-ajedrez.md, step 2, decision 175): on its own city lot, members only
## past the doorkeeper; the hall with its tables, the cafeteria, the tournament room with the Gran Maestro on the stage,
## the storeroom and his locked office; the gang's members at the tables and in the audience.

const LEVEL := preload("res://scenes/levels/chess_club.tscn")

var club: ChessClub


func before_each() -> void:
	club = LEVEL.instantiate()
	club.get_node("Cop").input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)


func _at(x: float, z: float) -> Vector3:
	return club.global_transform * Vector3(x, 1.0, z)


func test_it_is_on_its_own_lot_and_play_can_open_it() -> void:
	var lot: Dictionary = CityLayout.place("chess")
	assert_false(lot.is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=chess"])), "chess")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["chess"]))
	assert_almost_eq(lot.size.x, ChessClub.HALF_X * 2, 0.01, "as wide as its lot")
	assert_almost_eq(lot.size.z, ChessClub.HALF_Z * 2, 0.01, "and as deep")


func test_it_is_the_chess_infiltration_place() -> void:
	assert_true(club is InfiltrationPlace)
	assert_eq(club.variant, "chess")


func test_the_rooms_are_where_they_say() -> void:
	assert_true(club.in_hall(_at(-4.0, 4.0)))
	assert_true(club.in_cafe(_at(8.0, 5.0)))
	assert_true(club.in_tournament(_at(-4.0, -4.0)))
	assert_true(club.in_storeroom(_at(8.0, -8.0)))
	assert_true(club.in_back_room(_at(8.0, -2.5)), "the office behind the cafeteria")
	assert_false(club.in_hall(_at(8.0, -2.5)))


func test_the_office_is_locked() -> void:
	assert_true(club.office_door.locked)


func test_members_at_the_tables_in_the_audience_and_the_rival() -> void:
	assert_eq(club.members.size(), ChessClub.PLAYERS + ChessClub.AUDIENCE + 1)
	var in_hall := club.members.filter(func(member: ClubMember) -> bool:
		return club.in_hall(member.global_position + Vector3.UP))
	assert_eq(in_hall.size(), ChessClub.PLAYERS, "the players at the hall's tables")
	for member: ClubMember in club.members:
		assert_true(member.look.begins_with("ajedrecista"))
	assert_true(club.in_tournament(club.rival.global_position + Vector3.UP), "the rival on the stage")
	assert_eq(club.free_seats.size(), ChessClub.TABLES.size() * 2 - ChessClub.PLAYERS, "seats for the cops")


func test_the_same_seed_seats_the_same_members() -> void:
	var other: ChessClub = LEVEL.instantiate()
	other.case_seed = club.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in club.members.size():
		assert_eq(other.members[i].position, club.members[i].position)
		assert_eq(other.members[i].look, club.members[i].look)


func test_the_gran_maestro_is_the_boss_on_the_stage_facing_the_door() -> void:
	assert_eq(club.boss, club.alfil)
	assert_true(club.alfil.is_boss())
	assert_true(club.in_tournament(club.alfil.global_position + Vector3.UP))
	assert_gt(club.alfil.position.y, ChessClub.STAGE_SIZE.y, "up on the stage")
	assert_gt((-club.alfil.global_basis.z).dot(club.global_basis.z), 0.99, "looking at the door (+Z)")


func test_members_gossip_and_the_gran_maestro_has_his_own_lines() -> void:
	var cop: Cop = club.get_node("Cop")
	club.members[0].use(cop)
	assert_true(club.members[0].said().begins_with("CHESS_GOSSIP_"))
	club.alfil.use(cop)
	assert_true(club.alfil.said().begins_with("ALFIL_"))


func test_the_whole_club_watches_for_members() -> void:
	assert_eq(club.suspicion.disguise_look, "chess")
	assert_eq(club.suspicion.prefix, "CHESS_")
	assert_eq(club.suspicion.boss_found_out, "ALFIL_FOUND_OUT")
	assert_true(club.suspicion.inside.call(_at(-4.0, 4.0)), "the hall counts")
	assert_true(club.suspicion.inside.call(_at(8.0, 5.0)), "and the cafeteria")
	assert_false(club.suspicion.inside.call(_at(0.0, 14.0)), "the street doesn't")


## A cop walking in from the street.
func _walk_in(cop: Cop) -> void:
	cop.global_position = club.global_transform * Vector3(ChessClub.ENTRANCE_X, 0.1, ChessClub.HALF_Z + 1.0)
	cop.global_rotation.y = club.global_rotation.y
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		club.doorman._physics_process(1.0 / 60.0)


func test_the_doorkeeper_wants_a_member() -> void:
	var cop: Cop = club.get_node("Cop")
	cop.put_on_disguise("glasses", 0.0)
	await _walk_in(cop)
	assert_eq(club.doorman.said(), "CHESSDOOR_NO_1", "a grandpa's glasses aren't a member")
	assert_gt((club.global_transform.affine_inverse() * cop.global_position).z, ChessClub.HALF_Z - 0.3,
		"didn't get in")


func test_the_doorkeeper_lets_a_member_in() -> void:
	var cop: Cop = club.get_node("Cop")
	cop.put_on_disguise("chess_glasses", 0.0)
	cop.put_on_disguise("chess_vest", 0.0)
	await _walk_in(cop)
	assert_eq(club.doorman.said(), "CHESSDOOR_WELCOME")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = club.get_node("Cop")
	var station := club.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_chess_club_s_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PLACE_CHESS", "PROMPT_TALK_CHESS", "CHESS_CUFFED", "PROMPT_TALK_ALFIL", "ALFIL_CUFFED",
		"ALFIL_FOUND_OUT", "CHESSDOOR_WELCOME", "CHESSDOOR_NO_0", "CHESSDOOR_NO_1", "HINT_CHESSDOOR_NO_DISGUISE",
		"HUD_CHESS_SUSPICION", "HINT_CHESS_FOUND_OUT"]
	for i in 10:
		keys.append("CHESS_GOSSIP_%d" % i)
	for i in 4:
		keys.append("ALFIL_%d" % i)
	for i in 3:
		keys.append("CHESS_FOUND_OUT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
