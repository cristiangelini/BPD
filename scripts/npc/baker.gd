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

const MAX_COMPLAINT := 100.0
const STRUCK := 15.0
const DOOR_BROKEN := 5.0
## Each customer that runs away without paying.
const CUSTOMER_FLED := 5.0
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


func is_serving() -> bool:
	return not queue.is_empty()


func _physics_process(delta: float) -> void:
	_since_struck += delta
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	_walk_to(till_post if is_serving() else door_post, delta)
	if is_serving() and global_position.distance_to(till_post) < 0.3:
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
