class_name BankHostage
extends CharacterBody3D

## A hostage of the bank robbery (robo-banco.md, step 2, decision 102): one of the neighbors who came to the bank,
## crouched on the hall's floor in front of the counter. E on one takes them by the hand (step 4): they tell their
## complaint, a different one each time, stand up and follow that cop; out of the bank they're free, say thanks and
## go home. A robber who sees one being led out raises the alarm (BankRobber.saw_hostage). Online the host's walk and
## go free, and a guest's follow them (NpcSync, net_state). At the party (robo-banco-rehenes.md, step 1) they sway
## to the music while they sit, and they don't want to go (step 2, decision 121): led by the hand they walk at half
## speed and protest every few seconds, and let go before the door they walk back to their spot on the floor and sit
## down again. Two of them, by the seed, are fans of the gang (step 3): they wear a cardboard mask of one of the four
## animals, look around while they sit, and a cop in their cone makes them shout to El Oso (`snitched`, the drill gets
## nervous as when a robber sees one). Food wins them over (step 4): E with a donut box or a croissant in hand gives
## them one, and they follow that cop at full speed without a word of protest. The one El Oso lets go for a kept
## promise only gets as far as the door (walk_out), and walks back in unless a cop takes them by the hand there.
## Every number here is (propuesta).

signal freed_now(hostage: BankHostage)
## A fan saw a cop and warned the gang.
signal snitched(hostage: BankHostage, cop: Node3D)

const LOOKS: Array[String] = ["vecina", "clienta", "cliente", "senora", "abuelo", "abuela", "politico", "repartidor",
	"heladero", "periodista"]
const SCALES := {"abuelo": 0.82, "abuela": 0.8}
## Crouched on the floor: the model squashed this much.
const CROUCH := 0.82
const LINES := 8
const SAY_TIME := 4.0
## They walk this fast (m/s), this far behind the cop's hand.
const SPEED := 1.8
const KEEP_AWAY := 1.2
## At the party, sitting: they rock side to side this much (radians), this many times a second.
const SWAY := 0.12
const SWAY_RATE := 1.6
## At the party, led by the hand: this much of SPEED, and a new protest every PROTEST_EVERY seconds.
const RELUCTANT := 0.5
const PARTY_LINES := 8
const PROTEST_EVERY := 6.0
const BACK_LINES := 3
## Back at their spot when this close (m).
const HOME_REACH := 0.25
## A fan's cone (full angle in degrees and depth in meters), where their head turns to from their body (all around,
## the door behind them too), how long each look holds, and how high their eyes are sitting.
const SNITCH_SIGHT := Vector2(120, 8)
const SNITCH_LOOKS: Array[float] = [0.0, 1.4, PI, -1.4]
const SNITCH_HOLD := 2.5
const SNITCH_EYE := 1.0
## The same cop again only after this long (s).
const SNITCH_AGAIN := 5.0
## Where the cardboard mask goes on the model: over the face.
const MASK_AT := Vector3(0, 1.31, 0.21)
## Won over with food: these many thanks (HOSTAGE_FED_n).
const FED_LINES := 3
## Let go by El Oso: this long at the door before they walk back in (s).
const DOOR_WAIT := 8.0
## Stuck on the way back (behind the counter, against a wall) this long, they're just back in their spot.
const HOME_GIVE_UP := 20.0

@export var look := "vecina"
var next_line := 0
## The cop leading them by the hand, if any.
var led_by: Cop
## At the party (decision 121): they sway to the music while they sit, each at their own beat.
var partying := false
var sway_phase := 0.0
## Let go at the party before the door: walking back to `home`, where they sat (the level's spot for them).
var returning := false
var home := Vector3.ZERO
var _home_yaw := 0.0
var _protest_left := 0.0
var _home_left := 0.0
## Won over with a donut or a croissant: they follow at full speed and don't protest (until they're free).
var fed := false
## Waiting at the door after El Oso let them go, and the way back in before their spot.
var _door_left := 0.0
var _path: Array[Vector3] = []
## A fan of the gang: the animal on their cardboard mask ("" if they're not one). Set before they enter the tree.
var snitch := ""
## Where a fan's head looks now, turned from their body (radians).
var head_look := 0.0
var _look_index := 0
var _look_left := SNITCH_HOLD
## Cop -> seconds until a fan shouts about them again.
var _snitched := {}
var freed := false
## Whether a world position is out of the bank (the level sets it; nowhere is, by default).
var is_out: Callable = func(_at: Vector3) -> bool: return false
var _model: Node3D
var _size := 1.0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_hostages")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.3
	shape.shape = capsule
	shape.position.y = 0.65
	add_child(shape)
	_model = load("res://assets/models/npc_%s.glb" % look).instantiate()
	_size = SCALES.get(look, 1.0)
	_model.scale = Vector3(_size, _size * CROUCH, _size)
	# The models face +Z; the hostage faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	if snitch != "":
		var mask: Node3D = load("res://assets/models/bank_mask_%s.glb" % snitch).instantiate()
		mask.name = "Mask"
		mask.position = MASK_AT
		_model.add_child(mask)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.6, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	home = global_position
	_home_yaw = rotation.y


