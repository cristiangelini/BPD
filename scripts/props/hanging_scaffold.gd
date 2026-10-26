class_name HangingScaffold
extends AnimatableBody3D

## The window cleaners' hanging scaffold of the Las Palomas building (docs/diseno/edificio.md, step 3): a platform hung
## by two cables from the crane on the roof, in front of 30B's balcony. Its two buttons send it down to the street or
## up to floor 30, TRAVEL_TIME from end to end; pressing the way it's already going stops it. It swings with the wind,
## harder the higher it is, and with every body that lands on it, and it leans toward the end that carries more: what
## isn't well placed slides off under the rails. Every number here is (propuesta).

signal arrived(stop: int)

const TRAVEL_TIME := 40.0
## The deck, its top at the body's origin.
const SIZE := Vector3(6.0, 0.12, 1.2)
## The gap in the back rail, where it meets the gap in the balcony's rail.
const OPENING := 3.0
const RAIL_HEIGHT := 1.0
const OWN_KG := 120.0
## The swing, as a spring back to level: how hard it pulls, how fast it calms down, and the most it leans (radians).
const STIFFNESS := 2.5
const DAMPING := 0.5
const MAX_TILT := 0.35
## Wind: a gust every GUST_EVERY s on average, up to GUST rad/s of swing at the top and nothing at the street.
const GUST_EVERY := 4.0
const GUST := 0.3
## A body landing on it: rad/s of swing per kg·m/s it brings, per m off the center.
const BUMP := 0.002
## How far it leans toward the loaded end: radians per m that the weight's center sits off the middle.
const LOAD_TILT := 0.16
## The deck is slick metal: a box that isn't wedged slides when it leans.
const DECK_FRICTION := 0.05
const STEEL := Color(0.7, 0.72, 0.75)
const BOARDS := Color(0.75, 0.55, 0.3)

## The deck height of each end, in the parent's space: the street and floor 30.
var stops: Array[float] = []
## The end it stands at (or comes from while moving).
var at_stop := 1
## How high its deck hangs, in the parent's space (it rides on this, not on `position`, which the physics sync owns).
var deck_y := 0.0
## -1 going down, 1 going up, 0 stopped.
var direction := 0
## Where the cables hang from, in the parent's space (one per end of the deck).
var anchors: Array[Vector3] = []
## The lean toward the street (x) and toward an end (z), radians, and how fast each changes.
var tilt := Vector2.ZERO
var spin := Vector2.ZERO
var rng := RandomNumberGenerator.new()
## How strong the wind blows (1 normal, 0 calm).
var wind := 1.0
var buttons: Array[ScaffoldButton] = []
var _gust_in := GUST_EVERY
var _on_deck: Area3D
var _cables: Array[MeshInstance3D] = []


func _ready() -> void:
	sync_to_physics = true
	add_to_group("scaffolds")
	var slick := PhysicsMaterial.new()
	slick.friction = DECK_FRICTION
	physics_material_override = slick
	_part(Vector3(0, -SIZE.y / 2, 0), SIZE, BOARDS)
	var half := SIZE / 2
	# The rails: a top bar and a middle one, with room under them for what slides.
	for bar_y: float in [RAIL_HEIGHT, RAIL_HEIGHT / 2]:
		_part(Vector3(0, bar_y, half.z), Vector3(SIZE.x, 0.05, 0.05), STEEL)
		for side: float in [-1.0, 1.0]:
			_part(Vector3(side * half.x, bar_y, 0), Vector3(0.05, 0.05, SIZE.z), STEEL)
			var back := (half.x - OPENING / 2)
			_part(Vector3(side * (OPENING / 2 + back / 2), bar_y, -half.z), Vector3(back, 0.05, 0.05), STEEL)
	for x: float in [-half.x, -OPENING / 2, OPENING / 2, half.x]:
		for z: float in [-half.z, half.z]:
			if absf(x) < half.x and z > 0:
				continue
			_part(Vector3(x, RAIL_HEIGHT / 2, z), Vector3(0.05, RAIL_HEIGHT, 0.05), STEEL)
	# The control box on the front rail, with its two buttons.
	_part(Vector3(-half.x + 0.6, 0.9, half.z - 0.1), Vector3(0.4, 0.4, 0.12), Color(0.9, 0.75, 0.2))
	for i in 2:
		var button := ScaffoldButton.new()
		button.scaffold = self
		button.way = [-1, 1][i]
		button.position = Vector3(-half.x + 0.5 + i * 0.2, 0.95, half.z - 0.18)
		_part_on(button, Vector3.ZERO, Vector3(0.12, 0.12, 0.05), Color(0.85, 0.2, 0.2) if i == 0 else Color(0.2, 0.7, 0.3))
		add_child(button)
		buttons.append(button)
	_on_deck = Area3D.new()
	_on_deck.collision_mask = 0xFFFFFFFF
	var area_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE.x, 1.6, SIZE.z)
	area_shape.shape = box
	area_shape.position.y = 0.8
	_on_deck.add_child(area_shape)
	add_child(_on_deck)
	_on_deck.body_entered.connect(_on_landed)
	for i in 2:
		var cable := MeshInstance3D.new()
		var cable_mesh := BoxMesh.new()
		cable_mesh.size = Vector3(0.03, 1.0, 0.03)
		cable.mesh = cable_mesh
		cable.material_override = _material(Color(0.2, 0.2, 0.2))
		cable.top_level = true
		add_child(cable)
		_cables.append(cable)


