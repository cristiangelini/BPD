class_name MansionStorm
extends Node3D

## The storm over the mansion (escena-mansion.md, "El lugar"): rain falling all around but not through the roof, and
## now and then a lightning bolt that lights everything up for a moment (the thunder comes with it). Every number here
## is (propuesta).

## Seconds between bolts: drawn between these two each time.
const BOLT_EVERY := Vector2(15.0, 35.0)
const FLASH_SECONDS := 0.25
const FLASH_ENERGY := 3.0
## The rain falls over a square this wide, from this high.
const RAIN_WIDTH := 70.0
const RAIN_HEIGHT := 14.0
const RAIN_DROPS := 6000

## Same seed, same bolts.
var storm_seed := 1
## Bolts so far.
var bolts := 0
## The house's box (center and size, in this node's space): the rain stops on its roof.
var roof_center := Vector3.ZERO
var roof_size := Vector3.ONE
var flash: DirectionalLight3D
var rain: GPUParticles3D
var _rng := RandomNumberGenerator.new()
var _next_bolt := 0.0
var _flash_left := 0.0


func _ready() -> void:
	_rng.seed = hash("mansion storm %d" % storm_seed)
	_next_bolt = _rng.randf_range(BOLT_EVERY.x, BOLT_EVERY.y)
	flash = DirectionalLight3D.new()
	flash.name = "Lightning"
	flash.light_color = Color(0.8, 0.85, 1.0)
	flash.light_energy = 0.0
	flash.rotation = Vector3(-PI / 3, PI / 5, 0)
	add_child(flash)
	_make_rain()


func _process(delta: float) -> void:
	if _flash_left > 0.0:
		_flash_left -= delta
		flash.light_energy = FLASH_ENERGY * maxf(_flash_left, 0.0) / FLASH_SECONDS
	_next_bolt -= delta
	if _next_bolt <= 0.0:
		bolt()


## A lightning bolt: everything lights up and fades back to night.
func bolt() -> void:
	bolts += 1
	_flash_left = FLASH_SECONDS
	flash.light_energy = FLASH_ENERGY
	_next_bolt = _rng.randf_range(BOLT_EVERY.x, BOLT_EVERY.y)


## Streaks falling from above over the whole place, hidden when they hit the house's roof.
func _make_rain() -> void:
	rain = GPUParticles3D.new()
	rain.name = "Rain"
	rain.amount = RAIN_DROPS
	rain.lifetime = 1.2
	rain.preprocess = 1.2
	rain.position = Vector3(0, RAIN_HEIGHT, 0)
	rain.visibility_aabb = AABB(Vector3(-RAIN_WIDTH / 2, -RAIN_HEIGHT - 2, -RAIN_WIDTH / 2),
		Vector3(RAIN_WIDTH, RAIN_HEIGHT + 4, RAIN_WIDTH))
	rain.collision_base_size = 0.05
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(RAIN_WIDTH / 2, 0.5, RAIN_WIDTH / 2)
	process.direction = Vector3.DOWN
	process.spread = 2.0
	process.initial_velocity_min = 14.0
	process.initial_velocity_max = 16.0
	process.gravity = Vector3(0, -9.8, 0)
	process.collision_mode = ParticleProcessMaterial.COLLISION_HIDE_ON_CONTACT
	rain.process_material = process
	var streak := BoxMesh.new()
	streak.size = Vector3(0.015, 0.35, 0.015)
	var water := StandardMaterial3D.new()
	water.albedo_color = Color(0.7, 0.75, 0.85, 0.45)
	water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	streak.material = water
	rain.draw_pass_1 = streak
	add_child(rain)
	var roof := GPUParticlesCollisionBox3D.new()
	roof.name = "Roof"
	roof.size = roof_size
	roof.position = roof_center
	add_child(roof)
