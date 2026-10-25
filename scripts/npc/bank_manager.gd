class_name BankManager
extends CharacterBody3D

## Mr. Moneda, the bank's manager (robo-banco-gerente.md, step 1, decision 124): in every bank robbery he waits on the
## sidewalk by his car, in pajamas and slippers, pacing back and forth, rubbing his arms and complaining out loud. E on
## him gets the back door's key: he hands it to the first cop who talks to him (Cop.has_key, the same flag as the
## grandpa's pots), and the back door (FrontDoor) opens with it from outside. Later he only complains. In the variant
## where he's the gang's real boss (`boss`, step 2) he looks the same at first sight, but the key he gives doesn't fit
## (the level marks the back door), every 20 to 30 s he stops, takes a walkie out of his pajama's pocket and murmurs
## into it for 2 s (`radioed`: the level hurries the drill if no cop is near him), and now and then a complaint gives
## him away. The handcuffs (step 3): the boss gives up (`caught`, he doesn't pace nor use the walkie again) and E walks
## him to the patrol car (OwnerEscort, the level adds it); the honest one protests ("¡Soy la víctima!"), the cuffs hold
## him only HONEST_CUFF seconds and `wrongly_cuffed` goes off the first time.
## Every number here is (propuesta).

signal key_given(cop: Cop)
## The boss talked to the gang on his walkie.
signal radioed(manager: BankManager)
## The boss in handcuffs, the first time.
signal caught_now(manager: BankManager)
## The honest one in handcuffs, the first time.
signal wrongly_cuffed(manager: BankManager)

const MODEL := preload("res://assets/models/npc_gerente.glb")
## He paces this fast (m/s) between his two spots, and stands this long at each end (s).
const SPEED := 0.6
const PAUSE := 3.0
const REACH := 0.15
## A new complaint every this many seconds, each shown this long.
const LINE_EVERY := 9.0
const SAY_TIME := 4.0
const LINES := 4
const AGAIN_LINES := 3
## The boss: every this many seconds (a random time between both) the walkie, shown this long; every BOSS_LINE_EVERY
## complaints one of BOSS_LINES that gives him away.
const WALKIE_EVERY := Vector2(20.0, 30.0)
const WALKIE_TIME := 2.0
const WALKIE_LINES := 3
const BOSS_LINES := 2
const BOSS_LINE_EVERY := 3
## The honest manager stays cuffed this long (s), however long the cuffs say.
const HONEST_CUFF := 3.0

## The two ends of his pacing (world positions; the level sets them before he enters the tree).
var spots: Array[Vector3] = []
## The gang's real boss (step 2).
var boss := false
var has_key := true
## The boss was cuffed: he gave up. The honest one was cuffed once.
var caught := false
var was_cuffed := false
var _cuffed_left := 0.0
var next_line := 0
## Seconds the walkie is still out, and until the next time.
var walkie_left := 0.0
var _walkie_in := 0.0
var _rng := RandomNumberGenerator.new()
var _walkie: Node3D
var _to := 1
var _pause_left := PAUSE
var _line_left := 2.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("bank_manager")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; the manager faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	_walkie = _model.find_child("walkie", true, false) as Node3D
	_walkie.hide()
	_walkie_in = _rng.randf_range(WALKIE_EVERY.x, WALKIE_EVERY.y)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	if spots.is_empty():
		spots = [global_position, global_position]


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_MANAGER"


## E: the back door's key the first time, a complaint after that; cuffed (the boss), the escort to the patrol car.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	if caught:
		say("MANAGER_CAUGHT_AGAIN")
		return
	if has_key:
		has_key = false
		cop.has_key = true
		say("MANAGER_KEY")
		cop.show_hint("HINT_BANK_BACK_KEY")
		key_given.emit(cop)
		return
	say("MANAGER_AGAIN_%d" % (next_line % AGAIN_LINES + 1))
	next_line += 1


## The handcuffs: the boss gives up for good, the honest one protests and is let go soon.
func cuffed(seconds: float) -> void:
	if boss:
		_cuffed_left = maxf(_cuffed_left, seconds)
		walkie_left = 0.0
		_walkie.hide()
		_model.rotation.z = 0.0
		say("MANAGER_CAUGHT")
		if not caught:
			caught = true
			caught_now.emit(self)
		return
	_cuffed_left = maxf(_cuffed_left, minf(seconds, HONEST_CUFF))
	say("MANAGER_VICTIM")
	if not was_cuffed:
		was_cuffed = true
		wrongly_cuffed.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## What the escort calls (OwnerEscort): a line for `seconds`; he has no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key)
	_bubble_left = seconds


func _raise(_points: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if caught or is_cuffed():
		return
	_line_left -= delta
	if _line_left <= 0.0:
		_line_left = LINE_EVERY
		if _bubble_left <= 0.0:
			_complain()
	if boss:
		_use_walkie(delta)
	_pace(delta)


## The seed for his walkie's times (the level gives the case's).
func seed_with(value: int) -> void:
	_rng.seed = value
	_walkie_in = _rng.randf_range(WALKIE_EVERY.x, WALKIE_EVERY.y)


func _complain() -> void:
	if boss and next_line % BOSS_LINE_EVERY == BOSS_LINE_EVERY - 1:
		say("MANAGER_BOSS_%d" % (floori(next_line / float(BOSS_LINE_EVERY)) % BOSS_LINES + 1))
	else:
		say("MANAGER_%d" % (next_line % LINES + 1))
	next_line += 1


## The boss's walkie: out of the pocket for WALKIE_TIME every WALKIE_EVERY, standing still while he murmurs.
func _use_walkie(delta: float) -> void:
	if walkie_left > 0.0:
		walkie_left -= delta
		if walkie_left <= 0.0:
			_walkie.hide()
		return
	_walkie_in -= delta
	if _walkie_in <= 0.0:
		radio()


## Out with the walkie: "Apúrense..." and the gang hears him.
func radio() -> void:
	_walkie_in = _rng.randf_range(WALKIE_EVERY.x, WALKIE_EVERY.y)
	walkie_left = WALKIE_TIME
	_walkie.show()
	_pause_left = maxf(_pause_left, WALKIE_TIME)
	say("MANAGER_WALKIE_%d" % (_rng.randi() % WALKIE_LINES + 1))
	radioed.emit(self)


func walkie_showing() -> bool:
	return _walkie.visible


## Back and forth between his two spots, rubbing his arms (a little shiver of the model) while he stands.
func _pace(delta: float) -> void:
	if _pause_left > 0.0:
		_pause_left -= delta
		_model.rotation.z = sin(Time.get_ticks_msec() * 0.03) * 0.03
		velocity = Vector3.ZERO
		return
	_model.rotation.z = 0.0
	var to := spots[_to]
	var flat := Vector3(to.x - global_position.x, 0.0, to.z - global_position.z)
	if flat.length() <= REACH:
		_to = 1 - _to
		_pause_left = PAUSE
		velocity = Vector3.ZERO
		return
	rotation.y = atan2(-flat.x, -flat.z)
	velocity = flat.normalized() * SPEED
	velocity.y = -1.0
	move_and_slide()


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""