func prompt_key(cop: Cop) -> String:
	if freed:
		return ""
	if wants_food() and food_of(cop):
		return "PROMPT_FEED_HOSTAGE"
	return "PROMPT_LET_GO_HOSTAGE" if led_by == cop else "PROMPT_LEAD_HOSTAGE"


## E: takes them by the hand (they tell their complaint and stand up), or lets go (they crouch where they are).
func use(cop: Cop) -> void:
	if freed:
		return
	var food := food_of(cop) if wants_food() else null
	if food:
		feed(cop, food)
		return
	if led_by == cop:
		led_by = null
		if partying:
			returning = true
			_home_left = HOME_GIVE_UP
			say("HOSTAGE_BACK_%d" % (next_line % BACK_LINES + 1))
		else:
			_model.scale.y = _size * CROUCH
		return
	_take(cop)
	_protest()
	if partying:
		cop.show_hint("HINT_BANK_PARTY_LEAD")


## Up and following `cop` by the hand.
func _take(cop: Cop) -> void:
	led_by = cop
	returning = false
	_door_left = 0.0
	_path.clear()
	_turn(0.0)
	_model.scale.y = _size


## Whether food would win them over: at the party, not yet fed and still inside.
func wants_food() -> bool:
	return partying and not fed and not freed


## What a cop has in hand to give them: a croissant, or a donut box with donuts left (null if nothing).
static func food_of(cop: Cop) -> Grabbable:
	var held: Grabbable = cop.get_node("Grabber").held
	if held is BankCroissant or (held is DonutBox and (held as DonutBox).donuts > 0):
		return held
	return null


## Given a donut or a croissant: they eat it, say thanks and follow that cop at full speed.
func feed(cop: Cop, food: Grabbable) -> void:
	if food is DonutBox:
		(food as DonutBox).take_one()
	elif food is BankCroissant:
		(food as BankCroissant).given(cop)
	fed = true
	_take(cop)
	say("HOSTAGE_FED_%d" % (next_line % FED_LINES + 1))
	next_line += 1


## Sitting in their spot: not led, not on the way back, not at the door.
func sitting() -> bool:
	return not freed and not led_by and not returning and _door_left <= 0.0


## Let go by El Oso: standing just out of the entrance at `at`, they wait at the door for DOOR_WAIT seconds and then
## walk back in along `way_in` to their spot, unless a cop takes them by the hand there (out of the bank, free).
func walk_out(at: Vector3, way_in: Array[Vector3]) -> void:
	global_position = at
	_turn(0.0)
	_model.scale.y = _size
	_door_left = DOOR_WAIT
	_path = way_in.duplicate()
	say("HOSTAGE_DOOR")


## What they say when taken by the hand, and every PROTEST_EVERY seconds at the party while led.
func _protest() -> void:
	if partying:
		say("HOSTAGE_PARTY_%d" % (next_line % PARTY_LINES + 1))
		_protest_left = PROTEST_EVERY
	else:
		say("HOSTAGE_%d" % (next_line % LINES + 1))
	next_line += 1


## How fast they follow the hand: half as fast at the party (propuesta), unless food won them over.
func speed() -> float:
	return SPEED * RELUCTANT if partying and not fed else SPEED


