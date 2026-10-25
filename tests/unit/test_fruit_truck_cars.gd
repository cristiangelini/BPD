extends GutTest

## Fruit truck step 1 (control-frutas.md): in the "fruit_truck" variant every car in the queue is a fruit seller's
## pickup, tinted by its color, with 6 to 10 watermelons in its open bed, one crate of another fruit, a sign with the
## seller's name and no trunk. Time is stepped by hand, 0.1 s at a time, like test_traffic_queue.gd.

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
	queue.variant = "fruit_truck"
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func test_every_car_is_a_fruit_truck_with_watermelons() -> void:
	_tick(20)
	assert_gt(queue.cars.size(), 2)
	for car in queue.cars:
		assert_true(car.fruit)
		assert_false(car.clown)
		var melons := car.get_node("Bed").get_child_count()
		assert_between(melons, QueueCar.FRUIT_MELONS.x, QueueCar.FRUIT_MELONS.y)
		assert_eq(melons, car.melons())
		assert_null(car.lid, "an open bed, no trunk")
		assert_eq((car.get_node("Plate") as Label3D).text, car.plate)


func test_the_sign_has_the_seller_name() -> void:
	_tick(1)
	var car := queue.front()
	var sign := car.get_node("Sign") as Label3D
	assert_eq(sign.text, tr("FRUIT_SIGN") % car.driver.name)
	assert_string_contains(sign.text, car.driver.name)


func test_it_shows_only_its_own_crate() -> void:
	_tick(1)
	var car := queue.front()
	assert_has(QueueCar.FRUIT_CRATES, car.crate)
	for kind in QueueCar.FRUIT_CRATES:
		var node := car.find_child("crate_" + kind, true, false) as Node3D
		assert_not_null(node, kind)
		assert_eq(node.visible, kind == car.crate, kind)


func test_its_paint_is_its_color() -> void:
	_tick(1)
	var car := queue.front()
	var tinted := 0
	for mesh in car.get_node("Model").find_children("*", "MeshInstance3D", true, false):
		var material := (mesh as MeshInstance3D).material_override as StandardMaterial3D
		if material:
			tinted += 1
			assert_eq(material.albedo_color, QueueCar.FRUIT_PAINTS[car.look])
	assert_gt(tinted, 0)


func test_the_trucks_queue_up_like_cars() -> void:
	_tick(25)
	var first := queue.front()
	var second := queue.cars[1]
	assert_true(first.waiting())
	assert_true(second.waiting())
	assert_almost_eq(second.at.z - first.at.z, QueueCar.LENGTH + QueueCar.GAP, 0.1)


func test_e_still_asks_for_the_license_and_cuffs_still_work() -> void:
	_tick(25)
	var car := queue.front()
	car.use(null)
	assert_true(car.papers_checked)
	assert_eq(car.net_state(), [car.state, false])
	car.open_trunk()


func test_a_guest_copy_knows_it_is_a_fruit_truck() -> void:
	_tick(1)
	var setup := queue.front().net_setup()
	assert_true(setup.fruit)
	assert_eq(setup.crate, queue.front().crate)


func test_the_level_takes_the_variant_from_the_args() -> void:
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=fruit_truck"])), "fruit_truck")


func test_the_sign_is_translated() -> void:
	assert_ne(tr("FRUIT_SIGN"), "FRUIT_SIGN")
