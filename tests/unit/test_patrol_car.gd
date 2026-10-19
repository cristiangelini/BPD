extends GutTest

## The patrol car (docs/diseno/allanamiento.md, "Patrullero"): getting in and out, only the driver drives.

const CAR_SCENE := preload("res://scenes/vehicles/patrol_car.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _ground() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(400, 0.2, 400)
	shape.shape = box
	floor_body.add_child(shape)
	floor_body.position = Vector3(0, -0.1, 0)
	add_child_autofree(floor_body)


func _car() -> PatrolCar:
	_ground()
	var car: PatrolCar = CAR_SCENE.instantiate()
	add_child_autofree(car)
	return car


func _cop(at: Vector3) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(cop)
	cop.global_position = at
	return cop


func test_cops_take_the_seat_by_their_door() -> void:
	var car := _car()
	var driver := _cop(Vector3(2, 0.1, 0.5))
	var back := _cop(Vector3(-2, 0.1, -0.5))
	assert_eq(car.enter(driver), 0, "left front door is the driver's")
	assert_eq(car.enter(back), 3, "right back door")
	assert_eq(driver.vehicle, car)
	assert_true(driver.is_busy(), "no grabbing from the seat")


func test_a_full_car_takes_no_one_else() -> void:
	var car := _car()
	for i in 4:
		assert_ne(car.enter(_cop(Vector3(2, 0.1, 0))), -1)
	assert_eq(car.enter(_cop(Vector3(2, 0.1, 0))), -1)


func test_getting_out_stands_beside_the_door() -> void:
	var car := _car()
	var cop := _cop(Vector3(2, 0.1, 0.5))
	car.use(cop)
	car.use(cop)
	assert_null(cop.vehicle)
	assert_eq(car.seat_of(cop), -1)
	assert_eq(cop.get_parent(), car.get_parent())
	assert_gt(cop.global_position.x, 1.5, "out by the driver's side")
	assert_false(cop.is_busy())


func test_the_driver_drives_and_tops_out_at_60() -> void:
	var car := _car()
	await wait_physics_frames(30)
	car.enter(_cop(Vector3(2, 0.1, 0.5)))
	car.drive(1.0, 0.0, false)
	await wait_seconds(6.0)
	assert_gt(car.forward_speed(), PatrolCar.MAX_SPEED * 0.8, "gets close to top speed")
	assert_lt(car.forward_speed(), PatrolCar.MAX_SPEED + 1.0, "but no faster")
	assert_gt(car.global_position.z, 20.0, "moved forward")


func test_without_a_driver_the_car_stays_put() -> void:
	var car := _car()
	await wait_physics_frames(30)
	car.enter(_cop(Vector3(-2, 0.1, 0.5)))
	car.drive(1.0, 0.0, false)
	await wait_seconds(1.0)
	assert_almost_eq(car.global_position.z, 0.0, 0.2, "a passenger can't drive")


func test_seated_cops_ride_along() -> void:
	var car := _car()
	await wait_physics_frames(30)
	var cop := _cop(Vector3(2, 0.1, 0.5))
	car.enter(cop)
	car.drive(1.0, 0.0, false)
	await wait_seconds(2.0)
	assert_almost_eq(cop.global_position.z, car.to_global(Vector3(0.5, 0.3, 0.55)).z, 0.05)


func test_siren_toggles() -> void:
	var car := _car()
	car.toggle_siren()
	assert_true(car.siren_on)
	car.toggle_siren()
	assert_false(car.siren_on)


func test_a_hard_turn_at_top_speed_does_not_tip_over() -> void:
	var car := _car()
	await wait_physics_frames(30)
	car.enter(_cop(Vector3(2, 0.1, 0.5)))
	car.drive(1.0, 0.0, false)
	await wait_seconds(5.0)
	car.drive(1.0, 1.0, false)
	await wait_seconds(2.0)
	assert_gt(car.global_basis.y.y, 0.9, "still on its wheels")
	car.drive(0.0, -1.0, true)
	await wait_seconds(2.0)
	assert_gt(car.global_basis.y.y, 0.9, "handbrake slide too")
