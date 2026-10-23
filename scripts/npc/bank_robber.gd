class_name BankRobber
extends StaticBody3D

## A robber of the bank (robo-banco.md, step 2, decision 102), with a rubber animal mask. Each one stands at a task
## and looks at it, sweeping their head like the night guard of the jailbreak: the rabbit watches the entrance and
## looks everywhere, the pig watches the hostages and stops to eat his sandwich, the duck watches the drill at the
## vault with ear muffs on and a narrow cone, and El Oso, the boss, stands behind the counter by the phone. Whoever
## sees a cop in their cone says so and `spotted` goes off (the drill speeds up in step 3). They don't move yet, so
## online every PC has the same ones. Every number here is (propuesta).

signal spotted(robber: BankRobber, cop: Node3D)

const ANIMALS: Array[String] = ["conejo", "chancho", "pato", "oso"]
const MODELS := {
	"conejo": preload("res://assets/models/npc_ladron_conejo.glb"),
	"chancho": preload("res://assets/models/npc_ladron_chancho.glb"),
	"pato": preload("res://assets/models/npc_ladron_pato.glb"),
	"oso": preload("res://assets/models/npc_ladron_oso.glb"),
}
const SCALES := {"conejo": 1.0, "chancho": 1.0, "pato": 1.0, "oso": 1.15}
## Each one's cone (full angle in degrees and depth in meters) and where their head looks, turned from their body.
const SIGHT := {"conejo": Vector2(100, 10), "chancho": Vector2(80, 8), "pato": Vector2(60, 6), "oso": Vector2(90, 12)}
const LOOKS := {
	"conejo": [0.0, 0.8, -0.3, -0.8, 0.3],
	"chancho": [0.0, 0.4, 0.0, -0.4],
	"pato": [0.0],
	"oso": [0.0, 0.5, 0.0, -0.5],
}
const LOOK_HOLD := 2.5
const TURN_SPEED := 1.5
const EYE_HEIGHT := 1.35
## The pig eats every EAT_EVERY seconds for EAT_TIME, looking at his sandwich: he sees nothing meanwhile.
const EAT_EVERY := 20.0
const EAT_TIME := 5.0
## The same cop doesn't count as spotted again for this long.
const SPOT_AGAIN := 5.0
const LINES := 4
const SAY_TIME := 4.0

@export var animal := "conejo"
## Where their head looks now, turned from their body (radians).
var look := 0.0
var eating_left := 0.0
var _eat_left := EAT_EVERY
var _look_index := 0
var _look_left := LOOK_HOLD
var _next_line := 0
## Cop -> seconds until they count as spotted again.
var _spotted := {}
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_robbers")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6 * SCALES[animal]
	shape.shape = capsule
	shape.position.y = capsule.height / 2
	add_child(shape)
	var model: Node3D = MODELS[animal].instantiate()
	model.scale = Vector3.ONE * SCALES[animal]
	# The models face +Z; the robber faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func is_boss() -> bool:
	return animal == "oso"


func is_eating() -> bool:
	return eating_left > 0.0


## Where their face points now: their body's front turned by their head.
func facing() -> Vector3:
	return (-global_basis.z).rotated(Vector3.UP, look).normalized()


## Whether they see `at` (a world position): in their cone, near enough and with no wall in between (or the wall hit
## is `body` itself).
func sees(at: Vector3, body: CollisionObject3D = null) -> bool:
	if is_eating():
		return false
	var eye := global_position + Vector3.UP * EYE_HEIGHT
	var flat := Vector3(at.x - eye.x, 0, at.z - eye.z)
	if flat.length() > SIGHT[animal].y or flat.length() < 0.01:
		return false
	if facing().angle_to(flat.normalized()) > deg_to_rad(SIGHT[animal].x) / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or (body != null and hit.collider == body)


func sees_cop(cop: Node3D) -> bool:
	return sees(cop.global_position + Vector3.UP, cop as CollisionObject3D)


func _physics_process(delta: float) -> void:
	_turn_head(delta)
	if animal == "chancho":
		_eat(delta)
	for cop: Variant in _spotted.keys():
		_spotted[cop] -= delta
		if not is_instance_valid(cop) or _spotted[cop] <= 0.0:
			_spotted.erase(cop)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if not _spotted.has(cop) and sees_cop(cop):
			_spotted[cop] = SPOT_AGAIN
			say("ROBBER_%s_SPOT" % animal.to_upper())
			spotted.emit(self, cop)


func _turn_head(delta: float) -> void:
	var looks: Array = LOOKS[animal]
	_look_left -= delta
	if _look_left <= 0.0:
		_look_left = LOOK_HOLD
		_look_index = (_look_index + 1) % looks.size()
	look = move_toward(look, looks[_look_index], TURN_SPEED * delta)


func _eat(delta: float) -> void:
	if eating_left > 0.0:
		eating_left = maxf(eating_left - delta, 0.0)
		return
	_eat_left -= delta
	if _eat_left <= 0.0:
		_eat_left = EAT_EVERY
		eating_left = EAT_TIME
		say("ROBBER_CHANCHO_EAT")


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_ROBBER"


## E on a robber: a line of their own, a different one each time.
func use(_cop: Cop) -> void:
	say("ROBBER_%s_%d" % [animal.to_upper(), _next_line % LINES + 1])
	_next_line += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
