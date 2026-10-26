class_name VipGift
extends Grabbable

## Something Rulo Brillantina asks for that nobody can hide anything in (carcel-vip.md, step 3): the sparkling water
## from the kitchen's fridge, the feather pillow from the punishment cell's bunk, the mirror by the watchtower and his
## spare sunglasses on his limo's roof. The cake, the guitar and the flowers are VisitItems (step 4: they can hide a
## piece of his escape). Every number here is (propuesta).

enum Kind { WATER, PILLOW, MIRROR, GLASSES }

const SIZES := {Kind.WATER: Vector3(0.1, 0.32, 0.1), Kind.PILLOW: Vector3(0.6, 0.14, 0.4),
	Kind.MIRROR: Vector3(0.5, 0.7, 0.06), Kind.GLASSES: Vector3(0.18, 0.06, 0.08)}
const MASSES := {Kind.WATER: 1.0, Kind.PILLOW: 0.5, Kind.MIRROR: 3.0, Kind.GLASSES: 0.1}

var kind := Kind.WATER


func _init() -> void:
	collision_layer = 4
	collision_mask = 15


func _ready() -> void:
	add_to_group("vip_gifts")
	mass = MASSES[kind]
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZES[kind]
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	add_child(build_model(kind))


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_VIP_GIFT_%s" % Kind.keys()[kind]


## Online (PropSync): a guest's copy is made from this script with its kind.
func net_setup() -> Dictionary:
	return {"kind": kind}


static func build_model(of: Kind) -> Node3D:
	var root := Node3D.new()
	root.name = "Model"
	match of:
		Kind.WATER:
			root.add_child(CopTool.piece(CopTool.cylinder(0.05, 0.26), Color(0.55, 0.8, 0.95), Vector3(0, 0.13, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.02, 0.06), Color(0.2, 0.5, 0.9), Vector3(0, 0.29, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.052, 0.07), Color(0.95, 0.95, 0.95), Vector3(0, 0.14, 0)))
		Kind.PILLOW:
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.6, 0.14, 0.4)), Color(0.97, 0.95, 0.9), Vector3(0, 0.07, 0)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.12, 0.02, 0.12)), Color(0.9, 0.75, 0.3),
				Vector3(0.18, 0.15, 0.1)))
		Kind.MIRROR:
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.5, 0.7, 0.04)), VipPlan.GOLD, Vector3(0, 0.35, 0)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.42, 0.62, 0.01)), Color(0.75, 0.85, 0.9),
				Vector3(0, 0.35, 0.025)))
		Kind.GLASSES:
			for x: float in [-0.05, 0.05]:
				root.add_child(CopTool.piece(CopTool.box(Vector3(0.08, 0.05, 0.015)), Color(0.08, 0.08, 0.1),
					Vector3(x, 0.03, 0.03)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.18, 0.012, 0.012)), VipPlan.GOLD, Vector3(0, 0.05, 0.03)))
			for x: float in [-0.09, 0.09]:
				root.add_child(CopTool.piece(CopTool.box(Vector3(0.01, 0.01, 0.08)), VipPlan.GOLD, Vector3(x, 0.05, -0.01)))
	return root
