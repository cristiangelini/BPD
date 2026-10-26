extends GutTest

## The thieves' school "Academia Manos Ligeras" (infiltracion-escuela.md, step 2, decision 173): on its own city lot,
## the classroom, the practice yard, the library and the Director's locked office; the students at their desks, the
## Profesora Ganzúa in front of them, the Director unseen in his office and the lookout who only lets in thieves.

const LEVEL := preload("res://scenes/levels/school_hall.tscn")

var school: SchoolHall


func before_each() -> void:
	school = LEVEL.instantiate()
	school.get_node("Cop").input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)


func test_it_is_on_its_own_lot_and_play_can_open_it() -> void:
	var lot: Dictionary = CityLayout.place("school")
	assert_false(lot.is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=school"])), "school")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["school"]))
	assert_almost_eq(lot.size.x, SchoolHall.HALF_X * 2, 0.01, "as wide as its lot")
	assert_almost_eq(lot.size.z, SchoolHall.HALF_Z * 2, 0.01, "and as deep")


func test_it_is_the_school_infiltration_place() -> void:
	assert_true(school is InfiltrationPlace)
	assert_eq(school.variant, "school")


func test_the_rooms_are_where_they_say() -> void:
	var at := func(x: float, z: float) -> Vector3: return school.global_transform * Vector3(x, 1.0, z)
	assert_true(school.in_classroom(at.call(-6.0, 5.0)))
	assert_true(school.in_yard(at.call(6.0, 5.0)))
	assert_true(school.in_library(at.call(-7.0, -5.0)))
	assert_true(school.in_back_room(at.call(8.0, -5.0)), "the office at the back east")
	assert_false(school.in_classroom(at.call(0.0, 5.0)), "the lobby is neither")
	assert_false(school.in_yard(at.call(0.0, 5.0)))
	assert_true(school.is_inside(at.call(0.0, 5.0)))


func test_the_office_is_locked() -> void:
	assert_true(school.office_door.locked)


func test_students_at_desks_facing_the_board_and_the_teacher_facing_them() -> void:
	assert_eq(school.members.size(), SchoolHall.MEMBERS)
	for member: ClubMember in school.members:
		assert_true(SchoolHall.seats().any(func(seat: Vector3) -> bool:
			return (seat + Vector3(0, SchoolHall.FLOOR_TOP, 0)).distance_to(member.position) < 0.01), "at a desk")
		assert_true(member.look.begins_with("alumn"))
		assert_lt((-member.global_basis.z).dot(school.global_basis.x), -0.99, "looking at the board (-X)")
	assert_eq(school.free_seats.size(), 12 - SchoolHall.MEMBERS, "desks left for the cops")
	assert_gt((-school.teacher.global_basis.z).dot(school.global_basis.x), 0.99, "the teacher looks at them")
	assert_true(school.in_classroom(school.teacher.global_position + Vector3.UP))
	assert_false(school.teacher.is_boss())


func test_the_same_seed_seats_the_same_students() -> void:
	var other: SchoolHall = LEVEL.instantiate()
	other.case_seed = school.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in school.members.size():
		assert_eq(other.members[i].position, school.members[i].position)
		assert_eq(other.members[i].look, school.members[i].look)


func test_the_director_waits_unseen_in_his_office() -> void:
	assert_eq(school.boss, school.director)
	assert_true(school.director.is_boss())
	assert_true(school.in_back_room(school.director.global_position + Vector3.UP))
	assert_false(school.director.visible)
	assert_eq(school.director.collision_layer, 0, "not in the way")
	school.set_director_present(true)
	assert_true(school.director.visible)
	assert_eq(school.director.collision_layer, 8)


func test_students_gossip_and_the_teacher_has_her_own_lines() -> void:
	var cop: Cop = school.get_node("Cop")
	school.members[0].use(cop)
	assert_true(school.members[0].said().begins_with("SCHOOL_GOSSIP_"))
	school.teacher.use(cop)
	assert_true(school.teacher.said().begins_with("GANZUA_"))


func test_the_students_watch_for_thieves() -> void:
	assert_eq(school.suspicion.disguise_look, "thief")
	assert_eq(school.suspicion.prefix, "SCHOOL_")
	assert_eq(school.suspicion.boss_found_out, "DIRECTOR_FOUND_OUT")
	var cop: Cop = school.get_node("Cop")
	assert_gt(school.suspicion.offence(cop, 0.0), 0.0, "a cop in uniform is suspicious")
	cop.put_on_disguise("thief_mask", 0.0)
	cop.put_on_disguise("thief_shirt", 0.0)
	assert_eq(school.suspicion.offence(cop, 0.0), 0.0, "a thief standing still isn't")


## A cop walking into the doorway from the sidewalk.
func _walk_in(cop: Cop) -> void:
	cop.global_position = school.global_transform * Vector3(SchoolHall.ENTRANCE_X, 0.1, SchoolHall.HALF_Z + 1.0)
	cop.global_rotation.y = school.global_rotation.y
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		school.doorman._physics_process(1.0 / 60.0)


func test_the_lookout_wants_a_thief() -> void:
	var cop: Cop = school.get_node("Cop")
	cop.put_on_disguise("mime_shirt", 0.0)
	await _walk_in(cop)
	assert_eq(school.doorman.said(), "SCHOOLDOOR_NO_1", "a mime's shirt isn't a thief")
	var inside_z := (school.global_transform.affine_inverse() * cop.global_position).z
	assert_gt(inside_z, SchoolHall.HALF_Z - 0.5, "didn't get in")


func test_the_lookout_lets_a_thief_in() -> void:
	var cop: Cop = school.get_node("Cop")
	cop.put_on_disguise("thief_mask", 0.0)
	cop.put_on_disguise("thief_beanie", 0.0)
	await _walk_in(cop)
	assert_eq(school.doorman.said(), "SCHOOLDOOR_WELCOME")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = school.get_node("Cop")
	var station := school.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_school_s_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PLACE_SCHOOL", "SCHOOL_MOTTO", "SCHOOL_BOARD", "PROMPT_TALK_STUDENT", "SCHOOL_CUFFED",
		"PROMPT_TALK_GANZUA", "GANZUA_CUFFED", "PROMPT_TALK_DIRECTOR", "DIRECTOR_CUFFED", "DIRECTOR_FOUND_OUT",
		"SCHOOLDOOR_WELCOME", "SCHOOLDOOR_NO_0", "SCHOOLDOOR_NO_1", "HINT_SCHOOLDOOR_NO_DISGUISE",
		"HUD_SCHOOL_SUSPICION", "HINT_SCHOOL_FOUND_OUT"]
	for i in 10:
		keys.append("SCHOOL_GOSSIP_%d" % i)
	for i in 4:
		keys.append("GANZUA_%d" % i)
		keys.append("DIRECTOR_%d" % i)
	for i in ClubSuspicion.FOUND_OUT_LINES:
		keys.append("SCHOOL_FOUND_OUT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
