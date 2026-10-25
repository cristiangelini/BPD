class_name CityRain
extends Node3D

## The city's rain (ciudad-viva.md, step 6): 1 shift in 4 it rains for a while. It falls around whoever is looking,
## the sky turns grey, the street gets dark and shiny with puddles, the patrol car grips less (like in the rainy
## chase), the cars slow down and the people hurry. Every number here is (propuesta).

const CHANCE := 4
## When it starts (s into the shift) and how long it lasts (s).
const START_MIN := 60.0
const START_MAX := 600.0
const LENGTH_MIN := 180.0
const LENGTH_MAX := 360.0
## Seconds the rain takes to come and to go.
const FADE := 10.0
const CAR_SLOW := 20.0 / 30.0
const WALK_FAST := 1.4
const PUDDLES := 40
const WET_ROUGHNESS := 0.2
const DRY_ROUGHNESS := 0.9
const PUDDLE := Color(0.22, 0.27, 0.36)

## The shift's rain: from `start` for `length` seconds, or never (length 0).
var start := 0.0
var length := 0.0
## Seconds since the shift began, and how wet it is now (0 dry, 1 pouring).
var time := 0.0
var wet := 0.0
var clock: CityClock
## The street's materials that shine when wet.
var streets: Array[StandardMaterial3D] = []
var _drops: CPUParticles3D
var _puddles: Array[MeshInstance3D] = []


## The rain of the shift with `seed_value`: {start, length}, length 0 when it doesn't rain.
static func plan(seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["city rain", seed_value])
	if rng.randi() % CHANCE != 0:
		return {"start": 0.0, "length": 0.0}
	return {"start": rng.randf_range(START_MIN, START_MAX), "length": rng.randf_range(LENGTH_MIN, LENGTH_MAX)}


func _ready() -> void:
	_drops = CPUParticles3D.new()
	_drops.name = "Drops"
	_drops.amount = ChaseWeather.RAIN_DROPS
	_drops.lifetime = 1.0
	_drops.local_coords = false
	_drops.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_drops.emission_box_extents = ChaseWeather.RAIN_AREA / 2
	_drops.direction = Vector3.DOWN
	_drops.spread = 4.0
	_drops.initial_velocity_min = 14.0
	_drops.initial_velocity_max = 16.0
	_drops.gravity = Vector3(0, -6, 0)
	var streak := BoxMesh.new()
	streak.size = Vector3(0.02, 0.55, 0.02)
	var water := StandardMaterial3D.new()
	water.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.albedo_color = Color(0.75, 0.82, 0.95, 0.45)
	streak.material = water
	_drops.mesh = streak
	_drops.emitting = false
	add_child(_drops)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var puddle := StandardMaterial3D.new()
	puddle.albedo_color = PUDDLE
	puddle.roughness = 0.05
	puddle.metallic = 0.3
	for i in PUDDLES:
		var disc := CylinderMesh.new()
		disc.top_radius = rng.randf_range(0.6, 1.6)
		disc.bottom_radius = disc.top_radius
		disc.height = 0.01
		var spot := MeshInstance3D.new()
		spot.mesh = disc
		spot.material_override = puddle
		var along_x := rng.randf() < 0.5
		var street := CityLayout.street_z(rng.randi_range(0, CityLayout.ROWS)) if along_x \
			else CityLayout.street_x(rng.randi_range(0, CityLayout.COLUMNS))
		var run := rng.randf_range(-CityLayout.SIZE.x / 2, CityLayout.SIZE.x / 2) if along_x \
			else rng.randf_range(-CityLayout.SIZE.y / 2, CityLayout.SIZE.y / 2)
		var across := street + rng.randf_range(-4.0, 4.0)
		spot.position = Vector3(run, 0.02, across) if along_x else Vector3(across, 0.02, run)
		spot.scale = Vector3(1, 1, rng.randf_range(0.5, 1.0))
		spot.visible = false
		add_child(spot)
		_puddles.append(spot)


## How wet it is `at` seconds into the shift: it comes and goes in FADE seconds.
func wetness(at: float) -> float:
	if length <= 0.0 or at < start or at > start + length:
		return 0.0
	return clampf(minf(at - start, start + length - at) / FADE, 0.0, 1.0)


func _process(delta: float) -> void:
	time += delta
	set_wet(wetness(time))
	var camera := get_viewport().get_camera_3d()
	if camera and _drops.emitting:
		_drops.global_position = camera.global_position + Vector3.UP * ChaseWeather.RAIN_HEIGHT / 2


## Makes the city as wet as `amount` (0 to 1): drops, puddles, shine, grey sky, grip, cars and people.
func set_wet(amount: float) -> void:
	wet = amount
	_drops.emitting = wet > 0.05
	for spot in _puddles:
		spot.visible = wet > 0.3
	for street in streets:
		street.roughness = lerpf(DRY_ROUGHNESS, WET_ROUGHNESS, wet)
	if clock:
		clock.overcast = wet
	var raining := wet > 0.5
	for car in get_tree().get_nodes_in_group("patrol_cars"):
		(car as PatrolCar).grip = ChaseWeather.RAIN_GRIP if raining else 1.0
	for car in get_tree().get_nodes_in_group("city_cars"):
		if car is CityCar:
			(car as CityCar).speed_factor = CAR_SLOW if raining else 1.0
	for walker in get_tree().get_nodes_in_group("city_walkers"):
		(walker as CityWalker).hurry = WALK_FAST if raining else 1.0
