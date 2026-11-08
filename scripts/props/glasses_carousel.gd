class_name GlassesCarousel
extends StaticBody3D

## The turning stand of glasses in the optician's salon (docs/diseno/allanamiento-optica.md, "El exhibidor
## giratorio"): it turns slowly by itself. A cop walking into it, something thrown at it or E gives it a push, and it
## turns faster; past THROW_SPIN it throws one of its PAIRS every THROW_EVERY, flying out across the salon (hard
## enough to crack a display case). The host throws; online sync comes in step 7. Every number here is (propuesta).

signal threw(pair: Grabbable)

const MODEL := preload("res://assets/models/glasses_carousel.glb")
const PAIR_MODEL := preload("res://assets/models/loose_glasses.glb")
const IDLE_SPIN := 0.4
const PUSH_SPIN := 3.5
const MAX_SPIN := 12.0
## How fast it slows down back to IDLE_SPIN, in rad/s each second.
const FRICTION := 1.5
const THROW_SPIN := 6.0
const THROW_EVERY := 0.35
const PAIRS := 12
const PAIR_SIZE := Vector3(0.16, 0.06, 0.06)
const PAIR_KG := 0.05
## Where the pairs hang: how far from the pole, and the three tiers' heights.
const ARM := 0.3
const TIERS: Array[float] = [0.7, 1.05, 1.4]
const PUSH_REACH := 0.55

## Radians per second, around Y.
var spin := IDLE_SPIN
var pairs_left := PAIRS
var thrown: Array[Grabbable] = []
var model: Node3D
var _throw_left := 0.0


func _ready() -> void:
	_shape(Vector3(0, 0.03, 0), Vector3(0.6, 0.06, 0.6))
	_shape(Vector3(0, 0.85, 0), Vector3(0.12, 1.7, 0.12))
	model = MODEL.instantiate()
	add_child(model)
	var area := Area3D.new()
	area.collision_layer = 0
	# Cops (2) and props (4).
	area.collision_mask = 6
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = PUSH_REACH
	cylinder.height = 1.8
	shape.shape = cylinder
	shape.position.y = 0.9
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_body_entered)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SPIN_CAROUSEL"


func use(_cop: Cop) -> void:
	push()


## One push: it turns PUSH_SPIN faster, up to MAX_SPIN.
func push() -> void:
	spin = minf(spin + PUSH_SPIN, MAX_SPIN)


func _on_body_entered(body: Node3D) -> void:
	if body is Grabbable and thrown.has(body):
		return
	if body is Cop or body is RigidBody3D:
		push()


func _physics_process(delta: float) -> void:
	model.rotate_y(spin * delta)
	spin = move_toward(spin, IDLE_SPIN, FRICTION * delta)
	if spin < THROW_SPIN or pairs_left <= 0 or not multiplayer.is_server():
		_throw_left = 0.0
		return
	_throw_left -= delta
	if _throw_left <= 0.0:
		_throw_left = THROW_EVERY
		throw_pair()


## Throws one pair off its arm, flying out along the turn with a little hop.
func throw_pair() -> Grabbable:
	if pairs_left <= 0:
		return null
	var index := PAIRS - pairs_left
	pairs_left -= 1
	var turn := model.rotation.y + index * TAU / 5.0
	var out := Vector3(cos(turn), 0, -sin(turn))
	var along := Vector3.UP.cross(out)
	var pair := Grabbable.new()
	pair.name = "LoosePair%d" % index
	pair.collision_layer = 4
	pair.collision_mask = 15
	pair.mass = PAIR_KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = PAIR_SIZE
	shape.shape = box
	pair.add_child(shape)
	pair.add_child(PAIR_MODEL.instantiate())
	get_parent().add_child(pair)
	pair.global_position = global_position + out * (PUSH_REACH + 0.1) + Vector3.UP * TIERS[index % TIERS.size()]
	pair.look_at(pair.global_position + out)
	pair.linear_velocity = (out * 0.6 + along * 0.8).normalized() * spin * 0.6 + Vector3.UP * 1.0
	thrown.append(pair)
	threw.emit(pair)
	return pair


func _shape(at: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	add_child(shape)
