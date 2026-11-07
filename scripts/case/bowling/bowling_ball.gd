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
## Its color (MODELS), and the name painted on it ("": none; lane 7's balls from other alleys).
var look := 0
var tag := ""


static func make(kg: float, look_index: int) -> BowlingBall:
	var ball := BowlingBall.new()
	ball.name = "Ball"
	ball.mass = kg
	ball.look = look_index
	ball._build()
	return ball


## What the guests' copy of a ball the host made during the case needs (PropSync): lane 7's balls.
func net_setup() -> Dictionary:
	return {"mass": mass, "look": look, "tag": tag, "rack": rack, "slot": slot}


func _ready() -> void:
	if get_child_count() == 0:
		_build()
	if tag != "" and not has_node("Tag"):
		var label := Label3D.new()
		label.name = "Tag"
		label.text = tag
		label.font_size = 28
		label.pixel_size = 0.004
		label.outline_size = 8
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position.y = RADIUS + 0.12
		add_child(label)


func _build() -> void:
	collision_layer = 4
	collision_mask = 15
	continuous_cd = true
	var material := PhysicsMaterial.new()
	material.friction = FRICTION
	material.bounce = BOUNCE
	physics_material_override = material
	contact_monitor = true
	max_contacts_reported = 2
	body_entered.connect(_hit)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = RADIUS
	shape.shape = sphere
	add_child(shape)
	var model: Node3D = MODELS[look % MODELS.size()].instantiate()
	model.position.y = -RADIUS
	add_child(model)


## The cop who threw it last (null: nobody yet, or not a cop).
func thrower() -> Cop:
	if last_holder == 0 or not is_instance_id_valid(last_holder):
		return null
	return (instance_from_id(last_holder) as Node).get_parent() as Cop


## A bowled ball rolling into a cop knocks it off its feet. Online the host's ball rolls and tells a guest's PC to
## knock its own cop down too (the guests' copies don't hit anything).
func _hit(body: Node) -> void:
	var cop := body as Cop
	if not cop or not bowled or linear_velocity.length() < TRIP_SPEED or not multiplayer.is_server():
		return
	var push := Vector3(linear_velocity.x, 0, linear_velocity.z).normalized() * TRIP_PUSH
	cop.knock_back(push, TRIP_TIME)
	if cop.sync and cop.sync.is_inside_tree() and not cop.sync.is_multiplayer_authority() and cop.sync.net.actions:
		cop.sync.net.actions.tell_guests(cop, "knock_back", cop, [push, TRIP_TIME])
	cop.show_hint("HINT_BOWL_HIT", true)
	tripped.emit(cop)
