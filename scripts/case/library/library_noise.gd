class_name LibraryNoise
extends Node

## The library's noise (escena-biblioteca.md, "El silencio"): a bar at the top that only goes up with what the cops do
## (talking out loud through the voice chat, shouting, running inside, searching a shelf, the siren by the door) and
## goes down by itself, faster while a cop reads in the armchair. At HUSH_AT Doña Sigilo turns up by whoever made the
## last noise and hushes them: their voice chat goes quiet for HUSH_SECONDS. At BLACKOUT_AT she turns off every light
## for BLACKOUT_SECONDS, the six readers swap places in the dark and Tomasito, if nobody read him his story yet, wakes up
## scared; then the lights and the bar go back to 0. Above STORY_STOPS_AT a story for Tomasito stops. The host decides.
## Every number here is (propuesta).

const TALK_PER_SECOND := 2.0
const SHOUT := 15.0
const RUN_PER_SECOND := 1.0
const SEARCH := 10.0
const SIREN := 20.0
## The siren counts this close to the front door, in meters.
const SIREN_REACH := 20.0
const DECAY_PER_SECOND := 1.0
## A cop reading in the armchair takes this much more off per second.
const READING_PER_SECOND := 1.0
const HUSH_AT := 50.0
const BLACKOUT_AT := 100.0
const STORY_STOPS_AT := 30.0
const HUSH_SECONDS := 10.0
const BLACKOUT_SECONDS := 60.0
## A reader in the armchair stays this close, in meters.
const ARMCHAIR_REACH := 1.5
## The ambient light inside in the dark: just enough to make out shapes.
const DARK_AMBIENT := Color(0.05, 0.05, 0.08)

signal changed(level: float)

var library: Library
var case: CrimeSceneCase
var level := 0.0
var blackout_left := 0.0
## How many blackouts there were (the readers' shuffle uses it).
var blackouts := 0
## The cop who made the last noise.
var last_cop: Cop
## Doña Sigilo already hushed someone since the bar was last at 0.
var hushed_once := false
## Hushed cops: seconds left.
var hushed := {}
## Cops reading in the armchair.
var reading: Array[Cop] = []
var bar: ProgressBar
var _hud: CanvasLayer
var _siren_was := false
## The sky's ambient light, kept while it's dark in here (_dark).
var _sky := {}


func _ready() -> void:
	add_to_group("library_noise")
	_hud = CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	_hud.add_child(box)
	var title := Label.new()
	title.text = "HUD_LIBRARY_NOISE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.show_percentage = false
	bar.modulate = Color(0.95, 0.75, 0.3)
	box.add_child(bar)
	_hud.visible = false
	add_child(_hud)


## Noise made by `cop` (null: nobody in particular).
func add(amount: float, cop: Cop = null) -> void:
	if case.follower or blackout_left > 0.0:
		return
	level = minf(level + amount, BLACKOUT_AT)
	if cop:
		last_cop = cop
	changed.emit(level)
	if level >= STORY_STOPS_AT:
		library.kid.interrupt()
	if level >= BLACKOUT_AT:
		blackout()
	elif level >= HUSH_AT and not hushed_once:
		hush(last_cop)


## Doña Sigilo, right by `cop`: "¡SHHH!". Their voice chat goes quiet for a while.
func hush(cop: Cop) -> void:
	hushed_once = true
	if not cop:
		return
	hushed[cop] = HUSH_SECONDS
	var librarian := library.librarian
	librarian.global_position = cop.global_position - cop.global_transform.basis.z * 0.8
	librarian.look_at(Vector3(cop.global_position.x, librarian.global_position.y, cop.global_position.z), Vector3.UP,
		true)
	librarian.say("LIBRARIAN_SHHH", HUSH_SECONDS / 2)
	cop.show_hint("HINT_LIBRARY_HUSHED")


func is_hushed(cop: Cop) -> bool:
	return hushed.get(cop, 0.0) > 0.0


## Lights out: the readers swap places in the dark, and Tomasito wakes up scared if nobody read him his story.
func blackout() -> void:
	blackout_left = BLACKOUT_SECONDS
	blackouts += 1
	level = BLACKOUT_AT
	changed.emit(level)
	for lamp in library.lamps:
		lamp.visible = false
	var spots: Array[Vector3] = []
	var turns: Array[float] = []
	for reader in library.readers:
		spots.append(reader.position)
		turns.append(reader.rotation.y)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["library blackout", case.case_seed, blackouts])
	var order := range(spots.size())
	# A shuffle where nobody stays in their own seat.
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i - 1)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for i in library.readers.size():
		library.readers[i].position = spots[order[i]]
		library.readers[i].rotation.y = turns[order[i]]
	library.kid.scare()
	_hint_all("HINT_LIBRARY_BLACKOUT")


func lights_back() -> void:
	blackout_left = 0.0
	level = 0.0
	hushed_once = false
	changed.emit(level)
	for lamp in library.lamps:
		lamp.visible = true
	_hint_all("HINT_LIBRARY_LIGHTS_BACK")


## E on the armchair: the cop sits down to read, and the noise goes down faster while they stay.
func start_reading(cop: Cop) -> void:
	if not reading.has(cop):
		reading.append(cop)


## Host: `cop`'s player talked for the last MimeSilence.TALK_EVERY seconds (VoiceChat).
func heard_talking(cop: Node3D) -> void:
	if cop is Cop and library.inside(cop.global_position):
		add(TALK_PER_SECOND * MimeSilence.TALK_EVERY, cop)


## With the lights out it's dark inside even by day: while this PC's camera is in the building, the sky's ambient
## light gives way to a faint dark blue (the roof already keeps the sun out). Each PC sees its own.
func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	_dark(blackout_left > 0.0 and camera != null and library.inside(camera.global_position))


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


func _physics_process(delta: float) -> void:
	_hud.visible = case.at_tent
	bar.value = level
	if case.follower:
		return
	for cop: Cop in hushed.keys():
		hushed[cop] -= delta
		if hushed[cop] <= 0.0:
			hushed.erase(cop)
			if hushed.is_empty() and blackout_left <= 0.0:
				library.librarian_back()
	if blackout_left > 0.0:
		blackout_left -= delta
		if blackout_left <= 0.0:
			lights_back()
		return
	var armchair := library.to_global(Library.ARMCHAIR_AT)
	reading = reading.filter(func(cop: Cop) -> bool:
		return is_instance_valid(cop) and cop.global_position.distance_to(armchair) <= ARMCHAIR_REACH)
	if level > 0.0:
		level = maxf(level - (DECAY_PER_SECOND + READING_PER_SECOND * reading.size()) * delta, 0.0)
		changed.emit(level)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop and cop.is_running and library.inside(cop.global_position):
			add(RUN_PER_SECOND * delta, cop)
	var door := library.to_global(Vector3(Library.DOOR_FRONT_X, 0, Library.FRONT_Z))
	var siren := false
	for car in get_tree().get_nodes_in_group("patrol_cars"):
		if car is PatrolCar and (car as PatrolCar).siren_on and (car as Node3D).global_position.distance_to(door) <= SIREN_REACH:
			siren = true
	if siren and not _siren_was:
		add(SIREN)
	_siren_was = siren


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
