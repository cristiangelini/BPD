extends GutTest

## The garbage truck jailbreak, step 3 (fuga-basura.md): the dumpster, Don Ruperto's truck taking whatever is in it
## (bags and cops) and dropping the cops around the corner, Ruperto spotting one that moves, and the guard's roll of
## bags.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_basura_camion.json"

var level: JailbreakLevel
var guard: GarbageGuard
var truck: GarbageTruck
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "garbage"
	level.case_seed = 7575
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as GarbageGuard
	guard.set_physics_process(false)
	truck = level.garbage_truck
	truck.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _drive_until(done: Callable, seconds: float) -> bool:
	var step := 1.0 / 30.0
	var left := seconds
	while left > 0.0:
		truck._physics_process(step)
		if done.call():
			return true
		left -= step
	return false


func _local(at: Vector3) -> Vector3:
	return lot.affine_inverse() * at


func test_it_comes_in_three_minutes_or_so() -> void:
	assert_eq(truck.stage, "")
	assert_false(truck.visible, "out of sight")
	assert_between(truck.next_left, GarbageTruck.FIRST_AT - GarbageTruck.SHIFT, GarbageTruck.FIRST_AT + GarbageTruck.SHIFT)
	truck.next_left = 0.05
	truck._physics_process(0.1)
	assert_eq(truck.stage, "coming")
	assert_true(truck.visible)


func test_in_and_out_of_the_dumpster() -> void:
	var dumpster := level.dumpster
	cop.global_position = dumpster.global_position + Vector3(0, 0.1, 1.5)
	assert_eq(dumpster.prompt_key(cop), "PROMPT_DUMPSTER_IN")
	dumpster.use(cop)
	assert_true(dumpster.contains(cop.global_position))
	assert_eq(dumpster.prompt_key(cop), "PROMPT_DUMPSTER_OUT")
	dumpster.use(cop)
	assert_false(dumpster.contains(cop.global_position))


func test_it_takes_a_cop_in_a_bag_around_the_corner() -> void:
	var bag: GarbageBag = guard.bags[0]
	bag.take(level.dumpster.inside())
	level.dumpster.throw_in(bag)
	cop.is_crouching = true
	bag.use(cop)
	watch_signals(truck)
	truck.come()
	assert_true(_drive_until(func() -> bool: return truck.stage == "emptying", 60.0), "it gets to the dumpster")
	var stop := _local(truck.global_position)
	assert_almost_eq(stop.z, GarbageTruck.LANE_Z, 0.1, "in the lane")
	assert_lt(absf(_local(truck.global_transform * GarbageTruck.HOPPER).x - GarbageTruck.HOPPER.x
		- _local(level.dumpster.global_position).x), 0.2, "the hopper at the dumpster")
	assert_true(_drive_until(func() -> bool: return truck.stage == "backing", 10.0), "emptied")
	assert_signal_emitted(truck, "emptied")
	assert_eq(level.dumpster.bags, 0)
	assert_false(bag.in_use, "the bag back on the roll")
	assert_eq(truck.riders, [cop] as Array[Cop])
	assert_eq(cop.seated_in, truck)
	assert_false(cop.visible)
	assert_true(_drive_until(func() -> bool: return truck.stage == "going", 60.0), "around the corner")
	assert_signal_emitted(truck, "dropped")
	assert_null(cop.seated_in)
	assert_true(cop.visible)
	assert_true(level.outside_cells(cop.global_position), "out")
	assert_gt(_local(cop.global_position).distance_to(Vector3(0, 0, StationRooms.HALF_Z)), 25.0, "far from the door")
	assert_true(_drive_until(func() -> bool: return truck.stage == "", 60.0), "gone")
	assert_false(truck.visible)
	assert_between(truck.next_left, GarbageTruck.EVERY - GarbageTruck.SHIFT, GarbageTruck.EVERY + GarbageTruck.SHIFT)
	assert_eq(guard.times_caught, 0)


func test_a_cop_that_moves_in_the_dumpster_is_caught() -> void:
	cop.global_position = level.dumpster.inside() + Vector3.UP * 0.1
	truck.come()
	_drive_until(func() -> bool: return truck.stage == "emptying", 60.0)
	cop.global_position += Vector3(0.5, 0, 0)
	_drive_until(func() -> bool: return truck.stage != "emptying", 10.0)
	assert_eq(guard.times_caught, 1, "Ruperto tells the guard")
	assert_true(truck.riders.is_empty())
	assert_false(level.outside_cells(cop.global_position), "back in a cell")


func test_one_that_keeps_still_goes_too() -> void:
	cop.global_position = level.dumpster.inside() + Vector3.UP * 0.1
	truck.come()
	_drive_until(func() -> bool: return truck.stage == "backing", 70.0)
	assert_eq(guard.times_caught, 0)
	assert_eq(truck.riders, [cop] as Array[Cop])


func test_a_catch_takes_them_off_the_truck() -> void:
	truck.seat(cop)
	guard.catch()
	assert_true(truck.riders.is_empty())
	assert_null(cop.seated_in)
	assert_true(cop.visible)


func test_his_roll_of_bags() -> void:
	assert_eq(guard.bags.size(), JailbreakLevel.BAG_ROLL)
	for bag in guard.bags:
		assert_false(bag.in_use)
		assert_false(bag.visible)
		bag.in_use = true
	guard.round_cell = 0
	guard.start_round()
	var step := 1.0 / 30.0
	for i in 900:
		guard._physics_process(step)
		if guard.stage == "in_cell":
			break
	assert_null(guard.bag, "none left")
