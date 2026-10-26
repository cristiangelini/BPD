class_name ArmTable
extends StaticBody3D

## The arm-wrestling table in the biker bar's patio (infiltracion-motos.md, step 3, decision 176): a high round table
## with two elbow pads and, while someone is wrestling, two clasped forearms on it that lean toward whoever is winning
## (`lean`, from -1, the biker, to 1, the cop). E on it is a push; on the host it's `pushed` (step 4 counts them). Online
## the host tells the guests how it leans (step 6). Every number here is (propuesta).

signal pushed(cop: Cop)

const MODEL := preload("res://assets/models/arm_table.glb")
const ARMS := preload("res://assets/models/arm_lock.glb")
const TOP := 1.03
## The most the arms lean (radians).
const MAX_LEAN := 1.1

## -1 the biker is winning, 1 the cop.
var lean := 0.0
var _arms: Node3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.9, TOP, 0.9)
	shape.shape = box
	shape.position.y = TOP / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	_arms = ARMS.instantiate()
	_arms.name = "Arms"
	_arms.position.y = TOP
	add_child(_arms)
	set_wrestling(false)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BIKER_ARM"


## A push: on the host, `pushed`.
func use(cop: Cop) -> void:
	if multiplayer.is_server():
		pushed.emit(cop)


## Shows the clasped arms (someone is wrestling) or not, straight up.
func set_wrestling(on: bool) -> void:
	_arms.visible = on
	set_lean(0.0)


## Leans the arms to `value` (-1 the biker wins, 1 the cop): the cop's side is +Z.
func set_lean(value: float) -> void:
	lean = clampf(value, -1.0, 1.0)
	_arms.rotation.x = lean * MAX_LEAN


func is_wrestling() -> bool:
	return _arms.visible
