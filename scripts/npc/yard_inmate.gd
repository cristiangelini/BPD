class_name YardInmate
extends CharacterBody3D

## An inmate out in the yard at yard time in the prison's tunnel case (carcel-tunel.md, step 2): the riot's model in its
## orange jumpsuit, playing basketball by the hoop (hopping for the rebound), walking round the ring or leaning on
## the wall in the sun, once TunnelPlan starts. Walks a route of level-space points when sent somewhere. Step 3: the
## gang wander round the yard (WANDER) and, with dirt in their trouser legs (`drops_dirt`), shake a little out every
## PILE_EVERY seconds (`dropped_dirt`); sent to the tunnel they walk to their cell and go in (`in_tunnel`, out of
## sight), and coming out they leave dirty footprints (`left_print`) for `prints_left` metres. Step 4: the gardener
## (GARDEN, with a straw hat) goes from planter to planter (`stops`), working at each a while, and with fertiliser in his
## hands drops dirt too; he greets a cop who comes close (GREET_REACH, once every GREET_EVERY seconds). Every number
## here is (propuesta).

signal dropped_dirt(inmate: YardInmate, at: Vector3)
signal left_print(inmate: YardInmate, at: Vector3, heading: Vector3)
signal reached_tunnel(inmate: YardInmate)
signal back_in_yard(inmate: YardInmate)

enum Activity { HOOP, RING, SUN, WANDER, GARDEN }
enum Trip { NONE, IN, OUT }

const MODEL := preload("res://assets/models/npc_preso.glb")
const SAY_TIME := 3.0
const SPEED := 1.4
const REACH := 0.3
## The hoop players hop this high every HOP_EVERY seconds; the sunbathers lean back this far.
const HOP := 0.25
const HOP_EVERY := 1.2
const LEAN := -0.18
## The ring the walkers go round (level space centre and radius), in this many points.
const RING_AT := Vector2(4.0, 14.0)
const RING_RADIUS := 3.0
const RING_POINTS := 8
## Where the gang wander (level space), how often the dirt falls out of their trouser legs (one in SHAKE_SAY_ONE_IN
## with a line) and how far apart their dirty footprints are.
const WANDER_AREA := Rect2(-12.0, 9.5, 24.0, 9.0)
const PILE_EVERY := Vector2(10.0, 15.0)
const SHAKE_SAY_ONE_IN := 3
const PRINT_STEP := 0.7
## Step 4: the gardener works this long at each planter, leaning over it, and greets close cops.
const GARDEN_TIME := Vector2(6.0, 10.0)
const GARDEN_LEAN := 0.4
const GREET_REACH := 3.0
const GREET_EVERY := 10.0
const HAT := Color(0.9, 0.8, 0.45)

var prison: PrisonLevel
var activity := Activity.RING
## Where they stand at the start (level space x, z) and where they face from there.
var spot := Vector2.ZERO
var face := Vector2.ZERO
## For the walkers: which point of the ring they start at.
var ring_from := 0
var busy := false
var route: Array[Vector2] = []
## Step 3: one of the gang, with dirt in their trouser legs; how many metres more their feet leave prints; on the way
## to the tunnel or back, or in it.
var drops_dirt := false
var prints_left := 0.0
var trip := Trip.NONE
var in_tunnel := false
var wander_seed := 0
## Step 4: the gardener's planters (level space x, z), in order.
var stops: Array[Vector2] = []
var _stop := 0
var _pause := 0.0
var _greet_left := 0.0
## A guest's copy (step 7): the host walks them.
var follower := false
var _next := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _idle: Tween
var _rng := RandomNumberGenerator.new()
var _pile_left := 0.0
var _walked := 0.0


func _ready() -> void:
	add_to_group("yard_inmates")
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
	if activity == Activity.GARDEN:
		_model.add_child(CopTool.piece(CopTool.cylinder(0.36, 0.04), HAT, Vector3(0, 1.5, 0)))
		_model.add_child(CopTool.piece(CopTool.cylinder(0.17, 0.14), HAT, Vector3(0, 1.58, 0)))


## Stands at their spot, facing the way they look from there.
func place() -> void:
	global_position = prison.global_transform * Vector3(spot.x, PrisonLevel.FLOOR_TOP, spot.y)
	_face(prison.global_transform * Vector3(face.x, PrisonLevel.FLOOR_TOP, face.y))


## The `index`-th point of the walkers' ring (level space x, z).
static func ring_point(index: int) -> Vector2:
	var angle := TAU * posmod(index, RING_POINTS) / RING_POINTS
	return RING_AT + Vector2(cos(angle), sin(angle)) * RING_RADIUS


## Yard time: off to what they do, `offset` seconds after the others.
func start(offset: float) -> void:
	if busy:
		return
	busy = true
	_stop_idle()
	match activity:
		Activity.HOOP:
			_idle = create_tween().set_loops()
			_idle.tween_interval(offset)
			_idle.tween_property(_model, "position:y", HOP, HOP_EVERY / 4).set_ease(Tween.EASE_OUT)
			_idle.tween_property(_model, "position:y", 0.0, HOP_EVERY / 4).set_ease(Tween.EASE_IN)
			_idle.tween_interval(HOP_EVERY / 2)
		Activity.SUN:
			_model.rotation.x = LEAN
		Activity.RING:
			_walk_ring()
		Activity.GARDEN:
			_rng.seed = wander_seed
			_pile_left = _rng.randf_range(PILE_EVERY.x, PILE_EVERY.y) + offset
			walk([stops[_stop]])
		Activity.WANDER:
			_rng.seed = wander_seed
			_pile_left = _rng.randf_range(PILE_EVERY.x, PILE_EVERY.y) + offset
			_wander()


