class_name KeyBoard
extends StaticBody3D

## The board of blank keys behind the hardware store's counter (ferreteria.md, "Las llaves maestras"). In that story
## the storeroom key hangs among them: every E tries one in the lock (the cop walks it over in his head), and the right
## one turns up after a few tries drawn from the seed. Tobías doesn't like anyone at his board. Every number here is
## (propuesta).

## A cop tried a key: whether it was the right one.
signal tried(at: Vector3, found: bool)

const SIZE := Vector3(1.6, 0.8, 0.06)
## Tries the right key takes: MIN_TRIES to MAX_TRIES, by the seed.
const MIN_TRIES := 2
const MAX_TRIES := 5

## Tries the storeroom key takes in this match; 0: it isn't on the board (the till has it).
var tries_needed := 0
var tries := 0


static func tries_for(case_seed: int) -> int:
	return MIN_TRIES + case_seed % (MAX_TRIES - MIN_TRIES + 1)


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)


func found() -> bool:
	return tries_needed > 0 and tries >= tries_needed


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_KEY_BOARD" if tries_needed > 0 and not found() else ""


func use(cop: Cop) -> void:
	if tries_needed == 0 or found():
		return
	tries += 1
	if found():
		cop.has_key = true
		cop.show_hint("HINT_KEY_BOARD_FOUND")
	else:
		cop.show_hint("HINT_KEY_BOARD_WRONG")
	tried.emit(global_position, found())
