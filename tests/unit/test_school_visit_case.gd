extends GutTest

## The school visit as a case (politico-escuela.md, step 7, decision 210): the group photo solves it, eight gaffes lose
## it, the pay counts gaffes, crying pupils and the janitor, and a loose janitor rides off on his floor polisher waxing
## the sidewalk.

const LEVEL := preload("res://scenes/levels/school_visit.tscn")

var school: SchoolVisitLevel
var case: SchoolCase


func before_each() -> void:
	school = LEVEL.instantiate()
	school.case_seed = 7
	school.get_node("Cop").input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)
	case = school.case


func test_the_comisario_tells_it_in_his_office() -> void:
	assert_false(case.tip_given, "not before seeing him")
	case.give_tip()
	assert_true(case.tip_given)


func test_the_photo_solves_it() -> void:
	school.janitor.cuffed(Handcuffs.SECONDS)
	school.tour.finished.emit()
	assert_true(case.photo_done)
	assert_true(case.solved())
	assert_null(case.chase, "the janitor is cuffed: nobody runs")
	await wait_seconds(SchoolCase.SHIFT_DELAY + 0.5)
	assert_true(case.shift_over)


func test_leaving_ashamed_loses_it() -> void:
	school.questions.shamed.emit()
	assert_true(case.shamed)
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)
	school.tour.finished.emit()
	assert_false(case.photo_done, "no photo once he's gone")


func test_the_pay_counts_gaffes_crying_and_the_janitor() -> void:
	case.photo_done = true
	school.questions.gaffes = 4
	school.pupils[0].cried.emit(school.pupils[0])
	school.pupils[1].cried.emit(school.pupils[1])
	assert_eq(case.cried, 2)
	var expected := SchoolCase.SALARY - 4 * SchoolCase.PER_GAFFE - 2 * SchoolCase.PER_CRY
	assert_eq(case.report().salary, expected)
	assert_false(case.report().approved, "four gaffes and two crying leave it under the quota")
	OwnerEscort.of(school.janitor).boarded.emit()
	var pay := case.report()
	assert_eq(pay.salary, expected + SchoolCase.JANITOR)
	assert_eq(pay.quota, SchoolCase.QUOTA)
	assert_true(pay.approved, "the janitor detained brings it back over")


func test_a_loose_janitor_rides_off_on_the_polisher() -> void:
	var janitor := school.janitor
	school.tour.finished.emit()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.FLOOR_POLISHER)
	assert_eq(case.chase.who, "janitor")
	assert_false(janitor.visible, "he left on it")
	assert_false(case.shift_over, "the shift waits for the chase")
	case._on_chase_ended(true)
	assert_true(case.janitor_detained(), "caught, he counts as detained")
	case._on_chase_ended(false)
	assert_false(case.janitor_detained())
	assert_true(case.solved(), "got away, it's solved all the same")


func test_the_polisher_waxes_the_sidewalk() -> void:
	school.tour.finished.emit()
	var wax := case.chase.drops.drip()
	assert_eq((wax.mesh.material as StandardMaterial3D).albedo_color, ChaseDrops.PUDDLE_COLORS[ChaseDrops.WAX])
	assert_true(case.chase.drops.on_puddle(wax.global_position), "as slippery as ice cream")
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.FLOOR_POLISHER], 14.0 / 3.6, 0.01)
	assert_eq(SuspectCar.LANES[SuspectCar.FLOOR_POLISHER], ChaseRoute.SIDEWALK_LANE)
	assert_has(ChaseCase.ON_FOOT, SuspectCar.FLOOR_POLISHER)
	assert_true(ChaseSuspect.MODELS.has("janitor"))


func test_the_planilla_shows_the_gaffes() -> void:
	school.questions.gaffes = 2
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, tr("OBJ_SCHOOL_GAFFES") % [2, SchoolQuestions.MAX_GAFFES])
	assert_has(texts, "OBJ_SCHOOL_JANITOR")


func test_play_draws_it() -> void:
	var found := false
	for i in 3000:
		if PlaceDraw.pick(i + 1, [], 1) == "school_visit":
			found = true
			break
	assert_true(found)
