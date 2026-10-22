class_name Comisario
extends StaticBody3D

## The comisario behind his desk at the station (docs/diseno/comisaria.md, "El comisario"): E on him gives the case
## of the shift. Until then the patrol car won't take anyone ("¡Primero el caso!").

## A cop talked to him; the case listens and gives the tip once.
signal spoke(cop: Cop)

const MODEL := preload("res://assets/models/npc_comisario.glb")
## Woken up at night by the jailbreak's guard (fuga.md).
const PAJAMAS := preload("res://assets/models/npc_comisario_pijama.glb")

## In his pajamas instead of his uniform.
@export var in_pajamas := false


func _ready() -> void:
	add_child((PAJAMAS if in_pajamas else MODEL).instantiate())
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_COMISARIO"


func use(cop: Cop) -> void:
	spoke.emit(cop)
