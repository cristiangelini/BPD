class_name StorageBox
extends Grabbable

## A box of old files in the storage room over the cells in the roof jailbreak (docs/diseno/fuga-techo.md, step 2):
## the seed stacks some of them, ready to fall. One landing hard (falling faster than THUMP_SPEED) thumps on the
## cells' ceiling, and the host tells the guard (`thumped`).
## Every number here is (propuesta).

signal thumped(box: StorageBox)

const MODEL := preload("res://assets/models/storage_box.glb")
const SIZE := Vector3(0.5, 0.4, 0.4)
const THUMP_SPEED := 2.0

var _falling := false


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 4.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	add_to_group("storage_boxes")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not multiplayer.is_server() or freeze:
		return
	if linear_velocity.y < -THUMP_SPEED:
		_falling = true
	elif _falling and linear_velocity.y > -0.5:
		_falling = false
		thumped.emit(self)
