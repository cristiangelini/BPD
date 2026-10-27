extends GutTest

## The hotel's ending (escena-hotel.md, step 5): the culprit who runs off goes in the hotel's shuttle, dropping
## suitcases off its roof (SuspectCar, ChaseDrops, ChaseSuitcase); one run over covers the patrol car's windshield in
## clothes for 2 s; and the guest is interrogated as one.

const LEVEL := preload("res://scenes/levels/hotel.tscn")


func test_the_shuttle_is_a_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.hotel.getaway, SuspectCar.HOTEL_SHUTTLE)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.HOTEL_SHUTTLE))
	assert_false(SuspectCar.SPEEDS.has(SuspectCar.HOTEL_SHUTTLE), "at the usual speed")
	assert_true(ChaseSuspect.MODELS.has("guest"), "they get out as a guest")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_guest"), "and are interrogated as one")
	for key: String in ["CRIME_owner_guest", "CONFESS_owner_guest", "HINT_ESCAPE_guest"]:
		assert_ne(tr(key), key)


func test_the_shuttle_waits_at_the_curb_and_drives_out() -> void:
	var hotel := Hotel.new()
	add_child_autofree(hotel)
	var getaway := hotel.getaway(0, null)
	var at := hotel.to_local((getaway.at as Transform3D).origin)
	assert_gt(at.z - SuspectCar.SIZES[SuspectCar.HOTEL_SHUTTLE].z / 2, Hotel.FRONT_Z, "clear of the building")
	assert_gt(absf(at.x - Hotel.DOOR_FRONT_X), 3.0, "not in front of the door")
	assert_gt(hotel.to_local(getaway.via[0] as Vector3).z, at.z, "out into the street")


func test_a_suitcase_is_moved_aside_or_run_over() -> void:
	var drops := ChaseDrops.new()
	var moved := ChaseSuitcase.new()
	add_child(moved)
	assert_eq(moved.prompt_key(null), "PROMPT_MOVE_SUITCASE")
	moved.use(null)
	assert_true(moved.is_queued_for_deletion())
	var car := Node3D.new()
	add_child_autofree(car)
	var suitcase := ChaseSuitcase.new()
	suitcase.car = car
	suitcase.drops = drops
	add_child(suitcase)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_false(is_instance_valid(suitcase), "the patrol car went over it fast")
	assert_eq(drops.laundry_left, ChaseSuitcase.LAUNDRY_SECONDS, "clothes on the windshield")
	drops.free()


func test_the_culprit_runs_off_in_the_shuttle() -> void:
	var level: HotelLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.HOTEL_SHUTTLE)
	assert_eq(chase.who, "guest")
	var suitcase := chase.drops.drop_suitcase()
	assert_eq(suitcase.car, chase.car)
	assert_has(chase.drops.suitcases, suitcase)
	chase.drops.laundry_left = 1.0
	await wait_physics_frames(2)
	var cover := chase.car.get_node_or_null("ConfettiCover") as Node3D
	assert_true(cover != null and cover.visible, "the windshield is covered")
