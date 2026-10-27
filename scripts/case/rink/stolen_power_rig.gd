class_name StolenPowerRig
extends RinkRig

## The stolen power (allanamiento-pista.md, "La luz robada"): Doña Pirueta hooked a cable to the street pole and the
## rink runs on stolen power. Every time the resurfacer starts, the hall's lights flicker for a moment, and the first
## time is the story's own clue (on the checklist). The mirror ball spins on its own, throwing colored spots on the ice,
## and there's no way to turn it off. Every number here is (propuesta).

## How long the lights flicker when the resurfacer starts, how often they go off and on, and how dim they go.
const FLICKER_TIME := 1.5
const FLICKER_EVERY := 0.12
const DIM := 0.1
## The whole hall's exposure on the dim beat, so the flicker reads even by the light from outside.
const DIM_EXPOSURE := 0.4
## The mirror ball's turns per second and the colored spots it throws, tilted out from straight down.
const BALL_SPIN := 0.2
const SPOT_TILT := deg_to_rad(35.0)
const SPOT_COLORS: Array[Color] = [Color(1.0, 0.3, 0.6), Color(0.3, 0.7, 1.0), Color(1.0, 0.85, 0.3),
	Color(0.5, 1.0, 0.5)]

var flickers := 0
var spots: Array[SpotLight3D] = []
var _flicker_left := 0.0
## The hall's lights and the light coming in, which flicker together.
var lights: Array[Light3D] = []
var _energy: Array[float] = []
var _env: Environment
var _exposure := 1.0
var _running := false


func setup(place: Rink) -> void:
	super.setup(place)
	lights.assign(rink.hall_lights)
	var sun := rink.get_node_or_null("Sun") as Light3D
	if sun:
		lights.append(sun)
	for lamp in lights:
		_energy.append(lamp.light_energy)
	var world := rink.get_node_or_null("Environment") as WorldEnvironment
	if world:
		# Its own copy, so the rink's scene keeps its exposure.
		world.environment = world.environment.duplicate()
		_env = world.environment
		_exposure = _env.tonemap_exposure
	for i in SPOT_COLORS.size():
		var spot := SpotLight3D.new()
		spot.light_color = SPOT_COLORS[i]
		spot.light_energy = 4.0
		spot.spot_range = 12.0
		spot.spot_angle = 10.0
		# Straight down, then tilted out to its side of the ball.
		spot.rotation = Vector3(-PI / 2 + SPOT_TILT, TAU * i / SPOT_COLORS.size(), 0)
		rink.mirror_ball.add_child(spot)
		spots.append(spot)


func _physics_process(delta: float) -> void:
	rink.mirror_ball.rotate_y(BALL_SPIN * TAU * delta)
	var running := rink.resurfacer.is_running()
	if running and not _running:
		flicker()
	_running = running
	if _flicker_left <= 0.0:
		return
	_flicker_left = maxf(_flicker_left - delta, 0.0)
	var off := _flicker_left > 0.0 and int(_flicker_left / FLICKER_EVERY) % 2 == 0
	for i in lights.size():
		lights[i].light_energy = _energy[i] * (DIM if off else 1.0)
	if _env:
		_env.tonemap_exposure = _exposure * (DIM_EXPOSURE if off else 1.0)


## The resurfacer started and the stolen power can't take it: the lights flicker. The first time it's a clue.
func flicker() -> void:
	flickers += 1
	_flicker_left = FLICKER_TIME
	rink.raid.float_label(tr("RINK_FLICKER"), rink.resurfacer.global_position + Vector3.UP * 2.2,
		Color(1.0, 0.95, 0.5))
	if flickers == 1:
		rink.raid.add_clue(tr("CLUE_RINK_LIGHTS_FLICKER"))
