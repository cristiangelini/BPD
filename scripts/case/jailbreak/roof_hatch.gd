class_name RoofHatch
extends StaticBody3D

## The way between the storage room and the roof in the roof jailbreak (docs/diseno/fuga-techo.md, step 2): the
## ladder in the storage room (E climbs up, `goes_up`) and the hatch on the roof (E climbs back down). The level moves
## the cop (`used`).

signal used(hatch: RoofHatch, cop: Cop)

const LADDER := preload("res://assets/models/roof_ladder.glb")
const HATCH := preload("res://assets/models/roof_hatch.glb")

## The ladder (up) or the hatch on the roof (down).
@export var goes_up := true


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 5.6, 0.1) if goes_up else Vector3(0.9, 0.2, 0.9)
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	add_child((LADDER if goes_up else HATCH).instantiate())


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LADDER_UP" if goes_up else "PROMPT_HATCH_DOWN"


func use(cop: Cop) -> void:
	used.emit(self, cop)
