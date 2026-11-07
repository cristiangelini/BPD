extends GutTest

## The farm raid's placeholders (docs/diseno/allanamiento-granja.md, decision 380): Don Florencio stands on the floor
## at about a cop's size and his nephew Pancho smaller, the animals stand on their feet at their sizes (a hen under
## half a metre, the cow taller than a pig), and the farm's things load with meshes.

const ANIMALS := {"farm_chicken": [0.3, 0.6], "farm_goat": [0.8, 1.1], "farm_pig": [0.5, 0.8], "farm_cow": [1.3, 1.6]}
const THINGS := ["farm_tractor", "scarecrow", "hay_bale", "chicken_coop", "farm_well", "feed_bell", "egg_basket"]


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


func test_the_farmer_and_his_nephew_stand_on_the_floor() -> void:
	var farmer := _box("npc_florencio")
	assert_almost_eq(farmer.position.y, 0.0, 0.05, "Don Florencio stands on the floor")
	assert_between(farmer.size.y, 1.5, 1.8, "his height, straw hat and all")
	var nephew := _box("npc_pancho")
	assert_almost_eq(nephew.position.y, 0.0, 0.05, "Pancho stands on the floor")
	assert_lt(nephew.size.y, farmer.size.y, "shorter than his uncle")


func test_the_animals_stand_on_their_feet_at_their_sizes() -> void:
	for model: String in ANIMALS:
		var box := _box(model)
		assert_almost_eq(box.position.y, 0.0, 0.05, "%s stands on its feet" % model)
		assert_between(box.size.y, ANIMALS[model][0], ANIMALS[model][1], "%s's height" % model)


func test_the_farms_things_load_with_meshes() -> void:
	for model in THINGS:
		assert_gt(_box(model).size.length(), 0.3, model)
	assert_gt(_box("farm_tractor").size.y, 1.8, "the tractor's exhaust stands above a cop")
