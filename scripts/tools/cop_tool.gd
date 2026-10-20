class_name CopTool
extends Node3D

## One of the tools in a cop's belt (docs/diseno/herramientas.md). It hangs from the camera all the time; its model
## only shows while it's in hand, and left click uses it then.

## Where the tool sits in the right hand, relative to the camera.
const IN_HAND := Vector3(0.17, -0.15, -0.5)

## Its name on the belt (tr() key).
var name_key := ""
## Set by the belt.
var cop: Cop
var model: Node3D


func _ready() -> void:
	model = build_model()
	model.position = IN_HAND
	model.visible = false
	add_child(model)
	for mesh in model.find_children("*", "GeometryInstance3D", true, false):
		(mesh as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func set_in_hand(in_hand: bool) -> void:
	model.visible = in_hand


## What left click does with it right now (tr() key), under the crosshair.
func prompt_key() -> String:
	return ""


## Left click pressed with the tool in hand.
func press() -> void:
	pass


## Left click let go.
func release() -> void:
	pass


## The placeholder model in hand (procedural low poly, decision 71).
func build_model() -> Node3D:
	return Node3D.new()


## A box or cylinder piece of a placeholder model, in a flat color.
static func piece(mesh: PrimitiveMesh, color: Color, at := Vector3.ZERO, turn := Vector3.ZERO) -> MeshInstance3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	mesh.material = material
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = at
	part.rotation = turn
	return part


static func box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


static func cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	mesh.rings = 1
	return mesh
