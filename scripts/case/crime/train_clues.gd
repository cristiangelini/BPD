class_name TrainClues
extends Node

## The train case's clues where they go (escena-tren.md, "Las pistas"), put by Train when the case comes: the empty
## showcase with the prints, the footprint in the luggage car's soot, the hair on the broken window's sill (the
## window, opened, lets the wind take it), the bitten sandwich on a dining table, and señor Mostaza's round with his
## cart, which wipes the footprint wherever it passes unless someone keeps him busy buying something. Every number
## here is (propuesta).

## The cart's round: out of its corner, down the aisle to the back of the luggage car and back, in the cars' space.
const CART_ROUTE: Array[Vector3] = [
	Vector3(-2.6, 0, 0.1), Vector3(-28.4, 0, 0.1), Vector3(-2.6, 0, 0.1), Train.CART_AT,
]
const CART_SPEED := 0.6
## The first round starts this long after the tip, and the next ones this long after the last ended.
const CART_FIRST := 40.0
const CART_EVERY := 100.0
## Seconds he stays selling after a cop buys something, and what it costs.
const CART_HOLD := 30.0
const PRICE := 10
## The footprint this close to the cart's middle gets wiped, in meters.
const CART_REACH := 0.6
## Where the footprint can be: on the cart's way, off the aisle's middle.
const FOOTPRINT_SPOTS: Array[Vector3] = [Vector3(-27, 0, 0.55), Vector3(-23.5, 0, 0.55), Vector3(-19, 0, 0.55)]
const SILL_AT := Train.BROKEN_WINDOW_AT + Vector3(0.2, -0.36, 0)
const SANDWICH_AT := Train.TABLES[1] + Vector3(0.15, 0.79, -0.1)
const SOOT := Color(0.14, 0.13, 0.13)
## The rope round the showcase's glass, and its knot on the side to the aisle.
const ROPE_Y := 0.98
const KNOT_AT := Train.SHOWCASE_AT + Vector3(0, ROPE_Y, TrainShowcase.SIZE.z / 2 + 0.06)

var train: Train
var case: CrimeSceneCase
var showcase: TrainShowcase
var window: TrainWindow
var knot: TrainKnot
var footprint: FlourPrint
## Where the cart is on its round (index of the next corner; -1: parked), and how long until it moves again.
var cart_next := -1
var cart_wait := CART_FIRST
var _route: Array[Vector3] = []


func _ready() -> void:
	var plan := case.plan
	var who := case.culprit()
	showcase = TrainShowcase.new()
	showcase.name = "Showcase"
	showcase.case = case
	showcase.has_prints = plan.clues.has("prints")
	showcase.position = Train.SHOWCASE_AT + Vector3(0, 1.2, 0)
	train.cars().add_child(showcase)
	_rope()
	knot = TrainKnot.new()
	knot.name = "Knot"
	knot.case = case
	knot.is_clue = plan.clues.has("knot")
	knot.left = who.left
	knot.position = KNOT_AT
	train.cars().add_child(knot)
	window = TrainWindow.new()
	window.name = "BrokenWindow"
	window.clues = self
	window.position = Train.BROKEN_WINDOW_AT + Vector3(0.1, 0, 0)
	train.cars().add_child(window)
	PlaceBuilder.new(train.cars()).box(SILL_AT + Vector3(0, -0.03, 0), Vector3(0.36, 0.04, 1.0), Train.BODY)
	_route.assign(CART_ROUTE)
	if plan.clues.has("footprint"):
		footprint = FlourPrint.new()
		footprint.name = "SootPrint"
		footprint.case = case
		footprint.shoe = who.shoe
		footprint.dust = SOOT
		footprint.position = FOOTPRINT_SPOTS[hash(["train footprint", case.case_seed]) % FOOTPRINT_SPOTS.size()]
		train.cars().add_child(footprint)
		case.flour_print = footprint
	if plan.clues.has("hair"):
		_clue_item("hair", SILL_AT)
	if plan.clues.has("bite"):
		_clue_item("bite", SANDWICH_AT)


func _rope() -> void:
	var builder := PlaceBuilder.new(train.cars())
	var size := TrainShowcase.SIZE + Vector3(0.03, 0, 0.03)
	for side: float in [-1.0, 1.0]:
		builder.mesh_box(Train.SHOWCASE_AT + Vector3(0, ROPE_Y, side * size.z / 2), Vector3(size.x, 0.03, 0.02),
			TrainKnot.ROPE)
		builder.mesh_box(Train.SHOWCASE_AT + Vector3(side * size.x / 2, ROPE_Y, 0), Vector3(0.02, 0.03, size.z),
			TrainKnot.ROPE)


func _clue_item(kind: String, at: Vector3) -> void:
	var item := CrimeClueItem.new()
	item.name = "Clue_" + kind
	item.kind = kind
	item.look = "museum"
	item.case = case
	item.hair_color = MagicianTraits.HAIRS[case.culprit().hair]
	item.position = at
	train.cars().add_child(item)
	case.items[kind] = item


func _physics_process(delta: float) -> void:
	# Online the host's train decides where the cart is (step 6).
	if case.follower or not case.tip_given:
		return
	if cart_wait > 0.0:
		cart_wait -= delta
		if cart_wait <= 0.0 and cart_next < 0:
			cart_next = 0
		return
	if cart_next >= 0:
		push_cart(delta)


## One step of the cart along its round, señor Mostaza behind it, and the footprint if it's under it.
func push_cart(delta: float) -> void:
	var cart := train.cart
	var target := _route[cart_next]
	var step := CART_SPEED * delta
	if cart.position.distance_to(target) <= step:
		cart.position = target
		cart_next += 1
		if cart_next >= _route.size():
			cart_next = -1
			cart_wait = CART_EVERY
	else:
		cart.position = cart.position.move_toward(target, step)
	var heading := target - cart.position
	if heading.length() > 0.01:
		train.vendor.position = cart.position - heading.normalized() * 0.9
		train.vendor.rotation.y = atan2(heading.x, heading.z)
	if footprint and not footprint.wiped:
		var off := footprint.position - cart.position
		if Vector2(off.x, off.z).length() <= CART_REACH:
			footprint.wipe()


## A cop bought something from señor Mostaza: he stays selling a while, and it comes off the salary.
func buy(cop: Cop) -> void:
	cart_wait = maxf(cart_wait, CART_HOLD)
	case.spend(PRICE)
	train.vendor.say("TRAIN_VENDOR_SOLD")
	if cop:
		cop.show_hint(tr("HINT_TRAIN_BOUGHT") % PRICE)


## The open window's wind: the hair on the sill flies off, unless it was already bagged.
func blow() -> void:
	if not case.items.has("hair"):
		return
	var hair: CrimeClueItem = case.items.hair
	if hair.get_parent() == train.cars() and hair.position.distance_to(SILL_AT) <= 0.5:
		hair.wash()
