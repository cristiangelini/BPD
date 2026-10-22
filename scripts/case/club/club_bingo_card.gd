class_name ClubBingoCard
extends StaticBody3D

## A bingo card lying on a club table, for a cop (infiltracion.md, step 3). Five columns (B 1-15, I 16-30, N 31-45,
## G 46-60, O 61-75) with a free middle. E on it marks every number Doña Chela called that's on it; the first E makes it
## yours. A called number left unmarked for ClubBingo.MARK_TIME is a miss, and the neighbor at the table notices. Any
## cop can mark any card, so a partner can cover for you. Every number here is (propuesta).

const SIZE := Vector3(0.36, 0.02, 0.44)
const CELL := 0.068
const PAPER := Color(0.97, 0.95, 0.86)
const INK := Color(0.15, 0.15, 0.3)
const MARKED := Color(0.85, 0.1, 0.15)

## The 25 numbers, column by column (B first), top to bottom; the middle one is 0, the free cell.
var numbers: Array[int] = []
## The numbers already marked this round.
var marked := {}
## Called numbers on this card waiting to be marked: number -> seconds since it was called.
var pending := {}
## Someone already took it (the first E); only taken cards count.
var claimed := false
## How many called numbers were missed on it.
var misses := 0
## The ClubBingo that calls the numbers (it sets it).
var bingo: Node
var _cells := {}


## The numbers of card `index` for the club with `case_seed`, the same on every PC.
static func numbers_for(case_seed: int, index: int) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["club card", case_seed, index])
	var all: Array[int] = []
	for column in 5:
		var pool: Array[int] = []
		for n in range(column * 15 + 1, column * 15 + 16):
			pool.append(n)
		for row in 5:
			var n: int = pool.pop_at(rng.randi_range(0, pool.size() - 1))
			all.append(0 if column == 2 and row == 2 else n)
	return all


## "B-12": the column's letter and the number.
static func label(n: int) -> String:
	return "%s-%d" % ["BINGO"[int((n - 1) / 15.0)], n]


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE + Vector3(0, 0.04, 0)
	shape.shape = box
	add_child(shape)
	var paper := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = SIZE
	var material := StandardMaterial3D.new()
	material.albedo_color = PAPER
	mesh.material = material
	paper.mesh = mesh
	add_child(paper)
	for column in 5:
		_add_cell("BINGO"[column], column, -1)
	for i in numbers.size():
		_add_cell("*" if numbers[i] == 0 else str(numbers[i]), int(i / 5.0), i % 5)
		_cells[numbers[i]] = get_child(get_child_count() - 1)


func _add_cell(text: String, column: int, row: int) -> void:
	var cell := Label3D.new()
	cell.text = text
	cell.font_size = 40
	cell.pixel_size = 0.0011
	cell.modulate = INK
	cell.outline_size = 0
	cell.rotation.x = -PI / 2
	cell.position = Vector3((column - 2) * CELL, SIZE.y / 2 + 0.002, (row - 1.5) * CELL)
	add_child(cell)


func has_number(n: int) -> bool:
	return n in numbers


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_BINGO_MARK" if claimed else "PROMPT_BINGO_TAKE"


## E: takes the card if nobody has, and marks what's pending.
func use(cop: Cop) -> void:
	var first := not claimed
	claimed = true
	if pending.is_empty():
		cop.show_hint("HINT_BINGO_YOURS" if first else "HINT_BINGO_NOTHING")
		return
	for n: int in pending.keys():
		mark(n)


func mark(n: int) -> void:
	pending.erase(n)
	marked[n] = true
	var cell: Label3D = _cells.get(n)
	if cell:
		cell.modulate = MARKED
		cell.text = "X"


## Doña Chela called `n`: if it's here and the card is taken, it waits to be marked.
func called(n: int) -> void:
	if claimed and has_number(n) and not marked.has(n):
		pending[n] = 0.0


## A new round: every mark goes.
func clear() -> void:
	marked.clear()
	pending.clear()
	for i in numbers.size():
		var cell: Label3D = _cells.get(numbers[i])
		if cell and numbers[i] != 0:
			cell.modulate = INK
			cell.text = str(numbers[i])


## Online: what the guests need to show the same card.
func net_state() -> Array:
	return [claimed, marked.keys(), pending.keys(), misses]


func apply_net_state(state: Array) -> void:
	claimed = state[0]
	var now := {}
	for n: int in state[1]:
		now[n] = true
	if now.size() < marked.size():
		clear()
	for n: int in now:
		if not marked.has(n):
			mark(n)
	pending.clear()
	for n: int in state[2]:
		pending[n] = 0.0
	misses = state[3]
