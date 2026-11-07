class_name ZooHideout
extends LootSpot

## A place at the zoo where Copito could be hidden (escena-zoo.md, "Copito, escondido en el zoológico"): a keeper's
## locker, the ice-cream freezer, the shelf of plush penguins, the pedal boat or the tortoise's shell. Searching takes
## SEARCH_SECONDS; then the zoo says what turned up (Zoo.search). The feeding log on the hut's desk works the same,
## reading takes READ_SECONDS. Every number here is (propuesta).

const SEARCH_SECONDS := 5.0
const READ_SECONDS := 10.0

## "locker", "freezer", "plush", "boat", "shell" or "log": the prompt and what's there when he isn't.
var kind := ""
var busy := false


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ZOO_BUSY" if busy else "PROMPT_ZOO_SEARCH_" + kind


func use(cop: Cop) -> void:
	if busy or not place:
		return
	busy = true
	if cop:
		cop.show_hint("HINT_ZOO_READING" if kind == "log" else "HINT_ZOO_SEARCHING")
	await get_tree().create_timer(READ_SECONDS if kind == "log" else SEARCH_SECONDS).timeout
	busy = false
	if is_inside_tree():
		place.call("search", spot, cop)
