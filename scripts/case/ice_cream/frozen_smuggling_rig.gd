class_name FrozenSmugglingRig
extends IceCreamRig

## The smuggling in the ice (allanamiento-heladeria.md, "El contrabando en el hielo"): doña Nieve smuggles watches frozen
## in blocks of ice. The block with the watches is hidden with the delivery list and the fake stamp; the cold room's
## thermometer reads -40 when ice cream keeps at -18 (reading it, E, is the story's own clue), and every ASK_EVERY seconds
## a customer who never buys ice cream comes in asking whether "the cold" arrived. Every number here is (propuesta).

const ASK_EVERY := 50.0
const CUSTOMER := preload("res://assets/models/npc_cliente.glb")
## The thermometer on the cold room's inner wall, facing into the room.
const THERMOMETER_AT := Vector3(IceCreamShop.COLD_X1 - 0.08, IceCreamShop.FLOOR_TOP + 1.6, -3.0)

var thermometer: ClueSpot
var customer: IceVisitor
var _since := 0.0


func setup(place: IceCreamShop) -> void:
	super.setup(place)
	thermometer = sign_spot(THERMOMETER_AT, -PI / 2, "ICE_THERMOMETER", tr("CLUE_COLD_THERMOMETER"),
		Vector3(0.3, 0.4, 0.06), 56)
	thermometer.name = "Thermometer"
	customer = visitor(CUSTOMER)
	customer.name = "ColdCustomer"


## The customer who doesn't buy ice cream comes in and asks.
func ask() -> void:
	_since = 0.0
	customer.come(tr("ICE_COLD_ARRIVED"))


func _process(delta: float) -> void:
	# Online only the host's story runs it; its people and lines reach the guests by NpcSync.
	if not multiplayer.is_server():
		return
	_since += delta
	if _since >= ASK_EVERY:
		ask()
