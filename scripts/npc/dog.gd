class_name Dog
extends Grabbable

## One of the loose dogs of the pet salon (docs/diseno/peluqueria.md, "El peluquero y los perros"). It wanders the
## salon and the yard, follows the cop who has something in hand and jumps at him, and every now and then takes
## something small a cop left on the floor in its mouth and hides it in the doghouse (like the bakery's pigeons).
## A cop who bumps into it, or a hard landing, makes it bark: Ramiro complains. Cops can pick it up (it's light) to
## sit with it in the waiting armchair. Every number here is (propuesta).

signal barked(at: Vector3)

const SPEED := 2.2
## It follows a cop holding something within this range, stays this close and jumps at him every so often.
const FOLLOW_RANGE := 6.0
const KEEP := 1.0
const HOP_EVERY := 2.5
const HOP_SPEED := 3.0
## It takes things of at most this many kg, lying this close to the floor, within this range, after this rest.
const FETCH_KG := 1.0
const FETCH_RANGE := 6.0
const FETCH_EVERY := 12.0
const FLOOR_BAND := 0.3
const REACH := 0.5
## Bumped by a cop faster than this, or hitting anything harder than HIT_SPEED: it barks, at most once per cooldown.
const BUMP_SPEED := 2.5
const HIT_SPEED := 4.0
const BARK_COOLDOWN := 2.0
const REPATH := 0.5
const WANDER_EVERY := 4.0
## Where it holds what it carries, from its feet.
const MOUTH := Vector3(0, 0.38, 0.42)
const MODELS: Array[PackedScene] = [
	preload("res://assets/models/dog_0.glb"), preload("res://assets/models/dog_1.glb"),
	preload("res://assets/models/dog_2.glb"), preload("res://assets/models/dog_3.glb"),
	preload("res://assets/models/dog_4.glb"), preload("res://assets/models/dog_5.glb"),
]

enum State { WANDER, FOLLOW, FETCH, CARRY }

## Its coat (one of MODELS).
@export var coat := 0
## Where it wanders (floor rectangles of the salon, as Rect2 in x/z) and where it hides what it takes, set by the salon.
var areas: Array[Rect2] = []
var den: Vector3
var floor_y := 0.0
var state := State.WANDER
var target: Grabbable
var carried: Grabbable
var thefts := 0
var rng := RandomNumberGenerator.new()
var _goal: Vector3
var _path := PackedVector3Array()
var _repath := 0.0
var _wander := 0.0
var _hop := HOP_EVERY
var _fetch_wait := FETCH_EVERY
var _since_bark := BARK_COOLDOWN
var _impacts := ImpactTracker.new()
var _model: Node3D
var _step := 0.0


func _ready() -> void:
	add_to_group("dogs")
	contact_monitor = true
	max_contacts_reported = 4
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true
	_model = MODELS[coat % MODELS.size()].instantiate()
	add_child(_model)
	body_entered.connect(_on_body_entered)
	_goal = global_position


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_DOG"


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_DOG"


func throw_toward(holder_id: int, direction: Vector3) -> void:
	super.throw_toward(holder_id, direction)
	bark()


## Woof. Returns true if it barked now (not within BARK_COOLDOWN of the last one).
func bark() -> bool:
	if _since_bark < BARK_COOLDOWN:
		return false
	_since_bark = 0.0
	barked.emit(global_position)
	return true


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_since_bark += delta
	if is_held():
		_drop()
		target = null
		state = State.WANDER
		return
	_carry()
	if absf(linear_velocity.y) > 0.5:
		return
	match state:
		State.WANDER:
			_fetch_wait -= delta
			_wander -= delta
			if _wander <= 0.0 or _flat_distance(_goal) < REACH:
				_wander = WANDER_EVERY
				_set_goal(_wander_point())
			if _fetch_wait <= 0.0:
				_fetch_wait = FETCH_EVERY
				target = _pick_target()
				if target:
					state = State.FETCH
			elif _follow_cop():
				state = State.FOLLOW
		State.FOLLOW:
			var cop := _follow_cop()
			if not cop:
				state = State.WANDER
			else:
				_set_goal(cop.global_position)
				_hop -= delta
				if _flat_distance(cop.global_position) < KEEP + 0.5 and _hop <= 0.0:
					_hop = HOP_EVERY
					linear_velocity.y = HOP_SPEED
		State.FETCH:
			if not is_instance_valid(target) or target.is_held() or target.freeze or not _on_floor(target):
				target = null
				state = State.WANDER
			else:
				_set_goal(target.global_position)
				if _flat_distance(target.global_position) < REACH:
					_pick_up(target)
					target = null
					state = State.CARRY
					_set_goal(den)
		State.CARRY:
			if not carried:
				state = State.WANDER
			elif _flat_distance(den) < REACH:
				_drop()
				thefts += 1
				state = State.WANDER
	_walk(delta, state == State.FOLLOW)


