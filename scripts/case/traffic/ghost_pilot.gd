class_name GhostPilot
extends Node

## The Titiritero's remote control, seen from the ghost car (control-auto-fantasma.md, "Cómo es", steps 3 to 5): a child
## of the ghost QueueCar. While it waits in the queue and its pilot's car is there too, every PRANK_EVERY it pulls a
## prank by itself: honks, flashes its lights, creeps up to the barrier or backs up into the cop behind it. E at its
## empty window scares the pilot into a prank right away, and opening its trunk makes it bolt. Every prank is the tic:
## the pilot's remote shows at his window for TIC_SECONDS. Every number here is (propuesta).

signal pranked(kind: String)

const PRANKS: Array[String] = ["honk", "lights", "creep", "reverse"]
const PRANK_EVERY := Vector2(15.0, 25.0)
## Scared (E at its window), it pranks this soon, unless it just did one.
const SCARED_AFTER := 0.6
const SCARE_GAP := 4.0
const TIC_SECONDS := 2.0
## How far each move takes it from its place (forward is -; never past the barrier's face, 1.75 m ahead of a
## first car), and how fast it gets there and back.
const CREEP := -1.3
const REVERSE := 1.2
const BOLT := -1.5
const LURCH_SPEED := 5.0
const RETURN_SPEED := 1.0
## Backing up, it shoves cops this close behind its back bumper.
const SHOVE_REACH := 1.6
const SHOVE_SPEED := 4.0
const SHOVE_SECONDS := 0.6
const FLASH_SECONDS := 1.5
## Its headlights, in the car's space (forward is +Z).
const LAMPS: Array[Vector3] = [Vector3(-0.7, 0.75, 2.33), Vector3(0.7, 0.75, 2.33)]
const HONKS := 3

var car: QueueCar
var pranks := 0
var last_prank := ""
var _prank_left := 0.0
var _since_prank := INF
var _lurch_to := 0.0
var _tic_left := 0.0
var _flash_left := 0.0
var _flash: Node3D
## The car its remote shows at, to put it away there when that car leaves.
var _shown_on: QueueCar
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	car = get_parent() as QueueCar
	_rng.seed = hash(["ghost pranks", car.plate])
	_prank_left = _rng.randf_range(PRANK_EVERY.x, PRANK_EVERY.y)
	_flash = Node3D.new()
	_flash.name = "Flash"
	_flash.visible = false
	car.add_child(_flash)
	var lamp := StandardMaterial3D.new()
	lamp.albedo_color = Color(1.0, 0.97, 0.75)
	lamp.emission_enabled = true
	lamp.emission = Color(1.0, 0.95, 0.6)
	lamp.emission_energy_multiplier = 4.0
	for at in LAMPS:
		var bulb := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.16
		sphere.height = 0.2
		bulb.mesh = sphere
		bulb.material_override = lamp
		bulb.position = at
		_flash.add_child(bulb)


## The car whose driver holds the remote, while it's in the queue.
func pilot() -> QueueCar:
	var queue := car.get_parent() as TrafficQueue
	if not queue:
		return null
	for other in queue.cars:
		if is_instance_valid(other) and other.puppeteer and other.in_queue():
			return other
	return null


## It only plays up where its pilot can see it: both of them stopped in the queue.
func live() -> bool:
	var other := pilot()
	return car.waiting() and other != null and other.waiting()


func _physics_process(delta: float) -> void:
	_since_prank += delta
	if not car.follower and live():
		_prank_left -= delta
		if _prank_left <= 0.0:
			prank(PRANKS[_rng.randi() % PRANKS.size()])
	_move(delta)
	_tick_flash(delta)
	_tick_tic(delta)


## E at its empty window: the pilot jumps and presses something.
func scare() -> void:
	if _since_prank >= SCARE_GAP and live():
		_prank_left = minf(_prank_left, SCARED_AFTER)


## One of PRANKS, or "bolt" when its trunk opens; the pilot shows his remote. Online the host's pranks play on every PC.
func prank(kind: String) -> void:
	pranks += 1
	last_prank = kind
	_since_prank = 0.0
	_prank_left = _rng.randf_range(PRANK_EVERY.x, PRANK_EVERY.y)
	match kind:
		"honk":
			car.say(tr("GHOST_HONK_%d" % (pranks % HONKS)))
		"lights":
			_flash_left = FLASH_SECONDS
		"creep":
			_lurch_to = CREEP
		"reverse":
			_lurch_to = REVERSE
			_shove()
		"bolt":
			_lurch_to = BOLT
	_tic_left = TIC_SECONDS
	pranked.emit(kind)


## Off it goes to where the prank takes it, then slowly back to its place.
func _move(delta: float) -> void:
	if _lurch_to != 0.0:
		car.lurch = move_toward(car.lurch, _lurch_to, LURCH_SPEED * delta)
		if is_equal_approx(car.lurch, _lurch_to):
			_lurch_to = 0.0
	else:
		car.lurch = move_toward(car.lurch, 0.0, RETURN_SPEED * delta)


## Backing up, every cop right behind it gets shoved back.
func _shove() -> void:
	var back := -car.global_basis.z
	var bumper := car.global_position + back * (car.length() / 2)
	for cop: Cop in car.get_tree().get_nodes_in_group("cops"):
		var off := cop.global_position - bumper
		off.y = 0.0
		if off.length() < SHOVE_REACH and off.dot(back) > -0.5:
			cop.knock_back(back * SHOVE_SPEED, SHOVE_SECONDS)


func _tick_flash(delta: float) -> void:
	_flash_left -= delta
	_flash.visible = _flash_left > 0.0 and fmod(_flash_left, 0.5) > 0.25


## The tic: the pilot's remote out of his window while it lasts.
func _tick_tic(delta: float) -> void:
	_tic_left -= delta
	var other := pilot() if _tic_left > 0.0 else null
	if is_instance_valid(_shown_on) and _shown_on != other:
		GhostCar.show_remote(_shown_on, false)
	_shown_on = other
	if other:
		GhostCar.show_remote(other, true)


func ticking() -> bool:
	return _tic_left > 0.0


func flashing() -> bool:
	return _flash.visible


func _exit_tree() -> void:
	if is_instance_valid(_shown_on):
		GhostCar.show_remote(_shown_on, false)
