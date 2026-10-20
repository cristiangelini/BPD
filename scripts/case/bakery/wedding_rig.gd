class_name WeddingRig
extends BakeryRig

## The wedding cakes that never existed (panaderia.md): Marta took deposits for cakes she never baked. The display
## cakes are cardboard, and angry couples keep calling: Marta leaves the bakehouse door to answer the phone.
## Every number here is (propuesta).

## The phone hangs on the shop's east wall, past the counter, four steps from the bakehouse door; Marta stands there
## to talk.
const PHONE_AT := Vector3(Bakery.HALF_X - 0.08, 1.4, 3.0)
const CALL_POST := Vector3(Bakery.HALF_X - 0.6, Bakery.FLOOR_TOP, 3.0)
const FIRST_CALL := 25.0
const CALL_EVERY := 40.0
## It rings this long before she picks up, and she talks for CALL_TIME.
const RING_TIME := 2.5
const CALL_TIME := 8.0

var cardboard: Array[CardboardCake] = []
var phone: StaticBody3D
var _next_call := FIRST_CALL
var _ring_left := 0.0
var _ring: Label3D


func setup(place: Bakery) -> void:
	super.setup(place)
	for cake: Ornament in place.cakes:
		var fake := CardboardCake.new()
		fake.position = cake.position
		place.add_child(fake)
		cardboard.append(fake)
		cake.queue_free()
	place.cakes.clear()
	place.baker.call_post = CALL_POST
	phone = StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.08, 0.25, 0.18)
	shape.shape = box
	phone.add_child(shape)
	phone.add_child(_mesh(Vector3(0.08, 0.25, 0.18), Color(0.85, 0.2, 0.2), Vector3.ZERO))
	phone.add_child(_mesh(Vector3(0.06, 0.2, 0.06), Color(0.15, 0.15, 0.18), Vector3(-0.03, 0.0, 0.11)))
	phone.position = PHONE_AT
	place.add_child(phone)
	_ring = Label3D.new()
	_ring.text = "FX_RING"
	_ring.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_ring.pixel_size = 0.004
	_ring.outline_size = 8
	_ring.modulate = Color(1, 0.85, 0.3)
	_ring.position = PHONE_AT + Vector3(-0.1, 0.35, 0)
	_ring.hide()
	place.add_child(_ring)


func _physics_process(delta: float) -> void:
	if _ring_left > 0.0:
		_ring_left -= delta
		if _ring_left <= 0.0:
			_ring.hide()
			bakery.baker.take_call(CALL_TIME)
		return
	_next_call -= delta
	if _next_call <= 0.0:
		_next_call = CALL_EVERY
		ring()


## The phone rings; Marta picks up after RING_TIME.
func ring() -> void:
	_ring_left = RING_TIME
	_ring.show()


func _mesh(size: Vector3, color: Color, at: Vector3) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	look.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	look.material_override = material
	look.position = at
	return look
