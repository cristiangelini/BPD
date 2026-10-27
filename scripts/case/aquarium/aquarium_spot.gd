class_name AquariumSpot
extends LootSpot

## Where La Gorda could be hidden at the aquarium (escena-acuario.md, "La Gorda, escondida en el acuario"): the bottom
## of one of the six small tanks ("tank_sharks" to "tank_penguins"), the penguins' igloo ("igloo"), the plush basket
## ("basket") or the fish-food bucket ("bucket"). E searches it, which takes a while (Aquarium.search).


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_AQUARIUM_SEARCH_" + ("tank" if spot.begins_with("tank_") else spot)
