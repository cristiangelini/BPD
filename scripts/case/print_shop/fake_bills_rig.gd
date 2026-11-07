class_name FakeBillsRig
extends PrintShopRig

## The fake bills (allanamiento-imprenta.md, "Los billetes de mentira"): Don Renglón prints bills with his own face. In
## the recycling basket lies a badly cut one, and a cop this close to the basket notices it, the story's own clue (on
## the checklist the first time). And the rotativa throws bills instead of sheets. Every number here is (propuesta).

const NOTICE_RANGE := 2.0
const CHECK_EVERY := 0.5
const BILL_GREEN := Color(0.45, 0.75, 0.45)
const BILL_SIZE := Vector3(0.3, 0.004, 0.14)

var noticed := false
## The badly cut bill sticking out of the basket.
var bad_bill: MeshInstance3D
var _since := 0.0


func setup(place: PrintShop) -> void:
	super.setup(place)
	shop.press.sheet_color = BILL_GREEN
	shop.press.sheet_size = BILL_SIZE
	var mesh := BoxMesh.new()
	mesh.size = BILL_SIZE
	bad_bill = MeshInstance3D.new()
	bad_bill.name = "BadBill"
	bad_bill.mesh = mesh
	var paint := StandardMaterial3D.new()
	paint.albedo_color = BILL_GREEN
	bad_bill.material_override = paint
	bad_bill.position = basket_top()
	bad_bill.rotation = Vector3(0.5, 0.4, 0.3)
	var face := Label3D.new()
	face.text = "PRINT_SHOP_BILL_FACE"
	face.font_size = 24
	face.pixel_size = 0.003
	face.modulate = Color(0.1, 0.3, 0.1)
	face.position = Vector3(0, 0.004, 0)
	face.rotation.x = -PI / 2
	bad_bill.add_child(face)
	shop.add_child(bad_bill)


func basket_top() -> Vector3:
	return PrintShop.BASKET_AT + Vector3(0.1, PrintShop.BASKET_SIZE.y + 0.02, 0)


func _physics_process(delta: float) -> void:
	_since += delta
	if noticed or _since < CHECK_EVERY:
		return
	_since = 0.0
	var at := shop.to_global(basket_top())
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= NOTICE_RANGE:
			notice()
			break


## A cop sees the badly cut bill with Don Renglón's face: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	shop.raid.add_clue(tr("CLUE_BAD_BILL"))
	shop.raid.float_label(tr("PRINT_SHOP_BAD_BILL"), shop.to_global(basket_top()) + Vector3.UP * 0.6, BILL_GREEN)
