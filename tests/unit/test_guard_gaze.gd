extends GutTest

## The jailbreak, step 4 (fuga.md): the night guard looks around, gets suspicious of what he sees and, at 100, puts
## everything back.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var level: Node3D
var cop: Cop
var guard: NightGuard
var lot: Transform3D


func before_each() -> void:
	level = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	guard = level.guard
	lot = level.city.transform * CityLayout.lot("station")
	# The tests turn his head and run his eyes by hand.
	guard.set_physics_process(false)


## The cop out of the cells, in the cells room in front of the guard.
func _cop_out() -> void:
	cop.global_position = lot * Vector3(9.5, 0.1, 6.0)
	await wait_physics_frames(2)


func _watch(seconds: float) -> void:
	for i in int(seconds / 0.1):
		guard._watch(0.1)


func test_he_sees_in_a_cone_in_front_of_him_and_not_through_walls() -> void:
	assert_true(guard.sees(lot * Vector3(9.5, 1.0, 6.0)), "in front of him")
	assert_false(guard.sees(lot * Vector3(10.5, 1.0, 9.5)), "behind him")
	assert_false(guard.sees(lot * Vector3(6.5, 1.0, 8.0)), "too far to a side")
	assert_false(guard.sees(lot * Vector3(13.0, 1.0, 0.0)), "behind the bars and the wall")
	guard.look = 0.6
	assert_true(guard.sees(lot * Vector3(7.5, 1.0, 6.5)), "turning his head, he sees to his side")


func test_his_head_sweeps_the_cells() -> void:
	var most := 0.0
	var least := 0.0
	for i in 200:
		guard._turn_head(0.1)
		most = maxf(most, guard.look)
		least = minf(least, guard.look)
	assert_almost_eq(most, 0.6, 0.01, "he looks to one side")
	assert_almost_eq(least, -0.6, 0.01, "and to the other")


func test_cops_in_their_cells_dont_worry_him() -> void:
	_watch(5.0)
	assert_eq(guard.suspicion, 0.0)
	assert_eq(guard.times_caught, 0)


func test_a_cop_out_of_the_cells_raises_his_suspicion_and_then_it_calms_down() -> void:
	await _cop_out()
	_watch(1.0)
	assert_almost_eq(guard.suspicion, NightGuard.SUSPICION_COP, 1.0)
	guard.look = -0.6
	cop.global_position = lot * Vector3(13.0, 0.1, 3.0)
	await wait_physics_frames(2)
	_watch(1.0)
	assert_almost_eq(guard.suspicion, NightGuard.SUSPICION_COP - NightGuard.SUSPICION_CALM, 1.0, "back in, it goes down")


func test_the_box_moving_and_a_broken_donut_are_suspicious() -> void:
	level.box.hold(12345, level.box.global_position)
	assert_almost_eq(guard.alarm(), NightGuard.SUSPICION_BOX, 0.01, "someone is moving his box")
	level.box.let_go(12345)
	var donut := LooseDonut.new()
	level.add_child(donut)
	donut.global_position = lot * Vector3(10.0, 0.1, 6.0)
	await wait_physics_frames(2)
	assert_almost_eq(guard.alarm(), NightGuard.SUSPICION_CLUE, 0.01, "one of his donuts on the floor")


func test_at_100_he_puts_the_cop_back_and_locks_the_cells() -> void:
	for door: CellDoor in level.city.cell_doors:
		door.unlock()
		door.set_open(true)
	await _cop_out()
	_watch(2.5)
	await wait_physics_frames(1)
	assert_eq(guard.times_caught, 1)
	assert_eq(guard.suspicion, 0.0, "he calms down")
	assert_false(level.outside_cells(cop.global_position), "the cop is back in a cell")
	for door: CellDoor in level.city.cell_doors:
		assert_true(door.locked, "both cells locked again")
	assert_ne(guard.said(), "", "he says something")


func test_he_takes_back_his_box_the_stick_they_used_and_the_key() -> void:
	var broom: HookStick = level.sticks[0]
	var rod: HookStick = level.sticks[1]
	cop.get_node("Grabber").grab(broom)
	level.box.global_position = lot * Vector3(10.5, 0.1, 5.0)
	var key: CellKey = load("res://scenes/props/cell_key.tscn").instantiate()
	level.add_child(key)
	key.global_position = lot * Vector3(9.0, 0.1, 6.0)
	await wait_physics_frames(2)
	guard.catch()
	await wait_physics_frames(2)
	assert_false(is_instance_valid(broom), "he took the broom")
	assert_true(is_instance_valid(rod), "the rod nobody used stays in its cell")
	assert_eq(level.sticks.size(), 1)
	assert_null(cop.get_node("Grabber").held, "the cop's hands are empty")
	assert_almost_eq(level.box.global_position.distance_to(level.box_home.origin), 0.0, 0.1, "the box back on his desk")
	assert_false(is_instance_valid(key), "he picked up the key")
	assert_true(guard.key_on_belt, "and hung it on his belt")


func test_the_hud_shows_his_suspicion_and_the_catches() -> void:
	guard.suspicion = 40.0
	guard.times_caught = 1
	await wait_process_frames(2)
	assert_eq(level.suspicion_bar.value, 40.0)
	assert_string_contains(level.caught_label.text, "1")
	assert_string_contains(level.caught_label.text, "3")
