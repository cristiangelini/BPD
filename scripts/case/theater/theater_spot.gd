class_name TheaterSpot
extends LootSpot

## Where the Golden Mask could be hidden at the theater (escena-teatro.md, "La Máscara de Oro, escondida en el teatro"):
## the costume trunk in one of the six dressing rooms ("trunk_star" to "trunk_clover"), the tuba in the pit ("tuba"),
## under a seat of the front row ("seat") or among the old scenery in the basement ("scenery"). E searches it, which
## takes a while (Theater.search).


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_THEATER_SEARCH_" + ("trunk" if spot.begins_with("trunk_") else spot)
