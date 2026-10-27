class_name FrozenCashRig
extends IceCreamRig

## The frozen cash (allanamiento-heladeria.md, "Los billetes congelados"): the shop launders money, selling ice cream
## nobody buys. The ice cream bucket full of bills is hidden with the sales notebook of 900 kilos a day and the "VENDIDO"
## stamp; the till's display says 900 kg sold today with the shop empty (reading it, E, is the story's own clue), and
## every time someone comes in through the door doña Nieve shuts every freezer, in a rush (no more than once every
## COVER_REST seconds). Every number here is (propuesta).

const COVER_REST := 15.0
## The till's display, over the till on the cashier's desk, facing the customers.
const DISPLAY_AT := Vector3(-1.1, IceCreamShop.FLOOR_TOP + 1.42, 4.75)
## Just inside the front door, where whoever comes in walks through.
const DOOR_AT := Vector3(IceCreamShop.ENTRANCE_X, IceCreamShop.FLOOR_TOP + 1.0, IceCreamShop.FRONT_WALL_Z - 0.5)
const DOOR_SIZE := Vector3(1.6, 2.0, 0.6)

var display: ClueSpot
## Times she ran to shut the freezers.
var covers := 0
var _rest := 0.0


func setup(place: IceCreamShop) -> void:
	super.setup(place)
	display = sign_spot(DISPLAY_AT, 0.0, "ICE_TILL_900", tr("CLUE_TILL_900"), Vector3(0.62, 0.16, 0.06), 22)
	display.name = "TillDisplay"
	var door := Area3D.new()
	door.name = "DoorWatch"
	door.position = DOOR_AT
	door.collision_layer = 0
	door.collision_mask = 2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = DOOR_SIZE
	shape.shape = box
	door.add_child(shape)
	shop.add_child(door)
	door.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			cover())


## Someone came in: she shuts every freezer, unless she just did.
func cover() -> void:
	if _rest > 0.0:
		return
	_rest = COVER_REST
	covers += 1
	for freezer: IceFreezer in shop.freezers:
		if freezer.is_open and not freezer.is_melted:
			freezer.set_open(false)
	if not shop.nieve.is_fixing():
		shop.nieve.praise(0.0, "NIEVE_COVER_FREEZERS")


func _process(delta: float) -> void:
	_rest = maxf(_rest - delta, 0.0)