func _stop_idle() -> void:
	if _idle:
		_idle.kill()
		_idle = null
	_model.position.y = 0.0
	_model.rotation.x = 0.0


## Round and round the ring, from where they are on it.
func _walk_ring() -> void:
	var points: Array[Vector2] = []
	for i in RING_POINTS:
		points.append(ring_point(ring_from + 1 + i))
	walk(points)


## Off to somewhere else in the yard.
func _wander() -> void:
	walk([Vector2(_rng.randf_range(WANDER_AREA.position.x, WANDER_AREA.end.x),
		_rng.randf_range(WANDER_AREA.position.y, WANDER_AREA.end.y))])


## Step 3: off along `points` to the tunnel, and into it at the end.
func go_to_tunnel(points: Array[Vector2]) -> void:
	trip = Trip.IN
	walk(points)


## Out of the tunnel at `at` (world space), dirty to the knees, and back along `points` to the yard.
func come_out(at: Vector3, points: Array[Vector2], prints: float) -> void:
	in_tunnel = false
	_set_seen(true)
	global_position = at
	prints_left = prints
	trip = Trip.OUT
	walk(points)


## In the tunnel nobody sees them or bumps into them.
func _set_seen(seen: bool) -> void:
	visible = seen
	collision_layer = 8 if seen else 0


## Off along `points` (level space x, z).
func walk(points: Array[Vector2]) -> void:
	route = points
	_next = 0


func is_walking() -> bool:
	return _next < route.size()


## At the end of their way: into the tunnel, back in the yard, round the ring again or somewhere else to wander to.
func _arrive() -> void:
	route.clear()
	_next = 0
	match trip:
		Trip.IN:
			trip = Trip.NONE
			in_tunnel = true
			_set_seen(false)
			reached_tunnel.emit(self)
			return
		Trip.OUT:
			trip = Trip.NONE
			back_in_yard.emit(self)
	if activity == Activity.RING and busy:
		ring_from += RING_POINTS
		_walk_ring()
	elif activity == Activity.WANDER and busy:
		_wander()
	elif activity == Activity.GARDEN and busy:
		# At a planter: leaning over it a while, then on to the next.
		_pause = _rng.randf_range(GARDEN_TIME.x, GARDEN_TIME.y)
		_model.rotation.x = GARDEN_LEAN


## The gardener: done at a planter, off to the next; a cop close by gets a hello.
func _garden(delta: float) -> void:
	_greet_left -= delta
	if _greet_left <= 0.0:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if cop.global_position.distance_to(global_position) <= GREET_REACH:
				say("GARDENER_HELLO")
				_greet_left = GREET_EVERY
				break
	if _pause <= 0.0:
		return
	_pause -= delta
	if _pause <= 0.0:
		_model.rotation.x = 0.0
		_stop = (_stop + 1) % stops.size()
		walk([stops[_stop]])


## The gang in the yard shake some dirt out of their trouser legs now and then.
func _shake_dirt(delta: float) -> void:
	if not busy or not drops_dirt or in_tunnel or trip != Trip.NONE or _pause > 0.0:
		return
	_pile_left -= delta
	if _pile_left > 0.0:
		return
	_pile_left = _rng.randf_range(PILE_EVERY.x, PILE_EVERY.y)
	if _rng.randi_range(1, SHAKE_SAY_ONE_IN) == 1:
		say("YARD_PEBBLE")
	dropped_dirt.emit(self, global_position)


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


## What a guest's copy needs besides where they are and what they say (NpcSync, step 7): whether yard time started
## and whether they're in the tunnel.
func net_state() -> Array:
	return [busy, in_tunnel]


func apply_net_state(net: Variant) -> void:
	if net[0] and not busy:
		start(0.0)
		route.clear()
	if net[1] != in_tunnel:
		in_tunnel = net[1]
		_set_seen(not in_tunnel)


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if follower:
		return
	_shake_dirt(delta)
	if activity == Activity.GARDEN:
		_garden(delta)
	if route.is_empty():
		return
	if _next >= route.size():
		_arrive()
		return
	var local := prison.global_transform.affine_inverse() * global_position
	var to := route[_next] - Vector2(local.x, local.z)
	if to.length() < REACH:
		_next += 1
		return
	var step := to.normalized() * SPEED
	velocity = prison.global_basis * Vector3(step.x, 0, step.y)
	velocity.y = 0.0
	_face(global_position + velocity)
	var from := global_position
	move_and_slide()
	if prints_left > 0.0:
		var moved := from.distance_to(global_position)
		_walked += moved
		prints_left -= moved
		if _walked >= PRINT_STEP:
			_walked = 0.0
			left_print.emit(self, global_position, velocity.normalized())
