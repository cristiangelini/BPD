class_name CellKey
extends Grabbable

## The key of the station's cells (fuga.md): it was in one of the night guard's donuts. In hand, E on a cell door
## unlocks it and opens it (CellDoor).


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_KEY"
