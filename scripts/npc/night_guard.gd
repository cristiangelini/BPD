class_name NightGuard
extends StaticBody3D

## The night guard of the jailbreak (fuga.md, "La llave en la dona", step 2): he sits at his desk in front of the
## cells with a box of six donuts, and the key of the cells went into one of them without him noticing. Every
## EAT_EVERY seconds he eats one, from the last in the box to the first; if it's the one with the key, he spits it out
## and hangs it from his belt. The seed draws which donut has it. He only eats from the box while it's within his
## reach on the desk. He also looks around (step 4): his head sweeps the cells, and whatever he sees in a cone of
## SIGHT_ANGLE and SIGHT_RANGE in front of him (a cop out of the cells, the box moving, a broken donut or the key)
## raises his suspicion; at 100 he catches them (`caught`, the level puts everything back). Something thrown that lands
## away from him, or a cop shouting near him, makes him turn to look there for a while (step 5). Every number here is
## (propuesta).

signal ate(donut: int)
signal found_key
signal caught(times: int)

const MODEL := preload("res://assets/models/npc_carcelero.glb")
const EAT_EVERY := 40.0
## How far from him the box can be for him to take a donut.
const REACH := 1.5
const MUNCH_LINES := 5
const BUBBLE_TIME := 4.0
## What he sees: a cone this wide (full angle) and this deep in front of his face.
const SIGHT_ANGLE := deg_to_rad(70.0)
const SIGHT_RANGE := 10.0
const EYE_HEIGHT := 1.4
## Where his head looks, turned from his body, and how long he keeps each look.
const LOOKS: Array[float] = [0.0, 0.6, 0.0, -0.6]
const LOOK_HOLD := 3.0
const TURN_SPEED := 1.5
## Suspicion per second for each thing he sees, and how fast it goes down when he sees nothing (0 to 100).
const SUSPICION_COP := 50.0
const SUSPICION_BOX := 25.0
const SUSPICION_CLUE := 15.0
const SUSPICION_CALM := 8.0
## The box counts as moving above this speed, or while someone holds or hooks it.
const BOX_MOVING := 0.2
const CAUGHT_LINES := 3
## Noises: something thrown landing at least DISTRACT_MIN from him and within HEAR_RANGE, or a shout within HEAR_RANGE,
## turns him to look there for these seconds, faster than his usual sweep.
const HEAR_RANGE := 15.0
const DISTRACT_MIN := 3.0
const NOISE_LOOK := 4.0
const SHOUT_LOOK := 3.0
const DISTRACT_TURN_SPEED := 4.0
## A thrown thing makes its noise once it's slower than this, or this long after the throw (a donut rolls on).
const LANDED_SPEED := 0.5
const LANDING_MAX := 1.5
const NOISE_LINES := 3
const SHOUT_LINES := 2

var box: DonutBox
## Which donut of the box (its part donut_<n>) has the key: the box keeps it (DonutBox.key_donut).
var key_donut: int:
	get:
		return box.key_donut if box else -1
	set(value):
		box.key_donut = value
var key_on_belt := false
var eat_left := EAT_EVERY
var suspicion := 0.0
var times_caught := 0
## Where his head looks now, turned from his body (radians), and where it's going.
var look := 0.0
var _look_index := 0
var _look_left := LOOK_HOLD
## While he looks at a noise: where his head goes and for how long.
var distracted_left := 0.0
var _distract_look := 0.0
## Things thrown that haven't landed yet -> seconds since the throw.
var _flying := {}
## Whether a world position is out of the cells (the level sets it; nothing is, by default).
var outside_cells: Callable = func(_at: Vector3) -> bool: return false
## What his sight goes through: the desk in front of him.
var see_through: Array[RID] = []
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _rng := RandomNumberGenerator.new()


## The guard for this jailbreak's seed: the same donut has the key every time.
func setup(case_seed: int, donut_box: DonutBox) -> void:
	box = donut_box
	_rng.seed = hash(["night guard", case_seed])
	box.key_donut = _rng.randi_range(0, box.donuts - 1)


func _ready() -> void:
	add_to_group("night_guard")
	add_to_group("noise_listeners")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## The key is still in a donut of the box.
func key_in_box() -> bool:
	return not key_on_belt and box != null and key_donut < box.donuts


func box_in_reach() -> bool:
	return is_instance_valid(box) and box.global_position.distance_to(global_position) <= REACH


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	eat_left -= delta
	if eat_left <= 0.0:
		eat_left = EAT_EVERY
		eat()
	_listen(delta)
	_turn_head(delta)
	_watch(delta)


func _turn_head(delta: float) -> void:
	if distracted_left > 0.0:
		distracted_left -= delta
		look = rotate_toward(look, _distract_look, DISTRACT_TURN_SPEED * delta)
	else:
		_look_left -= delta
		if _look_left <= 0.0:
			_look_left = LOOK_HOLD
			_look_index = (_look_index + 1) % LOOKS.size()
		look = rotate_toward(look, LOOKS[_look_index], TURN_SPEED * delta)
	_model.rotation.y = look