## Hangs it at floor 30 from `crane`, its ends at `street` and `top`.
func setup(street: float, top: float, crane: Array[Vector3]) -> void:
	stops = [street, top]
	anchors = crane
	at_stop = 1
	deck_y = top
	position.y = top


func moving() -> bool:
	return direction != 0


## One of its buttons: that way, or stop if it's already going that way.
func press(way: int) -> void:
	if direction == way:
		direction = 0
	elif stops[1 if way > 0 else 0] != deck_y:
		direction = way


## A call button at one end: brings it there.
func call_to(stop: int) -> void:
	if stops[stop] != deck_y:
		direction = 1 if stop == 1 else -1


## The weight on it (y) and how far its center sits off the middle, with the scaffold's own weight: along the deck
## (x) and across it (z).
func load_center() -> Vector3:
	var kg := 0.0
	var moment := Vector2.ZERO
	for body: Node3D in _on_deck.get_overlapping_bodies():
		var mass := _mass_of(body)
		if mass <= 0.0:
			continue
		var local := to_local(body.global_position)
		kg += mass
		moment += Vector2(local.x, local.z) * mass
	if kg <= 0.0:
		return Vector3.ZERO
	return Vector3(moment.x / (kg + OWN_KG), kg, moment.y / (kg + OWN_KG))


## The swing it gets from a hit, as if `kg` came at `speed` m/s at `at` (global).
func bump(at: Vector3, kg: float, speed: float) -> void:
	var local := to_local(at)
	var push := kg * speed * BUMP
	spin.x += push * (1.0 + absf(local.z)) * signf(local.z if local.z != 0.0 else 1.0)
	spin.y -= push * (1.0 + absf(local.x)) * signf(local.x if local.x != 0.0 else 1.0)


## Online (NpcSync): the host runs it (the ride, the wind, the load) and the guests' copies follow where it is; this is
## the rest they show.
func net_state() -> Array:
	return [deck_y, direction, at_stop]


func apply_net_state(state: Variant) -> void:
	deck_y = state[0]
	direction = state[1]
	at_stop = state[2]
	_hang_cables()


func _physics_process(delta: float) -> void:
	if direction != 0:
		var speed := (stops[1] - stops[0]) / TRAVEL_TIME
		deck_y = clampf(deck_y + direction * speed * delta, stops[0], stops[1])
		var stop := 1 if direction > 0 else 0
		if deck_y == stops[stop]:
			direction = 0
			at_stop = stop
			arrived.emit(stop)
	_swing(delta)
	transform = Transform3D(Basis.from_euler(Vector3(tilt.x, 0, tilt.y)), Vector3(position.x, deck_y, position.z))
	_hang_cables()


func _swing(delta: float) -> void:
	var height := clampf((deck_y - stops[0]) / (stops[1] - stops[0]), 0.0, 1.0)
	_gust_in -= delta
	if _gust_in <= 0.0:
		_gust_in = rng.randf_range(0.5, 1.5) * GUST_EVERY
		spin.x += rng.randf_range(-1.0, 1.0) * GUST * wind * height
		spin.y += rng.randf_range(-0.5, 0.5) * GUST * wind * height
	var center := load_center()
	var rest := Vector2(center.z * LOAD_TILT, -center.x * LOAD_TILT)
	spin += (-(tilt - rest) * STIFFNESS - spin * DAMPING) * delta
	tilt = (tilt + spin * delta).clamp(-Vector2.ONE * MAX_TILT, Vector2.ONE * MAX_TILT)


func _on_landed(body: Node3D) -> void:
	var mass := _mass_of(body)
	var velocity := Vector3.ZERO
	if body is RigidBody3D:
		velocity = (body as RigidBody3D).linear_velocity
	elif body is CharacterBody3D:
		velocity = (body as CharacterBody3D).velocity
	if mass > 0.0 and velocity.y < 0.0:
		bump(body.global_position, mass, -velocity.y)


func _mass_of(body: Node3D) -> float:
	if body is Cop:
		return TowerElevator.COP_KG
	if body is RigidBody3D:
		return (body as RigidBody3D).mass
	return 0.0


## The two cables from the ends of the deck up to the crane.
func _hang_cables() -> void:
	if anchors.size() < 2 or not is_inside_tree():
		return
	var parent := get_parent() as Node3D
	for i in 2:
		var low := to_global(Vector3((i * 2 - 1) * (SIZE.x / 2 - 0.2), RAIL_HEIGHT, 0))
		var high := parent.to_global(anchors[i])
		var length := low.distance_to(high)
		var up := (high - low) / maxf(length, 0.01)
		var side := up.cross(Vector3.FORWARD).normalized() if absf(up.z) < 0.99 else Vector3.RIGHT
		_cables[i].global_transform = Transform3D(Basis(side, up * length, side.cross(up)), (low + high) / 2)


func _part(at: Vector3, size: Vector3, color: Color) -> void:
	_part_on(self, at, size, color)


## A box with its shape and its mesh on `body`.
func _part_on(body: Node3D, at: Vector3, size: Vector3, color: Color) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = _material(color)
	mesh.position = at
	body.add_child(mesh)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
