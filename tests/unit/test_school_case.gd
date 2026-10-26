extends GutTest

## The thieves' school's case (infiltracion-escuela.md, step 4, decision 173): the infiltration case with the school's
## texts, 3 of its 6 pieces of evidence by the seed (the homework on the Profesora's desk, the bank's plan on the
## classroom's back board, the register in the library, the students' video, the loot in the yard's trunk and the
## diploma in the locked office, whose key is in the Profesora's drawer), the report card in the planilla and the
## graduation, when the Director comes down to be cuffed.

const LEVEL := preload("res://scenes/levels/school_hall.tscn")

var school: SchoolHall
var cop: Cop


## A school whose seed has the evidence `kind`.
func _school_with(kind: String) -> void:
	var case_seed := 1
	while true:
		school = LEVEL.instantiate()
		school.case_seed = case_seed
		school.get_node("Cop").input_enabled = false
		add_child_autofree(school)
		if school.evidence.kinds.has(kind):
			break
		school.free()
		case_seed += 1
	cop = school.get_node("Cop")
	await wait_physics_frames(2)
	school.classes.set_process(false)
	school.case.give_tip()


## The host got `grade` from the cop in every subject.
func _grade_all(grade: int) -> void:
	for kind: String in SchoolClasses.SUBJECTS:
		school.classes.record(cop, kind, grade)


func test_the_school_case_with_its_own_texts() -> void:
	await _school_with("homework")
	assert_eq(school.case.place, school)
	assert_eq(school.case.texts(), InfiltrationCase.VARIANTS["school"])
	assert_eq(school.case.rows()[0].text, "OBJ_SCHOOL_GET_IN")
	assert_eq(school.evidence.kinds.size(), ClubEvidence.COUNT)
	for kind: String in school.evidence.kinds:
		assert_has(SchoolHall.EVIDENCE_KINDS, kind)


func test_grabbing_the_homework_on_the_profesoras_desk() -> void:
	await _school_with("homework")
	var homework: Grabbable = school.evidence.items["homework"]
	assert_true(school.in_classroom(homework.global_position))
	cop.global_position = homework.global_position + Vector3(0, -0.8, 1.0)
	cop.get_node("Grabber").grab(homework)
	await wait_physics_frames(2)
	assert_has(school.case.evidence_found, "homework")


func test_the_office_key_is_in_the_profesoras_drawer() -> void:
	await _school_with("homework")
	var drawer: KeyPot = school.get_node("KeyDrawer")
	assert_true(school.in_classroom(drawer.global_position))
	assert_eq(drawer.prompt_key(cop), "PROMPT_SCHOOL_DRAWER")
	assert_true(school.office_door.locked)
	drawer.use(cop)
	assert_true(cop.has_key)


func test_grabbing_the_loot_in_the_yards_trunk() -> void:
	await _school_with("loot")
	var loot: Grabbable = school.evidence.items["loot"]
	assert_true(school.in_yard(loot.global_position))
	cop.global_position = loot.global_position + Vector3(0, -0.5, 1.0)
	cop.get_node("Grabber").grab(loot)
	await wait_physics_frames(2)
	assert_has(school.case.evidence_found, "loot")


func test_photographing_the_board_and_the_diploma_and_searching_the_shelf() -> void:
	await _school_with("board")
	var board: ClubEvidenceSpot = school.get_node("Evidence_board")
	assert_true(school.in_classroom(board.global_position))
	board.use(cop)
	assert_false(school.case.evidence_found.has("board"), "E isn't a photo")
	board.photographed(cop)
	assert_has(school.case.evidence_found, "board")
	await _school_with("diploma")
	var diploma: ClubEvidenceSpot = school.get_node("Evidence_diploma")
	assert_true(school.in_back_room(diploma.global_position), "in the Director's office")
	diploma.photographed(cop)
	assert_has(school.case.evidence_found, "diploma")
	await _school_with("register")
	var shelf: ClubEvidenceSpot = school.get_node("Evidence_register")
	assert_true(school.in_library(shelf.global_position))
	shelf.use(cop)
	assert_has(school.case.evidence_found, "register")


