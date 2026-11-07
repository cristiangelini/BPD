class_name BookcaseShelf
extends StaticBody3D

## The loose shelf of Tablita's bookcase (docs/diseno/allanamiento-muebleria.md, "Tablita"). It leans against the
## bookcase until a cop holds E on it: then it's up in its slot and the cop has to keep E down HOLD_TIME seconds
## without moving while Tablita screws it in. Letting go or walking off drops it ("Oops! Again..."). Held long enough,
## Tablita tells that cop what he saw, and a while later the shelf comes loose again for the next one. Every number
## here is (propuesta).

## A cop took it up into its slot.
signal taken(cop: Cop)
## Held long enough: screwed in.
signal held(cop: Cop)
## Let go too soon.
signal dropped(cop: Cop)

const MODEL := preload("res://assets/models/bookcase_shelf.glb")
const HOLD_TIME := 5.0
## A cop holding it who moves this far from where they took it lets go.
const STILL := 0.4
## Up in its slot, and leaning against the bookcase's side, in the bookcase's space.
const SLOT := Vector3(0, 1.1, 0.01)
const LEANING := Vector3(0.62, 0.42, 0.1)
const LEAN := 1.25
## Seconds it lies on the floor after falling before Tablita picks it up again.
const ON_FLOOR := 2.0
## Seconds it stays screwed in (while Tablita talks) before it comes loose again.
const SCREWED := 8.0

## Who's holding it up, and for how long.
var holder: Cop
var held_for := 0.0
var _held_at := Vector3.ZERO
var _floor_left := 0.0
var _screwed_left := 0.0
var _look: Node3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.84, 0.03, 0.32)
	shape.shape = box
	shape.position.y = 0.015
	add_child(shape)
	_look = MODEL.instantiate()
	add_child(_look)
	_lean()


func prompt_key(cop: Cop) -> String:
	return "" if holder or not _free() or cop.turning == self else "PROMPT_HOLD_SHELF"


## E pressed: up in its slot, held by this cop until they let go of E (end_turn).
func use(cop: Cop) -> void:
	if holder or not _free():
		return
	holder = cop
	held_for = 0.0
	_held_at = cop.global_position
	cop.turning = self
	position = SLOT
	rotation = Vector3.ZERO
	cop.show_hint("HINT_SHELF_HOLD")
	taken.emit(cop)


## E let go (or walked off): before HOLD_TIME the shelf falls.
func end_turn(cop: Cop) -> void:
	if is_instance_valid(cop) and cop.turning == self:
		cop.turning = null
	if cop != holder:
		return
	holder = null
	if held_for < HOLD_TIME:
		_fall()
		dropped.emit(cop)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if _floor_left > 0.0 or _screwed_left > 0.0:
		_floor_left -= delta
		_screwed_left -= delta
		if _free():
			_lean()
		return
	if holder == null:
		return
	if not is_instance_valid(holder) or holder.turning != self \
			or Vector2(holder.global_position.x - _held_at.x, holder.global_position.z - _held_at.z).length() > STILL:
		end_turn(holder)
		return
	held_for += delta
	if held_for < HOLD_TIME:
		return
	var cop := holder
	end_turn(cop)
	cop.show_hint("HINT_SHELF_DONE")
	_screwed_left = SCREWED
	held.emit(cop)


## Whether it's lying on the floor after falling.
func is_down() -> bool:
	return _floor_left > 0.0


## Whether it's leaning on the bookcase, ready to be held up.
func _free() -> bool:
	return _floor_left <= 0.0 and _screwed_left <= 0.0


func _fall() -> void:
	_floor_left = ON_FLOOR
	position = Vector3(SLOT.x, 0.02, SLOT.z + 0.6)
	rotation = Vector3(0, 0.3, 0)


func _lean() -> void:
	position = LEANING
	rotation = Vector3(0, 0, LEAN)
