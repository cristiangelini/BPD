class_name FakeAntiquesRig
extends FurnitureRig

## Yesterday's antiques (allanamiento-muebleria.md, "Las antigüedades de ayer"): Don Cajón beats new furniture with a
## chain and sells it as antiques from 1890. The aging machine is hidden with the "Año 1890" labels and the bag of fresh
## sawdust. The dining chairs are the "antiques": E turns one upside down, showing its absurd price and, underneath,
## the stamp "Made last week", the story's own clue (on the checklist the first time). Every number here is
## (propuesta).

## The dining room's chairs, now antiques that turn over, and how many times one was turned.
var antiques: Array[AntiqueChair] = []
var flips := 0


func setup(place: FurnitureStore) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["fake antiques", place.case_seed])
	for chair in place.chairs:
		var antique := AntiqueChair.new()
		antique.name = "AntiqueChair"
		antique.price = rng.randi_range(40, 99) * 1000 + 999
		for spec: Array in FurnitureStore.CHAIR_SHAPES:
			var shape := CollisionShape3D.new()
			var box := BoxShape3D.new()
			box.size = spec[1]
			shape.shape = box
			shape.position = spec[0]
			antique.add_child(shape)
		antique.add_child(FurnitureStore.CHAIR_MODEL.instantiate())
		antique.transform = chair.transform
		antique.flipped.connect(flip)
		place.add_child(antique)
		chair.queue_free()
		antiques.append(antique)
	place.chairs.clear()


## `cop` turned a chair over: "Made last week" underneath and, the first time, the clue.
func flip(cop: Cop) -> void:
	flips += 1
	cop.show_hint("HINT_CHAIR_STAMP")
	if flips == 1:
		store.raid.add_clue(tr("CLUE_LAST_WEEK_STAMP"))
