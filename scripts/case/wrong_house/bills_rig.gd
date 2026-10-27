class_name WhBillsRig
extends WrongHouseRig

## Bills with the comisario's face (casa-equivocada.md, "Billetes con la cara del comisario"): Don Tinta, a retired
## printer, prints fake bills with the comisario's face. The printing plate (30 kg, two carry it) is the main evidence;
## the bundle of fake bills and the tin of ink are the extras. The story's own clue is a fake bill stuck on his mailbox.
## Whoever handles the ink tin has blue hands for INKY seconds and leaves blue prints on everything they grab. Every
## number here is (propuesta).

const INKY := 30.0
const INK := Color(0.12, 0.24, 0.72)

var ink_pot: Evidence
## Cop -> seconds of blue hands left.
var inky := {}
## What got blue prints on it.
var inked: Array[Grabbable] = []
var bill_clue: ClueSpot


func setup(wrong_house: WrongHouse) -> void:
	super.setup(wrong_house)
	ink_pot = place.extras[1]
	var post := WrongHouse.at(place.guilty, WrongHouse.MAILBOX_AT)
	bill_clue = clue_spot(post + Vector3(0, 0.7, 0), Vector3(0.24, 0.14, 0.1), "PROMPT_LOOK_BILL", "CLUE_WH_FAKE_BILL")
	patch(bill_clue, Vector3(0, 0, 0.035), Vector3(0.22, 0.11, 0.005), Color(0.42, 0.78, 0.38))
	patch(bill_clue, Vector3(0, 0, 0.04), Vector3(0.05, 0.05, 0.005), Color(0.92, 0.88, 0.76))


func _physics_process(delta: float) -> void:
	for id: int in ink_pot.holders:
		var grabber := instance_from_id(id) as Grabber
		if not grabber or not grabber.get_parent() is Cop:
			continue
		var cop: Cop = grabber.get_parent()
		if not inky.has(cop):
			cop.show_hint("HINT_WH_INKY")
		inky[cop] = INKY
	for cop: Cop in inky.keys():
		inky[cop] -= delta
		if inky[cop] <= 0.0 or not is_instance_valid(cop):
			inky.erase(cop)
			continue
		var held: Grabbable = cop.get_node("Grabber").held
		if held and held != ink_pot and not inked.has(held):
			stain(held)


## Leaves a blue hand print on it.
func stain(item: Grabbable) -> void:
	inked.append(item)
	var print_mark := patch(item, Vector3(0, 0.12, 0), Vector3(0.09, 0.005, 0.11), INK)
	print_mark.name = "InkPrint"
