extends GutTest

## The gym raid's placeholders (docs/diseno/allanamiento-gimnasio.md, decision 250): el profe Fito and Lula stand on the
## floor at about the cop's size, and the props load with meshes.

const PEOPLE := ["npc_profe_fito", "npc_lula", "gym_mannequin"]
const PROPS := ["gym_stereo", "gym_record_wall", "gym_record_bar"]


func _box(model: String) -> AABB:
	var scene: PackedScene = load("res://assets/models/%s.glb" % model)
	assert_not_null(scene, model)
	var node: Node3D = scene.instantiate()
	add_child_autofree(node)
	var meshes := node.find_children("*", "MeshInstance3D", true, false)
	assert_gt(meshes.size(), 0, model)
	var box := AABB()
	for i in meshes.size():
		var mesh := meshes[i] as MeshInstance3D
		var part := mesh.global_transform * mesh.get_aabb()
		box = part if i == 0 else box.merge(part)
	return box


func test_the_people_stand_on_the_floor_at_a_cops_size() -> void:
	for model in PEOPLE:
		var box := _box(model)
		assert_almost_eq(box.position.y, 0.0, 0.05, "%s stands on the floor" % model)
		assert_between(box.size.y, 1.4, 1.8, "%s height" % model)


func test_the_props_load_with_meshes() -> void:
	for model in PROPS:
		assert_gt(_box(model).size.length(), 0.3, model)
	assert_almost_eq(_box("gym_record_bar").size.x, 1.8, 0.05, "the record bar is 1.8 m long")
