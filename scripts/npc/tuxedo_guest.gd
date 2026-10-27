class_name TuxedoGuest
extends WeddingPerson

## Tito or one of his five groomsmen (escena-boda.md, "Los seis trajes iguales"): the same rented tuxedo, top hat and
## slicked hair. Under the hat, his own hair (tinted); his glasses, if he wears them; his rented shoes (stretched to his
## size); his teeth (hidden until he bites, step 3) and his carnation: white for Tito, red for the groomsmen. E on him,
## for now, a line of his (Tito's are about Rosa). Getting his traits out comes in step 3. Every number here is
## (propuesta).

const MODEL := preload("res://assets/models/npc_tuxedo.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const RED_CARNATION := Color(0.85, 0.12, 0.18)
const GROOM_LINES := 4
const GROOMSMAN_LINES := 6

## WeddingTraits.draw: name, hair, glasses, shoe, teeth, cologne, groom, stubborn.
var traits := {}
## His place in the case's traits, from 0 (Tito is 0).
var index := 0


func _ready() -> void:
	model = MODEL
	if traits.groom:
		line_key = "WEDDING_GROOM_LINE_"
		lines = GROOM_LINES
	else:
		line_key = "WEDDING_GROOMSMAN_LINE_"
		lines = GROOMSMAN_LINES
	super._ready()
	add_to_group("wedding_tuxedos")
	tint("hair", WeddingTraits.HAIRS[traits.hair])
	if not traits.groom:
		tint("carnation", RED_CARNATION)
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	var size := inverse_lerp(WeddingTraits.SHOE_MIN, WeddingTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)


## Says the next of his lines; a groomsman, with an offset so the six don't all start with the same one.
func talk() -> void:
	say(line_key + str((index + _lines_said) % lines))
	_lines_said += 1
