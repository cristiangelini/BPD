class_name ReturnsSack
extends StaticBody3D

## The counter's sack of returned letters (escena-correo.md, "Las pistas"). E with empty hands: a look at the letter
## on top (if the letter is one of the case's clues, it's the one stamped at 3 in the morning, sent by someone on the
## culprit's route). E with something in hand: it goes into the sack, on top of whatever was there (PostOfficeClues).

var clues: PostOfficeClues


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_RETURNS_LOOK"


func use(cop: Cop) -> void:
	if not clues:
		return
	var held: Node = cop.get_node("Grabber").held if cop else null
	if held:
		clues.drop_in_returns(cop, held as Node3D)
	else:
		clues.look_at_returns(cop)
