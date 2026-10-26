class_name CellSkylight
extends StaticBody3D

## The old skylight in a cell's ceiling in the roof jailbreak (docs/diseno/fuga-techo.md, step 1): from the cell, a
## cop up high enough (on the mattress on the bunk, or on a partner's shoulders) pushes it with E, PUSHES presses (the
## seed's loose one, LOOSE_PUSHES), each a creak the guard can hear (`creaked`). Open, E climbs up onto the storage
## room over the cells (`climbed`), and from up there E on it climbs back down.
## Every number here is (propuesta).

signal creaked(skylight: CellSkylight)
signal climbed(skylight: CellSkylight, cop: Cop)

const FRAME := preload("res://assets/models/cell_skylight.glb")
const PANE := preload("res://assets/models/skylight_pane.glb")
const PUSHES := 4
const LOOSE_PUSHES := 2
## After a catch it has a new padlock: forcing it takes this many.
const LOCKED_PUSHES := 8
const PUSH_EVERY := 0.5
## How high off the cell's floor a cop's feet have to be to reach it (on the mattress on the bunk, or on someone).
const REACH_UP := 0.7
const OPEN_ANGLE := deg_to_rad(-100.0)
## How far each push lifts the pane before it gives.
const PUSH_ANGLE := deg_to_rad(-4.0)

## Which cell it's in (0 or 1).
@export var cell := 0
var pushes_left := PUSHES
var floor_y := 0.0
var _next_push_ms := 0
var _pane: Node3D


func _ready() -> void:
	add_to_group("cell_skylights")
	collision_layer = 8
	# One face under the ceiling, to push from the cell, and one on top, to climb down from the storage room.
	for y: float in [-0.03, StationRooms.WALL + 0.02]:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(0.8, 0.04, 0.8)
		shape.shape = box
		shape.position.y = y
		add_child(shape)
	add_child(FRAME.instantiate())
	_pane = PANE.instantiate()
	_pane.position = Vector3(0, -0.02, -0.35)
	add_child(_pane)
	_refresh()


func is_open() -> bool:
	return pushes_left <= 0


## The seed's loose one gives sooner.
func set_loose() -> void:
	pushes_left = LOOSE_PUSHES


## Whether `cop` is up in the storage room, over it.
func is_above(cop: Node3D) -> bool:
	return cop.global_position.y > global_position.y


## Whether `cop` can reach it: from above, or standing high enough in the cell.
func reaches(cop: Node3D) -> bool:
	return is_above(cop) or cop.global_position.y - floor_y >= REACH_UP


func prompt_key(cop: Cop) -> String:
	if is_above(cop):
		return "PROMPT_SKYLIGHT_DOWN"
	if not reaches(cop):
		return "PROMPT_SKYLIGHT_TOO_HIGH"
	return "PROMPT_SKYLIGHT_UP" if is_open() else "PROMPT_SKYLIGHT_PUSH"


func use(cop: Cop) -> void:
	if not reaches(cop):
		return
	if is_open() or is_above(cop):
		climbed.emit(self, cop)
		return
	var now := Time.get_ticks_msec()
	if now < _next_push_ms:
		return
	_next_push_ms = now + int(PUSH_EVERY * 1000.0)
	push()


## Shut again with a new padlock (after a catch).
func lock_again() -> void:
	pushes_left = LOCKED_PUSHES
	_refresh()


## One more push: it creaks, and the last one opens it.
func push() -> void:
	if is_open():
		return
	pushes_left -= 1
	_refresh()
	creaked.emit(self)


func _refresh() -> void:
	_pane.rotation.x = OPEN_ANGLE if is_open() else (PUSHES - pushes_left) * PUSH_ANGLE


## Online (NpcSync): how much it still holds.
func net_state() -> Variant:
	return pushes_left


func apply_net_state(state: Variant) -> void:
	if pushes_left != int(state):
		pushes_left = state
		_refresh()
