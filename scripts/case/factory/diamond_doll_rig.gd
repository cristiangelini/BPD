class_name DiamondDollRig
extends FactoryRig

## The diamond doll (fabrica.md, "El muñeco del diamante"): Fermín hid a stolen diamond inside one doll of the bin of
## finished ones, the same as all the others but 1.5 kg heavier. That doll is the main evidence, drawn with the seed
## among the bin's; the jeweler's loupe and the delivery list are hidden. The story's own clue: the quality control
## sheet by the scale, where a doll weighed 2 kg. Every number here is (propuesta).

const DOLL_SCENE := preload("res://scenes/props/diamond_doll.tscn")
const SHEET_SCENE := preload("res://scenes/props/quality_sheet.tscn")
## Where the sheet lies, beside the scale.
const SHEET_FROM_SCALE := Vector3(0.6, 0.0, 0.0)

var doll: Evidence
var sheet: ClueNote


func setup(place: DollFactory) -> void:
	super.setup(place)
	var i := place.case_seed % place.pile.size()
	var plain: Node3D = place.pile[i]
	doll = DOLL_SCENE.instantiate()
	doll.position = plain.position
	place.pile[i] = doll
	plain.free()
	place.add_child(doll)
	place.main = doll
	sheet = SHEET_SCENE.instantiate()
	sheet.text = tr("CLUE_QUALITY_SHEET")
	sheet.position = DollFactory.SCALE_AT + SHEET_FROM_SCALE + Vector3.UP * 0.02
	place.add_child(sheet)
	sheet.read.connect(place.raid.add_clue)
