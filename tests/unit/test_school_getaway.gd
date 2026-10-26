extends GutTest

## The Director's getaway (infiltracion-escuela.md, step 5, decision 173): found out, he drives off in the school's
## learner car, slowly (35 km/h) and stalling it for 2 s every 6 s of driving, and the chase starts in the middle of
## the case; caught, it's solved with the evidence they have. In Play the school is one of the six infiltrations.

const LEVEL := preload("res://scenes/levels/school_hall.tscn")

var school: SchoolHall


func before_each() -> void:
	Campaign.current = null
	school = LEVEL.instantiate()
	school.get_node("Cop").input_enabled = false
	add_child_autofree(school)
	await wait_physics_frames(2)
	school.classes.set_process(false)
	school.case.give_tip()


func test_found_out_the_director_drives_off_in_the_learner_car() -> void:
	school.suspicion.raise(school.members[0], 100.0)
	assert_not_null(school.case.chase)
	assert_eq(school.case.chase.suspect_id, SuspectCar.LEARNER_CAR)
	assert_eq(school.case.chase.who, "director")
	assert_false(school.director.visible, "he isn't in the school")
	var car: SuspectCar = school.case.chase.truck
	assert_eq(car.kind, SuspectCar.LEARNER_CAR)
	assert_not_null(car.get_node("Rider"), "the Director at the wheel")


func test_found_out_after_the_graduation_too() -> void:
	school.classes.start_graduation()
	assert_true(school.director.visible)
	school.suspicion.raise(school.members[0], 100.0)
	assert_eq(school.case.chase.suspect_id, SuspectCar.LEARNER_CAR)
	assert_false(school.director.visible, "he left the classroom")


func test_the_learner_car_is_slow_and_a_car() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.LEARNER_CAR], 35.0 / 3.6, 0.01)
	assert_lt(SuspectCar.SPEEDS[SuspectCar.LEARNER_CAR], SuspectCar.SPEED, "slower than a getaway car")
	assert_false(ChaseCase.ON_FOOT.has(SuspectCar.LEARNER_CAR), "chased in the patrol car")


func test_it_stalls_every_so_often_and_stops() -> void:
	var car := SuspectCar.new()
	car.kind = SuspectCar.LEARNER_CAR
	car.points.assign([Vector3.ZERO, Vector3(0, 0, 500)])
	car.next = 1
	add_child_autofree(car)
	assert_false(car.is_stalled())
	car._stall(SuspectCar.STALL_EVERY - 0.1)
	assert_false(car.is_stalled())
	car._stall(0.2)
	assert_true(car.is_stalled(), "it stalled")
	assert_true(car.get_node("Stalled").visible, "and it shows")
	car._physics_process(0.016)
	assert_almost_eq(Vector2(car.velocity.x, car.velocity.z).length(), 0.0, 0.01, "stopped while stalled")
	car._stall(SuspectCar.STALL_TIME)
	assert_false(car.is_stalled(), "it starts again")
	assert_false(car.get_node("Stalled").visible)


func test_caught_it_counts_as_solved_with_the_evidence() -> void:
	school.case.found(school.evidence.kinds[0])
	school.suspicion.raise(school.members[0], 100.0)
	school.case._on_chase_ended(true)
	assert_true(school.case.solved())
	assert_eq(school.case.report().salary, InfiltrationCase.SALARY / 3)


func test_play_draws_the_school_among_the_infiltrations() -> void:
	assert_has(PlaceDraw.INFILTRATIONS, "school")
	assert_eq(PlaceDraw.PLACES.get("school"), "res://scenes/levels/school_hall.tscn")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "school":
			drawn = true
			break
	assert_true(drawn)
	TranslationServer.set_locale("es")
	assert_ne(tr("LEARNER_SIGN"), "LEARNER_SIGN")
	assert_ne(tr("LEARNER_STALLED"), "LEARNER_STALLED")
