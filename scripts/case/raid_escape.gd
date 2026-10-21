class_name RaidEscape
extends Node

## The raid's owner gets away (persecucion-final.md, decision 96): when he sees a cop pick up the main evidence close
## by, and he isn't cuffed or being walked, he runs off in what's his (the grandpa in his electric wheelchair, from his
## door; Marta and Ramiro in the getaway car, parked in front of the patrol car) and the chase starts on the spot.
## Caught and in the patrol car, it counts as taking the owner (decision 93); got away, the raid can still be solved with
## the evidence, but there's no interrogation. It happens once a raid. Every number here is (propuesta).

## He sees the evidence picked up from this close (m).
const SEES := 15.0
## The getaway car waits this far (m) in front of the patrol car's spot at the place.
const CAR_AHEAD := 9.0
## The wheelchair waits this far (m) out of his door, on the sidewalk.
const DOOR_OUT := 1.5
## Each owner's place in the city (CityLayout), what he gets away in (SuspectCar) and who gets off (ChaseSuspect).
const PLACES := {"grandpa": "grandpa", "baker": "bakery", "groomer": "pet_salon"}
const VEHICLES := {"grandpa": "wheelchair", "baker": "night", "groomer": "night"}

var raid: RaidCase
## The chase, once he ran off.
var chase: ChaseCase
var fled := false
var escaped := false


## Whether this owner can get away: the places that have one.
static func handles(owner_id: String) -> bool:
	return PLACES.has(owner_id)


func _physics_process(_delta: float) -> void:
	if fled or raid.follower or raid.case_failed or raid.case_solved or not raid.main_evidence.is_held():
		return
	var npc := raid.owner_npc
	if raid.escort.handles_use() or npc.global_position.distance_to(raid.main_evidence.global_position) > SEES:
		return
	flee()


## He runs off: he's gone from the place and drives off from his spot, with the chase on.
func flee() -> void:
	if fled:
		return
	fled = true
	var npc := raid.owner_npc
	npc.hide()
	npc.process_mode = Node.PROCESS_MODE_DISABLED
	npc.collision_layer = 0
	npc.collision_mask = 0
	var level := raid.get_parent()
	var city: Node3D = level.get_node("City")
	var map := level.get("city_map") as CityMap
	chase = ChaseCase.begin(level, VEHICLES[raid.owner_id], city.global_transform * spot(raid.owner_id), raid.car,
		city, raid.case_seed, map)
	chase.who = raid.owner_id
	chase.ended.connect(_on_ended)
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_ESCAPE_" + raid.owner_id)


## Where his vehicle waits, in the city's space: the wheelchair at his door, the car in front of the patrol car.
static func spot(owner_id: String) -> Transform3D:
	var place: String = PLACES[owner_id]
	var parking := CityLayout.parking(place)
	if VEHICLES[owner_id] == "wheelchair":
		var p := CityLayout.place(place)
		return Transform3D(parking.basis, CityLayout.door_of(place) + CityLayout.side_normal(p.side) * DOOR_OUT)
	return parking.translated_local(Vector3(0, 0, -CAR_AHEAD))


## Caught, the one in the patrol car is the owner the raid takes away; got away, nobody is.
func _on_ended(caught: bool) -> void:
	escaped = not caught
	if caught:
		raid.escort = chase.escort
