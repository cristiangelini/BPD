class_name RaceCar
extends RefCounted

## The street race check (control-carrera.md): between the city cars come the racers, in heats, sedans dressed up for
## the night's street races. A racer has a black spoiler on its trunk (big, small or none), a big number on both front doors (1 to
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
## The racers come in heats, out of the queue (step 2): HEATS of them, HEAT_SIZE racers each, the first FIRST_HEAT s
## after the checkpoint is set up and then one every HEAT_EVERY s.
const HEATS := Vector2i(4, 5)
const HEAT_SIZE := Vector2i(2, 3)
const FIRST_HEAT := 15.0
const HEAT_EVERY := Vector2(30.0, 45.0)
## A heat gathers at the back corner one behind the other, SLOT_GAP apart, waits GATHER s and revs REV_SECONDS (the
## warning, control-carrera.md answer 3), shaking: then it launches.
const SLOT_GAP := 7.0
const GATHER := 2.0
const REV_SECONDS := 3.0
const SHAKE := 0.05
const SHAKE_RATE := 45.0
const REV_LINES := 4
## Racing: this fast (m/s, three times a city car), up to it this quick.
const SPEED := 22.0
const ACCEL := 12.0
## The race lane, in the checkpoint's space: the other lane of the street. Near the checkpoint they swerve to CLIP_X,
## close past the queue, and clip the barrier's end; SWERVE m before and after it they're back in their lane.
const LANE := -6.0
const CLIP_X := -2.4
const CLIP_ZONE := 2.5
const SWERVE := 12.0
## A barrier this close to a racer's center (across, along the street) flies, before its body touches it.
const BARRIER_REACH := Vector2(2.9, 3.2)
const BARRIER_PUSH := 7.0
## Sparks out of the pipes, rolling faster than this (m/s).
const SPARKS_FROM := 1.0


## How many heats when no plan says it, from the seed.
static func heats_of(case_seed: int) -> int:
	return HEATS.x + absi(hash(["race heats", case_seed])) % (HEATS.y - HEATS.x + 1)


## How many racers in the `heat`th heat when no plan says it, from the seed.
static func heat_size(case_seed: int, heat: int) -> int:
	return HEAT_SIZE.x + absi(hash(["race heat size", case_seed, heat])) % (HEAT_SIZE.y - HEAT_SIZE.x + 1)


## Seconds from the `heat`th heat to the next one, from the seed.
static func heat_every(case_seed: int, heat: int) -> float:
	return HEAT_EVERY.x + float(absi(hash(["race heat every", case_seed, heat])) % 100) / 100.0 * (HEAT_EVERY.y
		- HEAT_EVERY.x)


## Across the street (the checkpoint's X) where a racer is at `z` along it: its lane, swerving to clip the barrier.
static func lane_x(z: float) -> float:
	var off := absf(z) - CLIP_ZONE
	if off <= 0.0:
		return CLIP_X
	if off >= SWERVE:
		return LANE
	return lerpf(CLIP_X, LANE, smoothstep(0.0, 1.0, off / SWERVE))


## What a racer roars while it revs, from its plate.
static func rev_line(plate: String) -> String:
	return "RACE_REV_%d" % (absi(hash(["race rev", plate])) % REV_LINES)


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
