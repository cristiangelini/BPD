extends GutTest

## The garbage truck jailbreak, step 2 (fuga-basura.md): hiding in the guard's bag, his count of the cell, the pillow
## dummy that fools it (unless he stares at it) and the weight of a bag with a cop inside.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_basura_bolsa.json"

var level: JailbreakLevel
var guard: GarbageGuard
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
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")
	# The cop starts in cell 0: his round is for that cell.
	guard.round_cell = 0


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _step_until(done: Callable, seconds: float) -> bool:
	var step := 1.0 / 30.0
	var left := seconds
	while left > 0.0:
		guard._physics_process(step)
		if done.call():
			return true
		left -= step
	return false


func _to_the_bag() -> GarbageBag:
	guard.start_round()
	_step_until(func() -> bool: return guard.stage == "in_cell", 30.0)
	return guard.bag


func _dummy(cell: int) -> BunkDummy:
	return level.get_node("BunkDummy%d" % cell)


func test_he_knows_whos_in_each_cell() -> void:
	assert_eq(guard.jailed, [1, 0] as Array[int], "the one cop, in cell 0")


func test_crouched_into_the_open_bag_and_out() -> void:
	var bag := _to_the_bag()
	assert_eq(bag.prompt_key(cop), "PROMPT_BAG_CROUCH")
	bag.use(cop)
	assert_null(bag.hider, "not standing up")
	cop.is_crouching = true
	assert_eq(bag.prompt_key(cop), "PROMPT_BAG_HIDE")
	bag.use(cop)
	assert_eq(bag.hider, cop)
	assert_eq(cop.seated_in, bag)
	assert_false(cop.visible, "out of sight")
	assert_eq(cop.current_prompt(), "PROMPT_BAG_OUT")
	bag.use(cop)
	assert_null(bag.hider)
	assert_null(cop.seated_in)
	assert_true(cop.visible)


func test_one_short_in_the_count_is_suspicious() -> void:
	var bag := _to_the_bag()
	cop.is_crouching = true
	bag.use(cop)
	assert_true(_step_until(func() -> bool: return guard.stage == "counting", 10.0))
	assert_almost_eq(guard.suspicion, GarbageGuard.MISSING_SUSPICION, 1.0, "one missing")
	assert_eq(guard._bubble.text, "GARBAGE_GUARD_MISSING")


func test_a_dummy_on_the_bunk_fools_the_count() -> void:
	var dummy := _dummy(0)
	assert_eq(dummy.prompt_key(cop), "PROMPT_DUMMY_BUILD")
	cop.global_position = dummy.global_position + Vector3(0, 0, 1.0)
	dummy.use(cop)
	assert_eq(dummy.prompt_key(cop), "PROMPT_DUMMY_ROLLING")
	for i in 100:
		dummy._physics_process(1.0 / 30.0)
	assert_true(dummy.built, "rolled in 3 s")
	var bag := _to_the_bag()
	cop.is_crouching = true
	bag.use(cop)
	assert_true(_step_until(func() -> bool: return guard.stage == "out_of_cell", 15.0), "a short look and out")
	assert_lt(guard.suspicion, 1.0, "the count came out right")
	assert_eq(guard.times_caught, 0)


func test_walking_away_stops_the_dummy() -> void:
	var dummy := _dummy(0)
	cop.global_position = dummy.global_position + Vector3(0, 0, 1.0)
	dummy.use(cop)
	cop.global_position = dummy.global_position + Vector3(0, 0, 3.0)
	dummy._physics_process(0.1)
	assert_null(dummy.builder)
	assert_false(dummy.built)


func test_staring_at_the_dummy_up_close_gives_it_away() -> void:
	var dummy := _dummy(0)
	dummy.built = true
	guard.jailed[0] = 3
	watch_signals(guard)
	_to_the_bag()
	_step_until(func() -> bool: return guard.times_caught > 0, 15.0)
	assert_eq(guard.times_caught, 1, "a long look at it")
	assert_false(dummy.built, "back to a pillow")


func test_a_cop_in_the_bag_goes_out_heavy_and_unseen() -> void:
	var bag := _to_the_bag()
	cop.is_crouching = true
	bag.use(cop)
	assert_true(_step_until(func() -> bool: return guard.stage == "to_street", 30.0))
	assert_true(guard.heavy)
	assert_eq(guard.heavy_streak, 1)
	var from := guard.global_position
	guard._physics_process(1.0)
	assert_almost_eq(guard.global_position.distance_to(from), GarbageGuard.WALK_SPEED * GarbageGuard.HEAVY_SPEED, 0.05,
		"half speed")
	assert_true(_step_until(func() -> bool: return guard.stage == "back", 120.0), "to the dumpster")
	assert_eq(guard.times_caught, 0, "nobody saw him outside the cells")
	await wait_physics_frames(2)
	assert_eq(bag.hider, cop, "still in it")
	assert_lt(cop.global_position.distance_to(level.dumpster.inside()), 1.0, "in the dumpster")
	assert_false(guard.heavy)


func test_two_heavy_bags_in_a_row_is_suspicious() -> void:
	guard.heavy_streak = 1
	var bag := _to_the_bag()
	guard.jailed[0] = 0
	cop.is_crouching = true
	bag.use(cop)
	_step_until(func() -> bool: return guard.stage == "out_of_cell", 15.0)
	assert_eq(guard.heavy_streak, 2)
	assert_almost_eq(guard.suspicion, GarbageGuard.HEAVY_AGAIN_SUSPICION, 1.0)


func test_a_catch_lets_him_out_of_the_bag() -> void:
	var bag := _to_the_bag()
	cop.is_crouching = true
	bag.use(cop)
	guard.catch()
	assert_null(cop.seated_in)
	assert_true(cop.visible)
	assert_false(level.outside_cells(cop.global_position), "back in a cell")
