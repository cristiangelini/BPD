class_name SwappedPlatesRig
extends GarageRig

## The swapped plates (allanamiento-taller.md, "Las patentes cambiadas"): Don Tuerca repaints stolen cars and puts new
## plates on them. The crate with 40 plates is hidden with the list of stolen cars and the spray can; one of the two
## clients' cars on the floor (drawn with the seed) has fresh paint, and a cop who touches it gets a green hand, the
## story's own clue (on the checklist the first time). Every number here is (propuesta).

signal painted_hand(cop: Cop)

## How far around the car's body a cop counts as touching it.
const TOUCH := 0.35
const PAINT := Color(0.2, 0.75, 0.35)

## The car with the fresh paint (an index of Garage.CARS), and the cops who already touched it.
var painted := -1
var touched := {}


func setup(place: Garage) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["swapped plates", place.case_seed])
	painted = [0, 2][rng.randi_range(0, 1)]
	var area := Area3D.new()
	area.name = "WetPaint"
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Garage.CAR_SIZE + Vector3(TOUCH, Garage.CABIN_SIZE.y + TOUCH, TOUCH) * 2
	shape.shape = box
	shape.position.y = box.size.y / 2
	area.add_child(shape)
	area.position = place.cars[painted].position
	place.add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			touch(body))


## `cop` touched the painted car: a green hand and, the first time anyone does, the clue.
func touch(cop: Cop) -> void:
	if touched.has(cop):
		return
	touched[cop] = true
	cop.show_hint("HINT_WET_PAINT")
	garage.raid.float_label(tr("GARAGE_WET_PAINT"), cop.global_position + Vector3.UP * 2.0, PAINT)
	if touched.size() == 1:
		garage.raid.add_clue(tr("CLUE_WET_PAINT"))
	painted_hand.emit(cop)
