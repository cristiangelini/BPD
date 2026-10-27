extends SupermarketRig

## The false-bottomed carts (allanamiento-super.md, "Los changuitos de doble fondo"): Don Ofertón's friends walk out with
## goods under a false floor. The full cart, its welder and the plan are hidden; one of the store's own carts (drawn with
## the seed) has a false floor too, half full: pushed, it pulls to one side and clinks like bottles, and the first clink is
## the clue. Every number here is (propuesta).

## How fast it has to be pushed to show, how hard it turns the cop that pushes it (radians a second) and how often it
## clinks.
const MOVING := 0.5
const PULL := 0.35
const CLINK_EVERY := 2.0

var crooked: ShoppingCart
## How many times it clinked.
var clinks := 0
var _clink_left := 0.0


func setup(place: Supermarket) -> void:
	super.setup(place)
	crooked = store.carts[store.case_seed % store.carts.size()]


func _physics_process(delta: float) -> void:
	if not is_instance_valid(crooked) or not crooked.pusher:
		_clink_left = 0.0
		return
	var cop := crooked.pusher
	if Vector2(cop.velocity.x, cop.velocity.z).length() < MOVING:
		return
	cop.rotate_y(PULL * delta)
	_clink_left -= delta
	if _clink_left <= 0.0:
		_clink_left = CLINK_EVERY
		clinked()


func clinked() -> void:
	clinks += 1
	store.raid.float_label(tr("SUPER_CARTS_CLINK"), crooked.global_position + Vector3.UP * 1.2, Color(0.7, 0.9, 1))
	if clinks == 1:
		store.raid.add_clue(tr("SUPER_CARTS_CLUE"))
