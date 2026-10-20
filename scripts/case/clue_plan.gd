class_name CluePlan
extends RefCounted

## Which clues point to which hidden evidence (investigacion.md, "Las pistas"), drawn from the case seed.
## Every item gets two clues: a note in the grandpa's hand and a second one. The story's own trail (the bingo's
## crumbs to the safe) is the second clue of its item; one of the others gets mud footprints from the back of the
## hall, and the rest get a second, vaguer note.


## Returns {"notes": [{"item", "precise", "place"}], "footprints": item index, "spare": note places left free}.
## `place` indexes the house's note places, all different. trail_item is -1 when the story has no trail of its own;
## loose_item, an item that isn't in a hiding spot, gets no clues at all (-1 for none).
static func draw(case_seed: int, place_count: int, item_count: int, trail_item: int, loose_item := -1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed * 31 + 5
	var others: Array = range(item_count).filter(func(i: int) -> bool: return i != trail_item and i != loose_item)
	var footprints: int = others[rng.randi_range(0, others.size() - 1)]
	var notes: Array[Dictionary] = []
	for i in item_count:
		if i != loose_item:
			notes.append({"item": i, "precise": true})
	for i: int in others:
		if i != footprints:
			notes.append({"item": i, "precise": false})
	var places: Array = range(place_count)
	for i in range(places.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = places[i]
		places[i] = places[j]
		places[j] = swap
	for i in notes.size():
		notes[i].place = places[i]
	return {"notes": notes, "footprints": footprints, "spare": places.slice(notes.size())}


## The note's text: the item (its NOTE_ITEM_ key) and where it is, precise or vague, already translated.
static func note_text(item_key: String, spot_id: String, precise: bool) -> String:
	var where := ("NOTE_SPOT_" if precise else "NOTE_VAGUE_") + spot_id
	return TranslationServer.translate(where) % TranslationServer.translate("NOTE_ITEM_" + item_key)
