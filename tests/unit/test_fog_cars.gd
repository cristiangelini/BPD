extends GutTest

## Fog check step 1 (control-neblina.md): in the "fog" variant the city is under a thick fog and every car comes with
## its headlights on, white, yellow or bluish, one of them maybe broken; its halo shows through the fog.

const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")

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
	queue.variant = "fog"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _car(traits: Dictionary) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "NB 137"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.fog_mode = true
	car.fog = traits
	car.at = Vector3(0, 0, 40)
	add_child_autofree(car)
	return car


func test_every_car_in_the_queue_has_its_headlights_on() -> void:
	for i in 4:
		var car := queue.spawn()
		car.set_physics_process(false)
		assert_true(car.fog_mode)
		assert_eq(car.fog, FogCar.traits_of(car.plate), "its plate's, without a plan")
		assert_not_null(car.get_node_or_null("Lamp"))
		assert_not_null(car.get_node_or_null("LampLeft"))


func test_the_headlights_come_in_three_colors_and_one_may_be_broken() -> void:
	var car := _car({"lights": 1, "broken": 0, "horn": 3})
	assert_true(FogCar.lit(car, true))
	assert_true(FogCar.lit(car, false))
	assert_eq((car.get_node("Lamp/Beam") as SpotLight3D).light_color, FogCar.LIGHTS[1])
	var left_out := _car({"lights": 0, "broken": 1, "horn": 0})
	assert_false(FogCar.lit(left_out, true), "the left one's dark")
	assert_true(FogCar.lit(left_out, false))
	assert_gt(left_out.get_node("LampLeft").position.x, 0.0, "the driver's left, on a car facing +Z")
	var right_out := _car({"lights": 2, "broken": 2, "horn": 0})
	assert_true(FogCar.lit(right_out, true))
	assert_false(FogCar.lit(right_out, false))


func test_the_halo_isn_t_swallowed_by_the_fog() -> void:
	var car := _car({"lights": 0, "broken": 0, "horn": 0})
	var halo := car.get_node("Lamp/Halo") as MeshInstance3D
	var glow := (halo.mesh as QuadMesh).material as StandardMaterial3D
	assert_true(glow.disable_fog)
	assert_eq(glow.billboard_mode, BaseMaterial3D.BILLBOARD_ENABLED)


func test_traits_come_from_the_plate_and_cover_every_kind() -> void:
	var lights := {}
	var broken := {}
	var horns := {}
	for i in 80:
		var traits := FogCar.traits_of("NB %03d" % i)
		assert_eq(traits, FogCar.traits_of("NB %03d" % i))
		lights[traits.lights] = true
		broken[traits.broken] = true
		horns[traits.horn] = true
	assert_eq(lights.size(), FogCar.LIGHTS.size())
	assert_eq(broken.size(), FogCar.BROKEN.size())
	assert_eq(horns.size(), FogCar.HORNS)


func test_the_fog_level_is_foggy_and_the_others_aren_t() -> void:
	var foggy: TrafficControlLevel = LEVEL_SCENE.instantiate()
	foggy.case_seed = 3
	foggy.variant = "fog"
	add_child_autofree(foggy)
	var env := (foggy.get_node("Environment") as WorldEnvironment).environment
	assert_true(env.fog_enabled)
	assert_almost_eq(env.fog_density, FogCar.DENSITY, 0.001)
	assert_almost_eq((foggy.get_node("Sun") as DirectionalLight3D).light_energy, FogCar.SUN_ENERGY, 0.001)
	var clear: TrafficControlLevel = LEVEL_SCENE.instantiate()
	clear.case_seed = 3
	clear.variant = "rush_hour"
	add_child_autofree(clear)
	assert_false((clear.get_node("Environment") as WorldEnvironment).environment.fog_enabled, "the fog stays put")


func test_texts_are_translated() -> void:
	for key in FogCar.LIGHT_NAMES + FogCar.BROKEN:
		assert_ne(tr(key), key)
