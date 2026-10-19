extends GutTest

## Placeholder body of the cop: one uniform per player and the own body hidden from the own camera.

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const OWN_MASK := 1 << (Cop.OWN_BODY_LAYER - 1)


func _meshes(cop: Cop) -> Array[Node]:
	return cop.model.find_children("*", "MeshInstance3D", true, false)


func test_local_cop_does_not_see_its_own_body() -> void:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	assert_eq(cop.camera.cull_mask & OWN_MASK, 0)
	assert_gt(_meshes(cop).size(), 0)
	for mesh in _meshes(cop):
		assert_eq((mesh as VisualInstance3D).layers, OWN_MASK)


func test_other_cops_stay_visible() -> void:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	for mesh in _meshes(cop):
		assert_eq((mesh as VisualInstance3D).layers & OWN_MASK, 0)


func test_set_uniform_swaps_the_model() -> void:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	var before := cop.model
	cop.set_uniform(2)
	assert_ne(cop.model, before)
	assert_eq(cop.model.name, "Model")
	assert_eq(cop.model.scene_file_path, "res://assets/models/cop_2.glb")
	for mesh in _meshes(cop):
		assert_eq((mesh as VisualInstance3D).layers, OWN_MASK)
