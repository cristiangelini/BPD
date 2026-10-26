extends GutTest

## The mimes' "Teatro del Silencio" (infiltracion-mimos.md, step 2, decision 170): its lot in the city, the seats with
## the aisle, the stage with a mark for each mime and cop, the locked dressing room and the cops starting at the
## station by the disguises; the mimes, Maestra Pausa and the mute doorman (step 2b).

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


func test_mimes_on_marks_and_pausa_in_front_of_them() -> void:
	assert_eq(theater.members.size(), MimeTheater.MEMBERS)
	for member: ClubMember in theater.members:
		assert_true(theater.marks.any(func(at: Vector3) -> bool: return at.distance_to(member.position) < 0.01),
			"on a mark")
		assert_true(member.look.begins_with("mimo"))
	assert_eq(theater.free_marks.size(), theater.marks.size() - MimeTheater.MEMBERS, "marks left for the cops")
	assert_eq(theater.boss, theater.pausa)
	assert_true(theater.pausa.is_boss())
	assert_lt(theater.pausa.global_basis.z.dot(theater.members[0].global_basis.z), 0.0, "facing each other")


func test_the_same_seed_puts_the_mimes_on_the_same_marks() -> void:
	var other: MimeTheater = LEVEL.instantiate()
	other.case_seed = theater.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in theater.members.size():
		assert_eq(other.members[i].position, theater.members[i].position)


func test_mimes_only_mime_and_pausa_speaks_when_cuffed() -> void:
	var cop: Cop = theater.get_node("Cop")
	theater.members[0].use(cop)
	assert_true(theater.members[0].said().begins_with("MIME_GOSSIP_"))
	theater.pausa.use(cop)
	assert_true(theater.pausa.said().begins_with("PAUSA_"))
	theater.pausa.cuffed(5.0)
	assert_eq(theater.pausa.said(), "PAUSA_CUFFED")


func test_the_mimes_watch_for_the_mime_disguise() -> void:
	assert_eq(theater.suspicion.disguise_look, "mime")
	assert_eq(theater.suspicion.prefix, "MIME_")
	assert_eq(theater.suspicion.boss, theater.pausa)
	var cop: Cop = theater.get_node("Cop")
	assert_gt(theater.suspicion.offence(cop, 0.0), 0.0, "a cop in uniform is suspicious")
	cop.put_on_disguise("mime_beret", 0.0)
	cop.put_on_disguise("mime_face", 0.0)
	assert_eq(theater.suspicion.offence(cop, 0.0), 0.0, "a mime standing still isn't")


## A cop walking into the doorway from the sidewalk.
func _walk_in(cop: Cop) -> void:
	cop.global_position = theater.global_transform * Vector3(MimeTheater.ENTRANCE_X, 0.1, MimeTheater.HALF_Z + 1.0)
	cop.global_rotation.y = 0.0
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		theater.doorman._physics_process(1.0 / 60.0)


func test_the_doorman_wants_a_mime() -> void:
	var cop: Cop = theater.get_node("Cop")
	cop.put_on_disguise("robe", 0.0)
	await _walk_in(cop)
	assert_eq(theater.doorman.said(), "MIMEDOOR_NO_1", "a robe isn't a mime")
	var inside_z := (theater.global_transform.affine_inverse() * cop.global_position).z
	assert_gt(inside_z, MimeTheater.HALF_Z - 0.5, "didn't get in")


func test_the_doorman_lets_a_mime_in() -> void:
	var cop: Cop = theater.get_node("Cop")
	cop.put_on_disguise("mime_face", 0.0)
	cop.put_on_disguise("mime_shirt", 0.0)
	await _walk_in(cop)
	assert_eq(theater.doorman.said(), "MIMEDOOR_WELCOME")