func test_the_recording_students_sit_by_each_other() -> void:
	await _school_with("recording")
	assert_eq(school.evidence.talkers.size(), 2)
	var apart := school.evidence.talkers[0].global_position.distance_to(school.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_the_report_card_in_the_planilla() -> void:
	await _school_with("homework")
	var expected := tr("SCHOOL_REPORT_ROW") % [tr("SCHOOL_NO_GRADE"), tr("SCHOOL_NO_GRADE"), tr("SCHOOL_NO_GRADE"),
		SchoolClasses.GRADUATE]
	assert_eq(school.clue_row([], false), expected)
	school.classes.record(cop, "lockpick", 8)
	assert_string_contains(school.clue_row([], false), "8.0")
	assert_true(school.case.rows().any(func(row: Dictionary) -> bool: return row.text == school.clue_row([], false)))


func test_low_grades_dont_graduate() -> void:
	await _school_with("homework")
	_grade_all(6)
	assert_false(school.classes.graduation_due)
	school.classes.record(cop, "lockpick", 9)
	school.classes.record(cop, "pickpocket", 9)
	assert_false(school.classes.graduation_due, "sneaking is still a 6")
	school.classes.record(cop, "sneak", 7)
	assert_true(school.classes.graduation_due)


func test_good_grades_make_the_next_bell_the_graduation() -> void:
	await _school_with("homework")
	assert_false(school.director.visible, "the Director waits unseen")
	assert_eq(school.director.collision_layer, 0)
	_grade_all(8)
	school.classes.next_left = SchoolClasses.WARNING + 0.05
	school.classes._lead(0.1)
	assert_eq(school.teacher.said(), "GANZUA_GRADUATION_SOON")
	school.classes._lead(SchoolClasses.WARNING)
	assert_true(school.classes.graduated)
	assert_false(school.classes.in_class(), "no class: the graduation")
	assert_true(school.director.visible)
	assert_eq(school.director.collision_layer, 8)
	assert_true(school.in_classroom(school.director.global_position), "down in the classroom")
	assert_eq(school.director.said(), "DIRECTOR_GRADUATION")
	assert_eq(school.clue_row([], false), tr("SCHOOL_GRADUATED_ROW"))
	school.classes.next_left = 0.0
	school.classes._lead(1.0)
	assert_false(school.classes.in_class(), "no more classes")


func test_the_director_stays_hidden_if_they_were_found_out() -> void:
	await _school_with("homework")
	school.members[0].cuffed(5.0)
	assert_true(school.suspicion.found_out)
	school.classes.start_graduation()
	assert_false(school.director.visible)


func test_cuffing_the_director_solves_it() -> void:
	await _school_with("homework")
	school.classes.start_graduation()
	for kind: String in school.evidence.kinds.slice(0, 2):
		school.case.found(kind)
	school.director.cuffed(20.0)
	assert_true(school.case.solved())
	assert_eq(school.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(school.case.custody().owner, "director")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_director"))
	assert_true(ChaseSuspect.MODELS.has("director"))


func test_cuffing_the_profesora_gives_them_away() -> void:
	await _school_with("homework")
	school.teacher.cuffed(5.0)
	assert_true(school.suspicion.found_out)


func test_the_case_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_GO_SCHOOL", "HINT_SCHOOL_IN", "HINT_DIRECTOR_CUFFED", "HINT_ESCAPE_director",
		"OBJ_SCHOOL_GET_IN", "OBJ_SCHOOL_EVIDENCE", "OBJ_SCHOOL_CUFF_DIRECTOR", "OBJ_SCHOOL_CATCH_DIRECTOR",
		"OBJ_SCHOOL_CAREFUL", "OBJ_SCHOOL_FOUND_OUT", "PROMPT_SCHOOL_DRAWER", "PROMPT_SCHOOL_board",
		"PROMPT_SCHOOL_register", "PROMPT_SCHOOL_diploma", "CRIME_owner_director", "CONFESS_owner_director",
		"GANZUA_GRADUATION_SOON", "GANZUA_GRADUATION", "DIRECTOR_GRADUATION", "HINT_SCHOOL_GRADUATION",
		"SCHOOL_REPORT_ROW", "SCHOOL_GRADUATED_ROW"]
	keys.append_array(InfiltrationCase.VARIANTS["school"].brief)
	for kind: String in SchoolHall.EVIDENCE_KINDS:
		keys.append("EVIDENCE_SCHOOL_" + kind)
	for i in 4:
		keys.append("SCHOOL_TALK_%d" % i)
	for i in 3:
		keys.append("DIRECTOR_SLIP_%d" % (i + 1))
		keys.append("CHASE_DIRECTOR_LINE_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
