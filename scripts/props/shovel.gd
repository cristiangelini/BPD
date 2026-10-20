class_name Shovel
extends Grabbable

## The pet salon's yard shovel (peluqueria.md, "Contrabando de huesos"): in hand, E on a DigSpot digs.


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_SHOVEL"
