extends GutTest

## The old patrol car behind the station (persecucion-lugares.md, "La grúa"): slower, it brakes worse, and its siren
## is a cop shouting out of the window.

const CAR_SCENE := preload("res://scenes/vehicles/patrol_car.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _ground() -> void:
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(600, 0.2, 600)
	shape.shape = box
	floor_body.add_child(shape)
	floor_body.position = Vector3(0, -0.1, 0)
	add_child_autofree(floor_body)


func _car(old: bool, x := 0.0) -> PatrolCar:
	var car: PatrolCar = CAR_SCENE.instantiate()
	car.old = old
	add_child_autofree(car)
	car.global_position = Vector3(x, 0.05, -250)
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(cop)
	car.enter(cop, 0)
	return car


func test_it_looks_old_and_tops_out_at_45() -> void:
	_ground()
	var car := _car(true)
	assert_eq(car.get_node("Model").scene_file_path, PatrolCar.OLD_MODEL.resource_path, "the faded one with rust")
	await wait_physics_frames(30)
	car.drive(1.0, 0.0, false)
	await wait_seconds(7.0)
	assert_gt(car.forward_speed(), PatrolCar.OLD_SPEED * 0.8, "it gets going")
	assert_lt(car.forward_speed(), PatrolCar.OLD_SPEED + 1.0, "but no faster than 45")


func test_it_brakes_worse_than_the_good_one() -> void:
	_ground()
	var cars: Array[PatrolCar] = [_car(false, -10.0), _car(true, 10.0)]
	await wait_physics_frames(30)
	var stops: Array[float] = []
	for car in cars:
		car.linear_velocity = car.global_basis.z * 12.0
	await wait_physics_frames(2)
	var from: Array[float] = [cars[0].global_position.z, cars[1].global_position.z]
	for car in cars:
		car.drive(-1.0, 0.0, false)
	await wait_seconds(4.0)
	for k in 2:
		stops.append(cars[k].global_position.z - from[k])
	assert_gt(stops[1], stops[0] + 2.0, "the old one needs more road to stop")


func test_its_siren_is_a_cop_shouting() -> void:
	_ground()
	var car := _car(true)
	await wait_physics_frames(3)
	car.toggle_siren()
	assert_false(car.siren_on, "the siren doesn't work")
	assert_false(car.get_node("SirenRed").visible)
	assert_eq(car.uiuus, 1)
	var shout: Label3D = car._shout
	assert_true(shout.visible, "someone shouts it instead")
	TranslationServer.set_locale("es")
	assert_eq(tr(shout.text), "¡Uiuuu! ¡Uiuuu!")
	await wait_seconds(PatrolCar.SHOUT_SECONDS + 0.3)
	assert_false(shout.visible)