func _physics_process(delta: float) -> void:
	if freed:
		return
	if returning:
		_walk_home(delta)
		return
	if _door_left > 0.0 and not led_by:
		_door_left -= delta
		if _door_left <= 0.0:
			returning = true
			_home_left = HOME_GIVE_UP
			say("HOSTAGE_BACK_%d" % (next_line % BACK_LINES + 1))
			next_line += 1
		return
	if not led_by:
		if snitch != "":
			_watch(delta)
		return
	if is_out.call(global_position):
		free_hostage()
		return
	if partying and not fed:
		_protest_left -= delta
		if _protest_left <= 0.0:
			_protest()
	var to := led_by.global_position - global_position
	to.y = 0.0
	var wish := to.normalized() * speed() if to.length() > KEEP_AWAY else Vector3.ZERO
	_step(wish, delta)


## A fan sitting: their head goes around, and a cop in their cone gets shouted about.
func _watch(delta: float) -> void:
	_look_left -= delta
	if _look_left <= 0.0:
		_look_left = SNITCH_HOLD
		_look_index = (_look_index + 1) % SNITCH_LOOKS.size()
	_turn(move_toward(head_look, SNITCH_LOOKS[_look_index], delta * 2.0))
	for seen: Variant in _snitched.keys():
		_snitched[seen] -= delta
		if not is_instance_valid(seen) or _snitched[seen] <= 0.0:
			_snitched.erase(seen)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if not _snitched.has(cop) and sees_cop(cop):
			_snitched[cop] = SNITCH_AGAIN
			say("HOSTAGE_SNITCH")
			snitched.emit(self, cop)


## Turns a fan's head (the whole sitting body, on the floor).
func _turn(to: float) -> void:
	head_look = to
	if _model:
		_model.rotation.y = PI + head_look


## Where a fan's face points now: their body's front turned by their head.
func facing() -> Vector3:
	return (-global_basis.z).rotated(Vector3.UP, head_look).normalized()


## Whether a fan sees this cop: in their cone, near enough and with no wall in between.
func sees_cop(cop: Node3D) -> bool:
	var eye := global_position + Vector3.UP * SNITCH_EYE
	var at := cop.global_position + Vector3.UP
	var flat := Vector3(at.x - eye.x, 0, at.z - eye.z)
	if flat.length() > SNITCH_SIGHT.y or flat.length() < 0.01:
		return false
	if facing().angle_to(flat.normalized()) > deg_to_rad(SNITCH_SIGHT.x) / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or hit.collider == cop


## Back to where they sat: once there, they sit down again facing the counter.
func _walk_home(delta: float) -> void:
	if not _path.is_empty():
		var by := _path[0] - global_position
		by.y = 0.0
		if by.length() < HOME_REACH:
			_path.remove_at(0)
		else:
			_step(by.normalized() * SPEED, delta)
			return
	var to := home - global_position
	to.y = 0.0
	_home_left -= delta
	if to.length() < HOME_REACH or _home_left <= 0.0:
		returning = false
		_path.clear()
		global_position = Vector3(home.x, global_position.y, home.z)
		velocity = Vector3.ZERO
		rotation.y = _home_yaw
		_model.scale.y = _size * CROUCH
		return
	_step(to.normalized() * SPEED, delta)


func _step(wish: Vector3, delta: float) -> void:
	if wish.length() > 0.05:
		look_at(global_position + wish, Vector3.UP)
	velocity = Vector3(wish.x, 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta, wish.z)
	move_and_slide()


## Out of the bank: thanks, and home (gone once the line's said).
func free_hostage() -> void:
	freed = true
	led_by = null
	returning = false
	_door_left = 0.0
	collision_layer = 0
	say("HOSTAGE_FREE")
	freed_now.emit(self)


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What a guest's copy needs besides where they are and what they say (NpcSync): free, standing up, still here, won
## over with food and where a fan's head looks.
func net_state() -> Array:
	return [freed, is_equal_approx(_model.scale.y, _size), visible, fed, snappedf(head_look, 0.01)]


func apply_net_state(state: Variant) -> void:
	if state[0] and not freed:
		freed = true
		led_by = null
		collision_layer = 0
		freed_now.emit(self)
	_model.scale.y = _size if state[1] else _size * CROUCH
	visible = state[2]
	if state.size() > 4:
		fed = state[3]
		_turn(state[4])


func _process(delta: float) -> void:
	if partying and not led_by and not returning and not freed:
		sway_phase += delta * SWAY_RATE * TAU
		_model.rotation.z = sin(sway_phase) * SWAY
	elif _model.rotation.z != 0.0:
		_model.rotation.z = 0.0
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
			if freed:
				hide()
