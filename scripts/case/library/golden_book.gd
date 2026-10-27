class_name GoldenBook
extends StaticBody3D

## The Golden Book (escena-biblioteca.md, "El Libro de Oro, escondido entre mil"): the city's first book, with covers
## of real gold. Found in its hiding spot, it lies there until a cop takes it back to its display case with E
## (Library.reveal_loot). Every number here is (propuesta).

const SIZE := Vector3(0.36, 0.08, 0.28)
const GOLD := Color(0.95, 0.76, 0.2)
const PAGES := Color(0.96, 0.93, 0.84)

var library: Library


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, SIZE.y / 2, 0), SIZE, GOLD)
	builder.mesh_box(Vector3(0.01, SIZE.y / 2, 0), Vector3(SIZE.x - 0.01, SIZE.y - 0.03, SIZE.z + 0.005), PAGES)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_GOLDEN_BOOK_RETURN"


func use(_cop: Cop) -> void:
	if library:
		library.reveal_loot()
