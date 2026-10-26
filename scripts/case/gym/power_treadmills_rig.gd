class_name PowerTreadmillsRig
extends GymRaidRig

## The treadmills that steal power (allanamiento-gimnasio.md, "Las cintas que roban luz"): el profe hooked the gym to
## the power plant next door and sells the "free" power. A cop running on a treadmill makes the lights of the gym and
## the neighborhood flicker, the story's own clue (on the checklist the first time). Every RUN_EVERY seconds the
## working treadmills run on their own for RUN_TIME seconds, and a cop who steps on one is thrown backwards. The box
## with the cable to the plant, the meter turned upside down and the wiring plan are hidden. Every number is (propuesta).

signal flickered

## A cop running this long on a working treadmill makes the lights flicker.
const RUN_FLICKER := 1.0
const FLICKERS := 4
const FLICKER_STEP := 0.12
const RUN_EVERY := 25.0
const RUN_TIME := 6.0
## How hard a running treadmill throws a cop off its back end (m/s) and how long it staggers.
const THROW := 7.0
const THROW_TIME := 1.0

var flickers := 0
var running := false
var _run_left := 0.0
var _until_run := RUN_EVERY
var _ran := {}
var _thrown := {}
var _lights: Array[Light3D] = []


func setup(place: GymRaid) -> void:
	super.setup(place)
	for light in place.get_node("Built").find_children("*", "OmniLight3D", true, false):
		_lights.append(light)
	for light in place.get_node("City").find_children("*", "DirectionalLight3D", true, false):
		_lights.append(light)


func _physics_process(delta: float) -> void:
	_until_run -= delta
	if not running and _until_run <= 0.0:
		start_running()
	elif running:
		_run_left -= delta
		if _run_left <= 0.0:
			running = false
			_until_run = RUN_EVERY
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var on := GymHall.treadmill_index(gym.to_local(cop.global_position))
		if on < 0 or not gym.treadmill_works(on):
			_ran.erase(cop)
			_thrown.erase(cop)
			continue
		# Each PC throws off its own player's cop: a copy of another one only follows its owner.
		if running and on != GymRaid.LULA_TREADMILL and not _thrown.has(cop) and is_mine(cop):
			_thrown[cop] = true
			cop.knock_back(gym.global_basis * Vector3(0, 2.0, -THROW), THROW_TIME)
		if cop.is_running:
			_ran[cop] = _ran.get(cop, 0.0) + delta
			if _ran[cop] >= RUN_FLICKER:
				_ran[cop] = -INF
				flicker()
		else:
			_ran.erase(cop)


## The working treadmills start on their own (with a roar) for RUN_TIME seconds.
func start_running() -> void:
	running = true
	_run_left = RUN_TIME
	_thrown.clear()
	for i in GymHall.TREADMILLS.size():
		if gym.treadmill_works(i) and i != GymRaid.LULA_TREADMILL:
			gym.raid.float_label(tr("GYM_TREADMILL_ROAR"),
				gym.to_global(GymHall.TREADMILLS[i] + Vector3(0, GymHall.FLOOR_TOP + 1.2, 0)), Color(1, 0.6, 0.2))


## The lights of the gym and the neighborhood flicker; the first time is the clue.
func flicker() -> void:
	flickers += 1
	if flickers == 1:
		gym.raid.add_clue(tr("CLUE_LIGHTS_FLICKER"))
	for i in FLICKERS * 2:
		get_tree().create_timer(FLICKER_STEP * (i + 1)).timeout.connect(func() -> void:
			for light in _lights:
				if is_instance_valid(light):
					light.visible = i % 2 == 1)
	flickered.emit()
