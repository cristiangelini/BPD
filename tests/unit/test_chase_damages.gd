extends GutTest

## The damage to the city in a chase (persecucion.md, "Cómo es el caso"): hard crashes are fined, ramming the suspect
## isn't.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "ice_cream"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


## A wall on the street `ahead` meters in front of the car, and the car rolling into it at `speed`.
func _roll_into_wall(level: ChaseLevel, speed: float, ahead := 8.0) -> void:
	var car := level.case.car
	car.enter(level.get_node("Cop"), 0)
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6, 3, 1)
	shape.shape = box
	wall.add_child(shape)
	level.add_child(wall)
	wall.global_transform = Transform3D(car.global_basis, car.global_position + car.global_basis.z * ahead + Vector3.UP * 1.5)
	await wait_physics_frames(2)
	car.linear_velocity = car.global_basis.z * speed


func test_a_hard_crash_is_a_fine() -> void:
	var level := _level()
	await wait_physics_frames(10)
	await _roll_into_wall(level, 15.0)
	await wait_physics_frames(90)
	var damages := level.case.damages
	assert_eq(damages.crashes, 1, "one crash, however long it scrapes")
	assert_eq(damages.fines, ChaseDamages.FINE)
	assert_true(level.damage_label.visible, "the damage shows at the top")


func test_a_gentle_bump_is_free() -> void:
	var level := _level()
	await wait_physics_frames(10)
	await _roll_into_wall(level, 2.0, 4.0)
	await wait_physics_frames(120)
	assert_eq(level.case.damages.crashes, 0)


func test_ramming_the_suspect_is_free() -> void:
	var level := _level()
	await wait_physics_frames(10)
	var car := level.case.car
	car.enter(level.get_node("Cop"), 0)
	var truck := level.truck
	truck.driving = false
	car.global_transform = Transform3D(truck.global_basis, truck.global_position - truck.global_basis.z * 9.0 + Vector3.UP * 0.3)
	await wait_physics_frames(2)
	car.linear_velocity = car.global_basis.z * 15.0
	await wait_physics_frames(90)
	assert_eq(level.case.damages.crashes, 0)


func test_the_fines_come_off_the_pay() -> void:
	var level := _level()
	await wait_physics_frames(10)
	level.case.damages.fines = 100
	level.case.damages.crashes = 2
	level.case.finish_shift()
	assert_eq(int(level.case._result.report.fines), 100)
	assert_eq(int(level.case._result.report.total), -100, "got away and crashed: no salary, and the fines")
