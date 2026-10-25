class_name RaceCar
extends RefCounted

## The street race check (control-carrera.md): among the city cars come the racers, sedans dressed up for the night's
## street races. A racer has a black spoiler on its trunk (big, small or none), a big number on both front doors (1 to
## 99), a neon light under its body and fat exhaust pipes that throw sparks while it rolls. Every number here is
## (propuesta).

const SPOILER := preload("res://assets/models/race_spoiler.glb")
const EXHAUST := preload("res://assets/models/race_exhaust.glb")
const ROUNDEL := preload("res://assets/models/race_roundel.glb")
## On the sedan (TrafficCar's model, forward +Z): the trunk lid, the back bumper and the front doors' sides.
const SPOILER_AT := Vector3(0, 1.0, -1.9)
const EXHAUST_AT := Vector3(0, 0.38, -2.3)
const ROUNDEL_AT := Vector3(1.09, 0.72, 0.2)
## Spoiler kinds: none, small, big (the radio's clue names them, step 4), and the small one's scale.
const SPOILERS: Array[String] = ["SPOILER_NONE", "SPOILER_SMALL", "SPOILER_BIG"]
const SMALL_SPOILER := 0.65
## The neon colors, and the names the radio gives them.
const NEONS: Array[Color] = [Color("ff3ca8"), Color("6cff3c"), Color("a03cff"), Color("ff8a1c")]
const NEON_NAMES: Array[String] = ["COLOR_PINK", "COLOR_LIME", "COLOR_VIOLET", "COLOR_ORANGE"]
## The neon strip under the body, and how far its glow reaches on the street.
const NEON_SIZE := Vector3(1.9, 0.04, 3.9)
const NEON_AT := Vector3(0, 0.16, 0)
const NEON_RANGE := 3.0
const NEON_ENERGY := 2.5
## The door number's size.
const NUMBER_SIZE := 64
const NUMBERS := Vector2i(1, 99)
## Without a plan, one car in RACER_EVERY of the queue is a racer.
const RACER_EVERY := 3
## Sparks out of the pipes, rolling faster than this (m/s).
const SPARKS_FROM := 1.0


## Whether the queue's `index`th car is a racer when no plan says it: from the seed, so every PC agrees.
static func racer_at(case_seed: int, index: int) -> bool:
	return absi(hash(["race racer", case_seed, index])) % RACER_EVERY == 0


## A racer's looks when no plan says them: from its plate, so every PC agrees.
static func traits_of(plate: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["race traits", plate])
	return draw(rng)


## A racer's looks: its door number, its neon (one of NEONS) and its spoiler (one of SPOILERS).
static func draw(rng: RandomNumberGenerator) -> Dictionary:
	return {"number": rng.randi_range(NUMBERS.x, NUMBERS.y), "neon": rng.randi() % NEONS.size(),
		"spoiler": rng.randi() % SPOILERS.size()}


## Dresses a sedan as a racer with `traits` (draw's).
static func dress(car: Node3D, traits: Dictionary) -> void:
	var spoiler: int = traits.get("spoiler", 0)
	if spoiler > 0:
		var wing: Node3D = SPOILER.instantiate()
		wing.name = "Spoiler"
		wing.position = SPOILER_AT
		wing.scale = Vector3.ONE * (SMALL_SPOILER if spoiler == 1 else 1.0)
		car.add_child(wing)
	var pipes: Node3D = EXHAUST.instantiate()
	pipes.name = "Exhaust"
	pipes.position = EXHAUST_AT
	car.add_child(pipes)
	pipes.add_child(_sparks())
	for side in [1.0, -1.0]:
		var roundel: Node3D = ROUNDEL.instantiate()
		roundel.name = "Roundel" if side > 0 else "RoundelLeft"
		roundel.position = Vector3(ROUNDEL_AT.x * side, ROUNDEL_AT.y, ROUNDEL_AT.z)
		roundel.rotation.y = 0.0 if side > 0 else PI
		car.add_child(roundel)
		var number := Label3D.new()
		number.name = "Number"
		number.text = str(traits.get("number", 1))
		number.font_size = NUMBER_SIZE
		number.pixel_size = 0.005
		number.modulate = Color.BLACK
		number.outline_size = 0
		number.position = Vector3(0.02, 0, 0)
		number.rotation.y = PI / 2
		roundel.add_child(number)
	var color := NEONS[int(traits.get("neon", 0)) % NEONS.size()]
	var strip := MeshInstance3D.new()
	strip.name = "Neon"
	var box := BoxMesh.new()
	box.size = NEON_SIZE
	var glow := StandardMaterial3D.new()
	glow.albedo_color = color
	glow.emission_enabled = true
	glow.emission = color
	glow.emission_energy_multiplier = 3.0
	box.material = glow
	strip.mesh = box
	strip.position = NEON_AT
	car.add_child(strip)
	var light := OmniLight3D.new()
	light.name = "NeonLight"
	light.light_color = color
	light.light_energy = NEON_ENERGY
	light.omni_range = NEON_RANGE
	light.position = Vector3(0, 0.1, 0)
	car.add_child(light)


## Its pipes throw sparks while it rolls at `speed`, and stop when it stops.
static func spark(car: Node3D, speed: float) -> void:
	var sparks := car.get_node_or_null("Exhaust/Sparks") as CPUParticles3D
	if sparks:
		sparks.emitting = speed > SPARKS_FROM


static func _sparks() -> CPUParticles3D:
	var sparks := CPUParticles3D.new()
	sparks.name = "Sparks"
	sparks.position = Vector3(-0.45, 0, -0.25)
	sparks.emitting = false
	sparks.amount = 24
	sparks.lifetime = 0.35
	sparks.direction = Vector3(0, 0.3, -1)
	sparks.spread = 25.0
	sparks.initial_velocity_min = 2.0
	sparks.initial_velocity_max = 4.0
	sparks.gravity = Vector3(0, -6, 0)
	sparks.scale_amount_min = 0.5
	sparks.scale_amount_max = 1.0
	var dot := SphereMesh.new()
	dot.radius = 0.025
	dot.height = 0.05
	var hot := StandardMaterial3D.new()
	hot.albedo_color = Color("ffc040")
	hot.emission_enabled = true
	hot.emission = Color("ff9020")
	hot.emission_energy_multiplier = 4.0
	hot.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dot.material = hot
	sparks.mesh = dot
	return sparks
