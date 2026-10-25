extends GutTest

## The garbage truck jailbreak, step 1 (fuga-basura.md): the sixth way out, the guard with the key doing his garbage
## rounds (open a cell, a giant bag on the floor, lock it again, the bag to the dumpster on the sidewalk) and back.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_basura.json"

var level: JailbreakLevel
var guard: GarbageGuard
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
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


## Steps his round by hand until `done` is true or `seconds` run out.
func _step_until(done: Callable, seconds: float) -> bool:
	var step := 1.0 / 30.0
	var left := seconds
	while left > 0.0:
		guard._physics_process(step)
		if done.call():
			return true
		left -= step
	return false


func test_the_garbage_is_one_of_the_ways_out() -> void:
	assert_true(JailbreakLevel.VARIANTS.has("garbage"))
	assert_eq(JailbreakLevel.VARIANTS.size(), 6, "in sixths")
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=garbage"])), "garbage")
	assert_true(level.is_garbage())
	assert_not_null(guard, "the garbage guard")
	assert_true(guard.key_on_belt, "the key on his belt")
	assert_null(level.box, "no donuts")
	assert_not_null(level.dumpster)
	assert_eq(level.dumpster.bags, 0)
	assert_gt((lot.affine_inverse() * level.dumpster.global_position).z, StationRooms.HALF_Z, "on the sidewalk")


func test_his_first_round_comes_in_a_minute_or_so() -> void:
	assert_false(guard.is_away())
	assert_between(guard.round_left, GarbageGuard.ROUND_MIN, GarbageGuard.ROUND_MAX)
	guard.round_left = 0.05
	guard._physics_process(0.1)
	assert_eq(guard.stage, "to_cell")


func test_a_round_opens_the_cell_drops_the_bag_and_locks_it_again() -> void:
	var cell := guard.round_cell
	var door: CellDoor = level.city.cell_doors[cell]
	assert_true(door.locked)
	watch_signals(guard)
	guard.start_round()
	assert_true(_step_until(func() -> bool: return guard.stage == "in_cell", 30.0), "he gets to the cell")
	assert_false(door.locked, "he opened it")
	assert_true(door.is_open)
	assert_signal_emitted(guard, "bag_dropped")
	assert_true(guard.bag.is_open, "open on the floor")
	assert_false(level.outside_cells(guard.bag.global_position), "inside the cell")
	assert_true(_step_until(func() -> bool: return guard.stage == "to_street", 30.0), "he steps out")
	assert_true(door.locked, "locked behind him")
	assert_false(door.is_open)
	var bag := guard.bag
	assert_false(bag.is_open, "knotted")
	assert_true(_step_until(func() -> bool: return guard.stage == "back", 60.0), "out to the dumpster")
	assert_signal_emitted(guard, "bag_thrown")
	assert_eq(level.dumpster.bags, 1)
	assert_lt(bag.global_position.distance_to(level.dumpster.inside()), 1.0, "the bag in the dumpster")
	assert_true(_step_until(func() -> bool: return not guard.is_away(), 60.0), "back at his desk")
	assert_eq(guard.round_cell, 1 - cell, "the other cell next time")
	assert_between(guard.round_left, GarbageGuard.ROUND_MIN, GarbageGuard.ROUND_MAX)


func test_a_catch_on_his_round_sends_him_back_with_the_cells_locked() -> void:
	guard.start_round()
	_step_until(func() -> bool: return guard.stage == "in_cell", 30.0)
	var bag := guard.bag
	guard.catch()
	assert_false(guard.is_away())
	assert_null(guard.bag)
	for door: CellDoor in level.city.cell_doors:
		assert_true(door.locked)
	await wait_physics_frames(1)
	assert_false(is_instance_valid(bag), "the bag goes")
	assert_eq(guard.times_caught, 1)
