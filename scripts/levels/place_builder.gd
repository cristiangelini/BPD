class_name PlaceBuilder
extends RefCounted

## Builds a place to raid out of colored boxes under one node: walls with door gaps, floor slabs, open boxes,
## legs and lights. The same pieces the grandpa's house builds itself with, shared by the places that came after.

const WALL := 0.15
const SLAB := 0.2

var root: Node3D
var _materials := {}


func _init(new_root: Node3D) -> void:
	root = new_root


## A wall along "x" (at z = fixed) or "z" (at x = fixed) on floor `level`, with door gaps centered at `doors`.
func wall(axis: String, fixed: float, from: float, to: float, level: int, doors: Array, color: Color) -> void:
	var y0 := level * GameScale.FLOOR_HEIGHT
	var height := GameScale.FLOOR_HEIGHT - SLAB
	var start := from
	var sorted_doors := doors.duplicate()
	sorted_doors.sort()
	for d: float in sorted_doors:
		var a := d - GameScale.DOOR_WIDTH / 2
		var b := d + GameScale.DOOR_WIDTH / 2
		_wall_piece(axis, fixed, start, a, y0, height, color)
		_wall_piece(axis, fixed, a, b, y0 + GameScale.DOOR_HEIGHT, height - GameScale.DOOR_HEIGHT, color)
		start = b
	_wall_piece(axis, fixed, start, to, y0, height, color)


func _wall_piece(axis: String, fixed: float, a: float, b: float, y0: float, height: float, color: Color) -> void:
	if b - a < 0.01 or height < 0.01:
		return
	var mid := (a + b) / 2
	if axis == "x":
		box(Vector3(mid, y0 + height / 2, fixed), Vector3(b - a, height, WALL), color)
	else:
		box(Vector3(fixed, y0 + height / 2, mid), Vector3(WALL, height, b - a), color)


## A floor slab whose top is at y = top.
func slab(x0: float, x1: float, z0: float, z1: float, top: float, color: Color) -> void:
	if x1 - x0 < 0.01 or z1 - z0 < 0.01:
		return
	box(Vector3((x0 + x1) / 2, top - SLAB / 2, (z0 + z1) / 2), Vector3(x1 - x0, SLAB, z1 - z0), color)


## A ramp to walk up one floor along -Z from `foot`, under treads that are only for the look.
func stairs(foot: Vector3, run: float, color: Color) -> void:
	var rise := GameScale.FLOOR_HEIGHT
	var steps := roundi(rise / GameScale.STEP_HEIGHT)
	var depth := run / steps
	for i in steps:
		var top := foot.y + (i + 1) * GameScale.STEP_HEIGHT
		mesh_box(Vector3(foot.x, top - 0.03, foot.z - (i + 0.5) * depth), Vector3(GameScale.STAIR_WIDTH, 0.06, depth), color)
	var ramp := body(foot + Vector3(0, rise / 2, -run / 2))
	ramp.rotation.x = atan2(rise, run)
	shape(ramp, Vector3(GameScale.STAIR_WIDTH, 0.05, Vector2(run, rise).length()))


## Four thin legs under a footprint, from the floor up to height.
func legs(center: Vector3, footprint: Vector2, height: float, color: Color) -> void:
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var at := center + Vector3(sx * (footprint.x / 2 - 0.06), height / 2, sz * (footprint.y / 2 - 0.06))
			box(at, Vector3(0.08, height, 0.08), color)


## A box open on one face ("top", "-x", "+x", "-z" or "+z"), standing on bottom_center.
func open_box(bottom_center: Vector3, size: Vector3, open: String, color: Color) -> void:
	var t := 0.05
	var center := bottom_center + Vector3(0, size.y / 2, 0)
	var faces := {
		"bottom": [Vector3(0, -size.y / 2 + t / 2, 0), Vector3(size.x, t, size.z)],
		"top": [Vector3(0, size.y / 2 - t / 2, 0), Vector3(size.x, t, size.z)],
		"-x": [Vector3(-size.x / 2 + t / 2, 0, 0), Vector3(t, size.y, size.z)],
		"+x": [Vector3(size.x / 2 - t / 2, 0, 0), Vector3(t, size.y, size.z)],
		"-z": [Vector3(0, 0, -size.z / 2 + t / 2), Vector3(size.x, size.y, t)],
		"+z": [Vector3(0, 0, size.z / 2 - t / 2), Vector3(size.x, size.y, t)],
	}
	for face: String in faces:
		if face != open:
			box(center + faces[face][0], faces[face][1], color)


func light(at: Vector3) -> OmniLight3D:
	var lamp := OmniLight3D.new()
	lamp.position = at
	lamp.light_color = Color(1.0, 0.82, 0.6)
	lamp.light_energy = 0.7
	lamp.omni_range = 8.0
	root.add_child(lamp)
	return lamp


func box(center: Vector3, size: Vector3, color: Color) -> void:
	shape(body(center), size)
	mesh_box(center, size, color)


func body(at: Vector3) -> StaticBody3D:
	var static_body := StaticBody3D.new()
	static_body.position = at
	root.add_child(static_body)
	return static_body


func shape(static_body: StaticBody3D, size: Vector3) -> void:
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	static_body.add_child(collision)


func mesh_box(center: Vector3, size: Vector3, color: Color) -> void:
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh(box_mesh, center, color)


func mesh(new_mesh: Mesh, at: Vector3, color: Color, turn := Vector3.ZERO) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = new_mesh
	instance.rotation = turn
	instance.material_override = material(color)
	instance.position = at
	root.add_child(instance)


func material(color: Color) -> StandardMaterial3D:
	if not _materials.has(color):
		var new_material := StandardMaterial3D.new()
		new_material.albedo_color = color
		new_material.roughness = 0.9
		# See-through colors (glass) need blending.
		if color.a < 1.0:
			new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_materials[color] = new_material
	return _materials[color]
