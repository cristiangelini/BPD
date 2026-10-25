extends GutTest

## The escape on foot from the transfer bus (traslado-presos.md, step 4, decision 105): an inmate out by a window or a
## door runs off along the sidewalk (ChaseCase.begin); caught and walked back, they sit in their own seat again, and
## got away, they count as escaped. One chase at a time.

const LEVEL := preload("res://scenes/levels/prisoner_transfer.tscn")

var level: PrisonLevel
var bus: PrisonBus
var plan: TransferPlan
var escape: TransferEscape


func before_each() -> void:
	level = LEVEL.instantiate()
	level.case_seed = 7
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	bus = level.bus
	plan = level.transfer
	escape = level.escape
	await wait_physics_frames(30)


func _catch(chase: ChaseCase) -> void:
	chase.pull_over()
	chase.suspect.cuffed(30.0)
	chase.escort.board()
	await wait_physics_frames(3)


func test_a_loose_inmate_at_the_door_steps_out_when_the_bus_stands_still() -> void:
	var inmate := plan.inmates[2]
	inmate.open_cuffs()
	inmate.door = 1
	await wait_physics_frames(2)
	assert_true(inmate.out, "out by the door")
	assert_ne(inmate.get_parent(), bus, "off the bus")
	assert_almost_eq(inmate.global_position.distance_to(bus.to_global(PrisonBus.DOORS[1].outside)), 0.0, 0.2)


func test_out_of_the_bus_the_chase_on_foot_starts() -> void:
	var inmate := plan.inmates[3]
	inmate.jump_out()
	assert_not_null(escape.chase, "a chase")
	assert_eq(escape.running, inmate)
	assert_eq(escape.chase.suspect_id, SuspectCar.INMATE_ON_FOOT)
	assert_eq(escape.chase.who, "transfer_inmate")
	assert_true(escape.chase.on_foot(), "on foot")
	assert_false(inmate.visible, "the runner stands in for them")


func test_caught_they_sit_in_their_own_seat_again() -> void:
	var inmate := plan.inmates[4]
	inmate.set_plan(90.0)
	inmate.jump_out()
	assert_eq(bus.return_seat, inmate.seat)
	await _catch(escape.chase)
	assert_eq(escape.caught, 1)
	assert_null(escape.chase, "the chase is over")
	assert_eq(inmate.get_parent(), bus, "back on the bus")
	assert_true(inmate.seated, "in the seat")
	assert_false(inmate.out)
	assert_true(inmate.visible)
	assert_eq(inmate.plan, 0.0, "the plan starts over")
	assert_almost_eq(inmate.position.distance_to(PrisonBus.seat_spot(inmate.seat)), 0.0, 0.01)
	assert_false(level.tricks.out.has(inmate))


func test_got_away_they_count_as_escaped() -> void:
	var inmate := plan.inmates[5]
	inmate.jump_out()
	escape.chase.fail("CASE_FAILED_ESCAPED")
	await wait_physics_frames(2)
	assert_eq(escape.escaped, [inmate] as Array[BusInmate])
	assert_eq(escape.caught, 0)


func test_one_chase_at_a_time() -> void:
	var first := plan.inmates[0]
	var second := plan.inmates[1]
	first.jump_out()
	second.jump_out()
	assert_eq(escape.running, first)
	assert_true(escape.waiting.has(second), "the second waits")
	await _catch(escape.chase)
	assert_eq(escape.running, second, "then runs")
	assert_not_null(escape.chase)
	assert_ne(escape.chase.truck.name, "GoneRunner1", "a runner of their own")


func test_the_bus_takes_the_inmate_to_its_whole_body() -> void:
	assert_eq(bus.body_half_size(), Vector2(PrisonBus.HALF_WIDTH, PrisonBus.HALF_LENGTH))
