extends GutTest

## The cleaning crew's jailbreak, step 3 (fuga-limpieza.md): the break room is the cleaning closet, and the early
## comisario takes a cop in the cleaning disguise with a mop for someone of the crew.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_armario.json"

var level: JailbreakLevel
var cop: Cop
var comisario: EarlyComisario


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "cleaning"
	level.case_seed = 2024
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	comisario = level.guard as EarlyComisario
	comisario.set_physics_process(false)
	level.cleaner.set_physics_process(false)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _closet_pieces() -> Array:
	var pieces := []
	for node in level.get_children():
		if node is DisguisePiece and DisguisePiece.LOOKS.cleaner.pieces.has(node.kind):
			pieces.append(node)
	return pieces


func test_the_closet_has_the_crews_clothes_and_tools() -> void:
	var pieces := _closet_pieces()
	assert_between(pieces.size(), 12 - JailbreakLevel.CLOSET_MISSING, 12)
	assert_true(pieces.size() >= 8, "at least two pieces for each cop")
	assert_eq(level.tools.size(), 3)
	assert_eq(level.tools.filter(func(tool: CleaningTool) -> bool: return tool.kind == "mop").size(), 2)


func test_two_pieces_make_the_cleaning_disguise() -> void:
	assert_false(cop.is_disguised("cleaner"))
	cop.put_on_disguise("cleaner_cap", 0.0)
	assert_false(cop.is_disguised("cleaner"), "one isn't enough")
	cop.put_on_disguise("cleaner_vest", 0.0)
	assert_true(cop.is_disguised("cleaner"))
	assert_false(cop.is_disguised("grandparent"), "not a grandparent")


func test_what_he_makes_of_a_cop_out_of_the_cells() -> void:
	assert_eq(comisario.offence(cop), NightGuard.SUSPICION_COP, "a cop, plain as day")
	cop.put_on_disguise("cleaner_cap", 0.0)
	cop.put_on_disguise("face_mask", 0.0)
	assert_eq(comisario.offence(cop), EarlyComisario.SUSPICION_IDLE, "someone of the crew doing nothing")
	cop.handed(level.tools[0])
	await wait_physics_frames(2)
	assert_true(comisario.is_cleaning(cop))
	assert_eq(comisario.offence(cop), 0.0, "someone of the crew cleaning")
	comisario._speeds[cop] = [cop.global_position, EarlyComisario.RUN_SPEED + 1.0]
	assert_eq(comisario.offence(cop), EarlyComisario.SUSPICION_RUNNING, "but not running")


func test_his_speed_comes_from_where_the_cop_goes() -> void:
	comisario._track_speeds(0.1)
	cop.global_position += Vector3(0.5, 0, 0)
	comisario._track_speeds(0.1)
	assert_almost_eq(comisario.speed_of(cop), 5.0, 0.01)


func test_caught_in_disguise_it_goes_back_to_the_closet() -> void:
	var lot := level.city.transform * CityLayout.lot("station")
	cop.put_on_disguise("cleaner_cap", 0.0)
	cop.put_on_disguise("cleaner_vest", 0.0)
	cop.global_position = lot * Vector3(9.0, 0.1, 6.4)
	await wait_physics_frames(2)
	var before := _closet_pieces().size()
	comisario.catch()
	await wait_physics_frames(2)
	assert_true(cop.disguise.is_empty(), "the disguise came off")
	assert_eq(_closet_pieces().size(), before + 2, "and its pieces are back")
	for piece: DisguisePiece in _closet_pieces():
		var local := lot.affine_inverse() * piece.global_position
		assert_true(local.z < StationRooms.SPLIT_Z, "in the closet, not in the cell")
