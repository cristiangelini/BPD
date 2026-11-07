class_name WoodenLetter
extends Grabbable

## One of the big wooden letters lying around the print shop (docs/diseno/allanamiento-imprenta.md, "Tipito"): a
## letter you can pick up and carry, KG kilos. Only the one Tipito asks for gets his gossip. Every number here is
## (propuesta).

const KG := 0.5
const SIZE := Vector3(0.36, 0.42, 0.1)
const WOOD := Color(0.78, 0.55, 0.3)

## The letter itself, as it is written.
@export var letter := "A"


func _ready() -> void:
	add_to_group("wooden_letters")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var text := TextMesh.new()
	text.text = letter
	text.font_size = 64
	text.pixel_size = 0.0075
	text.depth = SIZE.z
	var look := MeshInstance3D.new()
	look.name = "Look"
	look.mesh = text
	var wood := StandardMaterial3D.new()
	wood.albedo_color = WOOD
	look.material_override = wood
	add_child(look)
