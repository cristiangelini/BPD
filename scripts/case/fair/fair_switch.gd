class_name FairSwitch
extends StaticBody3D

## A control of one of the fun fair's rides (allanamiento-parque.md, step 2): the carousel's lever, the bumper cars'
## red button or the Ferris wheel's crank, on a little post. E on it calls `pressed`; what it says depends on its
## ride (FairRides.prompt_for).

signal pressed(cop: Cop)

const POST := Color(0.2, 0.2, 0.24)
const TOP := {"carousel": Color(0.9, 0.75, 0.3), "bumpers": Color(0.85, 0.2, 0.2), "wheel": Color(0.3, 0.45, 0.85)}

## "carousel", "bumpers" or "wheel".
var ride := ""
var rides: FairRides


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.4, 1.2, 0.4)
	shape.shape = box
	shape.position.y = 0.6
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.5, 0), Vector3(0.3, 1.0, 0.3), POST)
	builder.mesh_box(Vector3(0, 1.08, 0), Vector3(0.36, 0.16, 0.36), TOP[ride])
	match ride:
		"carousel":
			builder.mesh_box(Vector3(0, 1.35, 0.1), Vector3(0.05, 0.45, 0.05), POST.lightened(0.4))
		"bumpers":
			var knob := CylinderMesh.new()
			knob.top_radius = 0.08
			knob.bottom_radius = 0.08
			knob.height = 0.06
			builder.mesh(knob, Vector3(0, 1.19, 0), TOP[ride].lightened(0.2))
		"wheel":
			builder.mesh_box(Vector3(0.22, 1.08, 0), Vector3(0.08, 0.06, 0.06), POST.lightened(0.4))
			builder.mesh_box(Vector3(0.28, 1.2, 0), Vector3(0.05, 0.25, 0.05), POST.lightened(0.4))


func prompt_key(_cop: Cop) -> String:
	return rides.prompt_for(ride) if rides else ""


func use(cop: Cop) -> void:
	pressed.emit(cop)
