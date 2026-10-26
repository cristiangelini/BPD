class_name BedSheet
extends Grabbable

## The folded sheet on a cell's bunk in the roof jailbreak (docs/diseno/fuga-techo.md): two per bunk, four in all.
## Step 3: a sheet or a rope in hand, E on one ties them into a rope (SheetRope).

const MODEL := preload("res://assets/models/bed_sheet.glb")
const SIZE := Vector3(0.4, 0.06, 0.3)


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.6
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	add_to_group("bed_sheets")


## What a guest's copy needs (PropSync: the host makes new ones after a catch).
func net_setup() -> Dictionary:
	return {}


func prompt_key(cop: Cop) -> String:
	var held: Node = cop.get_node("Grabber").held
	if SheetRope.sheets_of(held) > 0 and held != self:
		return "PROMPT_KNOT"
	return "PROMPT_GRAB" if not held else ""


func use(cop: Cop) -> void:
	var held: Node = cop.get_node("Grabber").held
	if SheetRope.sheets_of(held) > 0 and held != self and multiplayer.is_server():
		SheetRope.tie(cop, held, self)
