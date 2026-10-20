class_name FightRig
extends StoryRig

## The retirees' fight club (historias.md): the grandpa is the Tuesday champion. His belt, the gloves and the fight
## notebook hide in the house, the ring stands in the attic, and a photo shows the neighbors with black eyes. Pushed,
## he pushes back harder, and he won't stand still for a story.

## Evidence order in fight_story.tres: the belt, the gloves, the fight notebook.
const BELT := 0
const GLOVES := 1
const NOTEBOOK := 2
const RING_SCENE := preload("res://scenes/props/fight_ring.tscn")
const PHOTO_SCENE := preload("res://scenes/props/fight_photo.tscn")
## The ring stands in the middle of the attic, clear of its hiding spot (propuesta).
const RING_AT := Vector3(6.0, 2.7, -6.2)

var ring: Node3D
var photo: ClueNote


func setup(house: GrandpaHouse) -> void:
	house.grandpa.champion = true
	ring = RING_SCENE.instantiate()
	ring.position = RING_AT
	house.add_child(ring)


## Not a trail: the photo takes the first note place the clues left free, which is only known once they're placed.
func place_trails(house: GrandpaHouse, _map: RID) -> void:
	var place: int = house.clue_plan.spare[house.suspicions.size()]
	photo = PHOTO_SCENE.instantiate()
	photo.text = house.tr("CLUE_FIGHT_PHOTO")
	photo.position = GrandpaHouse.NOTE_PLACES[place] + Vector3.UP * 0.02
	photo.read.connect(house.add_clue)
	house.get_node("Evidence").add_child(photo)


func extras(house: GrandpaHouse) -> Array[Dictionary]:
	var car := house.car
	return [
		{"text": "OBJ_EXTRA_GLOVES", "done": car.is_delivered(house.evidence[GLOVES] as Evidence)},
		{"text": "OBJ_EXTRA_FIGHT_BOOK", "done": car.is_delivered(house.evidence[NOTEBOOK] as Evidence)},
	]
