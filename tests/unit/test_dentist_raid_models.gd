extends GutTest

## The dentist raid's placeholders (docs/diseno/allanamiento-dentista.md, decision 460): Dr. Molina and Lucho stand on
## the floor at about a cop's size, the chair is big enough to sit a cop in, and the office's things load with meshes.

const THINGS := ["dentist_chair", "dental_drill", "xray_lightbox", "fish_tank", "gas_tank", "mold_cabinet",
	"denture_mold", "candy_jar", "candy_pop", "next_bell"]


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


func test_the_dentist_and_lucho_stand_on_the_floor() -> void:
	var dentist := _box("npc_molina")
	assert_almost_eq(dentist.position.y, 0.0, 0.05, "Dr. Molina stands on the floor")
	assert_between(dentist.size.y, 1.45, 1.7, "his height, loupes and all")
	var kid := _box("npc_lucho")
	assert_almost_eq(kid.position.y, 0.0, 0.05, "Lucho stands on the floor")


func test_the_chair_fits_a_cop_and_the_things_load() -> void:
	var chair := _box("dentist_chair")
	assert_almost_eq(chair.position.y, 0.0, 0.05, "the chair stands on the floor")
	assert_gt(chair.size.x, 0.6, "wide enough to sit a cop in")
	assert_gt(chair.size.z, 1.4, "long enough to lie back in")
	for model: String in THINGS:
		assert_gt(_box(model).size.length(), 0.1, model)
	assert_gt(_box("fish_tank").size.y, 1.2, "the fish tank on its cabinet is at a cop's eyes")
	assert_lt(_box("candy_pop").size.y, 0.2, "a candy is small enough for one hand")
