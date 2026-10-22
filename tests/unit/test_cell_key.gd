extends GutTest

## The jailbreak, step 3b (fuga.md): donuts out of the guard's box, the key in one of them, and the key opens the cells.

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


## The box dragged up to the bars, and the cop facing it from the west cell.
func _box_at_the_bars() -> void:
	level.box.freeze = true
	level.box.global_position = lot * Vector3(8.25, 0.1, 4.75)
	cop.global_position = lot * Vector3(8.25, 0.1, 3.7)
	await wait_physics_frames(3)
	var eye := cop.camera.global_position
	var to: Vector3 = level.box.global_position - eye
	cop.global_rotation.y = atan2(-to.x, -to.z)
	cop.camera.get_parent().rotation.x = atan2(to.y, Vector2(to.x, to.z).length())
	await wait_physics_frames(2)


func _grabber() -> Grabber:
	return cop.get_node("Grabber")


func test_e_on_the_box_at_the_bars_takes_a_donut_out() -> void:
	await _box_at_the_bars()
	assert_eq(cop.current_prompt(), "PROMPT_TAKE_DONUT")
	assert_true(cop.use())
	assert_is(_grabber().held, LooseDonut, "a donut in the cop's hands")
	assert_eq(level.box.donuts, 5)


func test_breaking_the_key_donut_gives_the_key() -> void:
	level.box.key_donut = 5
	await _box_at_the_bars()
	cop.use()
	var donut: LooseDonut = _grabber().held
	assert_true(donut.has_key, "the last donut is the first one out")
	assert_eq(cop.current_prompt(), "PROMPT_BREAK_DONUT")
	cop.use()
	await wait_physics_frames(1)
	assert_is(_grabber().held, CellKey, "the key falls into the cop's hands")
	assert_false(is_instance_valid(donut), "the donut is gone")


func test_breaking_any_other_donut_eats_it() -> void:
	level.box.key_donut = 0
	await _box_at_the_bars()
	cop.use()
	cop.stamina = 0.0
	cop.use()
	assert_null(_grabber().held)
	assert_eq(cop.stamina, GameScale.RUN_STAMINA, "eaten: stamina full")


func test_biting_the_key_donut_from_the_box_in_hand_drops_the_key() -> void:
	level.box.key_donut = 5
	level.box.freeze = false
	_grabber().grab(level.box)
	cop.use()
	await wait_physics_frames(1)
	assert_eq(get_tree().get_nodes_in_group("donut_boxes").size(), 1)
	var keys := level.find_children("*", "CellKey", true, false)
	assert_eq(keys.size(), 1, "the key fell out")


func test_the_key_opens_both_cells_and_without_it_they_stay_shut() -> void:
	var door: CellDoor = level.city.cell_doors[0]
	door.use(cop)
	assert_false(door.is_open, "no key, no way out")
	var key: CellKey = preload("res://scenes/props/cell_key.tscn").instantiate()
	level.add_child(key)
	key.global_position = cop.global_position + Vector3.UP
	_grabber().grab(key)
	assert_eq(door.prompt_key(cop), "PROMPT_CELL_UNLOCK")
	door.use(cop)
	assert_false(door.locked)
	assert_true(door.is_open)
	var other: CellDoor = level.city.cell_doors[1]
	other.use(cop)
	assert_true(other.is_open, "the same key opens the other cell")


func test_the_guards_box_isnt_the_armorys() -> void:
	var armory_box: DonutBox = preload("res://scenes/props/donut_box.tscn").instantiate()
	add_child_autofree(armory_box)
	assert_false(armory_box.loose)
	armory_box.use(cop)
	assert_eq(armory_box.donuts, DonutBox.DONUTS, "E on an armory box lying around does nothing")
	assert_eq(armory_box.prompt_key(cop), "PROMPT_GRAB")


func test_through_the_open_door_the_cop_walks_out() -> void:
	var door: CellDoor = level.city.cell_doors[0]
	door.unlock()
	door.set_open(true)
	await wait_physics_frames(40)
	assert_almost_eq(door.rotation.y, CellDoor.OPEN_TURN, 0.01, "swung open")
	var middle := (StationRooms.CELL_DOORS[0].x + StationRooms.CELL_DOORS[0].y) / 2
	cop.global_position = lot * Vector3(middle, 0.1, 3.4)
	cop.global_rotation.y = lot.basis.get_euler().y + PI
	await wait_physics_frames(2)
	for i in 90:
		cop.step(1.0 / 60, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	var at: Vector3 = lot.affine_inverse() * cop.global_position
	assert_gt(at.z, StationRooms.CELL_FRONT_Z + 0.5, "out of the cell")
