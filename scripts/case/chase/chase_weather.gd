class_name ChaseWeather
extends Node

## The weather of two of the chases (persecucion.md, "Los sospechosos"). Under the rain the street is wet and the
## patrol car's tires grip less everywhere, the rain falls around the car, and the wiper doesn't work: the driver
## sees the drops pile up on the windshield. At night the city is dark and the getaway car drives with its lights off:
## only the copilot's flashlight (F, even in the car) finds him, it reaches farther than on foot, and the copilot's
## map shows him only while the flashlight is on him. Every number here is (propuesta).

const RAIN := "rain"
const NIGHT := "night"
## The tires' grip on the wet street (the ice cream puddles take it lower still).
const RAIN_GRIP := 0.55
## Drops falling around the patrol car, and the area they fall on (m).
const RAIN_DROPS := 1500
const RAIN_AREA := Vector3(26, 0.5, 26)
const RAIN_HEIGHT := 14.0
## Drops on the windshield at the same time.
const WINDSHIELD_DROPS := 36
## At night the flashlight reaches this far (m) and this bright, and lights the suspect within its cone plus this
## margin (degrees).
const NIGHT_BEAM := 35.0
const NIGHT_ENERGY := 5.0
const BEAM_MARGIN := 6.0

var case: ChaseCase
var rain: CPUParticles3D
var windshield: WindshieldDrops


func _ready() -> void:
	if case.suspect_id == RAIN:
		_make_rain()
	elif case.suspect_id == NIGHT:
		_make_night()
	case.car.seats_changed.connect(_tell_seats)


func _make_rain() -> void:
	case.drops.weather_grip = RAIN_GRIP
	var env := _environment()
	if env:
		var sky := env.sky.sky_material as ProceduralSkyMaterial if env.sky else null
		if sky:
			sky.sky_top_color = Color(0.36, 0.4, 0.46)
			sky.sky_horizon_color = Color(0.55, 0.58, 0.62)
			sky.ground_horizon_color = Color(0.55, 0.58, 0.62)
		env.fog_enabled = true
		env.fog_light_color = Color(0.55, 0.58, 0.63)
		env.fog_density = 0.012
		env.adjustment_saturation = 0.75
	if case.sun:
		case.sun.light_energy = 0.4
		case.sun.light_color = Color(0.8, 0.85, 0.95)
	rain = CPUParticles3D.new()
	rain.name = "Rain"
	rain.amount = RAIN_DROPS
	rain.lifetime = 1.0
	rain.local_coords = false
	rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain.emission_box_extents = RAIN_AREA / 2
	rain.direction = Vector3.DOWN
	rain.spread = 4.0
	rain.initial_velocity_min = 14.0
	rain.initial_velocity_max = 16.0
	rain.gravity = Vector3(0, -6, 0)
	var streak := BoxMesh.new()
	streak.size = Vector3(0.02, 0.55, 0.02)
	var water := StandardMaterial3D.new()
	water.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water.albedo_color = Color(0.75, 0.82, 0.95, 0.45)
	streak.material = water
	rain.mesh = streak
	case.get_parent().add_child.call_deferred(rain)
	windshield = WindshieldDrops.new()
	windshield.seed_value = case.case_seed
	var layer := CanvasLayer.new()
	layer.name = "Windshield"
	layer.add_child(windshield)
	add_child(layer)


func _make_night() -> void:
	var env := _environment()
	if env:
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.02, 0.03, 0.07)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.3, 0.36, 0.6)
		env.ambient_light_energy = 0.3
		env.tonemap_exposure = 1.0
	if case.sun:
		case.sun.light_energy = 0.1
		case.sun.light_color = Color(0.6, 0.7, 1.0)
	for cop in get_tree().get_nodes_in_group("cops"):
		var beam := (cop as Cop).belt.flashlight.light if (cop as Cop).belt else null
		if beam:
			beam.spot_range = NIGHT_BEAM
			beam.light_energy = NIGHT_ENERGY


