class_name ItchyCostume
extends Grabbable

## The costume of the sale basket that itches (allanamiento-disfraces.md, "Los disfraces que pican"): a cop who grabs it
## drops it and scratches for SCRATCH seconds ("I itch all over!"), and the first time that's the story's clue.

signal itched(cop: Cop)

const MODEL := preload("res://assets/models/itchy_costume.glb")
const SIZE := Vector3(0.4, 0.12, 0.3)
const SCRATCH := 3.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 1.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func hold(holder_id: int, point: Vector3) -> void:
	super.hold(holder_id, point)
	var grabber := instance_from_id(holder_id) as Grabber
	if not grabber:
		return
	var cop := grabber.get_parent() as Cop
	_drop.call_deferred(grabber)
	cop.stagger(SCRATCH)
	cop.show_hint("HINT_ITCHY")
	itched.emit(cop)


## Out of the cop's hands, and online the owner's PC hears it's empty-handed again.
func _drop(grabber: Grabber) -> void:
	grabber.release()
	var cop := grabber.get_parent() as Cop
	if cop.sync and multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		cop.sync.tell_held()
