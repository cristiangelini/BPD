class_name IcePuddle
extends Area3D

## A puddle of melted ice cream on the floor (docs/diseno/allanamiento-heladeria.md, "Lo que se derrite"): a cop who
## walks on it slides on a little, and one who runs on it falls (a shove and a stagger). Each PC only throws its own
## cop, like the gym's treadmills. The origin is on the floor in the middle.

## Its color, by default the cold room's mix of everything.
var color := Color(0.85, 0.62, 0.55, 0.9)
## The push a walking cop keeps sliding with (times its speed), and the shove and stagger of a running one's fall.
const SLIDE := 0.3
const FALL_PUSH := 5.0
const FALL_SECONDS := 1.5

var size := Vector2(3.0, 3.0)
## How many cops fell in it.
var falls := 0


func _init(puddle_size := Vector2(3.0, 3.0), puddle_color := Color(0.85, 0.62, 0.55, 0.9)) -> void:
	size = puddle_size
	color = puddle_color


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size.x, 0.6, size.y)
	shape.shape = box
	shape.position.y = 0.3
	add_child(shape)
	var look := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 0.01
	mesh.radial_segments = 12
	look.mesh = mesh
	look.scale = Vector3(size.x, 1.0, size.y)
	look.position.y = 0.012
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.05
	look.material_override = material
	add_child(look)


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is Cop:
			slip(body)


## What the puddle does to `cop` this frame.
func slip(cop: Cop) -> void:
	if cop.is_staggered() or not GymRaidRig.is_mine(cop) or not cop.is_on_floor():
		return
	var going := Vector3(cop.velocity.x, 0.0, cop.velocity.z)
	if going.length() < 0.5:
		return
	if cop.is_running:
		falls += 1
		cop.knock_back(going.normalized() * FALL_PUSH, FALL_SECONDS)
		cop.show_hint("HINT_ICE_SLIPPED")
	else:
		cop.knock_back(going * SLIDE, 0.0)
