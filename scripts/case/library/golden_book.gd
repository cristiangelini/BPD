class_name GoldenBook
extends StaticBody3D

## The Golden Book (escena-biblioteca.md, "El Libro de Oro, escondido entre mil"): the city's first book, with covers
## of real gold. Found in its hiding spot, it lies there: E opens it first (inside is the culprit's bookmark, if it's
## one of the case's clues), and E again takes it back to its display case (Library.reveal_loot). Every number here is
## (propuesta).

const SIZE := Vector3(0.36, 0.08, 0.28)
const GOLD := Color(0.95, 0.76, 0.2)
const PAGES := Color(0.96, 0.93, 0.84)

var library: Library
## A cop opened it and looked for the bookmark.
var opened := false


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
	return "PROMPT_GOLDEN_BOOK_RETURN" if opened else "PROMPT_GOLDEN_BOOK_OPEN"


func use(cop: Cop) -> void:
	if not opened:
		open(cop)
	elif library:
		library.reveal_loot()


## Opened: the bookmark the culprit left in it says what they read.
func open(cop: Cop) -> void:
	opened = true
	var case := library.case if library else null
	var has_bookmark := case != null and case.plan.clues.has("bookmark")
	if has_bookmark:
		case.found("bookmark")
	if cop:
		cop.show_hint("HINT_GOLDEN_BOOK_BOOKMARK" if has_bookmark else "HINT_GOLDEN_BOOK_NO_BOOKMARK")
