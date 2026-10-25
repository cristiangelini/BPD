class_name GardenPlant
extends StaticBody3D

## One of the 48 plants of the prison's garden (carcel-huerta.md, step 2): a lettuce, a carrot, a tomato plant or a
## pumpkin in its bed. Every number here is (propuesta).

enum Kind { LETTUCE, CARROT, TOMATO, PUMPKIN }

const SIZE := Vector3(0.36, 0.4, 0.36)
const LEAF := Color(0.3, 0.62, 0.25)
const ORANGE := Color(0.95, 0.5, 0.12)
const RED := Color(0.85, 0.15, 0.12)
const STAKE := Color(0.55, 0.4, 0.22)

var kind := Kind.LETTUCE
## The bed it's in (0 to 11) and its place in it (0 to 3).
var bed := 0
var slot := 0
var _model: Node3D


func _ready() -> void:
	add_to_group("garden_plants")
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_model = build_model(kind)
	add_child(_model)


static func build_model(of: Kind) -> Node3D:
	var root := Node3D.new()
	root.name = "Model"
	match of:
		Kind.LETTUCE:
			root.add_child(CopTool.piece(_ball(0.16, 0.2), LEAF, Vector3(0, 0.1, 0)))
			root.add_child(CopTool.piece(_ball(0.1, 0.14), LEAF.lightened(0.3), Vector3(0, 0.16, 0)))
		Kind.CARROT:
			for x: float in [-0.05, 0.0, 0.05]:
				root.add_child(CopTool.piece(CopTool.box(Vector3(0.03, 0.25, 0.03)), LEAF, Vector3(x, 0.17, 0),
					Vector3(0, 0, x * 5.0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.05, 0.06), ORANGE, Vector3(0, 0.03, 0)))
		Kind.TOMATO:
			root.add_child(CopTool.piece(CopTool.cylinder(0.015, 0.4), STAKE, Vector3(0, 0.2, 0)))
			root.add_child(CopTool.piece(_ball(0.12, 0.22), LEAF, Vector3(0, 0.22, 0)))
			for at: Vector3 in [Vector3(0.09, 0.2, 0.06), Vector3(-0.07, 0.27, 0.07), Vector3(0.02, 0.14, -0.1)]:
				root.add_child(CopTool.piece(_ball(0.04, 0.08), RED, at))
		Kind.PUMPKIN:
			root.add_child(CopTool.piece(_ball(0.15, 0.2), ORANGE, Vector3(0, 0.1, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.015, 0.06), STAKE, Vector3(0, 0.22, 0)))
			root.add_child(CopTool.piece(_ball(0.1, 0.04), LEAF, Vector3(0.14, 0.05, 0.08)))
	return root


static func _ball(radius: float, height: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	mesh.rings = 5
	return mesh
