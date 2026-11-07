class_name SecretPassage
extends Node3D

## One of the mansion's three secret passages (escena-mansion.md, "Los pasadizos secretos", step 2): a narrow, dark
## corridor inside a double wall, with a doorway at each end shut by a panel that looks like the wall. Something in
## the room opens it (the bookcase, the grandfather clock, the candelabra on the fireplace's mantel) and slides out of
## the way; from the other room or from inside, the panel itself. E on any of its doors opens both ends at once, and
## again closes them. Every number here is (propuesta).

signal opened
signal closed

const SLIDE_SECONDS := 0.6

## "bookcase", "clock" or "fireplace" (Mansion.PASSAGES).
var id := ""
var is_open := false
## Someone opened it at least once.
var found := false
var doors: Array[PassageDoor] = []


## A door of this passage: a box of `size` centered at `center` (in the passage's space) that slides by `slide` when
## the passage opens (zero: it stays, like a lever). `prompt` is what E says while it's shut.
func add_door(door_name: String, center: Vector3, size: Vector3, slide: Vector3, prompt: String) -> PassageDoor:
	var door := PassageDoor.new()
	door.name = door_name
	door.passage = self
	door.prompt = prompt
	door.slide = slide
	door.position = center
	door.shut_at = center
	door.set_size(size)
	add_child(door)
	doors.append(door)
	return door


func toggle(cop: Cop) -> void:
	set_open(not is_open)
	if is_open and not found:
		found = true
		if cop:
			cop.show_hint("HINT_PASSAGE_FOUND")


func set_open(value: bool) -> void:
	if value == is_open:
		return
	is_open = value
	for door in doors:
		door.move(is_open, SLIDE_SECONDS)
	if is_open:
		opened.emit()
	else:
		closed.emit()
