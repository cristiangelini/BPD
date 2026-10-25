class_name LaxativeJar
extends Grabbable

## The jar of "Laxante Exprés" hidden in the spiteful vendor's bin at the market (politico-mercado.md, step 5): whoever
## takes it out knows whose stall it was in (MarketSpite).

const MODEL := preload("res://assets/models/laxative_jar.glb")
## Shown bigger than it is, like the samples.
const SHOWN := 1.5


func _ready() -> void:
	mass = 0.3
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.05 * SHOWN
	cylinder.height = 0.12 * SHOWN
	shape.shape = cylinder
	shape.position.y = 0.06 * SHOWN
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * SHOWN
	add_child(model)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_LAXATIVE_JAR"
