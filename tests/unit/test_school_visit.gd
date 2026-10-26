extends GutTest

## The Los Girasoles school (politico-escuela.md, step 2, decision 210): its lot on block (3, 3), the classroom with
## 20 pupils at their desks facing the blackboard, the teacher by her desk, the janitor in the hall and the playground
## behind the building.

const LEVEL := preload("res://scenes/levels/school_visit.tscn")

var school: SchoolVisitLevel


func before_each() -> void:
	school = LEVEL.instantiate()
	school.case_seed = 7
	school.get_node("Cop").input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)


func test_play_can_open_it() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=school_visit"])), "school_visit")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["school_visit"]))


func test_it_sits_on_its_own_lot_in_the_city() -> void:
	var lot := CityLayout.place("school_visit")
	assert_eq(lot.block, Vector2i(3, 3))
	assert_eq(CityLayout.lot("school_visit").origin.distance_to(school.city.transform.affine_inverse().origin), 0.0,
		"the city is laid around the school")
	var mine := CityLayout.footprint(lot.block, lot.side, lot.along, lot.size)
	for other: Dictionary in CityLayout.PLACES:
		if other.id != "school_visit":
			assert_false(mine.intersects(CityLayout.footprint(other.block, other.side, other.along, other.size)),
				"clear of %s" % other.id)


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = school.get_node("Cop")
	assert_gt(cop.global_position.distance_to(school.global_position), 40.0, "they drive here")


func test_twenty_pupils_at_their_desks_facing_the_blackboard() -> void:
	assert_eq(school.pupils.size(), 20)
	for pupil in school.pupils:
		assert_true(school.in_classroom(pupil.global_position), "%s is in the classroom" % pupil.name)
		assert_gt((-pupil.global_basis.z).dot(-school.global_basis.z), 0.99, "looking at the blackboard")
		assert_lt(pupil.get_node("Model").scale.x, 0.7, "a child, smaller than a grown-up")


func test_the_seed_deals_the_looks_five_each() -> void:
	var looks := SchoolVisitLevel.looks_for(7)
	for look in 4:
		assert_eq(looks.count(look), 5)
	var differs := false
	for s in range(1, 6):
		differs = differs or SchoolVisitLevel.looks_for(s) != looks
	assert_true(differs, "another seed, another classroom")


func test_the_teacher_faces_the_class_and_the_janitor_sweeps_the_hall() -> void:
	assert_true(school.in_classroom(school.teacher.global_position))
	assert_gt((-school.teacher.global_basis.z).dot(school.global_basis.z), 0.99, "looking at the pupils")
	assert_true(school.janitor.is_janitor())
	assert_false(school.in_classroom(school.janitor.global_position), "in the hall")
	assert_false(school.in_yard(school.janitor.global_position))


func test_everyone_has_something_to_say() -> void:
	var pupil := school.pupils[0]
	var cop: Cop = school.get_node("Cop")
	assert_eq(pupil.prompt_key(cop), "PROMPT_TALK_PUPIL")
	pupil.use(cop)
	var first := pupil.said()
	pupil.use(cop)
	assert_ne(pupil.said(), first, "a different line each time")
	school.janitor.use(cop)
	assert_string_starts_with(school.janitor.said(), "JANITOR_")
	school.teacher.use(cop)
	assert_string_starts_with(school.teacher.said(), "TEACHER_")


func test_the_playground_is_behind_the_building() -> void:
	var yard := school.to_global(Vector3(0, 0, -6))
	assert_true(school.in_yard(yard))
	assert_false(school.in_classroom(yard))
