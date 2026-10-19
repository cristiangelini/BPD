extends GutTest

## First person mitten hands (Cristian picked variant B on 19/10).

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const CRATE_SCENE := preload("res://scenes/props/crate.tscn")


func _cop(with_player := true) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = with_player
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(cop)
	return cop


func test_the_player_sees_hands_and_other_cops_have_none() -> void:
	var mine := _cop()
	assert_not_null(mine.hands)
	assert_eq(mine.hands.get_parent(), mine.camera)
	assert_gt(mine.hands.model.find_children("*", "MeshInstance3D", true, false).size(), 0)
	assert_null(_cop(false).hands)


func test_hands_wear_the_player_skin() -> void:
	var cop := _cop()
	cop.set_uniform(3)
	assert_eq(cop.hands.model.scene_file_path, CopHands.MODELS[3].resource_path)


func test_hands_reach_forward_while_holding() -> void:
	var cop := _cop()
	cop.global_position = Vector3(0, 0, 0)
	assert_eq(cop.hands.target_offset(), Vector3.ZERO)
	var crate: Grabbable = CRATE_SCENE.instantiate()
	add_child_autofree(crate)
	crate.global_position = Vector3(0, 1.4, -1.2)
	cop.get_node("Grabber").held = crate
	assert_lt(cop.hands.target_offset().z, 0.0, "toward the held thing")
	cop.get_node("Grabber").held = null


func test_hands_hide_behind_the_ram() -> void:
	var cop := _cop()
	cop.equip_ram()
	await wait_frames(2)
	assert_false(cop.hands.visible)
	cop.drop_ram()
	await wait_frames(2)
	assert_true(cop.hands.visible)
