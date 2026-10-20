class_name CardboardCake
extends Grabbable

## A display cake in the wedding story (panaderia.md, "Las tortas de boda que nunca existieron"): it's cardboard, so
## it doesn't break, and grabbing it gives it away.

const MODEL := preload("res://assets/models/bakery_cake.glb")

var knocked := false


func _init() -> void:
	mass = 0.4
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.18
	cylinder.height = 0.18
	shape.shape = cylinder
	add_child(shape)
	add_child(MODEL.instantiate())


func hold(holder_id: int, point: Vector3) -> void:
	var first := not holders.has(holder_id)
	super.hold(holder_id, point)
	if not first:
		return
	var grabber := instance_from_id(holder_id) as Node
	if grabber and grabber.get_parent() is Cop:
		(grabber.get_parent() as Cop).show_hint("HINT_HOLLOW_CAKE")
		knocked = true
