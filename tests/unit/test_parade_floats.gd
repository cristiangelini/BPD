extends GutTest

## Parade step 1 (control-desfile.md): in the "parade" variant most of the queue are the parade's floats, each with
## its theme on the front, its number on both sides and 3 to 5 masked dancers on the back; a few city cars come among
## them.

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "parade"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _float(traits: Dictionary) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "DE 139"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.parade_mode = true
	car.parade = traits
	car.at = Vector3(0, 0, 40)
	add_child_autofree(car)
	return car


func test_the_queue_is_mostly_floats_with_a_few_city_cars() -> void:
	var floats := 0
	for i in 20:
		var car := queue.spawn()
		car.set_physics_process(false)
		assert_true(car.parade_mode)
		assert_eq(car.parade, ParadeFloat.traits_of(car.plate), "its plate's, without a plan")
		if car.parade.is_empty():
			assert_eq(ParadeFloat.dancers_of(car).size(), 0, "a city car carries no dancers")
			assert_not_null(car.lid, "and has its trunk")
		else:
			floats += 1
			assert_eq(ParadeFloat.dancers_of(car).size(), car.parade.dancers.size())
	assert_between(floats, 8, 19)


func test_a_float_has_its_theme_signs_and_dancers_facing_back() -> void:
	var dancers := [{"mask": 0, "held": 1}, {"mask": 2, "held": 3}, {"mask": 4, "held": 0}]
	var car := _float({"theme": "whale", "skirt": 1, "number": 17, "dancers": dancers})
	assert_eq(car.get_node("Theme").scene_file_path,
		ParadeFloat.THEME_MODELS[ParadeFloat.THEMES.find("whale")].resource_path)
	assert_eq((car.get_node("Sign") as Label3D).text, tr("PARADE_SIGN") % 17)
	assert_eq((car.get_node("SignLeft") as Label3D).text, tr("PARADE_SIGN") % 17)
	var on := ParadeFloat.dancers_of(car)
	assert_eq(on.size(), 3)
	for dancer in on:
		assert_almost_eq(dancer.global_basis.z.normalized().dot(car.global_basis.z), -1.0, 0.01, "facing the cops")
		assert_lt(dancer.position.z, car.get_node("Theme").position.z, "behind the theme")
		assert_not_null(dancer.get_node_or_null("Look/ArmRight/Held"))
		assert_not_null(dancer.get_node_or_null("Look/ArmLeft/Held"))
	var held: Node3D = on[1].get_node("Look/ArmRight/Held")
	assert_eq(held.scene_file_path, ParadeFloat.HELD_MODELS[3].resource_path)


func test_masks_and_skirts_are_painted() -> void:
	var car := _float({"theme": "cake", "skirt": 3, "number": 2, "dancers": [{"mask": 1, "held": 0}]})
	var mask := _painted(car.get_node("Dancers/Dancer0/Look/Body"), "mask")
	assert_gt(mask.size(), 0)
	assert_eq((mask[0].material_override as StandardMaterial3D).albedo_color, ParadeFloat.MASKS[1])
	var skirt := _painted(car.get_node("Model"), "paint")
	assert_gt(skirt.size(), 0)
	assert_eq((skirt[0].material_override as StandardMaterial3D).albedo_color, ParadeFloat.SKIRTS[3])


func _painted(node: Node, part: String) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for mesh in node.find_children("*", "MeshInstance3D", true, false):
		if mesh.name.begins_with(part) or mesh.get_parent().name == part:
			out.append(mesh)
	return out


func test_traits_come_from_the_plate_and_cover_every_kind() -> void:
	var themes := {}
	var masks := {}
	var held := {}
	var cities := 0
	for i in 200:
		var traits := ParadeFloat.traits_of("DE %03d" % i)
		assert_eq(traits, ParadeFloat.traits_of("DE %03d" % i))
		if traits.is_empty():
			cities += 1
			continue
		themes[traits.theme] = true
		assert_between(int(traits.number), ParadeFloat.NUMBERS.x, ParadeFloat.NUMBERS.y)
		assert_between(traits.dancers.size(), ParadeFloat.DANCERS.x, ParadeFloat.DANCERS.y)
		for dancer: Dictionary in traits.dancers:
			masks[dancer.mask] = true
			held[dancer.held] = true
	assert_eq(themes.size(), ParadeFloat.THEMES.size())
	assert_eq(masks.size(), ParadeFloat.MASKS.size())
	assert_eq(held.size(), ParadeFloat.HELD.size())
	assert_between(cities, 30, 90)


func test_texts_are_translated() -> void:
	for key in ParadeFloat.THEME_NAMES + ParadeFloat.MASK_NAMES + ParadeFloat.HELD_NAMES + ["PARADE_SIGN"]:
		assert_ne(tr(key), key)
