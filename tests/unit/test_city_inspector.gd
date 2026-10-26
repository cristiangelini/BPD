extends GutTest

## The city's inspector (inspeccion.md, step 2, decision 107): on the campaign's last shift she comes into the case,
## follows the cops, rides in the back of the patrol car and gets out once nobody drives it.

const LEVEL := preload("res://scenes/levels/grandpa_house.tscn")

var level: Node3D
var cop: Cop
var car: PatrolCar


func before_each() -> void:
	Campaign.current = null
	level = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	cop = level.get_node("Cop")
	car = level.get_node("PatrolCar")
	await wait_physics_frames(10)


func after_each() -> void:
	Campaign.current = null


func test_she_comes_only_on_the_last_shift() -> void:
	var campaign := Campaign.start_new()
	assert_false(CityInspector.due())
	assert_null(CityInspector.join(cop))
	campaign.shift = Campaign.SHIFTS
	assert_true(CityInspector.due())
	assert_not_null(CityInspector.join(cop))
	assert_null(CityInspector.join(cop), "only one")


func test_she_follows_the_cop() -> void:
	Campaign.start_new().shift = Campaign.SHIFTS
	var inspector := CityInspector.join(cop)
	cop.global_position = car.to_global(Vector3(3.5, 0, -6))
	await wait_physics_frames(360)
	assert_lt(inspector.global_position.distance_to(cop.global_position), CityInspector.FOLLOW + 1.0)


func test_she_rides_the_car_and_gets_out() -> void:
	Campaign.start_new().shift = Campaign.SHIFTS
	var inspector := CityInspector.join(cop)
	inspector.global_position = car.to_global(Vector3(2.0, 0, -1))
	car.enter(cop, 0)
	await wait_physics_frames(5)
	assert_eq(inspector.car, car, "in the back")
	assert_eq(inspector.collision_layer, 0)
	car.exit(cop)
	await wait_physics_frames(5)
	assert_null(inspector.car)
	assert_eq(inspector.collision_layer, 1, "solid again")
	assert_gt(inspector.global_position.distance_to(car.global_position), car.body_half_size().y)


func test_the_cuffs_dont_close_on_her() -> void:
	Campaign.start_new().shift = Campaign.SHIFTS
	var inspector := CityInspector.join(cop)
	inspector.cuffed(Handcuffs.SECONDS)
	assert_false(inspector.is_cuffed())
	assert_eq(inspector.said(), "INSPECTOR_CUFFED")
