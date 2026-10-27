class_name ShoppingCart
extends Wheelbarrow

## A shopping cart of the supermarket (allanamiento-super.md, step 2). It's the wheelbarrow with a wire basket: one cop
## pushes it with E, E on something loads it, E on nothing parks it and G tips it over. A crouched cop who presses E on
## a parked, empty cart climbs in (`rider`) and rides along wherever it's pushed. If the cart going faster than
## CRASH_SPEED stops dead against something, the rider flies out forward. E from inside climbs out. Every number here is
## (propuesta).

const MODEL := preload("res://assets/models/shopping_cart.glb")
const SIZE := Vector3(0.6, 1.0, 0.95)
## Where the rider sits, over the basket's floor.
const SEAT := Vector3(0, 0.45, 0)
## How fast the pusher has to go, and how slow it has to stop in one frame, for the rider to fly out.
const CRASH_SPEED := 3.0
const STOPPED := 1.0
const THROW := 7.0
const THROW_STAGGER := 1.2
## How fast `top_speed` drops, in m/s each second.
const TOP_SPEED_DROP := 4.0

## The cop riding in the basket, if any.
var rider: Cop
## The cart's speed lately: it drops slowly, so a cart that just hit something still counts as fast (SuperCustomer).
## It comes from how far the cart moved, so online the host's copy of a guest's cart is as fast as the guest's own.
var top_speed := 0.0
var _last_speed := 0.0
var _last_at := Vector3.ZERO


func _ready() -> void:
	add_to_group("shopping_carts")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())


func prompt_key(cop: Cop) -> String:
	if rider == cop:
		return "PROMPT_CART_OUT"
	if not rider and cargo.is_empty() and cop.is_crouching:
		return "PROMPT_CART_RIDE"
	return "PROMPT_CART_TAKE"


## E on the parked cart: in, crouched and with the basket empty; else grab the handle.
func use(cop: Cop) -> void:
	if rider == cop:
		let_out()
	elif not rider and cargo.is_empty() and cop.is_crouching:
		rider = cop
		cop.seated_in = self
		cop.global_position = hold_point(cop)
	else:
		super.use(cop)


## Grabbing the handles moves the cart in front of the cop: that jump isn't speed.
func push(cop: Cop) -> void:
	super.push(cop)
	_last_at = global_position
	_last_speed = 0.0


## E from inside (the cop's seated_in): out, the same as `use` through the cop, so it happens on every PC.
func stand_up() -> void:
	if rider:
		rider.act("use", self)


## The rider climbs out next to the cart.
func let_out() -> void:
	if not rider:
		return
	var cop := rider
	rider = null
	if cop.seated_in == self:
		cop.seated_in = null
	cop.global_position = global_transform * Vector3(SIZE.x + 0.3, 0.1, 0)


## G tips it over: the rider tumbles out with the rest.
func dump() -> void:
	if rider:
		var ahead := -pusher.global_basis.z if pusher else -global_basis.z
		dump_rider(ahead)
	super.dump()


func dump_rider(ahead: Vector3) -> void:
	var cop := rider
	let_out()
	cop.global_position = global_position + ahead * 0.8 + Vector3.UP * 0.6
	cop.knock_back(ahead * THROW * 0.3, THROW_STAGGER)


func hold_point(_cop: Cop) -> Vector3:
	return global_transform * SEAT


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var moved := global_position - _last_at
	_last_at = global_position
	var speed := Vector2(moved.x, moved.z).length() / delta if pusher and delta > 0.0 else 0.0
	top_speed = maxf(speed, top_speed - TOP_SPEED_DROP * delta)
	# The pusher's own PC tells the crash to every PC (ActionSync): the others only see a copy of the push.
	if rider and pusher and _last_speed > CRASH_SPEED and speed < STOPPED and SupermarketRig.is_mine(pusher):
		pusher.act("crash", self, [-pusher.global_basis.z])
	_last_speed = speed


## Stopped dead against something: the rider flies out the front.
func crash(ahead: Vector3) -> void:
	var cop := rider
	if not cop:
		return
	dump_rider(ahead)
	cop.knock_back(ahead * THROW, THROW_STAGGER)
	cop.show_hint("SUPER_CART_CRASH")
