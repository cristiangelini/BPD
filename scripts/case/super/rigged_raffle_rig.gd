extends SupermarketRig

## The rigged raffle (allanamiento-super.md, "El sorteo arreglado"): Don Ofertón raffles a car, and every coupon in the
## urn is for "Primo Ofertón". By the entrance there's a table with a pad of coupons and a sign, «¡Sorteamos un auto!»;
## the top coupon of the pad already comes filled in with the cousin's name (E on it, the clue). The urn, the cardboard
## prize car and the winners' photo are hidden. Every number here is (propuesta).

const PAD_MODEL := preload("res://assets/models/super_coupon_pad.glb")
## The table against the front wall, east of the doorway, the pad on it and the sign over it.
const TABLE_AT := Vector3(6.3, Supermarket.FLOOR_TOP, 11.3)
const TABLE_SIZE := Vector3(1.2, 0.8, 0.6)
const PAD_SIZE := Vector3(0.17, 0.06, 0.13)
const SIGN_UP := 1.5

var coupons: ClueSpot
var sign_label: Label3D


func setup(place: Supermarket) -> void:
	super.setup(place)
	store._solid(TABLE_AT + Vector3(0, TABLE_SIZE.y / 2, 0), TABLE_SIZE)
	store._build.mesh_box(TABLE_AT + Vector3(0, TABLE_SIZE.y / 2, 0), TABLE_SIZE, Supermarket.RED)
	coupons = ClueSpot.new()
	coupons.name = "Coupons"
	coupons.size = PAD_SIZE
	coupons.prompt = "PROMPT_SUPER_COUPONS"
	coupons.text = tr("SUPER_RAFFLE_CLUE")
	var pad: Node3D = PAD_MODEL.instantiate()
	pad.position.y = -PAD_SIZE.y / 2
	coupons.add_child(pad)
	store.add_child(coupons)
	coupons.position = TABLE_AT + Vector3(0, TABLE_SIZE.y + PAD_SIZE.y / 2, -0.05)
	coupons.read.connect(store.raid.add_clue)
	sign_label = Label3D.new()
	sign_label.name = "RaffleSign"
	sign_label.text = tr("SUPER_RAFFLE_SIGN")
	sign_label.pixel_size = 0.006
	sign_label.outline_size = 10
	sign_label.modulate = Color(1, 0.85, 0.2)
	store.add_child(sign_label)
	sign_label.position = TABLE_AT + Vector3(0, SIGN_UP, TABLE_SIZE.z / 2 - 0.02)
	sign_label.rotation.y = PI
