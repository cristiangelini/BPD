class_name BoardCard
extends StaticBody3D

## A card on the station's board (CrimeBoard): a cook's file or a pinned clue. E on it goes to the board.

## A file's size; a clue is half as tall.
const SIZE := Vector2(0.86, 0.82)
const PAPER := Color(0.97, 0.95, 0.88)
const CROSS := Color(0.85, 0.1, 0.1)

var board: CrimeBoard
## "file" or "clue".
var kind := "file"
## The cook's index for a file; the clue's kind for a clue.
var id: Variant = 0
var label: Label3D
var size := SIZE
var _cross: Node3D


func _ready() -> void:
	if kind == "clue":
		size.y = SIZE.y / 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(size.x, size.y, 0.04)
	shape.shape = box
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3.ZERO, Vector3(size.x, size.y, 0.01), PAPER)
	label = Label3D.new()
	label.position = Vector3(0, 0, 0.01)
	label.pixel_size = 0.0015
	label.font_size = 40
	label.outline_size = 0
	label.modulate = Color(0.12, 0.12, 0.16)
	label.width = size.x / label.pixel_size - 30
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	_cross = Node3D.new()
	_cross.visible = false
	add_child(_cross)
	var lines := PlaceBuilder.new(_cross)
	for turn: float in [0.6, -0.6]:
		lines.mesh(_bar(), Vector3(0, 0, 0.02), CROSS, Vector3(0, 0, turn))


func set_crossed(crossed: bool) -> void:
	_cross.visible = crossed


func is_crossed() -> bool:
	return _cross.visible


func prompt_key(cop: Cop) -> String:
	return board.prompt_for(self, cop)


func use(cop: Cop) -> void:
	board.use_card(self, cop)


func _bar() -> BoxMesh:
	var bar := BoxMesh.new()
	bar.size = Vector3(size.length(), 0.05, 0.01)
	return bar
