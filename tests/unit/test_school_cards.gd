extends GutTest

## Taking the cards away (politico-escuela.md, step 5, decision 210): E puts a pupil's card in the cop's hands, an
## innocent one cries until a candy from the teacher's box, a trap's pupil tells who gave it, the card can be torn up
## or given back, and a cop next to the deputy points at who asks next.

const LEVEL := preload("res://scenes/levels/school_visit.tscn")

var school: SchoolVisitLevel
var cop: Cop
var grabber: Grabber


func before_each() -> void:
	school = LEVEL.instantiate()
	school.case_seed = 7
	cop = school.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)
	grabber = cop.get_node("Grabber")
	grabber.input_enabled = false


func _trap() -> SchoolPupil:
	return school.pupils.filter(func(p: SchoolPupil) -> bool: return p.trap)[0]


func _innocent() -> SchoolPupil:
	return school.pupils.filter(func(p: SchoolPupil) -> bool: return not p.trap)[0]


func _take(pupil: SchoolPupil) -> SchoolCard:
	cop.global_position = pupil.global_position + school.global_basis.z * 1.0
	assert_eq(pupil.prompt_key(cop), "PROMPT_TAKE_CARD")
	pupil.use(cop)
	return grabber.held as SchoolCard


func test_taking_a_card_puts_it_in_the_hands_and_the_pupil_cries() -> void:
	var pupil := _innocent()
	var said := pupil.card
	watch_signals(pupil)
	var card := _take(pupil)
	assert_not_null(card, "the card is in the cop's hands")
	assert_eq(card.key, said)
	assert_false(card.trap)
	assert_false(pupil.has_card())
	assert_true(pupil.crying)
	assert_eq(pupil.said(), "PUPIL_MINE")
	assert_signal_emitted_with_parameters(pupil, "card_taken", [pupil, false])
	assert_eq(card.held_prompt_key(cop), "PROMPT_TEAR_CARD")


func test_crying_ten_seconds_counts_and_a_candy_calms() -> void:
	var pupil := _innocent()
	watch_signals(pupil)
	_take(pupil)
	grabber.release()
	pupil.cry_for = SchoolPupil.CRY_TIME - 0.05
	await wait_seconds(0.2)
	assert_signal_emitted(pupil, "cried")
	assert_true(pupil.crying, "still crying")
	assert_eq(school.candy_box.prompt_key(cop), "PROMPT_TAKE_CANDY")
	school.candy_box.use(cop)
	assert_true(grabber.held is SchoolCandy)
	assert_eq(pupil.prompt_key(cop), "PROMPT_GIVE_CANDY")
	pupil.use(cop)
	assert_false(pupil.crying)
	assert_eq(pupil.said(), "PUPIL_THANKS")
	assert_null(grabber.held, "the candy is gone")
	assert_signal_emit_count(pupil, "cried", 1)


func test_a_candy_in_time_and_it_does_not_count() -> void:
	var pupil := _innocent()
	watch_signals(pupil)
	_take(pupil)
	grabber.release()
	school.candy_box.use(cop)
	pupil.use(cop)
	pupil.cry_for = 0.0
	await wait_seconds(0.3)
	assert_signal_not_emitted(pupil, "cried")


func test_a_trap_pupil_does_not_cry_and_tells_who_gave_it() -> void:
	var pupil := _trap()
	var card := _take(pupil)
	assert_true(card.trap)
	assert_false(pupil.crying)
	assert_string_starts_with(pupil.said(), "PUPIL_TRAP_TOLD_")
	assert_eq(school.questions.traps_left(), SchoolQuestions.TRAPS - 1)


func test_the_card_can_be_given_back_or_torn_up() -> void:
	var pupil := _innocent()
	var key := pupil.card
	_take(pupil)
	assert_eq(pupil.prompt_key(cop), "PROMPT_GIVE_CARD")
	pupil.use(cop)
	assert_eq(pupil.card, key, "back in their hand")
	assert_false(pupil.crying, "and happy again")
	assert_null(grabber.held)
	var card := _take(_trap())
	watch_signals(card)
	cop.use()
	assert_signal_emitted(card, "torn")
	assert_null(grabber.held)
	await wait_process_frames(2)
	assert_false(is_instance_valid(card))


func test_a_card_taken_while_read_is_no_gaffe() -> void:
	var tour := school.tour
	tour.start()
	tour._enter(SchoolTour.Phase.QUESTIONS, school.deputy_to_class())
	await wait_physics_frames(2)
	var pupil := _trap()
	pupil.raise_hand(true)
	school.questions.point_at(pupil)
	school.questions.ask()
	assert_eq(school.questions.reading, pupil)
	_take(pupil)
	school.questions._react_left = 0.05
	await wait_physics_frames(6)
	assert_eq(school.questions.gaffes, 0)
	assert_eq(tour.politician.said(), "SCHOOL_LUSTRE_NO_CARD")


func test_a_cop_by_the_deputy_points_at_who_asks() -> void:
	var tour := school.tour
	tour.start()
	tour._enter(SchoolTour.Phase.QUESTIONS, school.deputy_to_class())
	var end: Vector3 = tour._path[-1]
	tour.politician.global_position = end + Vector3.UP * 0.1
	tour._path = [end]
	await wait_physics_frames(3)
	var pupil := _innocent()
	pupil.raise_hand(true)
	cop.global_position = tour.politician.global_position + school.global_basis.x * 1.0
	cop.camera.look_at(pupil.global_position + Vector3.UP * 0.5)
	await wait_physics_frames(2)
	assert_true(school.questions.try_point(cop))
	assert_eq(tour.politician.said(), "SCHOOL_LUSTRE_POINTED")
	assert_false(school.questions.try_point(cop), "once every so often")
	school.questions.ask()
	assert_eq(school.questions.reading, pupil)


func test_too_far_from_the_deputy_and_pointing_does_nothing() -> void:
	var tour := school.tour
	tour.start()
	tour._enter(SchoolTour.Phase.QUESTIONS, school.deputy_to_class())
	await wait_physics_frames(2)
	var pupil := _innocent()
	pupil.raise_hand(true)
	cop.global_position = tour.politician.global_position + school.global_basis.x * 4.0
	cop.camera.look_at(pupil.global_position + Vector3.UP * 0.5)
	assert_false(school.questions.try_point(cop))
