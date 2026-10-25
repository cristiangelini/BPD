extends GutTest

## Ghost car step 1 (control-auto-fantasma.md): in the "ghost_car" variant every driver in the queue leans on their
## open window, but one car has nobody there: its front wheels steer by themselves, its antenna blinks and E at its
## window gets no papers. Time is stepped by hand, 0.1 s at a time, like test_crowded_car_cars.gd.

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
	queue.variant = "ghost_car"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func test_one_car_of_the_queue_is_the_ghost() -> void:
	_tick(60)
	assert_gt(queue.spawned, GhostCar.AT.y)
	var ghosts := 0
	for i in queue.get_child_count():
		var car := queue.get_child(i) as QueueCar
		assert_true(car.ghost_mode)
		if car.ghost:
			ghosts += 1
			assert_eq(String(car.name), "QueueCar%d" % GhostCar.ghost_at(5))
	assert_eq(ghosts, 1)


func test_the_ghost_car_is_somewhere_up_front() -> void:
	for case_seed in 50:
		var at := GhostCar.ghost_at(case_seed)
		assert_between(at, GhostCar.AT.x, GhostCar.AT.y)


func test_drivers_lean_on_their_windows_and_the_ghost_has_none() -> void:
	var normal := _car(false)
	var driver := normal.get_node("WindowDriver") as Node3D
	assert_not_null(driver)
	assert_null(normal.get_node_or_null("Antenna"))
	var shirt := driver.find_child("shirt", true, false)
	var mesh := shirt as MeshInstance3D if shirt is MeshInstance3D else shirt.find_children("*", "MeshInstance3D")[0] as MeshInstance3D
	assert_not_null(mesh.material_override, "tinted")
	var ghost := _car(true)
	assert_null(ghost.get_node_or_null("WindowDriver"))
	assert_not_null(ghost.get_node_or_null("Antenna"))


func test_its_front_wheels_steer_by_themselves_and_its_light_blinks() -> void:
	var ghost := _car(true)
	ghost.set_physics_process(false)
	var steer := {}
	var lit := {}
	for i in 20:
		ghost._physics_process(0.1)
		steer[snappedf((ghost.get_node("Wheel0") as Node3D).rotation.y, 0.01)] = true
		lit[(ghost.find_child("tip", true, false) as Node3D).visible] = true
		assert_eq((ghost.get_node("Wheel2") as Node3D).rotation.y, 0.0, "the back wheels stay straight")
	assert_gt(steer.size(), 3)
	assert_eq(lit.size(), 2)
	var normal := _car(false)
	normal.set_physics_process(false)
	for i in 10:
		normal._physics_process(0.1)
	assert_eq((normal.get_node("Wheel0") as Node3D).rotation.y, 0.0)


func test_e_at_its_empty_window_gets_no_papers() -> void:
	var ghost := _car(true)
	ghost.state = "waiting"
	ghost.use(null)
	assert_false(ghost.papers_checked)
	assert_eq(ghost.saying(), tr("GHOST_NOBODY_0"))
	ghost.use(null)
	assert_eq(ghost.saying(), tr("GHOST_NOBODY_1"))
	var normal := _car(false)
	normal.state = "waiting"
	normal.use(null)
	assert_true(normal.papers_checked)


func test_it_says_nothing_at_the_barrier() -> void:
	_tick(20)
	for car in queue.cars:
		if car.ghost:
			assert_false(car.said_line)


func test_online_copies_know_the_ghost() -> void:
	var ghost := _car(true)
	assert_true(ghost.net_setup().ghost)
	assert_true(ghost.net_setup().ghost_mode)


func _car(is_ghost: bool) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "GH 404"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.ghost_mode = true
	car.ghost = is_ghost
	car.at = Vector3(0, 0, 40)
	add_child_autofree(car)
	return car
