extends SupermarketRig

## The changed dates (allanamiento-super.md, "Las fechas cambiadas"): Don Ofertón relabels what expired with a gun that
## prints "vence en 2099". On a shelf of aisle 3 one can has its label half peeled off, and under it there's another date
## (the clue). And everything on the gondolas tastes of another century: a cop who takes a bite of the snack on aisle 2
## pulls a face. The gun, the box of old labels and the 30-year-old yogurt are hidden. Every number here is (propuesta).

## The peeled can, on the east side of the gondola between aisles 2 and 3, and the snack on aisle 2.
const CLUE_AT := Vector3(0.62, Supermarket.FLOOR_TOP + 1.02, -1.5)
const SNACK_AT := Vector3(-4.38, Supermarket.FLOOR_TOP + 0.62, 1.0)

var clue: ClueSpot
var snack: ClueSpot


func setup(place: Supermarket) -> void:
	super.setup(place)
	clue = _spot("PeeledCan", CLUE_AT, "PROMPT_SUPER_PEELED_CAN", tr("SUPER_DATES_CLUE"))
	clue.read.connect(store.raid.add_clue)
	snack = _spot("Snack", SNACK_AT, "PROMPT_SUPER_SNACK", tr("SUPER_DATES_GRIMACE"))


func _spot(spot_name: String, at: Vector3, prompt: String, text: String) -> ClueSpot:
	var spot := ClueSpot.new()
	spot.name = spot_name
	spot.size = Vector3(0.14, 0.16, 0.14)
	spot.prompt = prompt
	spot.text = text
	spot.position = at
	var model: Node3D = Supermarket.CAN_MODEL.instantiate()
	model.position.y = -Supermarket.CAN_SIZE.y / 2
	spot.add_child(model)
	store.add_child(spot)
	return spot
