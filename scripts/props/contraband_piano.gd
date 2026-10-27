class_name ContrabandPiano
extends Evidence

## Mr. Bellini's grand piano (edificio.md, "El piano del contrabando"): full of gold ingots, so it doesn't sound. E on
## it plays a key and it goes "clonc". Every hard hit shakes an ingot loose, up to INGOTS. It faces -x, keyboard first.
## Every number here is (propuesta).

signal played
signal ingot_dropped(ingot: RigidBody3D)

const INGOTS := 3
const INGOT_MODEL := preload("res://assets/models/gold_ingot.glb")
const INGOT_SIZE := Vector3(0.25, 0.07, 0.11)

var ingots_left := INGOTS


func _ready() -> void:
	super._ready()
	damaged.connect(func(_loss: float) -> void: drop_ingot())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PIANO"


func use(cop: Cop) -> void:
	cop.show_hint("HINT_PIANO_CLONK")
	played.emit()


## A gold ingot falls out from under the lid (heavy, worth nothing on its own: the piano is the evidence).
func drop_ingot() -> void:
	if ingots_left <= 0:
		return
	ingots_left -= 1
	var ingot := Grabbable.new()
	ingot.mass = 12.0
	ingot.collision_layer = collision_layer
	ingot.collision_mask = collision_mask
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = INGOT_SIZE
	shape.shape = box
	ingot.add_child(shape)
	var model := INGOT_MODEL.instantiate()
	model.position.y = -INGOT_SIZE.y / 2
	ingot.add_child(model)
	get_parent().add_child(ingot)
	ingot.global_position = global_position + global_basis * Vector3(0.5, -0.2, 0.75)
	ingot.linear_velocity = global_basis * Vector3(0.0, 0.5, 1.5)
	ingot_dropped.emit(ingot)
