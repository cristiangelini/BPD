extends SupermarketRig

## The fake cheese (allanamiento-super.md, "El queso de mentira"): Don Ofertón sells cheese that isn't, and keeps the bills
## in a giant plastic wheel. On the cheese table by the dairy fridge lie the real wheels, 10 kg each, and one of them is
## plastic too:
## dropped, it bounces back up like a ball (the clue, the first time). The fake big wheel (25 kg, two cops), its mold and
## a block of yellow wax are hidden. Every number here is (propuesta).

const WHEEL_MODEL := preload("res://assets/models/super_cheese_wheel.glb")
const WHEEL_SIZE := Vector3(0.4, 0.14, 0.4)
const WHEEL_KG := 10.0
const WHEELS := 4
## The cheese table in front of the dairy fridge with the wheels on it, and how hard the plastic one has to come down to
## bounce.
const TABLE_AT := Vector3(-9.0, Supermarket.FLOOR_TOP, -9.4)
const TABLE_SIZE := Vector3(2.0, 0.8, 0.7)
const WHEELS_ON := TABLE_AT + Vector3(0, 0.8, 0)
const BOUNCE := 0.85
const BOUNCE_SPEED := 2.0

var wheels: Array[Grabbable] = []
## Which of the wheels is plastic (drawn with the seed), and how many times it bounced.
var bouncy := 0
var bounces := 0
var _falling := false


func setup(place: Supermarket) -> void:
	super.setup(place)
	bouncy = store.case_seed % WHEELS
	store._solid(TABLE_AT + Vector3(0, TABLE_SIZE.y / 2, 0), TABLE_SIZE)
	store._build.mesh_box(TABLE_AT + Vector3(0, TABLE_SIZE.y / 2, 0), TABLE_SIZE, Supermarket.WOOD)
	for i in WHEELS:
		var wheel := ClubEvidence.make_item("CheeseWheel%d" % i, WHEEL_MODEL, WHEEL_SIZE, WHEEL_KG)
		(wheel.get_child(1) as Node3D).position.y = -WHEEL_SIZE.y / 2
		if i == bouncy:
			var rubber := PhysicsMaterial.new()
			rubber.bounce = BOUNCE
			wheel.physics_material_override = rubber
			wheel.mass = 1.0
		store.add_child(wheel)
		wheel.position = WHEELS_ON + Vector3((i - (WHEELS - 1) / 2.0) * 0.45, WHEEL_SIZE.y / 2 + 0.01, 0)
		wheels.append(wheel)


## The plastic wheel coming down fast and going back up: a bounce, and the first one is the clue.
func _physics_process(_delta: float) -> void:
	var wheel := wheels[bouncy]
	if not is_instance_valid(wheel):
		return
	if wheel.linear_velocity.y < -BOUNCE_SPEED:
		_falling = true
	elif _falling and wheel.linear_velocity.y > BOUNCE_SPEED * BOUNCE * 0.5:
		_falling = false
		bounced()


func bounced() -> void:
	bounces += 1
	store.raid.float_label(tr("SUPER_CHEESE_BOING"), wheels[bouncy].global_position + Vector3.UP * 0.5, Color(1, 0.85, 0.3))
	if bounces == 1:
		store.raid.add_clue(tr("SUPER_CHEESE_CLUE"))
