class_name CluePlan
extends RefCounted

## Which clues point to which hidden evidence (investigacion.md, "Las pistas"), drawn from the case seed.
## Every item gets two clues: a note in the grandpa's hand and a second one. The safe's second clue is a trail of
## cookie crumbs from the kitchen; one of the book and the cage gets mud footprints from the back of the hall,
## and the other gets a second, vaguer note.

## Item order matches GrandpaHouse.EVIDENCE: book, cage, safe.
const ITEMS := ["book", "cage", "safe"]
const SAFE := 2


## Returns {"notes": [{"item", "precise", "place"}], "footprints": item index, "crumbs": item index}.
## `place` indexes the house's note places, all different.
static func draw(case_seed: int, place_count: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed * 31 + 5
	var footprints := rng.randi_range(0, 1)
	var notes: Array[Dictionary] = []
	for i in ITEMS.size():
		notes.append({"item": i, "precise": true})
	notes.append({"item": 1 - footprints, "precise": false})
	var places: Array = range(place_count)
	for i in range(places.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = places[i]
		places[i] = places[j]
		places[j] = swap
	for i in notes.size():
		notes[i].place = places[i]
	return {"notes": notes, "footprints": footprints, "crumbs": SAFE}


## The note's text: the item and where it is, precise or vague, already translated.
static func note_text(item: int, spot_id: String, precise: bool) -> String:
	var where := ("NOTE_SPOT_" if precise else "NOTE_VAGUE_") + spot_id
	return TranslationServer.translate(where) % TranslationServer.translate("NOTE_ITEM_" + ITEMS[item])
