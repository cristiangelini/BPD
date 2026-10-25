extends GutTest

## Crowded car step 1 (control-auto-lleno.md): in the "crowded_car" variant the queue brings city cars, most with 1 to 4
## riders and some packed with 9 to 22, faces squashed on every window and the body sunk on its wheels. Time is stepped
## by hand, 0.1 s at a time, like test_traffic_queue.gd.

var checkpoint: TrafficCheckpoint
var barrier: RoadBarrier
var queue: TrafficQueue


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	barrier = RoadBarrier.new()
	barrier.freeze = true
	add_child_autofree(barrier)
	barrier.global_transform = checkpoint.global_transform
	for z in [4.0, 7.0]:
		var cone := TrafficCone.new()
		cone.freeze = true
		add_child_autofree(cone)
		cone.global_position = checkpoint.global_transform * Vector3(-1, 0, z)
	checkpoint.ready_now = checkpoint.is_set_up()
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "crowded_car"
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func test_every_car_has_riders_from_its_plate() -> void:
	_tick(40)
	assert_gt(queue.cars.size(), 3)
	for car in queue.cars:
		assert_false(car.clown)
		assert_false(car.fruit)
		assert_eq(car.crowd, CrowdedCar.riders_of(car.plate))
		var few := car.crowd >= CrowdedCar.FEW.x and car.crowd <= CrowdedCar.FEW.y
		var packed := car.crowd >= CrowdedCar.PACKED.x and car.crowd <= CrowdedCar.PACKED.y
		assert_true(few or packed, str(car.crowd))
		assert_not_null(car.lid, "a sedan, with its trunk")


func test_some_plates_come_packed_and_most_dont() -> void:
	var packed := 0
	for i in 200:
		if CrowdedCar.packed(CrowdedCar.riders_of("AB %03d" % i)):
			packed += 1
	assert_between(packed, 30, 90)


func test_a_packed_car_shows_faces_and_sags() -> void:
	var car := _car(15)
	var faces := car.get_node("Faces")
	assert_eq(faces.get_child_count(), mini(15, CrowdedCar.SLOTS.size()))
	assert_almost_eq((car.get_node("Model") as Node3D).position.y, -CrowdedCar.SAG, 0.001)
	var skins := {}
	for face in faces.get_children():
		var skin := face.find_child("skin", true, false)
		assert_not_null(skin)
		var mesh := skin as MeshInstance3D if skin is MeshInstance3D else skin.find_children("*", "MeshInstance3D")[0] as MeshInstance3D
		assert_not_null(mesh.material_override, "tinted")
		skins[(mesh.material_override as StandardMaterial3D).albedo_color] = true
	assert_gt(skins.size(), 1, "not all the same skin")


func test_a_few_riders_show_no_faces() -> void:
	var car := _car(3)
	assert_null(car.get_node_or_null("Faces"))
	assert_eq((car.get_node("Model") as Node3D).position.y, 0.0)


func test_fewer_riders_than_windows_fill_fewer_faces() -> void:
	var car := _car(CrowdedCar.PACKED_FROM)
	assert_eq(car.get_node("Faces").get_child_count(), CrowdedCar.PACKED_FROM)


func test_online_copies_get_the_riders() -> void:
	var car := _car(17)
	assert_eq(car.net_setup().crowd, 17)


func _car(riders: int) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "XY 123"
	car.crowd = riders
	car.at = Vector3(0, 0, 40)
	add_child_autofree(car)
	return car
