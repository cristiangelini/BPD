extends GutTest

## The wedding's ending (escena-boda.md, step 6): the level with its board; Tito never goes home tired; the culprit who
## runs off goes in the newlyweds' car with its cans (WeddingCar, ChaseDrops); the family's complaint comes off the
## salary; and he's interrogated as a tuxedo.

const LEVEL := preload("res://scenes/levels/wedding.tscn")


func _case(seed_value := 7) -> CrimeSceneCase:
	var hall := WeddingHall.new()
	hall.case_seed = seed_value
	add_child_autofree(hall)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hall
	add_child_autofree(case)
	case.start()
	return case


func test_the_newlyweds_car_is_a_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.wedding.getaway, WeddingHall.GETAWAY)
	assert_true(SuspectCar.MODELS.has(WeddingHall.GETAWAY))
	assert_true(ChaseSuspect.MODELS.has("tuxedo"), "he gets out in his tuxedo")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_tuxedo"), "and is interrogated in it")
	for key: String in ["HINT_ESCAPE_tuxedo", "CRIME_owner_tuxedo", "CONFESS_owner_tuxedo", "CHASE_TUXEDO_LINE_1"]:
		assert_ne(tr(key), key)


func test_the_car_waits_on_the_street_in_front() -> void:
	var case := _case()
	var hall := case.place as WeddingHall
	var at := hall.to_local((hall.getaway(case.plan.culprit, null).at as Transform3D).origin)
	assert_gt(at.z, WeddingHall.HALF_Z, "out on the street")
	assert_lt(absf(at.x), WeddingHall.HALF_X)


func test_tito_never_goes_home() -> void:
	var case := _case()
	for i in WeddingTraits.COUNT:
		case._tire()
	assert_eq(case.gone.size(), WeddingTraits.COUNT - 1, "the five groomsmen leave")
	assert_false(case.gone.has(WeddingTraits.GROOM), "Tito stays: it's his wedding")
	assert_true((case.place as WeddingHall).tuxedos[0].visible)


func test_the_complaint_comes_off_the_salary() -> void:
	var case := _case()
	case.accused = true
	case.complaint = 25
	case.finish_shift()
	assert_eq(case._result.report.fines, 25)
	assert_eq(case._result.report.total, ShiftReport.SALARY - 25)


func test_the_culprit_runs_off_in_the_newlyweds_car() -> void:
	var level: WeddingLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_not_null(level.board, "the board is in the station")
	assert_eq(level.case.place, level.hall)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, WeddingHall.GETAWAY)
	assert_true(chase.truck.has_node("Cans"), "the cans behind")
	assert_true(chase.truck.has_node("JustMarried"), "and the board")
	assert_false(chase.truck.has_node("Groom"), "nobody else in it")
	assert_true(chase.drops.wedding, "the cans come loose at the corners")
	assert_eq(chase.who, "tuxedo")
