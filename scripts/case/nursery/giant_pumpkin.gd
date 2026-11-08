class_name GiantPumpkin
extends Grabbable

## The contest seeds' giant pumpkin (allanamiento-vivero.md, "Las semillas del concurso"): 30 kg, round, it takes two
## cops to move. Made in code, so online the guests' copy is made from this script with the host's name (PropSync).

const MODEL := preload("res://assets/models/giant_pumpkin.glb")
const KG := 30.0
const RADIUS := 0.48


func _init() -> void:
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = RADIUS
	shape.shape = ball
	add_child(shape)
	var look: Node3D = MODEL.instantiate()
	look.position.y = -RADIUS
	add_child(look)


func net_setup() -> Dictionary:
	return {"name": name}
