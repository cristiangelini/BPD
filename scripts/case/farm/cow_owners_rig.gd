class_name CowOwnersRig
extends FarmRaidRig

## The cow of many owners (allanamiento-granja.md, "La vaca de muchos dueños"): Don Florencio sold Margarita twelve
## times, painting new spots on her before each sale so no buyer knew her again. Her spots are fresh paint: a cop who
## pats her (E on her) comes away with a black hand, the story's own clue (on the checklist the first time). And she's
## used to leaving with buyers: her gate swings open by itself every OPEN_EVERY seconds. Every number here is
## (propuesta).

signal painted(cop: Cop)

const OPEN_EVERY := 60.0

## The cops whose hand is black with her paint.
var black_hands: Array[Cop] = []
var _clue_given := false
var _open_left := OPEN_EVERY


func setup(place: FarmRaid) -> void:
	super.setup(place)
	place.cow.petted.connect(_on_petted)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_open_left -= delta
	if _open_left <= 0.0:
		_open_left = OPEN_EVERY
		open_gate()


## The gate swings open by itself (only the host decides; the gate follows online like the rest of the farm).
func open_gate() -> void:
	if farm.corral_gate.is_open:
		return
	farm.corral_gate.set_open(true)
	farm.raid.float_label(tr("FARM_GATE_CREAK"), farm.corral_gate.global_position + Vector3(0, 1.6, 1.5),
		Color(0.9, 0.85, 0.7))


## A pat on Margarita leaves the cop's hand black with fresh paint.
func _on_petted(cop: Cop) -> void:
	if not black_hands.has(cop):
		black_hands.append(cop)
	cop.set_meta("black_hand", true)
	farm.raid.float_label(tr("FARM_BLACK_HAND"), cop.global_position + Vector3.UP * 2.0, Color(0.15, 0.15, 0.15))
	if not _clue_given:
		_clue_given = true
		farm.raid.add_clue(tr("CLUE_COW_PAINT"))
	painted.emit(cop)
