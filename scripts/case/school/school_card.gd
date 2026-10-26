class_name SchoolCard
extends Grabbable

## A pupil's card with the question for the deputy (politico-escuela.md, step 5, decision 210), once a cop took it
## from their hand: what it says floats over it. E with it in hand tears it up; E on a pupil with no card gives it back
## (SchoolPupil.use).

signal torn(card: SchoolCard)

const SIZE := Vector3(0.16, 0.11, 0.01)
## Its collision, bigger than the paper so the hands find it.
const GRIP := Vector3(0.24, 0.18, 0.06)
const PAPER := Color(1.0, 0.98, 0.9)

## The text key on it and whether it's one of the janitor's traps.
var key := ""
var trap := false


static func make(text_key: String, is_trap: bool) -> SchoolCard:
	var card := SchoolCard.new()
	card.key = text_key
	card.trap = is_trap
	return card


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.05


func _ready() -> void:
	add_to_group("school_cards")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = GRIP
	shape.shape = box
	add_child(shape)
	var paper := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = SIZE
	paper.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = PAPER
	paper.material_override = material
	add_child(paper)
	var text := Label3D.new()
	text.name = "Text"
	text.text = key
	text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	text.font_size = 22
	text.outline_size = 6
	text.width = 360.0
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.modulate = Color(0.2, 0.2, 0.45)
	text.outline_modulate = PAPER
	text.pixel_size = 0.0025
	text.position.y = 0.18
	add_child(text)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_TEAR_CARD"


## Torn up: out of the game for good.
func use(cop: Cop) -> void:
	var grabber: Grabber = cop.get_node("Grabber")
	if grabber.held == self:
		grabber.release()
	cop.show_hint("HINT_CARD_TORN")
	torn.emit(self)
	queue_free()
