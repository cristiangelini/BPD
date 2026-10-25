extends GutTest

## The circus's ending (escena-circo.md, step 7): the clowns get tired and leave, finding the loot adds to the salary,
## and the culprit who runs off goes in the clown car, dropping inflatable clowns (SuspectCar, ChaseDrops, ChaseDummy).

const LEVEL := preload("res://scenes/levels/circus.tscn")


func _case(seed_value := 7) -> CrimeSceneCase:
	var circus := Circus.new()
	circus.case_seed = seed_value
	add_child_autofree(circus)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = circus
	add_child_autofree(case)
	case.start()
	return case


func test_the_clown_car_is_a_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.circus.getaway, SuspectCar.CLOWN_CAR)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SPEEDS, SuspectCar.SIZES,
			SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.CLOWN_CAR))
	assert_almost_eq(SuspectCar.SPEEDS.clown_car as float, 30.0 / 3.6, 0.01, "30 km/h")
	assert_true(ChaseSuspect.MODELS.has("clown"), "he gets out as a clown")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_clown"), "and is interrogated as one")


func test_the_car_waits_at_the_lots_front_and_drives_out() -> void:
	var case := _case()
	var circus := case.place as Circus
	var getaway := circus.getaway(case.plan.culprit, null)
	var at := circus.to_local((getaway.at as Transform3D).origin)
	assert_almost_eq(at.z, Circus.SIZE.y / 2 - 1.5, 0.01)
	var out := circus.to_local(getaway.via[0] as Vector3)
	assert_gt(out.z, Circus.SIZE.y / 2, "out into the street")


func test_a_tired_clown_leaves_and_skips_the_trick() -> void:
	var case := _case()
	var circus := case.place as Circus
	case._tire()
	assert_eq(case.gone.size(), 1)
	var gone := circus.clowns[case.gone[0]]
	assert_false(gone.visible)
	assert_does_not_have(circus.trick._here(), gone.index)


func test_the_loot_adds_to_the_salary() -> void:
	var case := _case()
	var circus := case.place as Circus
	case.accused = true
	circus.search(circus.loot_spot, null)
	case.finish_shift()
	assert_eq(case._result.report.evidence, int(CrimeSceneCase.LOOT_BONUS))
	assert_eq(case._result.report.salary, ShiftReport.SALARY)


func test_without_the_loot_just_the_salary() -> void:
	var case := _case()
	case.accused = true
	case.finish_shift()
	assert_eq(case._result.report.evidence, 0)


func test_a_dummy_pops() -> void:
	var dummy := ChaseDummy.new()
	add_child(dummy)
	assert_eq(dummy.prompt_key(null), "PROMPT_POP_DUMMY")
	dummy.use(null)
	assert_true(dummy.popped)
	assert_true(dummy.is_queued_for_deletion())


func test_the_culprit_runs_off_in_the_clown_car() -> void:
	var level: CircusLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.CLOWN_CAR)
	assert_eq(chase.who, "clown")
	assert_true(chase.drops.kids_bubble != null, "honking all the way")
	var dummy := chase.drops.drop_dummy()
	assert_true(dummy is ChaseDummy)
	assert_has(chase.drops.dummies, dummy)
