class_name CountBoard
extends Node3D

## The count's list (carcel-recuento.md, step 2): a big board in the yard, on two posts against the building's front,
## with the number of each of the LIST inmates (the same number they wear on their jumpsuit) and how many are counted.
## A counted number gets a red cross (`set_marked`). Its origin is on the floor, its face toward +Z. Every number here
## is (propuesta).

const COLUMNS := 5
const SIZE := Vector2(3.4, 2.2)
const BOTTOM := 0.6
const CELL := Vector2(0.6, 0.38)
const PAPER := Color(0.95, 0.93, 0.85)
const CROSS := Color(0.85, 0.1, 0.1)

var numbers: Array[int] = []
var marked := {}
var _crosses := {}
var _total: Label3D


## The board for `list` (the numbers in the order they go on it).
func build(list: Array[int]) -> void:
	numbers = list
	var middle := BOTTOM + SIZE.y / 2
	for side in [-1, 1]:
		add_child(CopTool.piece(CopTool.box(Vector3(0.1, BOTTOM + SIZE.y, 0.1)), PrisonLevel.WOOD,
			Vector3(side * (SIZE.x / 2 - 0.1), (BOTTOM + SIZE.y) / 2, -0.06)))
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x, SIZE.y, 0.05)), PrisonLevel.WOOD, Vector3(0, middle, 0)))
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x - 0.15, SIZE.y - 0.15, 0.02)), PAPER,
		Vector3(0, middle, 0.03)))
	var title := _label(tr("COUNT_BOARD_TITLE"), 64, Vector3(0, BOTTOM + SIZE.y - 0.22, 0.05))
	title.name = "Title"
	var rows := ceili(float(list.size()) / COLUMNS)
	for i in list.size():
		var at := Vector3((i % COLUMNS - (COLUMNS - 1) / 2.0) * CELL.x,
			BOTTOM + SIZE.y - 0.55 - (i / COLUMNS) * CELL.y, 0.05)
		_label("%02d" % list[i], 56, at)
		var cross := _label("X", 96, at + Vector3(0, 0, 0.01), CROSS)
		cross.name = "Cross%d" % list[i]
		cross.hide()
		_crosses[list[i]] = cross
	_total = _label("", 44, Vector3(0, BOTTOM + SIZE.y - 0.55 - rows * CELL.y, 0.05))
	_total.name = "Total"
	_show_total()


func _label(text: String, size: int, at: Vector3, color := Color.BLACK) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.004
	label.modulate = color
	label.outline_size = 0
	label.position = at
	add_child(label)
	return label


## Crosses `number` off the list (or puts it back).
func set_marked(number: int, on: bool) -> void:
	if not _crosses.has(number):
		return
	if on:
		marked[number] = true
	else:
		marked.erase(number)
	(_crosses[number] as Label3D).visible = on
	_show_total()


func is_marked(number: int) -> bool:
	return marked.has(number)


func counted() -> int:
	return marked.size()


func _show_total() -> void:
	_total.text = tr("COUNT_BOARD_TOTAL") % [counted(), numbers.size()]
