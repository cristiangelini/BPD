class_name StarShow
extends Node

## The star show (escena-planetario.md, "La función de las estrellas"): once the cops are at the scene, every EVERY
## seconds the speakers announce it and the whole planetario goes dark for DARK_SECONDS. In the dark only the stars on
## the dome's ceiling and the glow paint on the guides' gloves shine (Planetarium.set_dark), and when the lights come
## back every guide is somewhere else. A flashlight on inside during the show stops it: Doctor Órbita starts it over
## (the next one is EVERY seconds away) and loses FLASHLIGHT_PATIENCE of his patience; at 0 he throws the cops out of
## the dome room until the end of the shift. The host decides. Every number here is (propuesta).

const EVERY := 120.0
const DARK_SECONDS := 30.0
const PATIENCE := 100.0
const FLASHLIGHT_PATIENCE := 10.0
## The ambient light inside in the dark: just enough to make out shapes.
const DARK_AMBIENT := Color(0.06, 0.06, 0.12)
## Where a cop thrown out of the dome room lands: in the hall, in front of its door.
const THROWN_OUT_AT := Vector3(Planetarium.DOOR_DOME_X, 0, Planetarium.ROOMS_Z + 1.5)

var planetarium: Planetarium
var case: CrimeSceneCase
## Seconds to the next show, and seconds of dark left while one is on.
var until_show := EVERY
var show_left := 0.0
## How many shows there were (the guides' shuffle uses it).
var shows := 0
var patience := PATIENCE
## Doctor Órbita threw the cops out of the dome room.
var banned := false
var bar: ProgressBar
var _next: Label
var _hud: CanvasLayer
## The sky's ambient light, kept while it's dark in here (_dark).
var _sky := {}


func _ready() -> void:
	add_to_group("star_show")
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	_hud.add_child(box)
	var title := Label.new()
	title.text = "HUD_ORBITA_PATIENCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.show_percentage = false
	bar.max_value = PATIENCE
	bar.modulate = Color(0.55, 0.6, 1.0)
	box.add_child(bar)
	_next = Label.new()
	_next.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_next)
	_hud.visible = false
	add_child(_hud)


func is_on() -> bool:
	return show_left > 0.0


## Lights out: the show starts.
func start_show() -> void:
	show_left = DARK_SECONDS
	shows += 1
	_lights(false)
	planetarium.director.say("DIRECTOR_SHOW_STARTS")
	_hint_all("HINT_SHOW_STARTS")


## The show is over: the lights come back and every guide is somewhere else.
func end_show() -> void:
	show_left = 0.0
	until_show = EVERY
	_lights(true)
	_shuffle_guides()
	_hint_all("HINT_SHOW_ENDS")


## A flashlight on in the dark: Doctor Órbita stops the show, starts it over and loses patience; at 0 he throws the
## cops out of the dome room.
func flashlight_seen(cop: Cop) -> void:
	show_left = 0.0
	until_show = EVERY
	_lights(true)
	patience = maxf(patience - FLASHLIGHT_PATIENCE, 0.0)
	if patience <= 0.0 and not banned:
		banned = true
		planetarium.director.say("DIRECTOR_BANNED")
		_hint_all("HINT_DOME_BANNED")
		return
	planetarium.director.say("DIRECTOR_FLASHLIGHT")
	if cop:
		cop.show_hint("HINT_SHOW_STOPPED")


## The host's clock: the countdown while the cops are at the scene, the dark, the flashlights and the ban.
func tick(delta: float) -> void:
	if is_on():
		show_left -= delta
		if show_left <= 0.0:
			end_show()
			return
		for node in get_tree().get_nodes_in_group("cops"):
			var cop := node as Cop
			if cop and cop.belt and cop.belt.flashlight.is_on and planetarium.inside(cop.global_position):
				flashlight_seen(cop)
				return
	elif case.at_tent:
		until_show -= delta
		if until_show <= 0.0:
			start_show()
	if banned:
		for node in get_tree().get_nodes_in_group("cops"):
			var cop := node as Cop
			if cop and planetarium.room(cop.global_position) == "dome":
				cop.global_position = planetarium.to_global(THROWN_OUT_AT)
				cop.velocity = Vector3.ZERO
				cop.show_hint("HINT_DOME_BANNED")


func _physics_process(delta: float) -> void:
	_hud.visible = case.at_tent
	bar.value = patience
	_next.text = tr("HUD_SHOW_ON") if is_on() else tr("HUD_NEXT_SHOW") % ceili(until_show)
	if not case.follower:
		tick(delta)


## The ceiling lights and the glow paint.
func _lights(on: bool) -> void:
	for lamp in planetarium.lamps:
		lamp.visible = on
	planetarium.set_dark(not on)


## A shuffle where nobody stays in their own spot, drawn with the seed and the show.
func _shuffle_guides() -> void:
	var guides := planetarium.guides
	var spots: Array[Transform3D] = []
	for guide in guides:
		spots.append(guide.transform)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["planetarium show", case.case_seed, shows])
	var order := range(spots.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i - 1)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in guides.size():
		guides[i].transform = spots[order[i]]


## With the lights out it's dark inside even by day: while this PC's camera is in the building, the sky's ambient
## light gives way to a faint dark blue (the roof already keeps the sun out). Each PC sees its own.
func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	_dark(is_on() and camera != null and planetarium.inside(camera.global_position))


func _dark(on: bool) -> void:
	var found := get_tree().root.find_children("*", "WorldEnvironment", true, false)
	var env := (found[0] as WorldEnvironment).environment if not found.is_empty() else null
	if not env or on == not _sky.is_empty():
		return
	if on:
		_sky = {"source": env.ambient_light_source, "color": env.ambient_light_color,
			"energy": env.ambient_light_energy, "reflected": env.reflected_light_source}
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = DARK_AMBIENT
		env.ambient_light_energy = 1.0
		env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	else:
		env.ambient_light_source = _sky.source
		env.ambient_light_color = _sky.color
		env.ambient_light_energy = _sky.energy
		env.reflected_light_source = _sky.reflected
		_sky = {}


func _exit_tree() -> void:
	_dark(false)


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
