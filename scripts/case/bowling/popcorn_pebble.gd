class_name PopcornPebble
extends Grabbable

## One of the painted pebbles the popcorn machine spits (allanamiento-bolera.md, "Las palomitas mágicas"): small,
## light and bouncy. A script of its own, so the guests' copy of one the host's machine spat is made the same
## (PropSync). Every number here is (propuesta).

const MODEL := preload("res://assets/models/popcorn_pebble.glb")
const SIZE := Vector3(0.06, 0.05, 0.05)
const KG := 0.05
const BOUNCE := 0.8


func net_setup() -> Dictionary:
	return {}


func _ready() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var material := PhysicsMaterial.new()
	material.bounce = BOUNCE
	physics_material_override = material
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.position.y = -SIZE.y / 2
	add_child(model)
