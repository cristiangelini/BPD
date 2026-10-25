class_name LaundryWorker
extends CharacterBody3D

## An inmate working in the prison's laundry (carcel-lavanderia.md, step 2): the riot's model in its orange jumpsuit,
## standing at a station (a washer, a dryer, the folding table, the clothesline) and leaning over it as it works, once
## LaundryPlan starts. Step 3: when the truck comes, LaundryPlan sends them for a cart (`fetch`): down the room's east
## lane to the aisle between the two rows of carts, the cart pulled out into the aisle, and then pushed in front of them
## (LaundryPlan.push_route) through the canteen and the yard to the truck by the gate. Tipped over, they wait and set it
## back on its wheels. Then back to their station. Every number here is (propuesta).

signal delivered(worker: LaundryWorker, cart: LaundryCart)

enum Job { WORK, TO_CART, PUSH, BACK }

const MODEL := preload("res://assets/models/npc_preso.glb")
const SAY_TIME := 3.0
## Leaning over the work: this far, every WORK_EVERY seconds (each worker a little off the others).
const LEAN := 0.35
const WORK_EVERY := 1.6
const SPEED := 1.6
const PUSH_SPEED := 1.3
const REACH := 0.3
## The cart rolls this far ahead of them, turning toward where they go at this rate.
const CART_AHEAD := 0.95
const TURN_RATE := 5.0
## Pulling the cart out into the aisle takes this long; a tipped cart waits this long before they set it back.
const PULL_TIME := 0.5
const RIGHT_AFTER := 4.0

var prison: PrisonLevel
## Their station (level space x, z) and where they face from it.
var station := Vector2.ZERO
var face := Vector2.ZERO
var working := false
var job := Job.WORK
var cart: LaundryCart
var route: Array[Vector2] = []
## A guest's copy (step 7): the host walks them.
var follower := false
var _next := 0
var _wait := 0.0
var _push_dir := Vector3.ZERO
var _right_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _work: Tween


func _ready() -> void:
	add_to_group("laundry_workers")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## Stands at their station, facing their work.
func place() -> void:
	global_position = prison.global_transform * Vector3(station.x, PrisonLevel.FLOOR_TOP, station.y)
	_face(prison.global_transform * Vector3(face.x, PrisonLevel.FLOOR_TOP, face.y))


## Gets to work: leaning over it and back, over and over, `offset` seconds after the others.
func work(offset: float) -> void:
	if working:
		return
	working = true
	job = Job.WORK
	_work = create_tween().set_loops()
	_work.tween_interval(offset)
	_work.tween_property(_model, "rotation:x", LEAN, WORK_EVERY / 2).set_trans(Tween.TRANS_SINE)
	_work.tween_property(_model, "rotation:x", 0.0, WORK_EVERY / 2).set_trans(Tween.TRANS_SINE)


func _stop_working() -> void:
	working = false
	if _work:
		_work.kill()
		_work = null
	_model.rotation.x = 0.0


## Off for `new_cart`, `delay` seconds from now: down the east lane and up the aisle to just behind its place there.
func fetch(new_cart: LaundryCart, delay := 0.0) -> void:
	_stop_working()
	cart = new_cart
	cart.pusher = self
	job = Job.TO_CART
	_wait = delay
	var spot := LaundryPlan.cart_spot(cart.index)
	_walk([Vector2(LaundryPlan.LANE_X, station.y), Vector2(LaundryPlan.LANE_X, LaundryPlan.CROSS_Z),
		Vector2(LaundryPlan.AISLE_X, LaundryPlan.CROSS_Z), Vector2(LaundryPlan.AISLE_X, spot.y + CART_AHEAD)])


func _walk(points: Array[Vector2]) -> void:
	route = points
	_next = 0


## At the cart: pulled out into the aisle (set back on its wheels first if it's tipped), and off to the truck.
func _at_cart() -> void:
	if cart.tipped:
		cart.set_upright()
		_wait = LaundryCart.TIP_TIME
	var spot := LaundryPlan.cart_spot(cart.index)
	var to := prison.global_transform * Vector3(LaundryPlan.AISLE_X, PrisonLevel.FLOOR_TOP, spot.y)
	cart.create_tween().tween_property(cart, "global_position", to, PULL_TIME)
	_wait = maxf(_wait, PULL_TIME)
	_push_dir = -prison.global_basis.z
	job = Job.PUSH
	say("WORKER_PUSHING")
	_walk(LaundryPlan.push_route())


## At the truck: the cart goes up the ramp, and back to the station.
func _at_truck() -> void:
	var done := cart
	cart.pusher = null
	cart = null
	job = Job.BACK
	var back := LaundryPlan.push_route()
	back.reverse()
	back.remove_at(0)
	back.append_array([Vector2(LaundryPlan.AISLE_X, LaundryPlan.CROSS_Z), Vector2(LaundryPlan.LANE_X, LaundryPlan.CROSS_Z),
		Vector2(LaundryPlan.LANE_X, station.y), station])
	_walk(back)
	done.load_up()
	delivered.emit(self, done)


func _arrive() -> void:
	match job:
		Job.TO_CART:
			_at_cart()
		Job.PUSH:
			_at_truck()
		Job.BACK:
			route.clear()
			place()
			work(0.0)


## Turns so their model's front (+Z) is toward `at`.
func _face(at: Vector3) -> void:
	var away := global_position - (at - global_position)
	away.y = global_position.y
	if away.distance_to(global_position) > 0.01:
		look_at(away, Vector3.UP)


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if follower or job == Job.WORK:
		return
	if _wait > 0.0:
		_wait -= delta
		return
	if job == Job.PUSH and cart.tipped:
		# Knocked over: they complain, wait, and set it back on its wheels.
		if _right_left <= 0.0:
			_right_left = RIGHT_AFTER
			say("WORKER_MY_CART")
		_right_left -= delta
		if _right_left <= 0.0:
			cart.set_upright()
			_wait = LaundryCart.TIP_TIME
		return
	if _next >= route.size():
		_arrive()
		return
	var local := prison.global_transform.affine_inverse() * global_position
	var to := route[_next] - Vector2(local.x, local.z)
	if to.length() < REACH:
		_next += 1
		return
	var step := to.normalized() * (PUSH_SPEED if job == Job.PUSH else SPEED)
	velocity = prison.global_basis * Vector3(step.x, 0, step.y)
	velocity.y = 0.0
	_face(global_position + velocity)
	move_and_slide()
	if job == Job.PUSH:
		var ahead := velocity.normalized()
		if _push_dir.dot(ahead) < -0.99:
			# Turning right round (the lerp would never cross): start the swing to one side.
			_push_dir = _push_dir.rotated(Vector3.UP, 0.2)
		_push_dir = _push_dir.lerp(ahead, minf(1.0, TURN_RATE * delta)).normalized()
		var at := global_position + _push_dir * CART_AHEAD
		at.y = cart.global_position.y
		cart.global_position = at
		cart.look_at(at + _push_dir, Vector3.UP)
