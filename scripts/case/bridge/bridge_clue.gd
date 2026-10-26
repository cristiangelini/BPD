class_name BridgeClue
extends StaticBody3D

## A clue at the builders' pickup (politico-puente.md, step 5, decision 178): the invoices for "material de primera"
## taped to the tailgate, or the blue tarp beside the pickup with the missing steel beams under it. E reads the
## invoices, or lifts the tarp off the beams (it stays aside); either way every cop who uses it gets the hint, and the
## first time the case hears it (`found_now`).

signal found_now(clue: BridgeClue)

## "invoices" or "beams".
var kind := "invoices"
## The prompt before and after it was found, and the hint it gives.
var prompt := ""
var found_prompt := ""
var hint := ""
## What covers it (the tarp), moved aside when found.
var cover: Node3D
var found := false


func prompt_key(_cop: Cop) -> String:
	return found_prompt if found else prompt


func use(cop: Cop) -> void:
	cop.show_hint(hint)
	if found:
		return
	show_found()
	found_now.emit(self)


## Found, on every PC: the tarp lies crumpled beside the beams.
func show_found() -> void:
	found = true
	if cover:
		cover.position -= cover.basis.z * 1.3
		cover.scale = Vector3(1, 0.2, 0.6)
