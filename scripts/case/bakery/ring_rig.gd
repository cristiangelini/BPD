class_name RingRig
extends BakeryRig

## The ring in the bread: the stolen ring is baked into one of the 40 loaves, drawn with the seed.

const RING_SCENE := preload("res://scenes/props/stolen_ring.tscn")


func setup(place: Bakery) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 31 + 7
	place.ring_loaf = rng.randi_range(0, place.loaves.size() - 1)
	place.ring = RING_SCENE.instantiate()
	place.loaves[place.ring_loaf].stuff(place.ring)
	place.main = place.ring
