class_name ZooBlanket
extends StaticBody3D

## Copito's blanket on his ice floe (escena-zoo.md, "Las pistas"): whoever carried him off held him in it. E smells
## it: if it's one of the case's clues, it smells of the culprit (their animal's food). Wet by the elephant, it only
## smells of wet dog.

const CLOTH := Color(0.55, 0.75, 0.95)
const SIZE := Vector3(0.7, 0.05, 0.5)

var case: CrimeSceneCase
## The clue is in it this case.
var smells := false
var wet := false


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	PlaceBuilder.new(self).mesh_box(Vector3(0, SIZE.y / 2, 0), SIZE, CLOTH)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ZOO_BLANKET"


func use(cop: Cop) -> void:
	if wet:
		cop.show_hint("HINT_ZOO_BLANKET_WET")
	elif smells and case:
		case.found("blanket")
		cop.show_hint(tr("HINT_ZOO_BLANKET") % tr("SMELL_" + str(case.culprit().smell)))
	else:
		cop.show_hint("HINT_ZOO_BLANKET_NOTHING")


## The elephant's water: now it smells of wet dog, and the clue is lost unless it was already found.
func soak() -> void:
	if wet:
		return
	wet = true
	(get_child(get_child_count() - 1) as MeshInstance3D).material_override = PlaceBuilder.new(self).material(
		CLOTH.darkened(0.4))
	if smells and case:
		case.ruin("blanket")