## Walks along the path to the goal, stopping KEEP short of a cop it follows.
func _walk(delta: float, following: bool) -> void:
	_repath -= delta
	if _repath <= 0.0:
		_repath = REPATH
		_path = NavigationServer3D.map_get_path(get_world_3d().navigation_map, global_position, _goal, true)
	while _path.size() > 1 and _flat_distance(_path[0]) < 0.2:
		_path = _path.slice(1)
	var wish := Vector3.ZERO
	if not _path.is_empty() and not (following and _flat_distance(_goal) < KEEP):
		wish = _path[0] - global_position
		wish.y = 0.0
		if _path.size() == 1 and wish.length() < 0.05:
			wish = Vector3.ZERO
	if wish.length() > 0.01:
		wish = wish.normalized() * SPEED
		sleeping = false
		_model.rotation.y = atan2(wish.x, wish.z)
		_step += delta * 14.0
		_model.position.y = absf(sin(_step)) * 0.04
	else:
		_model.position.y = 0.0
	linear_velocity.x = wish.x
	linear_velocity.z = wish.z


func _set_goal(point: Vector3) -> void:
	if point.distance_to(_goal) > 0.3:
		_repath = 0.0
	_goal = point


func _flat_distance(point: Vector3) -> float:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length()


## The nearest cop with something (not a dog) in hand, within FOLLOW_RANGE.
func _follow_cop() -> Cop:
	var best: Cop
	var best_distance := FOLLOW_RANGE
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		# What the cop held may have just broken in its hands.
		var held = cop.get_node("Grabber").held
		if not is_instance_valid(held) or held is Dog:
			continue
		var d := _flat_distance(cop.global_position)
		if d < best_distance:
			best = cop
			best_distance = d
	return best


## Something small a cop left lying on the floor, the nearest within FETCH_RANGE.
func _pick_target() -> Grabbable:
	var best: Grabbable
	var best_distance := FETCH_RANGE
	for node in get_parent().get_children():
		var item := node as Grabbable
		if not item or item is Dog or item.mass > FETCH_KG or not item.was_held or item.is_held() or item.freeze \
				or not _on_floor(item):
			continue
		var d := _flat_distance(item.global_position)
		if d < best_distance:
			best = item
			best_distance = d
	return best


func _on_floor(item: Node3D) -> bool:
	return item.global_position.y - floor_y < FLOOR_BAND


func _pick_up(item: Grabbable) -> void:
	carried = item
	item.freeze = true
	add_collision_exception_with(item)


## Keeps what it carries in its mouth; a cop grabbing it takes it away.
func _carry() -> void:
	if not carried:
		return
	if not is_instance_valid(carried):
		carried = null
		return
	if carried.is_held():
		_drop()
		return
	carried.global_position = global_position + _model.basis * MOUTH


## Lets go of what it carries, set down on the floor under its mouth (fragile things survive a dog).
func _drop() -> void:
	if not carried or not is_instance_valid(carried):
		carried = null
		return
	var item := carried
	carried = null
	remove_collision_exception_with(item)
	if not item.is_held():
		var from := item.global_position
		var query := PhysicsRayQueryParameters3D.create(from + Vector3.UP * 0.2, from + Vector3.DOWN * 1.0, 1)
		query.exclude = [get_rid(), item.get_rid()]
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			item.global_position = (hit.position as Vector3) + Vector3.UP * (_half_height(item) + 0.01)
	item.linear_velocity = Vector3.ZERO
	item.freeze = false


static func _half_height(item: Node3D) -> float:
	var half := 0.0
	for child in item.get_children():
		var shape := child as CollisionShape3D
		if shape and shape.shape:
			half = maxf(half, shape.shape.get_debug_mesh().get_aabb().size.y / 2)
	return half


func _wander_point() -> Vector3:
	if areas.is_empty():
		return global_position
	var area: Rect2 = areas[rng.randi() % areas.size()]
	return Vector3(rng.randf_range(area.position.x, area.end.x), floor_y,
		rng.randf_range(area.position.y, area.end.y))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _impacts.hardest(state) > HIT_SPEED:
		bark.call_deferred()


func _on_body_entered(body: Node) -> void:
	if body is Cop and (body as Cop).velocity.length() > BUMP_SPEED:
		bark()
