class_name HollowBook
extends StaticBody3D

## The hollow book on a reading table (escena-biblioteca.md, "Las pistas"): a thick old book with its pages cut out. E
## opens it; if the bite is one of the case's clues, inside is the cookie the culprit hid and bit (in the library you
## don't eat). Every number here is (propuesta).

const SIZE := Vector3(0.26, 0.09, 0.2)
const COVER := Color(0.35, 0.18, 0.12)
const PAGES := Color(0.96, 0.93, 0.84)

var library: Library
var case: CrimeSceneCase
var has_bite := false
var opened := false
var cookie: CrimeClueItem
var _lid: Node3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, 0.01, 0), Vector3(SIZE.x, 0.02, SIZE.z), COVER)
	builder.mesh_box(Vector3(0.01, SIZE.y / 2, 0), Vector3(SIZE.x - 0.02, SIZE.y - 0.02, SIZE.z - 0.01), PAGES)
	# The hole cut in the pages.
	builder.mesh_box(Vector3(0.01, SIZE.y - 0.02, 0), Vector3(0.14, 0.012, 0.12), COVER.darkened(0.5))
	# The front cover hinges on the spine (its -x side).
	_lid = Node3D.new()
	_lid.position = Vector3(-SIZE.x / 2, SIZE.y, 0)
	add_child(_lid)
	PlaceBuilder.new(_lid).mesh_box(Vector3(SIZE.x / 2, 0.01, 0), Vector3(SIZE.x, 0.02, SIZE.z), COVER)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLLOW_BOOK_SHUT" if not opened else "PROMPT_HOLLOW_BOOK_OPEN"


## E: open it. The cookie, if there is one, comes out on the table next to it for a cop to bag.
func use(cop: Cop) -> void:
	if opened:
		if cop:
			cop.show_hint("HINT_HOLLOW_BOOK_OPENED")
		return
	opened = true
	_lid.rotation.z = 2.6
	if has_bite and case:
		cookie = CrimeClueItem.new()
		cookie.name = "Clue_bite"
		cookie.kind = "bite"
		cookie.look = "library"
		cookie.case = case
		cookie.position = position + Vector3(0.05, SIZE.y + 0.02, 0)
		get_parent().add_child(cookie)
		case.items["bite"] = cookie
	if cop:
		cop.show_hint("HINT_HOLLOW_BOOK_COOKIE" if has_bite else "HINT_HOLLOW_BOOK_EMPTY")
