class_name CityClock
extends Node

## The city's clock (ciudad-viva.md, step 5): one game hour lasts a real minute, so a whole day lasts 24 minutes. The
## sun turns with the hour, the sky and the light change color little by little, and at night the street lamps and
## the windows light up and half the people go home. A watch in the corner of the screen shows the time.
## Every number here is (propuesta).

signal night_changed(night: bool)

const SECONDS_PER_HOUR := 60.0
## A shift starts at a random hour between these.
const START_MIN := 8
const START_MAX := 20
const SUNRISE := 6.0
const SUNSET := 19.0
## Hours it takes the light to go from night to day (and back), around sunrise and sunset.
const TWILIGHT := 1.5
const NOON_ELEVATION := 62.0
const SUN_ENERGY := 1.2
const MOON_ENERGY := 0.12
const DAY_AMBIENT := 0.45
const NIGHT_AMBIENT := 0.12
const LAMP_ENERGY := 3.0
const WINDOW_ENERGY := 0.6
const DAY_SKY := Color(0.32, 0.56, 0.9)
const DAY_HORIZON := Color(0.75, 0.85, 0.95)
const DUSK_HORIZON := Color(0.98, 0.6, 0.38)
const NIGHT_SKY := Color(0.03, 0.04, 0.1)
const NIGHT_HORIZON := Color(0.1, 0.12, 0.22)
const DAY_SUN := Color(1, 0.93, 0.82)
const DUSK_SUN := Color(1, 0.62, 0.4)
const WINDOW_LIGHT := Color(1.0, 0.85, 0.5)

## The time, in hours from 0 to 24.
var hour := 12.0
var running := true
var sun: DirectionalLight3D
var environment: Environment
## Lamp heads and windows: they glow at night.
var lamps: Array[StandardMaterial3D] = []
var windows: Array[StandardMaterial3D] = []
var night := false
var _watch: Label


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 3
	add_child(layer)
	_watch = Label.new()
	_watch.offset_left = 20
	_watch.offset_top = 16
	_watch.add_theme_font_size_override("font_size", 24)
	_watch.add_theme_constant_override("outline_size", 6)
	layer.add_child(_watch)
	apply()


## A random start between START_MIN and START_MAX, from the shift's seed.
static func start_hour(seed_value: int) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["city clock", seed_value])
	return float(rng.randi_range(START_MIN, START_MAX))


## How much daylight there is at `at` (0 at night, 1 in the day), smooth around sunrise and sunset.
static func daylight(at: float) -> float:
	var morning := smoothstep(SUNRISE - TWILIGHT / 2, SUNRISE + TWILIGHT / 2, at)
	var evening := 1.0 - smoothstep(SUNSET - TWILIGHT / 2, SUNSET + TWILIGHT / 2, at)
	return minf(morning, evening)


## The sun's height over the horizon (degrees) at `at`: up from sunrise to sunset, under it the rest of the time.
static func elevation(at: float) -> float:
	return NOON_ELEVATION * sin((at - SUNRISE) / (SUNSET - SUNRISE) * PI) if at >= SUNRISE and at <= SUNSET \
		else -20.0


## "14:05".
static func text(at: float) -> String:
	var minutes := int(fposmod(at, 24.0) * 60.0)
	return "%02d:%02d" % [minutes / 60, minutes % 60]


func _process(delta: float) -> void:
	if not running:
		return
	hour = fposmod(hour + delta / SECONDS_PER_HOUR, 24.0)
	apply()


## Puts the sun, the sky, the lamps and the watch where the hour says.
func apply() -> void:
	var day := daylight(hour)
	var dusk := 1.0 - absf(day * 2.0 - 1.0)
	if sun:
		# From the east in the morning to the west in the evening; at night the moon lights a little from above.
		var high := elevation(hour) if day > 0.05 else 50.0
		sun.rotation_degrees = Vector3(-high, 90.0 - (hour - SUNRISE) / (SUNSET - SUNRISE) * 180.0, 0)
		sun.light_energy = lerpf(MOON_ENERGY, SUN_ENERGY, day)
		sun.light_color = DAY_SUN.lerp(DUSK_SUN, dusk).lerp(Color(0.6, 0.7, 1.0), 1.0 - day)
	if environment:
		environment.ambient_light_energy = lerpf(NIGHT_AMBIENT, DAY_AMBIENT, day)
		var sky := environment.sky.sky_material as ProceduralSkyMaterial if environment.sky else null
		if sky:
			sky.sky_top_color = NIGHT_SKY.lerp(DAY_SKY, day)
			sky.sky_horizon_color = NIGHT_HORIZON.lerp(DAY_HORIZON, day).lerp(DUSK_HORIZON, dusk * 0.7)
			sky.ground_horizon_color = sky.sky_horizon_color
	var glow := 1.0 - day
	for lamp in lamps:
		lamp.emission_energy_multiplier = LAMP_ENERGY * glow
	for window in windows:
		window.emission_enabled = glow > 0.01
		window.emission = WINDOW_LIGHT
		window.emission_energy_multiplier = WINDOW_ENERGY * glow
	if _watch:
		_watch.text = text(hour)
	var dark := day < 0.5
	if dark != night:
		night = dark
		night_changed.emit(night)
