class_name FactoryDoll
extends Grabbable

## A doll of the factory's belt and bins (docs/diseno/fabrica.md). A story can dress the dolls fed onto the belt:
## "captain" (the knockoff Captain Galaxy's helmet) or "hair" (the poodle's pink hair). A guest's copy comes dressed
## from net_setup() (step 8).

const HELMET_MODEL := preload("res://assets/models/captain_helmet.glb")
const HELMET_AT := Vector3(0, 0.095, 0)

var dress := ""


func _ready() -> void:
	if dress != "":
		wear(dress)


## Puts on `kind` (once), in or out of the tree.
func wear(kind: String) -> void:
	dress = kind
	if kind == "captain" and not has_node("CaptainHelmet"):
		var helmet: Node3D = HELMET_MODEL.instantiate()
		helmet.name = "CaptainHelmet"
		helmet.position = HELMET_AT
		add_child(helmet)
	elif kind == "hair" and not has_node(ConveyorBelt.MARK_NAMES.hair):
		var hair := MeshInstance3D.new()
		hair.name = ConveyorBelt.MARK_NAMES.hair
		var mesh := SphereMesh.new()
		mesh.radius = 0.09
		mesh.height = 0.18
		mesh.radial_segments = 8
		mesh.rings = 4
		var material := StandardMaterial3D.new()
		material.albedo_color = ConveyorBelt.PINK
		mesh.material = material
		hair.mesh = mesh
		hair.position = Vector3(0, 0.12, 0)
		hair.scale = Vector3(1.2, 0.6, 1.2)
		add_child(hair)


func net_setup() -> Dictionary:
	return {"dress": dress}
