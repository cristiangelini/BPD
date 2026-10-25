class_name FogCar
extends RefCounted

## The fog check (control-neblina.md): the city under a thick fog, you see some 15 m. The cars come with their
## headlights on: from afar only two lights grow in the fog (a halo the fog doesn't swallow), and a car's paint shows
## only up close. Every car's headlights are white, yellow or bluish, one of them may be broken (dark) and it has its
## own horn (step 3). Every number here is (propuesta).

## The fog: how thick, its color, and how dim the sun gets under it.
const DENSITY := 0.2
const FOG_COLOR := Color(0.62, 0.65, 0.68)
const SUN_ENERGY := 0.35
## The headlights' colors, and the names the radio gives them.
const LIGHTS: Array[Color] = [Color("fffbe8"), Color("ffd35a"), Color("a8d4ff")]
const LIGHT_NAMES: Array[String] = ["COLOR_WHITE", "COLOR_YELLOW", "COLOR_BLUISH"]
## Which headlight is broken: none, the left one or the right one, as the driver sees them (on a car facing +Z, its
## left is +X).
const BROKEN: Array[String] = ["BROKEN_NONE", "BROKEN_LEFT", "BROKEN_RIGHT"]
## How many horns there are (FOG_HORN_0 to FOG_HORN_9, step 3).
const HORNS := 10
## On the sedan (TrafficCar's model, forward +Z): its two headlights, the left one at +X.
const LAMP_AT := Vector3(0.7, 0.75, 2.33)
const LAMP_SIZE := Vector3(0.36, 0.14, 0.04)
## The glow around a lit headlight, seen through the fog, and its light down the street.
const HALO_SIZE := 1.1
const HALO_ALPHA := 0.55
const BEAM_RANGE := 18.0
const BEAM_ANGLE := 28.0
const BEAM_ENERGY := 3.0


## A car's headlights and horn when no plan says them: from its plate, so every PC agrees.
static func traits_of(plate: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["fog traits", plate])
	return draw(rng)


## A car's headlights (one of LIGHTS), which one is broken (one of BROKEN) and its horn (0 to HORNS - 1).
static func draw(rng: RandomNumberGenerator) -> Dictionary:
	return {"lights": rng.randi() % LIGHTS.size(), "broken": rng.randi() % BROKEN.size(), "horn": rng.randi() % HORNS}


## Puts the fog over `env` and dims `sun` (the level's).
static func fog_up(env: Environment, sun: DirectionalLight3D) -> void:
	if env:
		env.fog_enabled = true
		env.fog_mode = Environment.FOG_MODE_EXPONENTIAL
		env.fog_light_color = FOG_COLOR
		env.fog_density = DENSITY
		env.fog_sky_affect = 1.0
		env.adjustment_saturation = 0.8
	if sun:
		sun.light_energy = SUN_ENERGY
		# Under the fog the light is everywhere: no sharp shadows.
		sun.shadow_enabled = false


## Turns on `car`'s headlights as in `traits` (draw's): Lamp/LampLeft lit, or dark if broken, each lit one with its
## halo and its beam.
static func dress(car: Node3D, traits: Dictionary) -> void:
	var color := LIGHTS[int(traits.get("lights", 0)) % LIGHTS.size()]
	var broken: int = traits.get("broken", 0)
	for side: float in [1.0, -1.0]:
		var left := side > 0.0
		var dark := (broken == 1 and left) or (broken == 2 and not left)
		var lamp := MeshInstance3D.new()
		lamp.name = "LampLeft" if left else "Lamp"
		var box := BoxMesh.new()
		box.size = LAMP_SIZE
		var glass := StandardMaterial3D.new()
		if dark:
			glass.albedo_color = Color(0.12, 0.12, 0.13)
		else:
			glass.albedo_color = color
			glass.emission_enabled = true
			glass.emission = color
			glass.emission_energy_multiplier = 4.0
			glass.disable_fog = true
		box.material = glass
		lamp.mesh = box
		lamp.position = Vector3(LAMP_AT.x * side, LAMP_AT.y, LAMP_AT.z)
		car.add_child(lamp)
		if dark:
			continue
		lamp.add_child(_halo(color))
		var beam := SpotLight3D.new()
		beam.name = "Beam"
		beam.light_color = color
		beam.light_energy = BEAM_ENERGY
		beam.spot_range = BEAM_RANGE
		beam.spot_angle = BEAM_ANGLE
		# A spot shines down its -Z: turned round, it lights the street ahead of the car.
		beam.rotation = Vector3(-0.08, PI, 0)
		lamp.add_child(beam)


## Whether `car`'s headlight on that side is lit.
static func lit(car: Node3D, left: bool) -> bool:
	return car.get_node_or_null(("LampLeft" if left else "Lamp") + "/Halo") != null


static func _halo(color: Color) -> MeshInstance3D:
	var halo := MeshInstance3D.new()
	halo.name = "Halo"
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * HALO_SIZE
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	glow.disable_fog = true
	glow.albedo_color = Color(color, HALO_ALPHA)
	glow.albedo_texture = _soft_dot()
	quad.material = glow
	halo.mesh = quad
	halo.position = Vector3(0, 0, 0.05)
	return halo


static var _dot: GradientTexture2D


## A round glow, bright in the middle and gone at the edge.
static func _soft_dot() -> GradientTexture2D:
	if _dot:
		return _dot
	var ramp := Gradient.new()
	ramp.set_color(0, Color.WHITE)
	ramp.set_color(1, Color(1, 1, 1, 0))
	_dot = GradientTexture2D.new()
	_dot.gradient = ramp
	_dot.fill = GradientTexture2D.FILL_RADIAL
	_dot.fill_from = Vector2(0.5, 0.5)
	_dot.fill_to = Vector2(1, 0.5)
	_dot.width = 64
	_dot.height = 64
	return _dot
