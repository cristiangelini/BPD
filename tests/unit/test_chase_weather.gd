extends GutTest

## The rain and the night chases (persecucion.md, "Los sospechosos"): wet tires and a windshield nobody clears; a dark
## city where only the copilot's flashlight finds the getaway car.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level(suspect: String) -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = suspect
	add_child_autofree(level)
	return level


func test_in_the_rain_the_tires_grip_less_everywhere() -> void:
	var level := _level("rain")
	await wait_physics_frames(5)
	var wheel: VehicleWheel3D = level.case.car.get_node("WheelFrontLeft")
	var grip := PatrolCar.GRIP
	assert_almost_eq(wheel.wheel_friction_slip, grip * ChaseWeather.RAIN_GRIP, 0.01, "the wet street")
	assert_not_null(level.case.weather.rain, "it rains around the patrol car")
	assert_eq(level.truck.kind, "rain", "he drives the getaway car")


func test_in_the_rain_only_the_driver_sees_the_windshield_drops() -> void:
	var level := _level("rain")
	await wait_physics_frames(5)
	var cop: Cop = level.get_node("Cop")
	var windshield := level.case.weather.windshield
	assert_false(windshield.visible, "on foot, no windshield")
	level.case.car.enter(cop, 0)
	await wait_physics_frames(3)
	assert_true(windshield.visible, "at the wheel, the drops the wiper never clears")
	assert_eq(windshield.drops.size(), ChaseWeather.WINDSHIELD_DROPS)


func test_the_rain_chase_keeps_the_scene_environment_untouched() -> void:
	var level := _level("rain")
	await wait_physics_frames(3)
	var fresh: Node3D = LEVEL_SCENE.instantiate()
	assert_false((fresh.get_node("Environment") as WorldEnvironment).environment.fog_enabled, "the scene's own sky")
	assert_true((level.get_node("Environment") as WorldEnvironment).environment.fog_enabled, "this chase's copy")
	fresh.free()


func test_at_night_the_map_shows_him_only_in_the_flashlight() -> void:
	var level := _level("night")
	await wait_physics_frames(5)
	var cop: Cop = level.get_node("Cop")
	var weather := level.case.weather
	assert_lt(level.case.sun.light_energy, 0.2, "the city is dark")
	assert_eq(cop.belt.flashlight.light.spot_range, ChaseWeather.NIGHT_BEAM, "the flashlight reaches farther")
	assert_false(weather.shows_suspect(), "in the dark the map doesn't find him")
	cop.global_position = level.truck.global_position - level.truck.global_basis.z * 12.0
	await wait_physics_frames(2)
	var flashlight := cop.belt.flashlight
	flashlight.toggle()
	var aim := level.truck.global_position + Vector3.UP * 0.8
	cop.camera.look_at(aim)
	await wait_physics_frames(2)
	assert_true(weather.shows_suspect(), "lit up, the map shows him")
	cop.camera.look_at(cop.camera.global_position - (aim - cop.camera.global_position))
	await wait_physics_frames(2)
	assert_false(weather.shows_suspect(), "looking the other way, he's gone again")


func test_by_day_the_weather_changes_nothing() -> void:
	var level := _level("ice_cream")
	await wait_physics_frames(5)
	assert_true(level.case.weather.shows_suspect())
	assert_null(level.case.weather.rain)
	assert_null(level.case.weather.windshield)
	assert_eq(level.case.drops.weather_grip, 1.0)
