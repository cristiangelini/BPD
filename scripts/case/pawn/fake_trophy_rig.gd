class_name FakeTrophyRig
extends PawnRig

## The fake trophy (allanamiento-empenos.md, "El trofeo falso"): Don Regateo swapped the golf club's gold trophy (12 kg,
## the main evidence, hidden) for a copy of painted plastic and hid the painter's receipt. The copy (an extra) stands
## on top of a shelf in the middle of the shop and weighs nothing: the first time a cop walks by (or picks it up), it
## falls with a breath, and that's the story's clue. A customer says the club's winner got "an odd, light trophy".
## Every number here is (propuesta).

const COPY_SCENE := preload("res://scenes/props/plastic_trophy.tscn")
## On top of the middle shelf by the counter, its back half on the shelf.
const COPY_ON := PawnShop.SHELVES[3] + Vector3(0.9, PawnShop.SHELF_SIZE.y + 0.01, 0.2)
const BREATH := 1.6
const PUSH := 1.5

var copy: Evidence
var fell := false


func setup(place: PawnShop) -> void:
	super.setup(place)
	copy = COPY_SCENE.instantiate()
	copy.position = COPY_ON
	place.add_child(copy)
	place.extras.append(copy)
	var customer := place.customers[0]
	customer.rumor = "PAWN_RUMOR_FAKE_TROPHY"
	customer.rumored.connect(place.raid.add_clue)


## The copy falls off the shelf: it's plastic.
func fall() -> void:
	if fell:
		return
	fell = true
	if multiplayer.is_server() and not copy.is_held():
		copy.apply_impulse(Vector3(0, 0, PUSH), Vector3.UP * 0.5)
	shop.say_at(copy.global_position + Vector3.UP * 0.6, "PAWN_TROPHY_FALLS")
	shop.raid.add_clue(tr("CLUE_FAKE_TROPHY"))


func _physics_process(_delta: float) -> void:
	if fell or not is_instance_valid(copy):
		return
	if copy.is_held() or shop.cop_near(shop.to_local(copy.global_position), BREATH):
		fall()


func net_state() -> Variant:
	return fell


func apply_net_state(state: Variant) -> void:
	if state and not fell:
		fall()
