extends GutTest

## The approved NPC placeholders (decision 72) exist and stand on the floor at about the cop's size.

const NPCS := ["comisario", "abuelo", "sospechoso", "vecina", "periodista", "asuntos_internos", "carcelero",
	"preso", "abogado", "politico"]


func test_every_npc_model_loads_with_meshes() -> void:
	for npc in NPCS:
		var scene: PackedScene = load("res://assets/models/npc_%s.glb" % npc)
		assert_not_null(scene, npc)
		var node: Node3D = scene.instantiate()
		add_child_autofree(node)
		var meshes := node.find_children("*", "MeshInstance3D", true, false)
		assert_gt(meshes.size(), 0, npc)
		var box := AABB()
		for i in meshes.size():
			var mesh := meshes[i] as MeshInstance3D
			var part := mesh.global_transform * mesh.get_aabb()
			box = part if i == 0 else box.merge(part)
		assert_almost_eq(box.position.y, 0.0, 0.05, "%s stands on the floor" % npc)
		assert_between(box.size.y, 1.4, 1.8, "%s height" % npc)
