extends GutTest

## Deputy Lustre's visit to the school (politico-escuela.md, step 3, decision 210): he waits for his guard, gives his
## talk at the blackboard, goes out to recess with the pupils, comes back for the questions and ends with the group
## photo on the sidewalk.

const LEVEL := preload("res://scenes/levels/school_visit.tscn")

var school: SchoolVisitLevel
var tour: SchoolTour
var cop: Cop


func before_each() -> void:
	school = LEVEL.instantiate()
	school.case_seed = 7
	cop = school.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)
	tour = school.tour


## Puts him at the end of his way right away.
func _place_him() -> void:
	var end: Vector3 = tour._path[-1]
	tour.politician.global_position = end + Vector3.UP * 0.1
	tour._path = [end]


func test_he_waits_on_the_sidewalk_until_a_cop_comes() -> void:
	await wait_physics_frames(10)
	assert_eq(tour.phase, SchoolTour.Phase.WAITING)
	cop.global_position = tour.politician.global_position + Vector3(3, 0, 3)
	await wait_physics_frames(3)
	assert_eq(tour.phase, SchoolTour.Phase.TALK)
	assert_true(tour.walking(), "off to the classroom")


func test_the_talk_counts_from_the_blackboard_with_a_line_every_so_often() -> void:
	tour.start()
	await wait_physics_frames(5)
	assert_eq(tour.phase_left, SchoolTour.TALK_TIME, "not while he walks in")
	_place_him()
	await wait_seconds(0.3)
	assert_true(tour.placed)
	assert_lt(tour.phase_left, SchoolTour.TALK_TIME)
	assert_true(school.in_classroom(tour.politician.global_position))
	assert_string_starts_with(tour.politician.said(), "SCHOOL_LUSTRE_TALK_")


func test_the_bell_sends_everyone_to_the_playground() -> void:
	tour.start()
	_place_him()
	await wait_physics_frames(3)
	tour.phase_left = 0.05
	await wait_physics_frames(6)
	assert_eq(tour.phase, SchoolTour.Phase.RECESS)
	assert_eq(tour.politician.said(), "SCHOOL_LUSTRE_BELL")
	for pupil in school.pupils:
		assert_true(pupil.walking() or school.in_yard(pupil.global_position), "%s goes out" % pupil.name)
	assert_true(school.in_yard(tour._path[-1]), "and so does he")
	await wait_physics_frames(3)
	assert_lt(tour.phase_left, SchoolTour.RECESS_TIME, "recess counts from the bell")


func test_every_way_ends_where_it_should() -> void:
	for desk in [0, 7, 19]:
		var out := school.route_to_yard(desk, school.recess_spot(desk))
		assert_true(school.in_yard(out[-1]), "recess spot %d is in the playground" % desk)
		var back := school.route_to_desk(desk)
		assert_almost_eq(back[-1], school.to_global(SchoolVisitLevel.seat(desk)), Vector3.ONE * 0.01)
		var front := school.route_out_front(desk, school.photo_spot(desk))
		assert_gt(school.to_local(front[-1]).z, SchoolVisitLevel.FRONT_Z, "the photo is out on the sidewalk")


func test_a_pupil_walks_its_way_and_turns_at_the_end() -> void:
	var pupil := school.pupils[0]
	var to := pupil.global_position + school.global_basis.x * 1.0
	pupil.walk([to], 0.0, school.global_basis.z)
	await wait_seconds(1.2)
	assert_false(pupil.walking())
	assert_almost_eq(pupil.global_position.distance_to(to), 0.0, 0.05)
	assert_gt((-pupil.global_basis.z).dot(school.global_basis.z), 0.99)


func test_the_questions_come_every_so_often() -> void:
	watch_signals(tour)
	tour.start()
	tour._enter(SchoolTour.Phase.QUESTIONS, school.deputy_to_class())
	_place_him()
	await wait_physics_frames(3)
	assert_eq(tour.politician.said(), "SCHOOL_LUSTRE_QUESTIONS")
	tour._question_left = 0.05
	await wait_physics_frames(6)
	assert_signal_emitted(tour, "question_time")


func test_the_photo_ends_the_visit() -> void:
	watch_signals(tour)
	tour.start()
	tour._enter(SchoolTour.Phase.QUESTIONS, school.deputy_to_class())
	_place_him()
	await wait_physics_frames(3)
	tour.phase_left = 0.05
	await wait_physics_frames(6)
	assert_eq(tour.phase, SchoolTour.Phase.PHOTO)
	for pupil in school.pupils:
		assert_true(pupil.walking(), "the pupils go out front")
	_place_him()
	await wait_physics_frames(3)
	assert_eq(tour.politician.said(), "SCHOOL_LUSTRE_PHOTO")
	tour.phase_left = 0.05
	await wait_physics_frames(6)
	assert_eq(tour.phase, SchoolTour.Phase.OVER)
	assert_signal_emitted(tour, "finished")
	assert_eq(tour.progress(), 1.0)


func test_the_bar_fills_up_through_the_visit() -> void:
	assert_eq(tour.progress(), 0.0)
	tour.phase = SchoolTour.Phase.TALK
	tour.phase_left = SchoolTour.TALK_TIME / 2
	var talk := tour.progress()
	tour.phase = SchoolTour.Phase.RECESS
	tour.phase_left = SchoolTour.RECESS_TIME / 2
	var recess := tour.progress()
	tour.phase = SchoolTour.Phase.QUESTIONS
	tour.phase_left = SchoolTour.QUESTIONS_TIME / 2
	assert_between(talk, 0.0, recess)
	assert_between(recess, talk, tour.progress())
