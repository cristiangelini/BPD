extends GutTest

## Don Tito, the janitor (politico-escuela.md, step 6, decision 210): he swaps pupils' cards for traps in the classroom
## and at recess, has violet ink on his fingers (and two decoys), the rival's envelope is in his shed, and cuffed he
## stops and is walked to the patrol car.

const LEVEL := preload("res://scenes/levels/school_visit.tscn")

var school: SchoolVisitLevel
var janitor: SchoolJanitor
var cop: Cop


func before_each() -> void:
	school = LEVEL.instantiate()
	school.case_seed = 7
	cop = school.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)
	janitor = school.janitor


## Puts him (and every pupil) at the end of their way right away.
func _jump() -> void:
	if janitor.walking():
		janitor.global_position = janitor._path[-1] + Vector3.UP * 0.05
		janitor._path = [janitor._path[-1]]
	for pupil in school.pupils:
		if pupil.walking():
			pupil._wait_left = 0.0
			pupil.global_position = Vector3(pupil._path[-1].x, pupil.global_position.y, pupil._path[-1].z)
			pupil._path = [pupil._path[-1]]
	await wait_physics_frames(4)


func test_he_sweeps_the_hall_with_the_deck_in_his_pocket() -> void:
	assert_false(school.in_classroom(janitor.global_position))
	assert_false(school.in_yard(janitor.global_position))
	assert_true(janitor.get_node("Model").find_child("deck", true, false) != null, "the deck sticks out")


func test_only_up_close_the_fingers_tell_and_two_decoys_fool() -> void:
	await wait_process_frames(2)
	assert_false(janitor.get_node("Stain").visible)
	cop.global_position = janitor.global_position + school.global_basis.x * 1.5
	await wait_process_frames(2)
	assert_true(janitor.get_node("Stain").visible)
	assert_eq(janitor.get_node("Stain").text, "JANITOR_STAIN")
	assert_true(school.teacher.stained)
	var painted := school.pupils.filter(func(p: SchoolPupil) -> bool: return p.stained)
	assert_eq(painted.size(), 1, "one pupil with violet paint")


func test_in_the_talk_he_sweeps_by_a_desk_and_swaps_a_card() -> void:
	watch_signals(janitor)
	school.tour.start()
	await wait_physics_frames(2)
	janitor.swap_left = 0.05
	await wait_physics_frames(6)
	var pupil := janitor.target
	assert_not_null(pupil)
	assert_false(pupil.trap)
	assert_true(janitor.walking())
	await _jump()
	await wait_physics_frames(2)
	assert_signal_emitted_with_parameters(janitor, "swapped", [pupil])
	assert_true(pupil.trap, "now it's a trap")
	assert_eq(school.questions.traps_left(), SchoolQuestions.TRAPS + 1)
	assert_eq(pupil.said(), "PUPIL_NEW_CARD")
	assert_true(janitor.walking(), "back to the hall")
	assert_eq(janitor._path[-1], school.to_global(SchoolVisitLevel.JANITOR_AT))


func test_at_recess_he_goes_out_and_swaps_there() -> void:
	watch_signals(janitor)
	school.tour.start()
	await wait_physics_frames(2)
	school.tour._next()
	await wait_physics_frames(2)
	assert_eq(janitor._path[-1], school.to_global(SchoolVisitLevel.JANITOR_YARD), "off to the playground")
	await _jump()
	assert_true(school.in_yard(janitor.global_position))
	janitor.swap_left = 0.05
	await wait_physics_frames(4)
	assert_not_null(janitor.target)
	assert_true(school.in_yard(janitor.target.global_position), "a pupil playing")
	await _jump()
	await wait_physics_frames(2)
	assert_signal_emitted(janitor, "swapped")
	assert_eq(janitor.swap_left, SchoolJanitor.YARD_EVERY, "every 20 s at recess")


func test_the_ways_end_where_they_should() -> void:
	var way := school.janitor_to_desk(12)
	assert_lt(way[-1].distance_to(school.pupils[12].global_position), SchoolJanitor.SWAP_REACH + 0.5)
	var out := school.janitor_from_hall(way[-1], true)
	assert_eq(out[-1], school.to_global(SchoolVisitLevel.JANITOR_YARD))
	var back := school.janitor_from_hall(way[-1], false)
	assert_eq(back[-1], school.to_global(SchoolVisitLevel.JANITOR_AT))
	assert_eq(school.janitor_to_hall()[-1], school.to_global(SchoolVisitLevel.JANITOR_AT))


func test_cuffed_he_stops_and_goes_to_the_patrol_car() -> void:
	watch_signals(janitor)
	school.tour.start()
	janitor.cuffed(Handcuffs.SECONDS)
	assert_signal_emitted(janitor, "cuffed_now")
	assert_string_starts_with(janitor.said(), "JANITOR_CUFFED_")
	janitor.swap_left = 0.05
	await wait_physics_frames(6)
	assert_null(janitor.target, "no more cards")
	assert_eq(janitor.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	janitor.use(cop)
	assert_eq(OwnerEscort.of(janitor).escorted_by, cop)
	OwnerEscort.of(janitor).board()
	assert_true(janitor.caught())
	assert_eq(school.car.prisoner, janitor)


func test_the_envelope_is_in_the_shed_s_chest() -> void:
	var envelope := school.envelope
	assert_true(school.chest.drawers[0].contents.has(envelope))
	assert_eq(envelope.prompt_key(cop), "PROMPT_ENVELOPE")
	watch_signals(envelope)
	envelope.use(cop)
	assert_signal_emitted_with_parameters(envelope, "read", ["SCHOOL_ENVELOPE"])
