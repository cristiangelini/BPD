class_name TrainLadder
extends StaticBody3D

## The iron ladder by each car's front door, up to the skylight (escena-tren.md, pregunta 3): E puts the cop on the
## car's roof, for the chase after a magician running off along the roofs (TrainRoofChase).

const SIZE := Vector3(0.1, GameScale.FLOOR_HEIGHT, 0.5)
const IRON := Color(0.3, 0.3, 0.32)

var train: Train


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	for z: float in [-SIZE.z / 2, SIZE.z / 2]:
		builder.mesh_box(Vector3(0, SIZE.y / 2, z), Vector3(0.04, SIZE.y, 0.04), IRON)
	for i in 8:
		builder.mesh_box(Vector3(0, 0.3 + i * 0.3, 0), Vector3(0.03, 0.03, SIZE.z), IRON)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRAIN_LADDER"


## Up through the skylight: on the roof, right above.
func use(cop: Cop) -> void:
	var up := train.cars().to_global(Vector3(position.x - 0.8, TrainRoofChase.ROOF_Y + 0.1, 0))
	cop.warp(Transform3D(cop.global_basis, up))
