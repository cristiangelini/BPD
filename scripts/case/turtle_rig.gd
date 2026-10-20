class_name TurtleRig
extends StoryRig

## The turtle races (historias.md): Relámpago sleeps in her hiding spot at the end of a trail of lettuce leaves from
## the kitchen, four plain turtles that look just like her roam the house, and the trophies wait in the drawers.

## Evidence order in turtle_story.tres: Relámpago, the betting board.
const RACER := 0
const BOARD := 1
const DECOYS := 4
const DECOY_SCENE := preload("res://scenes/props/turtle_plain.tscn")
const LETTUCE_STEP := 0.4
const LETTUCE := Color(0.55, 0.85, 0.3)
const LEAF := Vector3(0.12, 0.01, 0.09)

var decoys: Array[Grabbable] = []


func setup(house: GrandpaHouse) -> void:
	var racer_walk: TurtleWalk = house.evidence[RACER].get_node("Walk")
	racer_walk.asleep = true
	racer_walk.walk_seed = house.case_seed
	var free: Array = range(GrandpaHouse.SPOTS.size()).filter(func(i: int) -> bool: return not house.evidence_spots.has(i))
	var rng := RandomNumberGenerator.new()
	rng.seed = house.case_seed * 19 + 7
	for i in DECOYS:
		var spot: int = free.pop_at(rng.randi_range(0, free.size() - 1))
		var turtle: Grabbable = DECOY_SCENE.instantiate()
		turtle.position = GrandpaHouse.SPOTS[spot].at + Vector3.UP * 0.1
		(turtle.get_node("Walk") as TurtleWalk).walk_seed = house.case_seed + i + 1
		house.get_node("Evidence").add_child(turtle)
		decoys.append(turtle)


## Lettuce leaves go from the kitchen counter to where Relámpago sleeps.
func place_trails(house: GrandpaHouse, map: RID) -> void:
	var to := house.evidence[RACER].global_position
	house.trails[house.tr("CLUE_LETTUCE")] = house.trail(map, GrandpaHouse.CRUMBS_FROM, to, LETTUCE_STEP, false, LETTUCE, LEAF)


func trail_item() -> int:
	return RACER


func extras(house: GrandpaHouse) -> Array[Dictionary]:
	var car := house.car
	var trophies := house.drawer_evidence
	var delivered := trophies.filter(func(t: Evidence) -> bool: return car.is_delivered(t)).size()
	return [
		{"text": "OBJ_EXTRA_BOARD", "done": car.is_delivered(house.evidence[BOARD] as Evidence)},
		{"text": house.tr("OBJ_EXTRA_TROPHIES") % [delivered, trophies.size()],
			"done": not trophies.is_empty() and delivered == trophies.size()},
	]
