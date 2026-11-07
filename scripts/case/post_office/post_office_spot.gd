class_name PostOfficeSpot
extends LootSpot

## Where La Vaquita Azul could be hidden at the post office (escena-correo.md, "La Vaquita Azul, escondida en el
## correo"): one of the six post boxes with a route's label ("box_red" to "box_purple"), the big sack of undelivered
## mail ("sack"), the parcel scale ("scale") or the giant mailbox on the sidewalk ("mailbox"). E searches it, which
## takes a while (PostOffice.search).


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_POST_SEARCH_" + ("box" if spot.begins_with("box_") else spot)