## Something was thrown (Grabbable.throw_toward): he'll look where it lands.
func heard_throw(body: Node3D) -> void:
	_flying[body] = 0.0


func _listen(delta: float) -> void:
	for body: Node3D in _flying.keys():
		if not is_instance_valid(body):
			_flying.erase(body)
			continue
		_flying[body] += delta
		var rigid := body as RigidBody3D
		var slow := rigid == null or rigid.linear_velocity.length() < LANDED_SPEED
		if (_flying[body] > 0.3 and slow) or _flying[body] > LANDING_MAX:
			_flying.erase(body)
			var distance := _flat(body.global_position).length()
			if distance >= DISTRACT_MIN and distance <= HEAR_RANGE:
				look_at_noise(body.global_position, NOISE_LOOK, "GUARD_NOISE_%d" % _rng.randi_range(0, NOISE_LINES - 1))


## A cop shouted into the microphone near him (VoiceChat): he turns toward the voice.
func shouted_by(cop: Node3D) -> void:
	if _flat(cop.global_position).length() <= HEAR_RANGE:
		look_at_noise(cop.global_position, SHOUT_LOOK, "GUARD_SHOUT_%d" % _rng.randi_range(0, SHOUT_LINES - 1))


## Turns his head toward `at` for `seconds`, saying `line`.
func look_at_noise(at: Vector3, seconds: float, line: String) -> void:
	var local := global_basis.inverse() * _flat(at)
	_distract_look = atan2(local.x, local.z)
	distracted_left = seconds
	say(line)


## From him to `at`, flat on the ground.
func _flat(at: Vector3) -> Vector3:
	return Vector3(at.x - global_position.x, 0, at.z - global_position.z)


## Where he's looking, flat on the ground (his model faces +Z).
func facing() -> Vector3:
	return (global_basis * Basis(Vector3.UP, look)).z.normalized()


## Whether he sees the point `at`: inside his cone and with no wall in between (the desk doesn't count).
func sees(at: Vector3, body: CollisionObject3D = null) -> bool:
	var eye := global_position + Vector3.UP * EYE_HEIGHT
	var flat := Vector3(at.x - eye.x, 0, at.z - eye.z)
	if flat.length() > SIGHT_RANGE or flat.length() < 0.01:
		return false
	if facing().angle_to(flat.normalized()) > SIGHT_ANGLE / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, see_through + [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or (body != null and hit.collider == body)


## How much suspicion he gains per second from what he sees right now.
func alarm() -> float:
	var rate := 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var chest := cop.global_position + Vector3.UP
		if outside_cells.call(cop.global_position) and sees(chest, cop as CollisionObject3D):
			rate += SUSPICION_COP
	if is_instance_valid(box) and _box_moving() and sees(box.global_position + Vector3.UP * 0.1, box):
		rate += SUSPICION_BOX
	# Looking at a noise, a donut over there is just what made it.
	for clue: Node3D in [] if distracted_left > 0.0 else get_tree().get_nodes_in_group("guard_clues"):
		if sees(clue.global_position + Vector3.UP * 0.05, clue as CollisionObject3D):
			rate += SUSPICION_CLUE
			break
	return rate


func _box_moving() -> bool:
	return box.is_held() or box.linear_velocity.length() > BOX_MOVING


func _watch(delta: float) -> void:
	var rate := alarm()
	suspicion = clampf(suspicion + (rate if rate > 0.0 else -SUSPICION_CALM) * delta, 0.0, 100.0)
	if suspicion >= 100.0:
		catch()


## He gets up and puts everyone back (the level does it, on `caught`), and calms down.
func catch() -> void:
	suspicion = 0.0
	times_caught += 1
	say("GUARD_CAUGHT_%d" % _rng.randi_range(0, CAUGHT_LINES - 1), 5.0)
	caught.emit(times_caught)


## Takes the next donut out of the box and eats it, or complains that the box is gone or empty.
func eat() -> void:
	if not box_in_reach() or box.donuts == 0:
		say("GUARD_NO_DONUTS")
		return
	var donut := box.take_one()
	ate.emit(donut)
	if donut == key_donut and not key_on_belt:
		key_on_belt = true
		say("GUARD_KEY_FOUND", 6.0)
		found_key.emit()
	else:
		say("GUARD_MUNCH_%d" % _rng.randi_range(0, MUNCH_LINES - 1))


func say(text: String, seconds := BUBBLE_TIME) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Online: what the guests need to show the same box and belt (NpcSync).
func net_state() -> Variant:
	return [box.donuts if is_instance_valid(box) else 0, key_on_belt, suspicion, times_caught, look]


func apply_net_state(state: Variant) -> void:
	key_on_belt = state[1]
	suspicion = state[2]
	times_caught = state[3]
	look = state[4]
	_model.rotation.y = look
	while is_instance_valid(box) and box.donuts > int(state[0]):
		box.take_one()
