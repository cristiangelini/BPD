extends GutTest

## The jailbreak, step 3a (fuga.md): the broom and the fishing rod fish the guard's donut box from the cells.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var level: Node3D
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	level = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")
	level.guard.set_physics_process(false)


## Puts the cop at the bars of the west cell with `stick` in hand, aiming its tip at the box.
func _aim_at_box(stick: HookStick) -> void:
	cop.global_position = lot * Vector3(9.6, 0.1, 3.9)
	await wait_physics_frames(3)
	var box_at: Vector3 = level.box.global_position
	var eye := cop.camera.global_position
	var flat := Vector3(box_at.x - eye.x, 0, box_at.z - eye.z)
	cop.global_rotation.y = atan2(-flat.x, -flat.z)
	cop.camera.get_parent().rotation.x = atan2(box_at.y - eye.y, flat.length())
	cop.get_node("Grabber").grab(stick)
	cop.get_node("Grabber").hold_distance = clampf(eye.distance_to(box_at) - stick.length, GameScale.HOLD_MIN,
		GameScale.HOLD_MAX)
	await wait_physics_frames(60)


func test_each_cell_has_something_to_fish_with() -> void:
	assert_eq(level.sticks.size(), 2)
	var cells := []
	for stick: HookStick in level.sticks:
		var at: Vector3 = lot.affine_inverse() * stick.global_position
		assert_lt(at.z, StationRooms.CELL_FRONT_Z, "%s lies in a cell" % stick.name)
		cells.append(at.x < StationRooms.CELL_SPLIT_X)
	assert_eq(cells, [true, false], "one in each cell")


func test_in_hand_the_tip_reaches_the_box_through_the_bars() -> void:
	var stick: HookStick = level.sticks[0]
	await _aim_at_box(stick)
	assert_lt(stick.tip().distance_to(level.box.global_position), HookStick.CATCH, "the tip is at the box")
	assert_eq(stick.held_prompt_key(cop), "PROMPT_HOOK_BOX")


func test_a_hooked_box_is_dragged_to_the_bars_and_out_of_the_guards_reach() -> void:
	var stick: HookStick = level.sticks[0]
	await _aim_at_box(stick)
	assert_true(cop.use(), "E with the stick in hand")
	assert_eq(stick.hooked, level.box)
	# Walking back from the bars drags it along.
	for i in 130:
		cop.step(1.0 / 60, Vector2(0, 0.5), false, false, false)
		await wait_physics_frames(1)
	await wait_physics_frames(30)
	var box_at: Vector3 = lot.affine_inverse() * level.box.global_position
	assert_lt(box_at.z, 6.2, "the box came toward the bars")
	assert_gt(box_at.z, StationRooms.CELL_FRONT_Z, "but it doesn't go through them")
	assert_false(level.guard.box_in_reach(), "the guard can't reach it anymore")


func test_e_again_lets_it_go_and_so_does_dropping_the_stick() -> void:
	var stick: HookStick = level.sticks[0]
	await _aim_at_box(stick)
	cop.use()
	cop.use()
	assert_null(stick.hooked, "E again lets the box go")
	cop.use()
	assert_not_null(stick.hooked)
	cop.get_node("Grabber").release()
	await wait_physics_frames(2)
	assert_null(stick.hooked, "dropping the stick lets the box go")


func test_lying_on_the_floor_it_hooks_nothing() -> void:
	var stick: HookStick = level.sticks[0]
	stick.global_position = level.box.global_position + stick.global_basis.z * stick.length
	stick.use(cop)
	assert_null(stick.hooked)
