extends GutTest

## The birthday party raid's placeholders (docs/diseno/allanamiento-cumple.md, decision 340): Chispita stands on the
## floor at about a cop's size, the children at a child's once scaled like the school's pupils, and the props load with
## meshes.

const KIDS := ["npc_tomasito", "npc_nene_fiesta", "npc_nena_fiesta"]
const PROPS := ["birthday_cake", "birthday_pinata", "bouncy_castle", "gift_box", "chispita_case"]


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


func test_chispita_stands_on_the_floor_at_a_cops_size() -> void:
	var box := _box("npc_chispita")
	assert_almost_eq(box.position.y, 0.0, 0.05, "Chispita stands on the floor")
	assert_between(box.size.y, 1.4, 1.8, "Chispita's height")


func test_the_children_are_a_childs_size_with_their_party_hats() -> void:
	for model in KIDS:
		var box := _box(model)
		assert_almost_eq(box.position.y, 0.0, 0.05, "%s stands on the floor" % model)
		assert_between(box.size.y * SchoolPupil.KID_SCALE, 1.0, 1.3, "%s, hat and all" % model)


func test_the_props_load_with_meshes() -> void:
	for model in PROPS:
		assert_gt(_box(model).size.length(), 0.3, model)
	assert_almost_eq(_box("bouncy_castle").size.y, 2.5, 0.05, "the castle's towers are 2.5 m tall")
