extends GutTest

## Maestra Pausa's getaway (infiltracion-mimos.md, step 6, decision 170): found out, she runs off on foot "driving"
## an invisible car and the chase starts in the middle of the case; caught, it's solved with the evidence they have.
## In Play the mimes' theater is one of the infiltrations.

const LEVEL := preload("res://scenes/levels/mime_theater.tscn")

var theater: MimeTheater


func before_each() -> void:
	Campaign.current = null
	theater = LEVEL.instantiate()
	theater.get_node("Cop").input_enabled = false
	add_child_autofree(theater)
	await wait_physics_frames(2)
	theater.rehearsal.set_process(false)
	theater.case.give_tip()


func test_found_out_pausa_runs_off_in_the_invisible_car() -> void:
	theater.suspicion.raise(theater.members[0], 100.0)
	assert_not_null(theater.case.chase)
	assert_eq(theater.case.chase.suspect_id, SuspectCar.INVISIBLE_CAR)
	assert_eq(theater.case.chase.who, "pausa")
	assert_false(theater.pausa.visible, "she left the theater")


func test_the_invisible_car_is_a_chase_on_foot_at_a_run() -> void:
	assert_true(ChaseCase.ON_FOOT.has(SuspectCar.INVISIBLE_CAR))
	assert_true(ChaseCase.CLOSE_BY.has(SuspectCar.INVISIBLE_CAR))
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.INVISIBLE_CAR], 14.0 / 3.6, 0.01)
	assert_false(SuspectCar.LANES.has(SuspectCar.INVISIBLE_CAR), "she drives it down the street, not the sidewalk")


func test_pausa_rides_it_where_the_cops_can_see_her() -> void:
	theater.suspicion.raise(theater.members[0], 100.0)
	var car: SuspectCar = theater.case.chase.truck
	assert_eq(car.kind, SuspectCar.INVISIBLE_CAR)
	assert_eq(SuspectCar.RIDERS[SuspectCar.INVISIBLE_CAR].size(), 1)


func test_caught_it_counts_as_solved_with_the_evidence() -> void:
	theater.case.found("box")
	theater.suspicion.raise(theater.members[0], 100.0)
	theater.case._on_chase_ended(true)
	assert_true(theater.case.solved())
	assert_eq(theater.case.report().salary, InfiltrationCase.SALARY / 3)


func test_play_draws_the_theater_among_the_infiltrations() -> void:
	assert_has(PlaceDraw.INFILTRATIONS, "mime")