## The level's environment, its own copy so the rain or the night doesn't change the scene's.
func _environment() -> Environment:
	if not case.world_environment or not case.world_environment.environment:
		return null
	case.world_environment.environment = case.world_environment.environment.duplicate(true)
	return case.world_environment.environment


## The copilot at night hears about the flashlight (after his seat's own hint), and the driver in the rain about the
## wiper.
func _tell_seats() -> void:
	var cop := case.tasks.local_cop()
	if case.suspect_id == NIGHT and case.tasks.does(cop, ChaseTasks.MAP_SEATS):
		cop.show_hint("HINT_CHASE_FLASHLIGHT")
	elif case.suspect_id == RAIN and cop and case.car.seat_of(cop) == 0:
		cop.show_hint("HINT_CHASE_WIPER")


func _physics_process(_delta: float) -> void:
	if rain and rain.is_inside_tree():
		rain.global_position = case.car.global_position + Vector3.UP * RAIN_HEIGHT
	var cop := case.tasks.local_cop()
	if windshield:
		windshield.visible = cop != null and case.car.seat_of(cop) == 0
	if case.suspect_id == NIGHT:
		_aim_beams()
	# In the car F still works for the copilot at night (the belt ignores it inside a vehicle).
	if case.suspect_id == NIGHT and case.tasks.does(cop, ChaseTasks.MAP_SEATS) \
			and Input.is_action_just_pressed("flashlight"):
		cop.act("belt_flashlight", cop)


## In the car the flashlight hangs on the shoulder pointing down: at night the beam goes where the cop looks.
func _aim_beams() -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).belt and (cop as Cop).vehicle == case.car:
			(cop as Cop).belt.flashlight.light.global_basis = (cop as Cop).camera.global_basis


## Whether the copilot's map shows the suspect: always, except at night, where only while a flashlight is on him.
func shows_suspect() -> bool:
	return case.suspect_id != NIGHT or lights_suspect()


## Whether a cop's flashlight in the patrol car is on the suspect's vehicle.
func lights_suspect() -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		var flashlight := (cop as Cop).belt.flashlight if (cop as Cop).belt else null
		if not flashlight or not flashlight.is_on:
			continue
		var eye := flashlight.light.global_transform
		var to := case.truck.global_position + Vector3.UP * 0.8 - eye.origin
		if to.length() <= NIGHT_BEAM and rad_to_deg((-eye.basis.z).angle_to(to)) <= Flashlight.ANGLE + BEAM_MARGIN:
			return true
	return false


## The drops on the windshield that the broken wiper never clears: they slide down slowly and new ones land on top.
class WindshieldDrops extends Control:
	var seed_value := 0
	## Each drop: [position as a share of the screen, radius in px, slide speed as a share a second].
	var drops: Array[Array] = []
	var _rng := RandomNumberGenerator.new()

	func _ready() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		_rng.seed = hash("windshield %d" % seed_value)
		for i in ChaseWeather.WINDSHIELD_DROPS:
			drops.append(_drop(_rng.randf()))

	func _drop(height: float) -> Array:
		return [Vector2(_rng.randf(), height), _rng.randf_range(6.0, 24.0), _rng.randf_range(0.01, 0.05)]

	func _process(delta: float) -> void:
		if not visible:
			return
		for i in drops.size():
			drops[i][0].y += drops[i][2] * delta
			if drops[i][0].y > 1.05:
				drops[i] = _drop(-0.05)
		queue_redraw()

	func _draw() -> void:
		for drop in drops:
			var at: Vector2 = drop[0] * size
			var radius: float = drop[1]
			draw_circle(at, radius, Color(0.8, 0.88, 1.0, 0.35))
			draw_circle(at - Vector2(radius, radius) * 0.3, radius * 0.3, Color(1, 1, 1, 0.35))
			draw_line(at - Vector2(0, radius * 3.0), at, Color(0.8, 0.88, 1.0, 0.15), radius * 0.6)
