class_name DenturesRig
extends StoryRig

## The care home dentures (historias.md): the grandpa rents dentures out of a chattering case, and hid his own with
## the rest, so nobody understands a word he says.

## Evidence order in dentures_story.tres: the case, the list of clients.
const CASE := 0
const CLIENTS := 1


func setup(house: GrandpaHouse) -> void:
	house.grandpa.toothless = true


func extras(house: GrandpaHouse) -> Array[Dictionary]:
	return [{"text": "OBJ_EXTRA_CLIENTS", "done": house.car.is_delivered(house.evidence[CLIENTS] as Evidence)}]
