class_name GhostWorkersRig
extends FactoryRig

## The ghost workers (fabrica.md, "Los operarios fantasma"): Fermín charges the owners for ten workers who don't exist
## and keeps their pay. Ten mannequins in work coats stand at the belt as if working (E: they never answer), the payroll
## book is the main evidence, hidden with their ten time cards and the wig Fermín wears to punch them in. The time
## clock in the reception has their cards punched at 3 in the morning: looking at it is the story's own clue. Every
## number here is (propuesta).

## Where the mannequins stand, inside the U of the belt, clear of its machines, the mold table and Nilda, and which way
## each one faces (toward the belt).
const MANNEQUIN_SPOTS := [
	{"at": Vector3(-9.0, DollFactory.FLOOR_TOP, 3.5), "turn": -PI / 2}, {"at": Vector3(-9.0, DollFactory.FLOOR_TOP, 0.0), "turn": -PI / 2},
	{"at": Vector3(-9.0, DollFactory.FLOOR_TOP, -1.5), "turn": -PI / 2}, {"at": Vector3(-9.0, DollFactory.FLOOR_TOP, -4.5), "turn": -PI / 2},
	{"at": Vector3(-3.0, DollFactory.FLOOR_TOP, 3.5), "turn": PI / 2}, {"at": Vector3(-3.0, DollFactory.FLOOR_TOP, 1.5), "turn": PI / 2},
	{"at": Vector3(-3.0, DollFactory.FLOOR_TOP, -3.0), "turn": PI / 2}, {"at": Vector3(-3.0, DollFactory.FLOOR_TOP, -4.5), "turn": PI / 2},
	{"at": Vector3(-8.5, DollFactory.FLOOR_TOP, -5.0), "turn": PI}, {"at": Vector3(-3.8, DollFactory.FLOOR_TOP, -5.0), "turn": PI},
]

var mannequins: Array[Mannequin] = []
var clock: ClueSpot


func setup(place: DollFactory) -> void:
	super.setup(place)
	for spot: Dictionary in MANNEQUIN_SPOTS:
		var mannequin := Mannequin.new()
		mannequin.position = spot.at
		mannequin.rotation.y = spot.turn
		place.add_child(mannequin)
		mannequins.append(mannequin)
	clock = ClueSpot.new()
	clock.prompt = "PROMPT_TIME_CLOCK"
	clock.text = tr("CLUE_TIME_CARDS")
	clock.size = Vector3(1.2, 0.7, 0.3)
	clock.position = DollFactory.CLOCK_AT + Vector3(0.3, 0, 0.05)
	place.add_child(clock)
	clock.read.connect(place.raid.add_clue)
