extends GutTest

## The cards and the questions of the school visit (politico-escuela.md, step 4, decision 210): five of the twenty
## cards are traps, a cop reads them up close, the hands go up in the questions and a trap read out is a gaffe; with
## eight he leaves ashamed.

const LEVEL := preload("res://scenes/levels/school_visit.tscn")

var school: SchoolVisitLevel
var questions: SchoolQuestions
var cop: Cop


func before_each() -> void:
	school = LEVEL.instantiate()
	school.case_seed = 7
	cop = school.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)
	questions = school.questions


func _to_questions() -> void:
	var tour := school.tour
	tour.start()
	tour._enter(SchoolTour.Phase.QUESTIONS, school.deputy_to_class())
	var end: Vector3 = tour._path[-1]
	tour.politician.global_position = end + Vector3.UP * 0.1
	tour._path = [end]
	await wait_physics_frames(3)


func _trap() -> SchoolPupil:
	return school.pupils.filter(func(p: SchoolPupil) -> bool: return p.trap)[0]


func _innocent() -> SchoolPupil:
	return school.pupils.filter(func(p: SchoolPupil) -> bool: return not p.trap)[0]


func test_every_pupil_holds_a_card_and_five_are_traps() -> void:
	assert_eq(questions.traps_left(), SchoolQuestions.TRAPS)
	for pupil in school.pupils:
		assert_true(pupil.has_card(), "%s has a card" % pupil.name)
		assert_eq(pupil.card.begins_with("SCHOOL_TRAP_"), pupil.trap)


func test_the_seed_deals_the_traps() -> void:
	var traps := school.pupils.filter(func(p: SchoolPupil) -> bool: return p.trap).map(
		func(p: SchoolPupil) -> int: return p.desk)
	var again: SchoolVisitLevel = LEVEL.instantiate()
	again.case_seed = 8
	again.get_node("Cop").input_enabled = false
	add_child_autofree(again)
	await wait_physics_frames(2)
	var others := again.pupils.filter(func(p: SchoolPupil) -> bool: return p.trap).map(
		func(p: SchoolPupil) -> int: return p.desk)
	assert_eq(others.size(), SchoolQuestions.TRAPS)
	assert_ne(others, traps, "another seed, other traps")


func test_a_cop_reads_the_card_only_up_close() -> void:
	var pupil := school.pupils[0]
	await wait_process_frames(2)
	assert_false(pupil.card_shown())
	cop.global_position = pupil.global_position + school.global_basis.z * 1.2
	await wait_process_frames(2)
	assert_true(pupil.card_shown())


func test_traps_always_put_their_hand_up_and_only_in_the_questions() -> void:
	questions.raise_hands()
	await wait_physics_frames(1)
	for pupil in school.pupils:
		assert_false(pupil.hand_up, "not before the questions")
	await _to_questions()
	questions.raise_hands()
	for pupil in school.pupils:
		if pupil.trap:
			assert_true(pupil.hand_up, "%s waves the trap" % pupil.name)
	var arm: Node3D = _trap().get_node("Arm")
	var tilt := arm.rotation.z
	await wait_seconds(0.2)
	assert_ne(arm.rotation.z, tilt, "waving it about")
	school.tour.phase_left = 0.05
	await wait_physics_frames(6)
	for pupil in school.pupils:
		assert_false(pupil.hand_up, "hands down for the photo")


func test_he_gives_the_floor_and_the_pupil_reads_the_card() -> void:
	await _to_questions()
	watch_signals(questions)
	questions.give_floor()
	assert_signal_emitted(questions, "asked")
	var pupil: SchoolPupil = get_signal_parameters(questions, "asked")[0]
	assert_eq(pupil.said(), pupil.card)
	assert_eq(school.tour.politician.said(), "SCHOOL_LUSTRE_ASK")


func test_an_innocent_question_gets_an_answer() -> void:
	await _to_questions()
	var pupil := _innocent()
	pupil.raise_hand(true)
	assert_true(questions.point_at(pupil))
	questions.give_floor()
	assert_eq(questions.reading, pupil, "the one pointed at")
	questions._react_left = 0.05
	await wait_physics_frames(6)
	assert_string_starts_with(school.tour.politician.said(), "SCHOOL_LUSTRE_ANSWER_")
	assert_eq(questions.gaffes, 0)


func test_a_trap_read_out_is_a_gaffe() -> void:
	await _to_questions()
	watch_signals(questions)
	_trap().raise_hand(true)
	assert_true(questions.point_at(_trap()))
	questions.give_floor()
	questions._react_left = 0.05
	await wait_physics_frames(6)
	assert_eq(questions.gaffes, 1)
	assert_signal_emitted_with_parameters(questions, "gaffe", [1])
	assert_string_starts_with(school.tour.politician.said(), "SCHOOL_LUSTRE_STAMMER_")
	assert_gt(school.tour.hold_left, 0.0, "he needs a moment")


func test_eight_gaffes_and_he_leaves_ashamed() -> void:
	await _to_questions()
	watch_signals(questions)
	questions.gaffes = SchoolQuestions.MAX_GAFFES - 1
	questions.reading = _trap()
	questions._react_left = 0.05
	await wait_physics_frames(6)
	assert_signal_emitted(questions, "shamed")
	assert_eq(school.tour.phase, SchoolTour.Phase.OVER)
	assert_eq(school.tour.politician.said(), "SCHOOL_LUSTRE_SHAMED")
	for pupil in school.pupils:
		assert_false(pupil.hand_up)


func test_you_cannot_point_at_a_hand_that_is_down() -> void:
	var pupil := _innocent()
	pupil.raise_hand(false)
	assert_false(questions.point_at(pupil))
