class_name VentGrille
extends StaticBody3D

## The loose vent grille high on a cell's back wall in the vent jailbreak (docs/diseno/fuga-ventilacion.md, step 1):
## a cop standing on the bunk loosens its SCREWS with E, TURNS presses each (at most one every TURN_EVERY seconds,
## with a fingernail), and with the last one out the grille drops to the floor and the hole into the duct is open.
## Every number here is (propuesta).

signal opened(grille: VentGrille)

const MODEL := preload("res://assets/models/vent_grille.glb")
const HOLE_MODEL := preload("res://assets/models/vent_hole.glb")
const SCREWS := 4
const TURNS := 4
const TURN_EVERY := 0.5
const HEIGHT := 2.2
## How high off the floor a cop's feet have to be to reach it (on the bunk).
const REACH_UP := 0.35

## Which cell it's in (0 or 1).
@export var cell := 0
var screws_left := SCREWS
## Turns given to the screw being loosened now.
var turns := 0
var floor_y := 0.0
var _next_turn_ms := 0
var _model: Node3D


func _ready() -> void:
	add_to_group("vent_grilles")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 0.4, 0.05)
	shape.shape = box
	add_child(shape)
	add_child(HOLE_MODEL.instantiate())
	_model = MODEL.instantiate()
	_model.position.z = 0.02
	add_child(_model)
	_refresh()


func is_open() -> bool:
	return screws_left <= 0


## Whether `cop` is up high enough (standing on the bunk) to reach it.
func reaches(cop: Node3D) -> bool:
	return cop.global_position.y - floor_y >= REACH_UP


func prompt_key(cop: Cop) -> String:
	if is_open():
		return ""
	return "PROMPT_VENT_SCREW" if reaches(cop) else "PROMPT_VENT_TOO_HIGH"


func use(cop: Cop) -> void:
	if is_open() or not reaches(cop):
		return
	var now := Time.get_ticks_msec()
	if now < _next_turn_ms:
		return
	_next_turn_ms = now + int(TURN_EVERY * 1000.0)
	turn()


## One more turn of the screw being loosened; the last turn takes it out.
func turn() -> void:
	if is_open():
		return
	turns += 1
	if turns >= TURNS:
		turns = 0
		screws_left -= 1
	_refresh()
	if is_open():
		opened.emit(self)


func _refresh() -> void:
	for i in SCREWS:
		var screw := _model.find_child("screw_%d" % i, true, false) as Node3D
		if screw:
			screw.visible = i < screws_left
	# Off the wall, it lies on the floor below.
	_model.position = Vector3(0, -(HEIGHT - 0.02) if is_open() else 0.0, 0.25 if is_open() else 0.02)
	_model.rotation.x = -PI / 2 if is_open() else 0.0


## Online: how many screws are left and the turns on the next (NpcSync).
func net_state() -> Variant:
	return [screws_left, turns]


func apply_net_state(state: Variant) -> void:
	screws_left = state[0]
	turns = state[1]
	_refresh()
