class_name MasterKeysRig
extends HardwareRig

## The master keys (ferreteria.md, "Las llaves maestras"): Tobías copies the key of every house on the block when the
## neighbors bring theirs, and keeps a copy for himself on a fat key ring. The ring is the main evidence, hidden with
## the wax molds and the list of addresses. The story's own clue: fresh filings by the key machine. What changes: the
## storeroom key isn't in the till but among the blank keys on the board behind the counter, and only trying them
## finds it. Every number here is (propuesta).

const FILINGS_SCENE := preload("res://scenes/props/metal_filings.tscn")
## Where the filings lie on the counter, from the key machine.
const FILINGS_AT := Vector3(-0.3, 0.01, 0.15)

var filings: ClueNote


func setup(place: HardwareStore) -> void:
	super.setup(place)
	place.till.has_key = false
	place.key_board.tries_needed = HardwareKeyBoard.tries_for(place.case_seed)
	filings = FILINGS_SCENE.instantiate()
	filings.text = tr("CLUE_FILINGS")
	filings.position = HardwareStore.KEY_MACHINE_AT + FILINGS_AT
	place.add_child(filings)
	filings.read.connect(place.raid.add_clue)
