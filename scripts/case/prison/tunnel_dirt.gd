class_name TunnelDirt
extends Node3D

## A bit of the tunnel's dirt on the floor (carcel-tunel.md, step 3): a little pile shaken out of a gang member's
## trouser leg in the yard, which stays, or a dirty footprint, which fades away after PRINT_LIFE seconds. Its origin is
## on the floor; a print's -Z is the way its walker went. Every number here is (propuesta).

enum Kind { PILE, PRINT }

const PRINT_LIFE := 30.0
const FADE_TIME := 3.0
const COLOR := Color(0.42, 0.3, 0.18)

var kind := Kind.PILE
var _material: StandardMaterial3D


func _ready() -> void:
	add_to_group("tunnel_dirt")
	_material = StandardMaterial3D.new()
	_material.albedo_color = COLOR
	_material.roughness = 1.0
	if kind == Kind.PILE:
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.06
		mesh.bottom_radius = 0.2
		mesh.height = 0.07
		mesh.radial_segments = 7
		_piece(mesh, Vector3(0, 0.035, 0))
		return
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for x: float in [-0.09, 0.09]:
		var shoe := BoxMesh.new()
		shoe.size = Vector3(0.09, 0.006, 0.24)
		_piece(shoe, Vector3(x, 0.004, 0.1 if x < 0 else -0.1))
	var fade := create_tween()
	fade.tween_interval(PRINT_LIFE - FADE_TIME)
	fade.tween_property(_material, "albedo_color:a", 0.0, FADE_TIME)
	fade.tween_callback(queue_free)


## What a guest's copy needs before it's added (NpcSync, step 7): a pile or a print.
func net_setup() -> Dictionary:
	return {"kind": kind}


func _piece(mesh: PrimitiveMesh, at: Vector3) -> void:
	mesh.material = _material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = at
	add_child(instance)
