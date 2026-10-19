class_name Dresser
extends Node3D

## A chest of drawers (cómoda) built from boxes when it loads: a static case open at the front (+Z) and DRAWERS
## drawers that slide out of it. Its origin is on the floor at the middle of the front. Turn it only in steps of 90°.

const DRAWERS := 3
const WIDTH := 1.0
const DEPTH := 0.5
const HEIGHT := 1.0
const PLANK := 0.03
const DRAWER_KG := 3.0
const WOOD := Color(0.62, 0.4, 0.26)
const FRONT := Color(0.78, 0.55, 0.36)
const KNOB := Color(0.95, 0.8, 0.3)

## One array per drawer with the scenes to put inside it (the house fills it from the case seed).
@export var contents: Array = []

var drawers: Array[Drawer] = []


func _ready() -> void:
	if drawers.size() > 0:
		return
	var shell := StaticBody3D.new()
	add_child(shell)
	var back := -DEPTH
	_static_box(shell, Vector3(0, HEIGHT / 2, back + PLANK / 2), Vector3(WIDTH, HEIGHT, PLANK))
	for side: float in [-1.0, 1.0]:
		_static_box(shell, Vector3(side * (WIDTH / 2 - PLANK / 2), HEIGHT / 2, back / 2), Vector3(PLANK, HEIGHT, DEPTH))
	var slot := (HEIGHT - PLANK) / DRAWERS
	for i in DRAWERS + 1:
		_static_box(shell, Vector3(0, i * slot + PLANK / 2, back / 2), Vector3(WIDTH - 2 * PLANK, PLANK, DEPTH))
	for i in DRAWERS:
		var drawer := _drawer(i * slot + PLANK, slot - PLANK)
		drawer.attach(global_basis.z)
		if i < contents.size():
			for scene: PackedScene in contents[i]:
				_put_inside(drawer, scene)


func _drawer(bottom: float, height: float) -> Drawer:
	var drawer := Drawer.new()
	drawer.mass = DRAWER_KG
	drawer.collision_layer = 4
	drawer.collision_mask = 15
	var inner_w := WIDTH - 2 * PLANK - 0.02
	var inner_d := DEPTH - PLANK - 0.02
	drawer.position = Vector3(0, bottom + 0.005, -inner_d / 2 - 0.005)
	add_child(drawer)
	var h := height - 0.02
	_body_box(drawer, Vector3(0, PLANK / 2, 0), Vector3(inner_w, PLANK, inner_d), WOOD)
	_body_box(drawer, Vector3(0, h / 2, -inner_d / 2 + PLANK / 2), Vector3(inner_w, h, PLANK), WOOD)
	for side: float in [-1.0, 1.0]:
		_body_box(drawer, Vector3(side * (inner_w / 2 - PLANK / 2), h / 2, 0), Vector3(PLANK, h, inner_d), WOOD)
	# The front sits just ahead of the case, so it never rubs on the sides.
	var front := inner_d / 2 + 0.01 + PLANK / 2
	_body_box(drawer, Vector3(0, h / 2, front), Vector3(WIDTH - 0.01, h, PLANK), FRONT)
	_mesh_box(drawer, Vector3(0, h / 2, front + 0.03), Vector3(0.12, 0.04, 0.04), KNOB)
	drawers.append(drawer)
	return drawer


## Drops a thing into the drawer, a bit above its bottom.
func _put_inside(drawer: Drawer, scene: PackedScene) -> void:
	var item: RigidBody3D = scene.instantiate()
	var spread := (drawer.contents.size() - 1) * 0.25
	item.position = drawer.position + Vector3(spread, 0.12, 0.0)
	add_child(item)
	drawer.contents.append(item)


func _static_box(body: StaticBody3D, center: Vector3, size: Vector3) -> void:
	_shape(body, center, size)
	_mesh_box(body, center, size, WOOD)


func _body_box(body: RigidBody3D, center: Vector3, size: Vector3, color: Color) -> void:
	_shape(body, center, size)
	_mesh_box(body, center, size, color)


func _shape(body: CollisionObject3D, center: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = center
	body.add_child(shape)


func _mesh_box(parent: Node3D, center: Vector3, size: Vector3, color: Color) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	box.material = material
	mesh.mesh = box
	mesh.position = center
	parent.add_child(mesh)
