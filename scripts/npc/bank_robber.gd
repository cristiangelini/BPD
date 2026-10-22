class_name BankRobber
extends CharacterBody3D

## A robber of the bank (robo-banco.md, step 2, decision 102), with a rubber animal mask. Each one stands at a task
## and looks at it, sweeping their head like the night guard of the jailbreak: the rabbit watches the entrance and
## looks everywhere, the pig watches the hostages and stops to eat his sandwich, the duck watches the drill at the
## vault with ear muffs on and a narrow cone, and El Oso, the boss, stands behind the counter by the phone. Whoever
## sees a cop in their cone says so and `spotted` goes off (the drill speeds up in step 3); seeing a hostage being
## led out, `saw_hostage` (step 4). The handcuffs only close on one who doesn't see a cop at arm's length (from behind),
## except the rabbit, who gives up as soon as he sees one; the pig, seeing one, drops his sandwich and runs to the
## van, where he hides for the getaway (step 6). Cuffed, E walks them to the patrol car (OwnerEscort). They don't
## sync online yet. Every number here is (propuesta).

signal spotted(robber: BankRobber, cop: Node3D)
signal saw_hostage(robber: BankRobber, hostage: Node3D)
## The handcuffs closed on them.
signal cuffed_now(robber: BankRobber)
## The pig got into the van.
signal hid_in_van(robber: BankRobber)

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
## A cop this close and in sight can't cuff them: they dodge.
const DODGE_REACH := 2.5
## The pig runs this fast (m/s) and gets in the van this close to its door.
const RUN_SPEED := 3.0
const ARRIVED := 0.6
const SAY_TIME := 4.0

@export var animal := "conejo"
## Where their head looks now, turned from their body (radians).
var look := 0.0
var eating_left := 0.0
var _eat_left := EAT_EVERY
var _look_index := 0
var _look_left := LOOK_HOLD
var _next_line := 0
## The rabbit gave up: he can be cuffed from the front.
var surrendered := false
## Where the pig runs, in order (world positions; the level sets them): out of the entrance and to the van's door.
var run_path: Array[Vector3] = []
var running := false
var in_van := false
var _cuffed_left := 0.0
## Cop -> seconds until they count as spotted again.
var _spotted := {}
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_robbers")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6 * SCALES[animal]
	shape.shape = capsule
	shape.position.y = capsule.height / 2
	add_child(shape)
	_model = MODELS[animal].instantiate()
	_model.scale = Vector3.ONE * SCALES[animal]
	# The models face +Z; the robber faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
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


## The handcuffs: they close unless they see a cop right in front of them (the rabbit who gave up lets them).
func cuffed(seconds: float) -> void:
	if not surrendered and not is_cuffed():
		for cop: Node3D in get_tree().get_nodes_in_group("cops"):
			if global_position.distance_to(cop.global_position) < DODGE_REACH and sees_cop(cop):
				say("ROBBER_DODGE")
				spotted.emit(self, cop)
				return
	running = false
	_cuffed_left = maxf(_cuffed_left, seconds)
	say("ROBBER_%s_CUFFED" % animal.to_upper())
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if in_van or is_cuffed():
		return
	if running:
		_run(delta)
		return
	_turn_head(delta)
	if animal == "chancho":
		_eat(delta)
	for seen: Variant in _spotted.keys():
		_spotted[seen] -= delta
		if not is_instance_valid(seen) or _spotted[seen] <= 0.0:
			_spotted.erase(seen)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if not _spotted.has(cop) and sees_cop(cop):
			_spotted[cop] = SPOT_AGAIN
			_saw_cop(cop)
	for hostage: Node3D in get_tree().get_nodes_in_group("bank_hostages"):
		if hostage.get("led_by") and not _spotted.has(hostage) \
				and sees(hostage.global_position + Vector3.UP * 0.8, hostage as CollisionObject3D):
			_spotted[hostage] = SPOT_AGAIN
			say("ROBBER_HOSTAGE")
			saw_hostage.emit(self, hostage)


func _saw_cop(cop: Node3D) -> void:
	say("ROBBER_%s_SPOT" % animal.to_upper())
	if animal == "conejo":
		surrendered = true
	elif animal == "chancho" and not run_path.is_empty():
		running = true
		eating_left = 0.0
		var sandwich := find_child("props", true, false) as Node3D
		if sandwich:
			sandwich.hide()
	spotted.emit(self, cop)


## The pig running along run_path; at its end he gets in the van and is gone until the getaway.
func _run(delta: float) -> void:
	var to := run_path[0] - global_position
	to.y = 0.0
	if to.length() < ARRIVED:
		run_path.remove_at(0)
		if run_path.is_empty():
			running = false
			in_van = true
			hide()
			collision_layer = 0
			hid_in_van.emit(self)
		return
	look_at(global_position + to, Vector3.UP)
	velocity = to.normalized() * RUN_SPEED
	velocity.y = 0.0 if is_on_floor() else -GameScale.GRAVITY * delta
	move_and_slide()


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


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_ROBBER"


## E on a robber: a line of their own, a different one each time; cuffed, the escort to the patrol car.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	say("ROBBER_%s_%d" % [animal.to_upper(), _next_line % LINES + 1])
	_next_line += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


## What the escort calls (OwnerEscort): a line for `seconds`; robbers have no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key)
	_bubble_left = seconds


func _raise(_points: float) -> void:
	pass


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	# The escort turns them with their +Z ahead.
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
