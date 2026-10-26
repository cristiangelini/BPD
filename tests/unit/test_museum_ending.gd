extends GutTest

## The museum's ending (escena-museo.md, step 5): the culprit who runs off goes in the art van, dropping empty frames
## (SuspectCar, ChaseDrops, ChaseFrame); each frame the patrol car breaks comes off the salary; and he's interrogated as
## a guard.

const LEVEL := preload("res://scenes/levels/museum.tscn")


func _case(seed_value := 7) -> CrimeSceneCase:
	var museum := Museum.new()
	museum.case_seed = seed_value
	add_child_autofree(museum)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = museum
	add_child_autofree(case)
	case.start()
	return case


func test_the_art_van_is_a_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.museum.getaway, SuspectCar.ART_VAN)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.ART_VAN))
	assert_false(SuspectCar.SPEEDS.has(SuspectCar.ART_VAN), "at the usual speed")
	assert_true(ChaseSuspect.MODELS.has("guard"), "he gets out as a guard")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_guard"), "and is interrogated as one")
	assert_ne(tr("CRIME_owner_guard"), "CRIME_owner_guard")


func test_the_van_waits_beside_the_steps_and_drives_out() -> void:
	var case := _case()
	var museum := case.place as Museum
	var getaway := museum.getaway(case.plan.culprit, null)
	var at := museum.to_local((getaway.at as Transform3D).origin)
	assert_true(museum.at_scene(museum.to_global(at)))
	assert_gt(absf(at.x), 8.0, "not on the steps")
	assert_gt(museum.to_local(getaway.via[0] as Vector3).z, Museum.SIZE.y / 2, "out into the street")


func test_broken_frames_come_off_the_salary() -> void:
	var case := _case()
	case.accused = true
	case.frame_broken()
	case.frame_broken()
	case.finish_shift()
	assert_eq(case._result.report.fines, 2 * CrimeSceneCase.FRAME_FINE)
	assert_eq(case._result.report.total, ShiftReport.SALARY - 2 * CrimeSceneCase.FRAME_FINE)


func test_a_frame_is_moved_aside_or_run_over() -> void:
	var case := _case()
	var moved := ChaseFrame.new()
	add_child(moved)
	assert_eq(moved.prompt_key(null), "PROMPT_MOVE_FRAME")
	moved.use(null)
	assert_true(moved.is_queued_for_deletion())
	assert_eq(case.frames_broken, 0, "moved aside, not broken")
	var car := Node3D.new()
	add_child_autofree(car)
	var frame := ChaseFrame.new()
	frame.car = car
	add_child(frame)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_false(is_instance_valid(frame), "the patrol car went over it fast")
	assert_eq(case.frames_broken, 1)


func test_the_culprit_runs_off_in_the_art_van() -> void:
	var level: MuseumLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.ART_VAN)
	assert_eq(chase.who, "guard")
	var frame := chase.drops.drop_frame()
	assert_true(frame is ChaseFrame)
	assert_eq(frame.car, chase.car)
	assert_has(chase.drops.frames, frame)
