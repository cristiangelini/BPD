class_name CardCatalog
extends StaticBody3D

## The card catalog by the library's door (escena-biblioteca.md, "El Libro de Oro, escondido entre mil"): the culprit
## swapped one card so nobody would look there. E reads it through, which takes a while (Library.read_catalog): the
## swapped card gives the section's letter if the book is on a shelf; otherwise, everything's in order.

var library: Library


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CARD_CATALOG"


func use(cop: Cop) -> void:
	if library:
		library.read_catalog(cop)
