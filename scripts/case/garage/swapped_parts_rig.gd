class_name SwappedPartsRig
extends GarageRig

## The swapped parts (allanamiento-taller.md, "Las piezas cambiadas"): Don Tuerca keeps the new parts his clients pay
## for and puts their old ones back, painted silver. The crate of new parts (two cops) is hidden with the fake invoices
## and the pile of painted old parts; a "new" brake disc waits on the counter, and a cop who grabs it is left with a rusty
## hand, the story's own clue (on the checklist the first time). Every number here is (propuesta).

## Where the disc lies on the counter, between the till and the bell.
const DISC_AT := Vector3(-9.0, Garage.FLOOR_TOP + 1.0 + RustyPart.SIZE.y / 2, 8.1)
const RUST := Color(0.8, 0.42, 0.18)

var disc: RustyPart


func setup(place: Garage) -> void:
	super.setup(place)
	disc = RustyPart.new()
	disc.name = "RustyDisc"
	disc.position = DISC_AT
	place.add_child(disc)
	disc.rusted.connect(_on_rusted)


## A cop grabbed the disc: an orange hand and, the first time anyone does, the clue.
func _on_rusted(cop: Cop) -> void:
	cop.show_hint("HINT_RUSTY_PART")
	garage.raid.float_label(tr("GARAGE_RUST"), cop.global_position + Vector3.UP * 2.0, RUST)
	if disc.stained.size() == 1:
		garage.raid.add_clue(tr("CLUE_RUSTY_PART"))
