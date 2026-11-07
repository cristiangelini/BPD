class_name WhLettersRig
extends WrongHouseRig

## The postman's letters (casa-equivocada.md, "Las cartas del cartero"): Don Sobre's cousin keeps a bag of stolen
## letters. The bag (10 kg) is the main evidence and the album of rare stamps the extra, both hidden. The story's own
## clue: opened envelopes in the trash bin out front. Shown the bag (a cop talks to him with it near), Don Sobre
## recognizes his letters, asks for them back once the case is closed and tells where his cousin hid the stamps.
## Every number here is (propuesta).

const BIN_MODEL := preload("res://assets/models/trash_bin.glb")
## The trash bin by his mailbox (house space).
const BIN_AT := Vector3(-6.4, WrongHouse.GRASS_TOP, 9.6)

var bag: Evidence
var stamps: Evidence
var bin_clue: ClueSpot


func setup(wrong_house: WrongHouse) -> void:
	super.setup(wrong_house)
	bag = place.main
	stamps = place.extras[0]
	place.mailman.bag = bag
	place.mailman.bag_line = tr("MAILMAN_BAG") % tr(spot_key(place.hidden_spots[1]))
	var bin: Node3D = BIN_MODEL.instantiate()
	bin.position = WrongHouse.at(place.guilty, BIN_AT)
	place.add_child(bin)
	for i in 3:
		var envelope := patch(bin, Vector3(-0.06 + i * 0.06, 0.47 + i * 0.01, 0.02 * i), Vector3(0.12, 0.005, 0.08),
			Color(0.95, 0.93, 0.88))
		envelope.rotation.y = i * 0.6
	bin_clue = clue_spot(bin.position + Vector3.UP * 0.3, Vector3(0.4, 0.6, 0.4), "PROMPT_LOOK_BIN", "CLUE_WH_ENVELOPES")


## How the mailman names a hiding spot ("in the fridge"): WH_SPOT_<ID>.
static func spot_key(spot: int) -> String:
	return "WH_SPOT_" + String(WrongHouse.SPOTS[spot].id).to_upper()
