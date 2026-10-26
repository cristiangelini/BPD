extends GutTest

## The bribe jailbreak, step 2 (fuga-soborno.md): the corridor's camera turns from one cell's door to the other's, the
## guard gives the wad back if it looks at the cell while he counts, and haggling lowers his price but makes him
## suspicious.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_soborno_camara.json"

var level: JailbreakLevel
var guard: BribeGuard
var camera: CorridorCamera
var cop: Cop


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "bribe"
	level.case_seed = 5151
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as BribeGuard
	guard.set_physics_process(false)
	camera = level.get_node("CorridorCamera")
	camera.set_physics_process(false)
	cop = level.get_node("Cop")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _step(seconds: float) -> void:
	for i in int(seconds * 30):
		guard._physics_process(1.0 / 30.0)


## The guard at cell `cell`'s bars, and the camera looking at `looking`.
func _at_bars(cell: int, looking: int) -> CellDoor:
	camera.cell = looking
	camera.turning = false
	camera.left = 1000.0
	var door: CellDoor = level.city.cell_doors[cell]
	door.use(cop)
	_step(12.0)
	return door


func _wads() -> Array:
	return level.get_children().filter(func(node: Node) -> bool:
		return node is BillWad and not node.is_queued_for_deletion())


func test_it_turns_from_one_cell_to_the_other() -> void:
	assert_between(camera.hold, CorridorCamera.HOLD_MIN, CorridorCamera.HOLD_MAX)
	var first := camera.cell
	assert_true(camera.watching(first))
	assert_false(camera.watching(1 - first))
	camera.left = 0.5
	for i in 20:
		camera.step(1.0 / 30.0)
	assert_true(camera.turning)
	assert_false(camera.watching(0) or camera.watching(1), "turning, it watches neither")
	for i in int(CorridorCamera.TURN_TIME * 30) + 2:
		camera.step(1.0 / 30.0)
	assert_true(camera.watching(1 - first), "now the other one")
	assert_almost_eq(camera.left, camera.hold, 0.3)


func test_it_looks_at_the_door_it_watches() -> void:
	var model: Node3D = camera.get_child(0)
	for cell in 2:
		camera.cell = cell
		camera.turning = false
		camera.left = camera.hold
		camera.step(0.0)
		var lens := (model.global_basis * Vector3(0, 0, 1)) * Vector3(1, 0, 1)
		var to_door := (camera.doors[cell] - camera.global_position) * Vector3(1, 0, 1)
		assert_gt(lens.normalized().dot(to_door.normalized()), 0.99, "facing door %d" % cell)


func test_counting_in_front_of_the_camera_he_gives_it_back() -> void:
	var door := _at_bars(0, 0)
	var wad: BillWad = _wads()[0]
	cop.handed(wad)
	door.use(cop)
	assert_eq(guard.stage, "counting")
	guard._physics_process(1.0 / 30.0)
	assert_eq(guard.stage, "at_bars", "the camera is on him")
	assert_true(guard.line.begins_with("BRIBE_GUARD_CAMERA_"))
	assert_eq(guard.paid, 0)
	assert_eq(guard.suspicion, BribeGuard.CAMERA_SUSPICION)
	await wait_physics_frames(2)
	assert_true(is_instance_valid(wad) and not wad.freeze, "the wad back")
	assert_false(level.outside_cells(wad.global_position), "in the cell")


func test_with_the_camera_on_the_other_cell_he_counts() -> void:
	var door := _at_bars(1, 0)
	var wad: BillWad = _wads()[0]
	var amount := wad.amount
	cop.handed(wad)
	door.use(cop)
	_step(BribeGuard.COUNT_TIME + 0.1)
	assert_eq(guard.paid, amount)


func test_the_camera_turning_to_him_mid_count() -> void:
	var door := _at_bars(1, 0)
	cop.handed(_wads()[0])
	door.use(cop)
	_step(1.0)
	camera.cell = 1
	_step(0.1)
	assert_eq(guard.paid, 0, "caught halfway through")
	assert_eq(guard.stage, "at_bars")


func test_haggling() -> void:
	var door := _at_bars(0, 1)
	var asked := guard.price
	for i in BribeGuard.HAGGLES:
		assert_eq(door.prompt_key(cop), "PROMPT_HAGGLE")
		door.use(cop)
		if guard.is_paid():
			break
		assert_eq(guard.price, asked - BribeGuard.HAGGLE_DROP * (i + 1))
		assert_true(guard.line.begins_with("BRIBE_GUARD_HAGGLE_"))
		assert_eq(guard.line_number, guard.price)
		assert_almost_eq(guard.suspicion, BribeGuard.HAGGLE_SUSPICION * (i + 1), 0.01)
	assert_eq(guard.haggles, BribeGuard.HAGGLES)
	assert_eq(door.prompt_key(cop), "PROMPT_CELL_LOCKED", "no more haggling")


func test_haggled_down_to_what_he_got_is_a_deal() -> void:
	var door := _at_bars(0, 1)
	guard.paid = guard.price - BribeGuard.HAGGLE_DROP
	door.use(cop)
	assert_true(guard.is_paid())
	assert_true(guard.line.begins_with("BRIBE_GUARD_DEAL_"))
	assert_false(guard.key_on_belt)
