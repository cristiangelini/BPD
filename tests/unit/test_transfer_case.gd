extends GutTest

## The prisoner transfer case (traslado-presos.md, step 5, decision 105): the bus stays locked until the comisario
## tells it, the warden counts the inmates once the bus stops in the prison's yard, the pay comes off for each missing
## inmate and each hard crash, and with 4 escaped or the bus tipped over the case is lost.

const LEVEL := preload("res://scenes/levels/prisoner_transfer.tscn")

var level: PrisonLevel
var bus: PrisonBus
var case: TransferCase


func before_each() -> void:
	level = LEVEL.instantiate()
	level.case_seed = 7
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	bus = level.bus
	case = level.transfer_case
	await wait_physics_frames(30)


func _put_bus(at: Transform3D) -> void:
	PhysicsServer3D.body_set_state(bus.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, at)
	bus.global_transform = at


func _into_the_yard() -> void:
	_put_bus(level.global_transform * Transform3D(Basis.IDENTITY, Vector3(0, 0.3, PrisonLevel.HALF_Z - 6.0)))


func test_the_bus_waits_for_the_comisario() -> void:
	assert_eq(bus.locked_hint, "HINT_COMISARIO_FIRST")
	case.give_tip()
	assert_eq(bus.locked_hint, "", "unlocked once he told it")


func test_stopped_in_the_yard_the_warden_counts_all_eight() -> void:
	case.give_tip()
	_into_the_yard()
	await wait_physics_frames(20)
	assert_true(case.counting, "the count starts")
	await wait_seconds(TransferCase.COUNT_STEP * (TransferPlan.INMATES + 2))
	assert_eq(case.counted, TransferPlan.INMATES)
	assert_true(case.solved())
	assert_eq(case.report().salary, TransferCase.SALARY)
	assert_eq(case.report().quota, TransferCase.QUOTA)


func test_the_count_waits_for_one_still_running() -> void:
	case.give_tip()
	level.transfer.inmates[3].jump_out()
	_into_the_yard()
	await wait_physics_frames(20)
	assert_false(case.counting, "not while one is loose")


func test_missing_inmates_and_crashes_come_off_the_pay() -> void:
	case.delivered = true
	level.escape.escaped.assign([level.transfer.inmates[0], level.transfer.inmates[1]])
	case.damages.crashes = 3
	assert_eq(case.report().salary, TransferCase.SALARY - 2 * TransferCase.PER_MISSING - 3 * TransferCase.PER_CRASH)
	assert_eq(case.on_board(), TransferPlan.INMATES - 2)


func test_four_escaped_lose_the_case() -> void:
	case.give_tip()
	level.escape.escaped.assign(level.transfer.inmates.slice(0, TransferCase.LOSE_AT))
	level.escape.chase_over.emit(level.transfer.inmates[0], false)
	assert_eq(case.failed_reason, "CASE_FAILED_TRANSFER_ESCAPED")
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_the_bus_on_its_side_loses_the_case() -> void:
	case.give_tip()
	bus.freeze = true
	_put_bus(bus.global_transform.rotated_local(Vector3.FORWARD, PI / 2).translated(Vector3.UP * 1.4))
	await wait_seconds(TransferCase.TIPPED_SECONDS + 0.5)
	assert_eq(case.failed_reason, "CASE_FAILED_BUS_TIPPED")


func test_the_transfer_comes_up_in_the_draw() -> void:
	var found := false
	for i in 600:
		if PlaceDraw.pick(i + 1, [], 1) == "transfer":
			found = true
			break
	assert_true(found)
	assert_eq(PlaceDraw.pick(1, ["--place=transfer"]), "transfer")
