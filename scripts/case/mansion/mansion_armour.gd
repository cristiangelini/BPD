class_name MansionArmour
extends StaticBody3D

## The suit of armour in the mansion's hall (escena-mansion.md, "Las pistas"), on its stone base. E pushes it and it
## comes down with a crash, face first; a hair caught on it (the case's clue) is lost with it.

signal fell

const SIZE := Vector3(0.45, 1.85, 0.3)
const STEEL := Color(0.7, 0.72, 0.75)
const FALL_SECONDS := 0.5

var fallen := false


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.9, 0), Vector3(0.45, 0.9, 0.3), STEEL)
	builder.mesh_box(Vector3(0, 1.55, 0), Vector3(0.3, 0.35, 0.3), STEEL)
	builder.mesh_box(Vector3(0, 1.62, 0.151), Vector3(0.2, 0.04, 0.01), Color(0.1, 0.1, 0.1))
	builder.mesh_box(Vector3(0, 0.2, 0), Vector3(0.4, 0.5, 0.25), STEEL.darkened(0.15))


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ARMOUR_FALLEN" if fallen else "PROMPT_ARMOUR"


func use(cop: Cop) -> void:
	if fallen:
		return
	push_over()
	if cop:
		cop.show_hint("HINT_ARMOUR_CRASH")


## Down it goes, toward its front (+Z).
func push_over() -> void:
	if fallen:
		return
	fallen = true
	create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) \
		.tween_property(self, "rotation:x", PI / 2, FALL_SECONDS).set_ease(Tween.EASE_IN)
	fell.emit()
