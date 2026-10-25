class_name Contraband
extends Grabbable

## Something a visitor tried to get into the prison on the visiting day (carcel-visitas.md, step 3): the file out of
## the cake, the key out of the loaf, the rope that was a scarf... Found, it's confiscated (VisitPlan.confiscated) and
## lands in the hands of the cop who found it. Every number here is (propuesta).

enum Kind { FILE, KEY, SAW, MAP, ROPE, TOOLS, LOCKPICKS, PIGEON, PHONE, SHOVEL, SPOON, DISGUISE }

## What each kind of visit item hides (VisitItem.Kind order), and what a pocket can hide.
const IN_ITEM: Array[Kind] = [Kind.FILE, Kind.KEY, Kind.SAW, Kind.MAP, Kind.ROPE, Kind.TOOLS, Kind.LOCKPICKS,
	Kind.PIGEON, Kind.PHONE, Kind.SHOVEL, Kind.SPOON, Kind.DISGUISE]
const IN_POCKET: Array[Kind] = [Kind.FILE, Kind.KEY, Kind.LOCKPICKS, Kind.MAP]
const METAL := Color(0.6, 0.62, 0.66)

var kind := Kind.FILE


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.3


func _ready() -> void:
	add_to_group("contraband")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.12, 0.06, 0.3)
	shape.shape = box
	shape.position.y = 0.03
	add_child(shape)
	add_child(_model())


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_CONTRABAND_%s" % Kind.keys()[kind]


func _model() -> Node3D:
	var root := Node3D.new()
	root.name = "Model"
	match kind:
		Kind.ROPE, Kind.DISGUISE:
			var color := Color(0.75, 0.6, 0.35) if kind == Kind.ROPE else Color(0.2, 0.3, 0.55)
			root.add_child(CopTool.piece(CopTool.cylinder(0.12, 0.08), color, Vector3(0, 0.04, 0)))
		Kind.PIGEON:
			var body := SphereMesh.new()
			body.radius = 0.08
			body.height = 0.12
			root.add_child(CopTool.piece(body, Color(0.6, 0.62, 0.7), Vector3(0, 0.06, 0)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.02, 0.02, 0.04)), Color(0.95, 0.6, 0.2),
				Vector3(0, 0.08, -0.09)))
		Kind.PHONE:
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.07, 0.015, 0.14)), Color(0.1, 0.1, 0.12), Vector3(0, 0.01, 0)))
		Kind.MAP:
			root.add_child(CopTool.piece(CopTool.cylinder(0.02, 0.28), Color(0.95, 0.9, 0.7), Vector3(0, 0.02, 0),
				Vector3(PI / 2, 0, 0)))
		_:
			# The tools, more or less: a handle and a metal blade.
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.04, 0.03, 0.1)), Color(0.45, 0.25, 0.12),
				Vector3(0, 0.015, 0.1)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.03, 0.01, 0.2)), METAL, Vector3(0, 0.015, -0.05)))
	return root
