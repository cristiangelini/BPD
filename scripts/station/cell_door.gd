class_name CellDoor
extends StaticBody3D

## A cell's barred door at the station (comisaria.md, fuga.md): 1.2 m of bars hinged at its west end, with a lock.
## Its origin is on the hinge, on the ground, and it runs along local +X. Unlocked, E opens it outward (+Z, into
## the cells room) and closes it; locked, E only rattles it, unless the cop has the key (CellKey) in hand. In the
## jailbreak both doors start locked. Every number here is (propuesta).

const WIDTH := 1.2
const BAR_EVERY := 0.25
const BARS := Color(0.25, 0.27, 0.3)
const LOCK := Color(0.65, 0.55, 0.25)
## How far it swings open.
const OPEN_TURN := -PI / 2
const SWING_TIME := 0.4

var locked := false
## The bribe jailbreak's guard (fuga-soborno.md): without the key, E on the locked door calls him and pays him.
var bribe: BribeGuard
var is_open := false
var _swing: Tween


func _ready() -> void:
	add_to_group("cell_doors")
	var height := GameScale.DOOR_HEIGHT
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(WIDTH, height, 0.1)
	shape.shape = box
	shape.position = Vector3(WIDTH / 2, height / 2, 0)
	add_child(shape)
	var material := StandardMaterial3D.new()
	material.albedo_color = BARS
	var x := BAR_EVERY / 2
	while x < WIDTH:
		_bar(Vector3(x, height / 2, 0), Vector3(0.05, height, 0.05), material)
		x += BAR_EVERY
	for y: float in [0.1, height / 2, height - 0.05]:
		_bar(Vector3(WIDTH / 2, y, 0), Vector3(WIDTH, 0.06, 0.06), material)
	var brass := StandardMaterial3D.new()
	brass.albedo_color = LOCK
	_bar(Vector3(WIDTH - 0.12, 1.0, 0), Vector3(0.14, 0.18, 0.14), brass)


func _bar(at: Vector3, size: Vector3, material: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	add_child(instance)


func prompt_key(cop: Cop) -> String:
	if locked and not _has_key(cop) and bribe and bribe.door_prompt(self, cop) != "":
		return bribe.door_prompt(self, cop)
	if locked:
		return "PROMPT_CELL_UNLOCK" if _has_key(cop) else "PROMPT_CELL_LOCKED"
	return "PROMPT_CELL_CLOSE" if is_open else "PROMPT_CELL_OPEN"


## E on it: with the key in hand a locked door unlocks and swings open; without it, it only rattles.
func use(cop: Cop) -> void:
	if locked and _has_key(cop):
		unlock()
		set_open(true)
		return
	if locked and bribe and bribe.door_prompt(self, cop) != "":
		bribe.door_use(self, cop)
		return
	if locked:
		_rattle()
		return
	set_open(not is_open)


static func _has_key(cop: Cop) -> bool:
	return cop != null and cop.get_node("Grabber").held is CellKey


func set_open(open: bool) -> void:
	is_open = open
	if _swing:
		_swing.kill()
	_swing = create_tween()
	_swing.tween_property(self, "rotation:y", OPEN_TURN if open else 0.0, SWING_TIME)


## Locks it shut, closing it first if it was open.
func lock() -> void:
	if is_open:
		set_open(false)
	locked = true


func unlock() -> void:
	locked = false


## A locked door shakes a little and stays shut.
func _rattle() -> void:
	if _swing and _swing.is_running():
		return
	_swing = create_tween()
	for turn: float in [0.03, -0.03, 0.0]:
		_swing.tween_property(self, "rotation:y", turn, 0.05)
