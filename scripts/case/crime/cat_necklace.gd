class_name CatNecklace
extends Grabbable

## Duquesa's diamond necklace (escena-gato.md, "Las pistas"): the culprit took it off her and hid it in another of the
## three spots. E with it in hand, the cop looks at the clasp: there is blood on the side of the hand Duquesa scratched
## (the clue, if it's one of the case's). Brought to Señora Ofelia she puts it on, and if nobody looked at it first the
## clue is gone with it. Every number here is (propuesta).

const DIAMOND := Color(0.85, 0.95, 1.0)
const GOLD := Color(0.95, 0.75, 0.25)

var case: CrimeSceneCase
## The hand of the culprit's scratch: "left" or "right" (the side with blood on the clasp).
var side := "left"
var looked := false
## Around the señora's neck: it says nothing any more.
var worn := false


func _ready() -> void:
	add_to_group("cat_necklaces")
	collision_layer = 4
	collision_mask = 15
	mass = 0.2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.22, 0.04, 0.22)
	shape.shape = box
	shape.position.y = 0.02
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	for i in 10:
		var turn := TAU * i / 10.0
		builder.mesh_box(Vector3(cos(turn) * 0.09, 0.02, sin(turn) * 0.09), Vector3(0.03, 0.03, 0.03), DIAMOND)
	builder.mesh_box(Vector3(0, 0.02, -0.1), Vector3(0.05, 0.02, 0.02), GOLD)


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_NECKLACE_LOOK"


## E with it in hand: a look at the clasp.
func used_in_hand(cop: Cop, _aimed: Node) -> void:
	look_at_clasp(cop)


func look_at_clasp(cop: Cop) -> void:
	looked = true
	var knows := case != null and case.plan.clues.has("necklace") and not case.ruined.has("necklace")
	if cop:
		cop.show_hint("HINT_NECKLACE_BLOOD_" + side if knows else "HINT_NECKLACE_CLEAN")
	if knows:
		case.found("necklace")


## The señora takes it and puts it on: unlooked at, the blood is lost under her pearls.
func put_on() -> void:
	worn = true
	if not looked and case:
		case.ruin("necklace")
