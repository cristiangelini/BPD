class_name CoffeeSafe
extends HintedEvidence

## The office's coffee machine that is really a safe (seguros.md, "La máquina de café es una caja fuerte"): 30 kg of
## premiums never paid out, carried between two cops. E on it gives coins instead of coffee: the story's own clue, shown
## and sent to the checklist once.

signal read(text: String)

var text := ""
var was_read := false


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_COFFEE"


func use(cop: Cop) -> void:
	cop.show_hint(text)
	if not was_read:
		was_read = true
		read.emit(text)
