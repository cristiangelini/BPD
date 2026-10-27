class_name SpyTelescope
extends Evidence

## Mr. Bellini's telescope (edificio.md, "El telescopio espía"): it points at the vault of the bank across the street.
## E on it looks through and shows the vault with its code's numbers. It points +z, at the street. Every number here
## is (propuesta).

signal looked


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TELESCOPE"


func use(cop: Cop) -> void:
	cop.show_hint("HINT_TELESCOPE_VAULT")
	looked.emit()
