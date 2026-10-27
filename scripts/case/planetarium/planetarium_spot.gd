class_name PlanetariumSpot
extends LootSpot

## Where El Pedrusco could be hidden at the planetarium (escena-planetario.md, "El Pedrusco, escondido en el
## planetario"): inside the giant Saturn ("saturn", its crank lowers the ring), under one of the six seats with a
## planet ("seat_mercury" to "seat_neptune"), in the moon-rock basket ("basket") or inside the kids' rocket ("rocket").
## E searches it, which takes a while (Planetarium.search).


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PLANETARIUM_SEARCH_" + ("seat" if spot.begins_with("seat_") else spot)
