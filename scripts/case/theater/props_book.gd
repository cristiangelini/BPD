class_name PropsBook
extends StaticBody3D

## The props book on the workshop's desk (escena-teatro.md, "La Máscara de Oro, escondida en el teatro"): every prop of
## the show goes in it. The culprit wrote the mask down as "props for scene 3" so nobody would ask. E reads it, which
## takes a while (Theater.read_book): the dressing room it went to, if the mask is in a trunk; otherwise, nothing new.

var theater: Theater


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PROPS_BOOK"


func use(cop: Cop) -> void:
	if theater:
		theater.read_book(cop)
