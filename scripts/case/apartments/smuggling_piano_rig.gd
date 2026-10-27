class_name SmugglingPianoRig
extends ApartmentsRig

## The smuggling piano (edificio.md, "El piano del contrabando"): Mr. Bellini's grand piano in 30B's living room is
## full of gold ingots. It is too big for the elevator, so it goes down on the scaffold, among four, and every hard hit
## shakes an ingot loose (ContrabandPiano). The story's clue: E plays it and it goes "clonc" (the first time goes on
## the checklist). Every number here is (propuesta).

const PIANO_SCENE := preload("res://scenes/props/contraband_piano.tscn")
const PIANO_HALF_HEIGHT := 0.5
## In the living room by the east wall, clear of the sofa and the shelves, on the parquet.
const PIANO_AT := Vector3(8.0, ApartmentTower.TOP_Y + 0.02, 6.0)

var piano: ContrabandPiano


func setup(place: ApartmentTower) -> void:
	super.setup(place)
	piano = PIANO_SCENE.instantiate()
	piano.position = PIANO_AT + Vector3.UP * (PIANO_HALF_HEIGHT + 0.01)
	place.add_child(piano)
	place.main = piano
	piano.played.connect(func() -> void: tower.raid.add_clue(tr("CLUE_PIANO_CLONK")))
