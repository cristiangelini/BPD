class_name Baker
extends CharacterBody3D

## Marta, the baker (docs/diseno/panaderia.md, "La panadera"). She never stops serving: while a customer waits at
## the counter she works the till, and otherwise she stands in front of the bakehouse door ("Solo personal").
## Like the grandpa she fills the complaint meter (denuncia) and calls her lawyer at 100, and every so often she
## offers the nearest cop "una muestrita": eating it (E) keeps that cop's hands busy for a while and calms her down.
## She is innocent: she can't be knocked out or arrested. Every number here is (propuesta).

signal complaint_changed(value: float)
signal lawyer_called
## A cop pushed her: it scares the customers.
signal hurt
## She let slip where something is (asked with R): the line, already translated.
signal slipped(text: String)

const MAX_COMPLAINT := 100.0
const STRUCK := 15.0
const DOOR_BROKEN := 5.0
## Each customer that runs away without paying.
const CUSTOMER_FLED := 5.0
## Seeing a loaf or a cake broken, and seeing someone open her till.
const SAW_BREAK := 10.0
const SAW_TILL := 10.0
## Each question (R) raises the complaint; the first ASKS get a slip, then she won't answer.
const ASKED := 5.0
## A camera flash in her face, and being cuffed (herramientas.md, propuesta).
const PHOTOGRAPHED := 3.0
const CUFFED := 15.0
const ASKS := 2
const ASK_COOLDOWN := 3.0
## Every phone call she takes (the angry couples of the wedding story) makes her nervous.
const CALL_NERVES := 3.0
const CALL_LINES := ["BAKER_PHONE_1", "BAKER_PHONE_2", "BAKER_PHONE_3"]
const SIGHT_RANGE := 8.0
const EYE := 1.4
## The meter drops one point every DECAY_EVERY seconds while nothing happens.
const DECAY_EVERY := 5.0
const STRUCK_COOLDOWN := 1.0
const STRUCK_SPEED := 2.0

const SPEED := 1.6
const SERVE_TIME := 4.0
## The sample: offered to a cop this close, every SAMPLE_EVERY seconds, for SAMPLE_OFFER seconds.
const SAMPLE_EVERY := 20.0
const SAMPLE_OFFER := 6.0
const SAMPLE_RANGE := 3.0
const SAMPLE_EATING := 3.0
const SAMPLE_CALM := 10.0
const TALK_RANGE := 6.0
const LINES := ["BAKER_LINE_1", "BAKER_LINE_2", "BAKER_LINE_3", "BAKER_LINE_4"]
const LINE_EVERY := 7.0

## Where she works the till and where she guards the bakehouse door, in the bakery's space (set by the bakery).
var till_post: Vector3
var door_post: Vector3
## The customers waiting at the counter, first come first served (the bakery keeps it).
var queue: Array[BakeryCustomer] = []
var complaint := 0.0
var has_called_lawyer := false
var offering := false
## What she lets slip when asked, in order (the bakery fills it from the case seed).
var slips: Array[String] = []
var asked := 0
## Where she answers the phone, when the story has one (set by its rig).
var call_post: Vector3
var _call_left := 0.0
var _calls := 0
var _ask_wait := 0.0
## Cuffed by a cop: she stays where she is until it runs out.
var _cuffed_left := 0.0
var _serve_left := SERVE_TIME
var _sample_wait := SAMPLE_EVERY
var _offer_left := 0.0
var _quiet := 0.0
var _since_struck := STRUCK_COOLDOWN
var _since_line := 0.0
var _line := 0

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	$Bump.body_entered.connect(_on_bump)
	_bubble.hide()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SAMPLE" if offering else ""


## E on her: takes the sample if she is offering one.
func use(cop: Cop) -> void:
	if not offering:
		_say("BAKER_BUSY")
		return
	offering = false
	_sample_wait = SAMPLE_EVERY
	cop.eat(SAMPLE_EATING)
	_set_complaint(complaint - SAMPLE_CALM)
	_say("BAKER_THANKS")


## R on her: a question. She lets slip where something is hidden, but only the first ASKS times.
func ask(_cop: Cop) -> bool:
	if _ask_wait > 0.0:
		return false
	if asked >= ASKS or asked >= slips.size():
		_say("BAKER_OFFENDED")
		return false
	_ask_wait = ASK_COOLDOWN
	_raise(ASKED)
	var line := slips[asked]
	asked += 1
	_say(line, 5.0)
	slipped.emit(line)
	return true


