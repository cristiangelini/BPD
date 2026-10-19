class_name HidingDraw
extends RefCounted

## Seeded draw of where each evidence hides and which pot keeps the door key
## (docs/diseno/allanamiento.md, "La evidencia"; decision 19). The same seed gives the same draw on every player.


## spot_fits_heavy[i]: hiding spot i can hold a heavy item. item_heavy[j]: item j is heavy.
## Returns {"spots": one distinct spot index per item, "key_pot": a pot index}.
static func draw(case_seed: int, spot_fits_heavy: Array, item_heavy: Array, pot_count: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed
	var order: Array = range(spot_fits_heavy.size())
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	var spots := []
	spots.resize(item_heavy.size())
	var taken := {}
	# Heavy items pick first, so they never run out of spots that fit them.
	for heavy_pass: bool in [true, false]:
		for j in item_heavy.size():
			if item_heavy[j] != heavy_pass:
				continue
			for s: int in order:
				if not taken.has(s) and (spot_fits_heavy[s] or not heavy_pass):
					taken[s] = true
					spots[j] = s
					break
	return {"spots": spots, "key_pot": rng.randi_range(0, pot_count - 1)}
