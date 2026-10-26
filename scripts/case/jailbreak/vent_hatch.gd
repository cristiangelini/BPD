class_name VentHatch
extends StaticBody3D

## A grille in the duct's floor in the vent jailbreak (docs/diseno/fuga-ventilacion.md, step 2): over each cell, back
## down into it; over the comisario's office, kicked open to drop in. E asks the level (`used`), which moves the cop.

signal used(hatch: VentHatch, cop: Cop)

const MODEL := preload("res://assets/models/vent_grille.glb")

## Where it lets a cop down, in the lot's space (the level turns it into the world).
var drop_to: Transform3D
## The one into the comisario's office (the way out); the others go back to a cell.
var into_office := false


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 0.06, 0.4)
	shape.shape = box
	shape.position.y = 0.03
	add_child(shape)
	var grille := MODEL.instantiate() as Node3D
	grille.rotation.x = -PI / 2
	grille.position.y = 0.02
	add_child(grille)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_VENT_OFFICE" if into_office else "PROMPT_VENT_DROP"


func use(cop: Cop) -> void:
	used.emit(self, cop)
