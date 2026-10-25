extends GutTest

## The laundry's washers and dryers: the inmate who squeezes in, slips into a cart on the next trip, or falls out dizzy
## (carcel-lavanderia.md, step 5).

const LEVEL := preload("res://scenes/levels/prison_laundry.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: LaundryPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.laundry


func test_six_machines_against_the_east_wall() -> void:
	assert_eq(plan.machines.size(), LaundryPlan.WASHER_ZS.size() + LaundryPlan.DRYER_ZS.size())
	for machine in plan.machines:
		var at := prison.global_transform.affine_inverse() * machine.global_position
		assert_almost_eq(at.x, LaundryPlan.MACHINE_X, 0.01)
		assert_false(machine.occupied)
	assert_eq(plan.machines.filter(func(m: LaundryMachine) -> bool: return m.dryer).size(), 2)


func test_someone_squeezes_in_halfway_after_a_drawn_trip() -> void:
	assert_eq(plan.machine_trips.size(), LaundryPlan.MACHINE_TRIPS)
	plan.start()
	plan.trip_now = plan.machine_trips[0] - 1
	plan.start_trip()
	assert_almost_eq(plan._machine_in, LaundryPlan.TRIP_EVERY / 2, 0.01)
	plan._machine_in = 0.02
	await wait_physics_frames(4)
	var pick := plan.machine_picks[0]
	assert_true(plan.machines[pick].occupied)


func test_a_trip_with_no_draw_leaves_the_machines_alone() -> void:
	for trip in LaundryPlan.TRIPS:
		if not plan.machine_trips.has(trip):
			plan.trip_now = trip - 1
			plan.start_trip()
			assert_lt(plan._machine_in, 0.0, "trip %d" % trip)
			return
	fail_test("some trip has no draw")


func test_someone_in_a_machine_moans_and_shakes() -> void:
	var machine := plan.machines[0]
	machine.set_occupied(true)
	machine._ay_left = 0.01
	await wait_seconds(0.3)
	assert_eq(machine.said(), "MACHINE_AY")
	assert_ne(machine.get_node("Body").rotation.z, 0.0)
	machine.set_occupied(false)
	assert_eq(machine.get_node("Body").rotation.z, 0.0)


func test_opening_a_machine_lets_out_a_dizzy_runner() -> void:
	var machine := plan.machines[2]
	machine.set_occupied(true)
	machine.use(cop)
	assert_false(machine.occupied)
	assert_eq(plan.found, 1)
	var runner := plan.runners[0]
	assert_almost_eq(runner.delay, LaundryPlan.DIZZY_TIME, 0.01)
	assert_eq(runner.said(), "MACHINE_DIZZY")
	assert_eq(runner.route[-1], LaundryPlan.GATE)


func test_opening_an_empty_machine_finds_nobody() -> void:
	plan.machines[1].use(cop)
	assert_eq(plan.found, 0)
	assert_true(plan.runners.is_empty())


func test_still_inside_at_the_next_trip_they_slip_into_a_cart() -> void:
	plan.start()
	plan.trip_now = 0
	var trip_carts := plan.carts_on_trip(1)
	var before := trip_carts.filter(func(c: LaundryCart) -> bool: return c.hidden).size()
	if before == trip_carts.size():
		trip_carts[0].hidden = false
		before -= 1
	plan.machines[0].set_occupied(true)
	plan.start_trip()
	assert_false(plan.machines[0].occupied)
	assert_eq(trip_carts.filter(func(c: LaundryCart) -> bool: return c.hidden).size(), before + 1)


func test_the_same_seed_draws_the_same_machines() -> void:
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 7
	add_child_autofree(other)
	assert_eq(other.laundry.machine_trips, plan.machine_trips)
	assert_eq(other.laundry.machine_picks, plan.machine_picks)
	for trip in plan.machine_trips:
		assert_lt(trip, LaundryPlan.TRIPS - 1, "there's a next trip to slip into")
