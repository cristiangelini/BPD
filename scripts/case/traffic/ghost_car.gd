class_name GhostCar
extends RefCounted

## The ghost car traffic control (control-auto-fantasma.md): every driver in the queue leans on their open window, but
## one car has nobody at the wheel. The Titiritero drives it by remote control from another car further back. This
## dresses the queue's cars: a driver at each window, and the ghost car's radio antenna with its blinking light and its
## front wheels that steer on their own. Every number here is (propuesta).

const DRIVER := preload("res://assets/models/window_driver.glb")
const ANTENNA := preload("res://assets/models/rc_antenna.glb")
const REMOTE := preload("res://assets/models/rc_remote.glb")
## In the window driver's hands, out in front of their face, its antenna up (the tic).
const REMOTE_AT := Vector3(0.05, 0.12, 0.3)
const REMOTE_SCALE := 1.5
## On the driver's side (+X) window sill of a sedan (TrafficCar's model), looking out.
const DRIVER_AT := Vector3(1.0, 0.95, 0.35)
## On the roof, toward the back.
const ANTENNA_AT := Vector3(-0.5, 1.59, -0.8)
## Red, light blue, white, green, yellow and violet, as WantedPlan.SHIRTS names them.
const SHIRTS: Array[Color] = [Color("c84a3a"), Color("7aa6d8"), Color("f2f0ea"), Color("4a9a5a"), Color("e0b040"),
	Color("7a4a9a")]
## Without a plan, the ghost car is this one in the queue (0 the first), from the seed...
const AT := Vector2i(2, 5)
## ...and its pilot comes this many cars behind it.
const PILOT_BEHIND := Vector2i(2, 5)
## Its front wheels steer back and forth this far (radians), this fast, while nobody turns them.
const STEER_MAX := 0.45
const STEER_RATE := 1.7
## Its antenna's light blinks this often.
const BLINK := 0.5
## What a cop gets for E at its empty window.
const NOBODY_LINES := 3


## Which car of the queue is the ghost one when no plan says it: from the seed, so every PC agrees.
static func ghost_at(case_seed: int) -> int:
	return AT.x + absi(hash(["ghost car at", case_seed])) % (AT.y - AT.x + 1)


## Which car of the queue its pilot drives when no plan says it.
static func pilot_at(case_seed: int) -> int:
	return ghost_at(case_seed) + PILOT_BEHIND.x + absi(hash(["ghost pilot", case_seed])) % (PILOT_BEHIND.y
		- PILOT_BEHIND.x + 1)


## The pilot's remote, out of his window or hidden away.
static func show_remote(car: Node3D, shown: bool) -> void:
	var driver := car.get_node_or_null("WindowDriver") as Node3D
	if not driver:
		return
	var remote := driver.get_node_or_null("Remote") as Node3D
	if not remote and shown:
		remote = REMOTE.instantiate()
		remote.name = "Remote"
		remote.position = REMOTE_AT
		remote.scale = Vector3.ONE * REMOTE_SCALE
		driver.add_child(remote)
	if remote:
		remote.visible = shown


## Whether the pilot's remote shows at this car's window right now.
static func remote_showing(car: Node3D) -> bool:
	var remote := car.get_node_or_null("WindowDriver/Remote") as Node3D
	return remote != null and remote.visible


## A driver leaning on its open window, in their own skin and hair (from the plate, so every PC agrees) and in `shirt`
## (one of SHIRTS, the plan's; -1 picks one from the plate too).
static func dress_driver(car: Node3D, plate: String, shirt := -1) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["window driver", plate])
	var driver: Node3D = DRIVER.instantiate()
	driver.name = "WindowDriver"
	driver.position = DRIVER_AT
	driver.rotation.y = PI / 2
	car.add_child(driver)
	CrowdedCar._tint(driver, "skin", CrowdedCar.SKINS[rng.randi() % CrowdedCar.SKINS.size()])
	CrowdedCar._tint(driver, "hair", CrowdedCar.HAIRS[rng.randi() % CrowdedCar.HAIRS.size()])
	var from_plate := rng.randi() % SHIRTS.size()
	CrowdedCar._tint(driver, "shirt", SHIRTS[shirt if shirt >= 0 else from_plate])


## The ghost car's antenna on its roof.
static func rig(car: Node3D) -> void:
	var antenna: Node3D = ANTENNA.instantiate()
	antenna.name = "Antenna"
	antenna.position = ANTENNA_AT
	car.add_child(antenna)


## Its front wheels steer by themselves and its antenna blinks, `time` seconds in.
static func haunt(car: Node3D, time: float) -> void:
	for i in 2:
		var wheel := car.get_node_or_null("Wheel%d" % i) as Node3D
		if wheel:
			wheel.rotation.y = sin(time * STEER_RATE) * STEER_MAX
	var tip := car.find_child("tip", true, false) as Node3D
	if tip:
		tip.visible = fmod(time, BLINK * 2) < BLINK


## E at its empty window: one of NOBODY_LINES, in turn.
static func nobody_line(times: int) -> String:
	return "GHOST_NOBODY_%d" % (times % NOBODY_LINES)
