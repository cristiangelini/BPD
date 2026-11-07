class_name ComisarioArmchair
extends Evidence

## The comisario's armchair, stolen from his office and on show in the furniture store's window
## (allanamiento-muebleria.md, "El sillón del comisario"): the main evidence, carried like any other, and E sits a cop
## on it.

signal sat(cop: Cop)

## Where a cop ends up on it, in its own space.
const SEAT := Vector3(0, 0.1, 0.05)


func prompt_key(_cop: Cop) -> String:
	return "" if is_held() else "PROMPT_SIT_ARMCHAIR"


func use(cop: Cop) -> void:
	if is_held():
		return
	cop.global_position = to_global(SEAT)
	cop.velocity = Vector3.ZERO
	sat.emit(cop)
