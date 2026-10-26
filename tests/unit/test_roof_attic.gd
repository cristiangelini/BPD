extends GutTest

## The roof jailbreak, step 2 (fuga-techo.md): the storage room over the cells with its boxes, some stacked; a box
## landing hard thumps and the guard hears it, and suspicious enough he counts heads with his flashlight; the ladder up
## to the roof and the hatch back down; running on the roof is heard, walking isn't.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_techo_deposito.json"

var level: JailbreakLevel
var guard: RoofGuard
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "roof"
	level.case_seed = 4242
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as RoofGuard
	guard.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _boxes() -> Array:
	return get_tree().get_nodes_in_group("storage_boxes")


func test_the_storage_room() -> void:
	assert_between(_boxes().size(), JailbreakLevel.STORAGE_MIN + JailbreakLevel.STORAGE_STACKED,
		JailbreakLevel.STORAGE_SPOTS.size() + JailbreakLevel.STORAGE_STACKED)
	assert_not_null(level.get_node_or_null("RoofLadder"))
	assert_not_null(level.get_node_or_null("RoofHatch"))
	await wait_physics_frames(60)
	assert_eq(guard.suspicion, 0.0, "the boxes sit still")
	for box: StorageBox in _boxes():
		assert_gt((lot.affine_inverse() * box.global_position).y, StationRooms.CEILING, "%s upstairs" % box.name)


func test_a_box_falling_thumps() -> void:
	var box: StorageBox = level.get_node("StorageBox%d" % JailbreakLevel.STORAGE_STACKED)
	box.global_position += Vector3.UP * 1.5
	await wait_physics_frames(60)
	assert_eq(guard.suspicion, RoofGuard.THUMP_SUSPICION)
	assert_true(guard.said().begins_with("ROOF_GUARD_THUMP"))


func test_suspicious_he_counts_heads() -> void:
	guard.suspicion = 40.0
	guard.heard_thump(lot * Vector3(10.0, 3.3, 2.0))
	assert_eq(guard.said(), "ROOF_GUARD_ALL_THERE", "everyone in the cells")
	assert_eq(guard.suspicion, RoofGuard.CALM_AFTER_LOOK)
	assert_eq(guard.times_caught, 0)
	cop.global_position = lot * JailbreakLevel.ATTIC_DOWN_AT
	guard.suspicion = 40.0
	guard.heard_thump(lot * Vector3(10.0, 3.3, 2.0))
	assert_eq(guard.times_caught, 1, "one missing")
	assert_eq(guard.said(), "ROOF_GUARD_MISSING")
	assert_false(level.outside_cells(cop.global_position), "back in the cell")


func test_the_ladder_up_and_the_hatch_down() -> void:
	cop.global_position = lot * JailbreakLevel.ATTIC_DOWN_AT
	(level.get_node("RoofLadder") as RoofHatch).use(cop)
	assert_gt((lot.affine_inverse() * cop.global_position).y, JailbreakLevel.ROOF_Y, "on the roof")
	await wait_physics_frames(20)
	assert_gt((lot.affine_inverse() * cop.global_position).y, JailbreakLevel.ROOF_Y - 0.1, "standing on it")
	(level.get_node("RoofHatch") as RoofHatch).use(cop)
	var y := (lot.affine_inverse() * cop.global_position).y
	assert_true(y > StationRooms.CEILING and y < JailbreakLevel.ROOF_Y, "back in the storage room")


func _move_on_roof(speed: float, seconds: float) -> void:
	var step := 1.0 / 30.0
	cop.global_position = lot * Vector3(0, JailbreakLevel.ROOF_Y + 0.05, 0)
	for i in int(seconds * 30):
		cop.global_position += lot.basis * Vector3(speed * step, 0, 0)
		level._roof_steps(step)


func test_walking_on_the_roof_is_quiet() -> void:
	_move_on_roof(GameScale.WALK_SPEED, 3.0)
	assert_eq(guard.suspicion, 0.0)


func test_running_on_the_roof_is_heard() -> void:
	_move_on_roof(GameScale.RUN_SPEED, 1.2)
	assert_eq(guard.suspicion, RoofGuard.STEPS_SUSPICION)
	assert_true(guard.said().begins_with("ROOF_GUARD_STEPS"))


func test_the_parapet() -> void:
	var walls := level.get_children().filter(func(node: Node) -> bool: return node.name.begins_with("Parapet"))
	assert_eq(walls.size(), 4, "around the roof")
