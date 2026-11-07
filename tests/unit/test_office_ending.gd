extends GutTest

## The office's ending (escena-oficina.md, step 5): the culprit who runs off goes in the water truck, dropping jugs off
## its back (SuspectCar, ChaseDrops, ChaseJug); one run over bursts and the patrol car skids on the water for 2 s; and
## the employee is interrogated as one.

const LEVEL := preload("res://scenes/levels/forms_office.tscn")


func test_the_water_truck_is_a_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.office.getaway, SuspectCar.WATER_TRUCK)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.WATER_TRUCK))
	assert_false(SuspectCar.SPEEDS.has(SuspectCar.WATER_TRUCK), "at the usual speed")
	assert_true(ChaseSuspect.MODELS.has("employee"), "they get out as an employee")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_employee"), "and are interrogated as one")
	for key: String in ["CRIME_owner_employee", "CONFESS_owner_employee", "HINT_ESCAPE_employee", "PROMPT_MOVE_JUG",
			"HINT_JUG_MOVED"]:
		assert_ne(tr(key), key)


func test_the_truck_waits_at_the_curb_and_drives_out() -> void:
	var office := FormsOffice.new()
	add_child_autofree(office)
	var getaway := office.getaway(0, null)
	var at := office.to_local((getaway.at as Transform3D).origin)
	assert_gt(at.z - SuspectCar.SIZES[SuspectCar.WATER_TRUCK].z / 2, FormsOffice.FRONT_Z, "clear of the building")
	assert_gt(absf(at.x - FormsOffice.DOOR_FRONT_X), 3.0, "not in front of the door")
	assert_gt(office.to_local(getaway.via[0] as Vector3).z, at.z, "out into the street")


func test_a_jug_is_moved_aside_or_run_over() -> void:
	var drops := ChaseDrops.new()
	var moved := ChaseJug.new()
	add_child(moved)
	assert_eq(moved.prompt_key(null), "PROMPT_MOVE_JUG")
	moved.use(null)
	assert_true(moved.is_queued_for_deletion())
	var car := Node3D.new()
	add_child_autofree(car)
	var jug := ChaseJug.new()
	jug.car = car
	jug.drops = drops
	jug.freeze = true
	add_child(jug)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_false(is_instance_valid(jug), "the patrol car went over it fast")
	assert_eq(drops.soaked_left, ChaseJug.WET_SECONDS, "water under the tires")
	drops.free()


func test_the_culprit_runs_off_in_the_water_truck_and_the_car_skids() -> void:
	var level: FormsOfficeLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.WATER_TRUCK)
	assert_eq(chase.who, "employee")
	var jug := chase.drops.drop_jug()
	assert_eq(jug.car, chase.car)
	assert_has(chase.drops.jugs, jug)
	assert_gt(jug.linear_velocity.length(), 0.0, "it rolls off the back")
	await wait_physics_frames(2)
	var dry := chase.car.grip
	chase.drops.soaked_left = 1.0
	await wait_physics_frames(2)
	assert_lt(chase.car.grip, dry, "the wet tires skid")
	chase.drops.soaked_left = 0.0
	await wait_physics_frames(2)
	assert_eq(chase.car.grip, dry, "and grip again once dry")
