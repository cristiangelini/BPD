extends GutTest

## The vent jailbreak, step 3 (fuga-ventilacion.md): the key board behind the guard, the one good key among six, the
## cell it opens and the key back on its hook after a catch.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_ventilacion_llaves.json"

var level: JailbreakLevel
var cop: Cop
var guard: VentGuard
var board: KeyBoard
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "vent"
	level.case_seed = 7171
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	guard = level.guard as VentGuard
	guard.set_physics_process(false)
	board = level.key_board
	lot = level.city.transform * CityLayout.lot("station")
	cop.global_position = lot * Vector3(12.4, 0.1, 8.0)
	await wait_physics_frames(1)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _hook(index: int) -> KeyHook:
	return board.get_node("Hook%d" % index)


func test_the_board_is_behind_his_back() -> void:
	assert_not_null(board)
	assert_true(level.outside_cells(board.global_position))
	guard.look = 0.0
	assert_false(guard.sees(board.global_position), "he looks at the cells, not at the board")
	var same := KeyBoard.new()
	add_child_autofree(same)
	same.setup(7171)
	assert_eq(same.good, board.good, "same seed, same hook")


func test_a_wrong_key_goes_back_on_its_hook() -> void:
	var wrong := (board.good + 1) % KeyBoard.HOOKS
	assert_eq(_hook(wrong).prompt_key(cop), "PROMPT_VENT_KEY")
	_hook(wrong).use(cop)
	await wait_physics_frames(1)
	assert_null(cop.get_node("Grabber").held, "nothing in hand")
	assert_true(board.has_key)


func test_the_good_one_opens_the_cell() -> void:
	_hook(board.good).use(cop)
	await wait_physics_frames(2)
	assert_true(cop.get_node("Grabber").held is CellKey, "the cells' key in hand")
	assert_false(board.has_key)
	assert_eq(_hook(board.good).prompt_key(cop), "", "nothing left on that hook")
	var door: CellDoor = level.city.cell_doors[0]
	cop.global_position = door.global_position + Vector3(0.6, 0.1, 1.0)
	await wait_physics_frames(1)
	door.use(cop)
	assert_false(door.locked, "open")


func test_after_a_catch_its_back_on_the_board() -> void:
	_hook(board.good).use(cop)
	await wait_physics_frames(2)
	guard.catch()
	await wait_physics_frames(2)
	assert_true(board.has_key)
	assert_null(cop.get_node("Grabber").held)
	assert_false(level.outside_cells(cop.global_position), "back in a cell")


func test_guests_see_the_key_gone() -> void:
	var other := KeyBoard.new()
	add_child_autofree(other)
	board.has_key = false
	other.apply_net_state(board.net_state())
	assert_false(other.has_key)
