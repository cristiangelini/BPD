extends GutTest

## The pizzeria raid's placeholders (docs/diseno/allanamiento-pizzeria.md, decision 490): Don Muzza and Tito stand on
## the floor at about a cop's size, the oven's mouth is at a cop's hands and the pizzeria's things load with meshes.

const THINGS := ["clay_oven", "dough_table", "dough_ball", "pizza_slice", "kitchen_plate", "pizza_box", "flour_sack",
	"desk_phone", "pizza_scooter"]


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


func test_don_muzza_and_tito_stand_on_the_floor() -> void:
	for npc: String in ["npc_muzza", "npc_tito"]:
		var box := _box(npc)
		assert_almost_eq(box.position.y, 0.0, 0.05, "%s stands on the floor" % npc)
		assert_between(box.size.y, 1.45, 1.7, "%s is about a cop's height" % npc)


func test_the_oven_is_big_and_the_things_load() -> void:
	var oven := _box("clay_oven")
	assert_almost_eq(oven.position.y, 0.0, 0.05, "the oven stands on the floor")
	assert_gt(oven.size.y, 1.5, "taller than a cop's hands")
	assert_gt(_box("dough_table").size.x, 1.5, "room for the dough balls")
	for model: String in THINGS:
		assert_gt(_box(model).size.length(), 0.1, model)
	assert_lt(_box("pizza_slice").size.x, 0.4, "a slice is small enough for one hand")
