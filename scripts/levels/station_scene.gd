class_name StationScene
extends CrimeScenePlace

## The station crime scene (escena-comisaria.md): the place is the station the city already builds, with the evidence
## room behind the break room (EvidenceRoom). It sits on the station's lot and brings the six suspects into it: the
## five coworkers of StationStaff, each with their traits and their file (StaffFile), and the armero behind his counter;
## el Chancho waits in cell 1. The cops are at the scene once inside the evidence room. What was stolen is drawn with
## the seed. The clues come in step 4b, the getaway in step 5. Every number here is (propuesta).

## What can go missing from the evidence room (BRIEF_STATION_A_<loot>, OBJ_STATION_LOOT_<loot>).
const LOOTS: Array[String] = ["necklace", "painting", "pillow"]

## The city that built the station (its armero is one of the suspects).
var city: City
var case: CrimeSceneCase
var loot := ""
var people: Array[StationStaff] = []


func _init() -> void:
	variant = "station"


func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot = LOOTS[hash(["station loot", case.case_seed]) % LOOTS.size()]
	people = StationStaff.spawn_all(self, case.cooks)
	for person in people:
		var index := StaffTraits.IDS.find(person.who)
		if index >= 0:
			person.file = StaffFile.new(case, index, person)
	if city and city.armero:
		city.armero.file = StaffFile.new(case, 0, city.armero)


## The suspect's body, by index (StaffTraits.IDS: the armero first).
func suspect(index: int) -> CollisionObject3D:
	if index == 0:
		return city.armero if city else null
	for person in people:
		if StaffTraits.IDS.find(person.who) == index:
			return person
	return null


## Whether a point in the world (ignoring height) is in the evidence room.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return local.x > EvidenceRoom.FROM_X and local.x < EvidenceRoom.TO_X and local.z < EvidenceRoom.FROM_Z \
		and local.z > EvidenceRoom.TO_Z
