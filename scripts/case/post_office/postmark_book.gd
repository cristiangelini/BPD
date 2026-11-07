class_name PostmarkBook
extends StaticBody3D

## The postmark book on Doña Sellito's desk (escena-correo.md, "La Vaquita Azul, escondida en el correo"): every letter
## stamped at the post office goes in it. The culprit stamped an envelope at 3 in the morning to mail the stamp to
## a post box. E reads the night's page, which takes a while (PostOffice.read_book): the box's color, if the stamp is
## in a post box; otherwise, no stamps that night.

var post_office: PostOffice


func _init(size := Vector3.ONE) -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_POSTMARK_BOOK"


func use(cop: Cop) -> void:
	if post_office:
		post_office.read_book(cop)
