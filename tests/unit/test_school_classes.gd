extends GutTest

## The Profesora Ganzúa's classes (infiltracion-escuela.md, step 3, decision 173): every so often the bell rings and
## everyone practices a subject in turn (lockpicking, pickpocketing, sneaking); each cop gets a grade from 1 to 10 at the
## end, the host keeps the best one per subject, and a low grade makes the students who see it suspicious.

const LEVEL := preload("res://scenes/levels/school_hall.tscn")

var school: SchoolHall
var classes: SchoolClasses
var cop: Cop


func before_each() -> void:
	school = LEVEL.instantiate()
	cop = school.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)
	classes = school.classes
	cop.input_enabled = true


## Puts the cop at `local` in the school, standing.
func _at(local: Vector3) -> void:
	cop.global_position = school.global_transform * (local + Vector3(0, 0.1, 0))
	await wait_physics_frames(2)
	classes._walked = 0.0


## Lets the grace after the bell pass and judges.
func _judge() -> void:
	classes.since_start = SchoolClasses.GRACE + 0.1
	classes.judge()


func test_the_first_class_comes_after_a_warning_and_they_go_in_turn() -> void:
	assert_false(classes.in_class())
	classes._lead(SchoolClasses.FIRST - SchoolClasses.WARNING + 0.1)
	assert_eq(school.teacher.said(), "GANZUA_BELL_SOON")
	classes._lead(SchoolClasses.WARNING)
	assert_true(classes.in_class())
	var first := classes.subject
	assert_has(SchoolClasses.SUBJECTS, first)
	assert_eq(school.teacher.said(), "GANZUA_CLASS_" + first.to_upper())
	var seen := [first]
	for i in 2:
		classes.class_left = 0.0
		classes.start_class()
		assert_false(seen.has(classes.subject), "a different subject each time")
		seen.append(classes.subject)


func test_picking_a_lock_still_is_right() -> void:
	classes.start_class("lockpick")
	var lock := SchoolHall.LOCKS[0]
	await _at(Vector3(lock.x - 0.6, 0, lock.z))
	classes.force_using = true
	_judge()
	assert_eq(classes.good_seconds, 1)
	classes.force_using = false
	_judge()
	assert_eq(classes.bad_seconds, 1, "without holding E")


func test_away_from_the_locks_is_wrong() -> void:
	classes.start_class("lockpick")
	await _at(Vector3(6.0, 0, 5.0))
	classes.force_using = true
	_judge()
	assert_eq(classes.bad_seconds, 1)


func test_pickpocketing_crouched_by_the_dummy() -> void:
	classes.start_class("pickpocket")
	await _at(SchoolHall.DUMMY_AT + Vector3(0, 0, 0.8))
	_judge()
	assert_eq(classes.bad_seconds, 1, "standing up, the bells ring")
	cop.set_crouching(true)
	_judge()
	assert_eq(classes.good_seconds, 1)


func test_sneaking_moves_only_with_her_back_turned() -> void:
	classes.start_class("sneak")
	await _at(Vector3(SchoolHall.CREAKY.get_center().x, 0, SchoolHall.CREAKY.get_center().y))
	classes._set_watching(false)
	classes._walked = 1.0
	_judge()
	assert_eq(classes.good_seconds, 1, "moving with her back turned")
	classes._set_watching(true)
	classes._walked = 1.0
	_judge()
	assert_eq(classes.bad_seconds, 1, "moving while she looks")
	classes._walked = 0.0
	_judge()
	assert_eq(classes.good_seconds, 2, "frozen while she looks")


func test_the_profesora_turns_around_during_sneaking() -> void:
	classes.start_class("sneak")
	assert_false(classes.watching, "her back turned first")
	classes._lead(SchoolClasses.TURN.y + 0.1)
	assert_true(classes.watching)
	assert_eq(school.teacher.said(), "GANZUA_LOOKING")


func test_skipping_class_inside_the_school_is_wrong() -> void:
	classes.start_class("lockpick")
	await _at(Vector3(-7.0, 0, -5.0))
	_judge()
	assert_eq(classes.bad_seconds, 1, "in the library")


func test_grades_go_from_one_to_ten() -> void:
	assert_eq(SchoolClasses.grade_of(0, 0), 1)
	assert_eq(SchoolClasses.grade_of(0, 14), 1)
	assert_eq(SchoolClasses.grade_of(14, 0), 10)
	assert_eq(SchoolClasses.grade_of(7, 7), 6)


func test_the_class_ends_with_a_grade_the_host_keeps() -> void:
	classes.start_class("lockpick")
	await _at(Vector3(-6.0, 0, 5.0))
	classes.good_seconds = 12
	classes.bad_seconds = 2
	watch_signals(classes)
	classes.class_left = 0.01
	classes._process(0.02)
	assert_false(classes.in_class())
	assert_eq(classes.last_grade, SchoolClasses.grade_of(12, 2))
	assert_eq(classes.grades["lockpick"][cop.uniform], classes.last_grade)
	assert_almost_eq(classes.average("lockpick"), float(classes.last_grade), 0.01)
	assert_signal_not_emitted(classes, "missed", "a good grade raises nobody")
	classes.record(cop, "lockpick", 2)
	assert_eq(classes.grades["lockpick"][cop.uniform], classes.last_grade, "the best one stays")


func test_a_low_grade_raises_the_students_who_see_it() -> void:
	cop.put_on_disguise("thief_mask", 0.0)
	cop.put_on_disguise("thief_shirt", 0.0)
	await _at(Vector3(-9.0, 0, 5.0))
	var seen := school.members.filter(func(m: ClubMember) -> bool: return m.sees_cop(cop))
	assert_false(seen.is_empty(), "the students face the board")
	var before: float = seen[0].suspicion
	watch_signals(classes)
	classes.record(cop, "pickpocket", SchoolClasses.LOW_GRADE)
	assert_signal_emitted_with_parameters(classes, "missed", [cop, SchoolClasses.LOW_GRADE_SUSPICION])
	assert_gt(seen[0].suspicion, before)


func test_outside_the_school_nothing_counts() -> void:
	classes.start_class("lockpick")
	await _at(Vector3(0, 0, SchoolHall.HALF_Z + 4.0))
	_judge()
	assert_eq(classes.good_seconds + classes.bad_seconds, 0)
	classes.class_left = 0.01
	classes._process(0.02)
	assert_eq(classes.grades["lockpick"].size(), 0, "no grade")


func test_the_class_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["GANZUA_BELL_SOON", "GANZUA_LOOKING", "GANZUA_BACK_TURNED", "SCHOOL_LOOKING",
		"SCHOOL_BACK_TURNED", "SCHOOL_GOOD", "SCHOOL_NOT_IN_CLASS", "SCHOOL_GO_TO_LOCK", "SCHOOL_NOT_PICKING",
		"SCHOOL_GO_TO_DUMMY", "SCHOOL_BELLS", "SCHOOL_GO_TO_FLOOR", "SCHOOL_SEEN_MOVING", "SCHOOL_YOUR_GRADE"]
	for kind: String in SchoolClasses.SUBJECTS:
		for start: String in ["GANZUA_CLASS_", "SCHOOL_CLASS_", "SCHOOL_HOW_", "HINT_SCHOOL_"]:
			keys.append(start + kind.to_upper())
	for key in keys:
		assert_ne(tr(key), key)
