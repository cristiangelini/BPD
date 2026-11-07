class_name ToyShelfBody
extends StaticBody3D

## The solid of a toy shelf in the toy store (docs/diseno/allanamiento-jugueteria.md, "Doña Ramona"): E with empty hands
## takes a toy off it (ShelfToy). Online only the host's makes it (PropSync copies it), like the ice cream's cones.

var size := Vector3.ONE
var _count := 0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)


func prompt_key(cop: Cop) -> String:
	return "" if cop.get_node("Grabber").held else "PROMPT_TAKE_TOY"


func use(cop: Cop) -> void:
	if cop.sync and not cop.sync.net.is_host():
		return
	var grabber: Grabber = cop.get_node("Grabber")
	if grabber.held:
		return
	var toy := ShelfToy.new()
	toy.color = ShelfToy.COLORS[_count % ShelfToy.COLORS.size()]
	_count += 1
	cop.get_parent().add_child(toy)
	toy.global_position = cop.camera.global_position - cop.camera.global_basis.z * 0.6
	grabber.grab(toy)
	SchoolPupil.tell_hands(cop)