## She goes to the phone and talks for `seconds`: nobody guards the bakehouse door meanwhile.
func take_call(seconds: float) -> void:
	_call_left = seconds
	_raise(CALL_NERVES)
	_say(CALL_LINES[_calls % CALL_LINES.size()], seconds)
	_calls += 1


func is_on_call() -> bool:
	return _call_left > 0.0


func is_serving() -> bool:
	return not queue.is_empty()


func _physics_process(delta: float) -> void:
	_since_struck += delta
	_ask_wait -= delta
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	if is_cuffed():
		_walk_to(global_position, delta)
	elif is_on_call():
		_call_left -= delta
		_walk_to(call_post, delta)
	else:
		_walk_to(till_post if is_serving() else door_post, delta)
	if is_serving() and not is_on_call() and global_position.distance_to(till_post) < 0.3:
		_serve_left -= delta
		if _serve_left <= 0.0:
			_serve_left = SERVE_TIME
			queue.pop_front().served()
	var cop := _nearest_cop(TALK_RANGE)
	if cop:
		var to := cop.global_position - global_position
		to.y = 0.0
		if to.length() > 0.1 and velocity.length() < 0.1:
			look_at(global_position + to, Vector3.UP, true)
	_sample(delta)
	_since_line += delta
	if cop and not offering and _since_line >= LINE_EVERY:
		_say(LINES[_line % LINES.size()])
		_line += 1


func _walk_to(target: Vector3, delta: float) -> void:
	var wish := target - global_position
	wish.y = 0.0
	if wish.length() > 0.1:
		wish = wish.normalized() * SPEED
		look_at(global_position + wish, Vector3.UP, true)
	else:
		wish = Vector3.ZERO
	velocity.x = wish.x
	velocity.z = wish.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()


func _sample(delta: float) -> void:
	if offering:
		_offer_left -= delta
		if _offer_left <= 0.0:
			offering = false
			_sample_wait = SAMPLE_EVERY
			_bubble.hide()
		return
	_sample_wait -= delta
	if _sample_wait <= 0.0 and not is_serving() and _nearest_cop(SAMPLE_RANGE):
		offering = true
		_offer_left = SAMPLE_OFFER
		_say("BAKER_SAMPLE", SAMPLE_OFFER)


func _nearest_cop(within: float) -> Cop:
	var best: Cop
	var best_distance := within
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var d := global_position.distance_to(cop.global_position)
		if d < best_distance:
			best = cop
			best_distance = d
	return best


## Pushed by a cop or hit by something thrown.
func struck() -> bool:
	if _since_struck < STRUCK_COOLDOWN:
		return false
	_since_struck = 0.0
	_raise(STRUCK)
	_say("BAKER_HURT")
	hurt.emit()
	return true


## A door came down with the ram: she hears it from anywhere in the bakery.
func door_broken() -> void:
	_raise(DOOR_BROKEN)
	_say("BAKER_DOOR")


## Something happened at `at` (a loaf split, the till opened): it counts if she can see it.
func saw(at: Vector3, points: float) -> bool:
	var eye := global_position + Vector3.UP * EYE
	if eye.distance_to(at) > SIGHT_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(eye, at, 1)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	# What blocks the view only counts if it's something in between, not the thing she's looking at.
	if not hit.is_empty() and (hit.position as Vector3).distance_to(at) > 0.4:
		return false
	_raise(points)
	_say("BAKER_SAW")
	return true


## A cop took her photo with the flash.
func photographed(_cop: Cop) -> void:
	_raise(PHOTOGRAPHED)
	_say("NPC_NO_PHOTOS")


## A cop cuffed her for `seconds`: she stays put, and complains.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	_raise(CUFFED)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func customer_fled() -> void:
	_raise(CUSTOMER_FLED)


func _raise(points: float) -> void:
	_quiet = 0.0
	_set_complaint(complaint + points)


func _set_complaint(value: float) -> void:
	var clamped := clampf(value, 0.0, MAX_COMPLAINT)
	if clamped == complaint:
		return
	complaint = clamped
	complaint_changed.emit(complaint)
	if complaint >= MAX_COMPLAINT and not has_called_lawyer:
		has_called_lawyer = true
		_say("BAKER_LAWYER")
		lawyer_called.emit()


func _on_bump(body: Node3D) -> void:
	var speed := 0.0
	if body is Cop:
		speed = (body as Cop).velocity.length()
	elif body is RigidBody3D:
		speed = (body as RigidBody3D).linear_velocity.length()
	if speed > STRUCK_SPEED:
		struck()


func _say(key: String, seconds := 3.0) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
