class_name RiggedScaleRig
extends IceCreamRig

## The rigged scale (allanamiento-heladeria.md, "La balanza trucha"): doña Nieve sells half a kilo as a kilo. The scale
## with the magnet is hidden with the spare magnet and the notebook of complaints she hid; on the counter, the "1 KG"
## sign is stuck over a tiny tub (reading it, E, is the story's own clue), and every COMPLAIN_EVERY seconds a customer
## comes back in saying it isn't a kilo. Every number here is (propuesta).

const COMPLAIN_EVERY := 45.0
const CUSTOMER := preload("res://assets/models/npc_clienta.glb")
## The tiny tub with the "1 KG" sign, on the till's table.
const TUB_AT := Vector3(-0.1, IceCreamShop.FLOOR_TOP + 1.035, 4.95)

var kilo_sign: ClueSpot
var customer: IceVisitor
var _since := 0.0


func setup(place: IceCreamShop) -> void:
	super.setup(place)
	kilo_sign = sign_spot(TUB_AT + Vector3(0, 0.2, 0), 0.0, "ICE_ONE_KILO", tr("CLUE_TINY_KILO"),
		Vector3(0.3, 0.15, 0.06), 48)
	kilo_sign.name = "KiloSign"
	var tub := MeshInstance3D.new()
	var cup := CylinderMesh.new()
	cup.top_radius = 0.05
	cup.bottom_radius = 0.04
	cup.height = 0.07
	tub.mesh = cup
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color(0.98, 0.96, 0.9)
	tub.material_override = paint
	tub.position = TUB_AT
	shop.add_child(tub)
	customer = visitor(CUSTOMER)
	customer.name = "KiloCustomer"


## A customer comes back in to complain about the kilo.
func complain() -> void:
	_since = 0.0
	customer.come(tr("ICE_NOT_A_KILO"))


func _process(delta: float) -> void:
	# Online only the host's story runs it; its people and lines reach the guests by NpcSync.
	if not multiplayer.is_server():
		return
	_since += delta
	if _since >= COMPLAIN_EVERY:
		complain()
