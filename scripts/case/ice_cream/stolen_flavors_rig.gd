class_name StolenFlavorsRig
extends IceCreamRig

## The stolen flavors (allanamiento-heladeria.md, "Los sabores robados"): doña Nieve copies the recipes of the shop
## across the street. The box with its recipes is hidden with the "secret ingredient" and the crossed-out photo of the
## other shop; in the glass case a new flavor's sign says "Igualito al de Enfrente" (reading it, E, is the story's own
## clue), and every OFFER_EVERY seconds she offers to try "the new flavor, like no other". Every number here is
## (propuesta).

const OFFER_EVERY := 40.0
## The new flavor's sign, standing on the counter over the glass case, facing the customers.
const SIGN_AT := Vector3(-2.2, IceCreamShop.FLOOR_TOP + 1.5, 4.95)

var flavor_sign: ClueSpot
## Times she offered the new flavor.
var offers := 0
var _since := 0.0


func setup(place: IceCreamShop) -> void:
	super.setup(place)
	flavor_sign = sign_spot(SIGN_AT, 0.0, "ICE_SAME_AS_ACROSS", tr("CLUE_SAME_AS_ACROSS"), Vector3(0.8, 0.35, 0.06))
	flavor_sign.name = "FlavorSign"


## She offers to try the new flavor (unless she's busy at the machine).
func offer() -> void:
	_since = 0.0
	if shop.nieve.is_fixing():
		return
	offers += 1
	# praise() with no points: only her line.
	shop.nieve.praise(0.0, "NIEVE_NEW_FLAVOR")


func _process(delta: float) -> void:
	# Online only the host's story runs it; its people and lines reach the guests by NpcSync.
	if not multiplayer.is_server():
		return
	_since += delta
	if _since >= OFFER_EVERY:
		offer()
