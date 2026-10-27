class_name WhParrotRig
extends WrongHouseRig

## The parrot who knows the code (casa-equivocada.md, "El loro que sabe la clave"): señora Plumas's parrot Pepe
## repeats the bank's safe code. Pepe is the main evidence, on a perch in her house drawn with the seed, and flies off
## from cops (Parrot); the empty cage and the notebook of codes are the extras, hidden. The story's own clue: from the
## front garden you hear Pepe saying numbers through the window. Every number here is (propuesta).

const PARROT_SCENE := preload("res://scenes/props/parrot.tscn")
## Where Pepe can land, downstairs (house space, the surface under his feet): the TV, the end of the counter, the
## washing machine, the arm of the sofa and the other end of the counter.
const PERCHES: Array[Vector3] = [Vector3(-2.95, 0.95, 6.5), Vector3(5.8, 0.96, 2.0), Vector3(6.4, 0.96, -3.3),
	Vector3(-4.45, 0.6, 2.5), Vector3(3.15, 0.96, 2.0)]
## The front window you hear him through (house space).
const WINDOW_AT := Vector3(-1.2, 1.5, WrongHouse.FRONT_Z + 0.2)

var pepe: Parrot
var window_clue: ClueSpot


func setup(wrong_house: WrongHouse) -> void:
	super.setup(wrong_house)
	pepe = PARROT_SCENE.instantiate()
	for at in PERCHES:
		pepe.perches.append(WrongHouse.at(place.guilty, at))
	place.add_child(pepe)
	pepe.land_on(first_perch(place.case_seed))
	place.main = pepe
	window_clue = clue_spot(WrongHouse.at(place.guilty, WINDOW_AT), Vector3(1.2, 1.0, 0.2), "PROMPT_LISTEN_WINDOW",
		"CLUE_WH_PARROT")


static func first_perch(case_seed: int) -> int:
	return hash(["wrong house parrot", case_seed]) % PERCHES.size()
