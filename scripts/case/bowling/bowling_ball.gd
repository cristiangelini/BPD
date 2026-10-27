class_name BowlingBall
extends Grabbable

## A bowling ball of the alley (allanamiento-bolera.md, step 2): a round body of 4 to 7 kg that rolls far on the lanes
## and knocks the pins down, grabbed and thrown like anything else. Every number here is (propuesta).

## It hit a cop and tripped it.
signal tripped(cop: Cop)

const RADIUS := 0.11
const MODELS: Array[PackedScene] = [preload("res://assets/models/bowling_ball.glb"),
	preload("res://assets/models/bowling_ball_1.glb"), preload("res://assets/models/bowling_ball_2.glb"),
	preload("res://assets/models/bowling_ball_3.glb"), preload("res://assets/models/bowling_ball_4.glb"),
	preload("res://assets/models/bowling_ball_5.glb")]
## Little friction and bounce, so it rolls on and doesn't hop.
const FRICTION := 0.3
const BOUNCE := 0.05
## A league player's ball rolling faster than this trips the cop it hits, like a banana peel.
const TRIP_SPEED := 2.0
const TRIP_PUSH := 2.5
const TRIP_TIME := 1.2

## The return it goes back to, and its place on that return's rack.
var rack := 0
var slot := 0
## A league player bowled it and it isn't back on the rack yet.
var bowled := false


static func make(kg: float, look: int) -> BowlingBall:
	var ball := BowlingBall.new()
	ball.name = "Ball"
	ball.collision_layer = 4
	ball.collision_mask = 15
	ball.mass = kg
	ball.continuous_cd = true
	var material := PhysicsMaterial.new()
	material.friction = FRICTION
	material.bounce = BOUNCE
	ball.physics_material_override = material
	ball.contact_monitor = true
	ball.max_contacts_reported = 2
	ball.body_entered.connect(ball._hit)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = RADIUS
	shape.shape = sphere
	ball.add_child(shape)
	var model: Node3D = MODELS[look % MODELS.size()].instantiate()
	model.position.y = -RADIUS
	ball.add_child(model)
	return ball


## The cop who threw it last (null: nobody yet, or not a cop).
func thrower() -> Cop:
	if last_holder == 0 or not is_instance_id_valid(last_holder):
		return null
	return (instance_from_id(last_holder) as Node).get_parent() as Cop


## A bowled ball rolling into this PC's own cop knocks it off its feet (a copy of another player's cop only follows).
func _hit(body: Node) -> void:
	var cop := body as Cop
	if not cop or not bowled or linear_velocity.length() < TRIP_SPEED:
		return
	if cop.sync and cop.sync.is_inside_tree() and not cop.sync.is_multiplayer_authority():
		return
	var flat := Vector3(linear_velocity.x, 0, linear_velocity.z)
	cop.knock_back(flat.normalized() * TRIP_PUSH, TRIP_TIME)
	cop.show_hint("HINT_BOWL_HIT")
	tripped.emit(cop)
