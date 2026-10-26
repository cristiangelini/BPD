extends GutTest

## Circus move step 1 (control-circo.md): in the "circus_move" variant most of the queue are the circus's striped
## trucks, each with a cage on its bed, its number over the door and an animal in it; a few city cars come among them.

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
	queue.variant = "circus_move"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _truck(traits: Dictionary) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "CI 138"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.circus_mode = true
	car.circus = traits
	car.at = Vector3(0, 0, 40)
	add_child_autofree(car)
	return car


func test_the_queue_is_mostly_circus_trucks_with_a_few_city_cars() -> void:
	var trucks := 0
	for i in 20:
		var car := queue.spawn()
		car.set_physics_process(false)
		assert_true(car.circus_mode)
		assert_eq(car.circus, CircusTruck.traits_of(car.plate), "its plate's, without a plan")
		if car.circus.is_empty():
			assert_null(CircusTruck.animal_of(car), "a city car carries no cage")
			assert_not_null(car.lid, "and has its trunk")
		else:
			trucks += 1
			assert_not_null(CircusTruck.animal_of(car))
	assert_between(trucks, 8, 19)


func test_a_truck_has_its_cage_door_number_and_animal() -> void:
	var car := _truck({"animal": "zebra", "stripes": 2, "cage": 7})
	assert_not_null(car.get_node_or_null("Cage/Door"))
	assert_eq((car.get_node("Cage/Number") as Label3D).text, tr("CIRCUS_CAGE") % 7)
	var animal := CircusTruck.animal_of(car)
	assert_eq(animal.scene_file_path, CircusTruck.ANIMAL_MODELS[CircusTruck.ANIMALS.find("zebra")].resource_path)
	assert_almost_eq(animal.global_basis.z.dot(car.global_basis.z), -1.0, 0.01, "facing the door, at the back")
	assert_true(car.get_node("Cage/Door").position.z < animal.position.z)


func test_the_stripes_are_painted() -> void:
	var car := _truck({"animal": "lion", "stripes": 3, "cage": 1})
	var stripes := car.get_node("Model").find_children("paint*", "MeshInstance3D", true, false)
	stripes.append_array(car.get_node("Model").find_children("*", "MeshInstance3D", true, false).filter(
		func(m: MeshInstance3D) -> bool: return m.get_parent().name == "paint"))
	assert_gt(stripes.size(), 0)
	var paint := (stripes[0] as MeshInstance3D).material_override as StandardMaterial3D
	assert_eq(paint.albedo_color, CircusTruck.STRIPES[3])


func test_traits_come_from_the_plate_and_cover_every_kind() -> void:
	var animals := {}
	var stripes := {}
	var cities := 0
	for i in 200:
		var traits := CircusTruck.traits_of("CI %03d" % i)
		assert_eq(traits, CircusTruck.traits_of("CI %03d" % i))
		if traits.is_empty():
			cities += 1
			continue
		animals[traits.animal] = true
		stripes[traits.stripes] = true
		assert_between(int(traits.cage), CircusTruck.CAGES.x, CircusTruck.CAGES.y)
	assert_eq(animals.size(), CircusTruck.ANIMALS.size())
	assert_eq(stripes.size(), CircusTruck.STRIPES.size())
	assert_between(cities, 30, 90)


func test_texts_are_translated() -> void:
	for key in CircusTruck.ANIMAL_NAMES + CircusTruck.STRIPE_NAMES + ["CIRCUS_CAGE", "CIRCUS_SIGN"]:
		assert_ne(tr(key), key)
