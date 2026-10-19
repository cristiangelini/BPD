class_name Grandpa
extends CharacterBody3D

## The grandpa of case 1.1 (docs/diseno/allanamiento.md, "El abuelo"). He shuffles after the nearest cop, complaining,
## and fills the complaint meter (denuncia) when he sees things break or gets pushed. At 100 he calls his lawyer.
## He is innocent (decision 5): he can't be knocked out or arrested.

signal complaint_changed(value: float)
signal lawyer_called

const MAX_COMPLAINT := 100.0
## Meter points (proposal).
const SAW_BREAK := 10.0
const STRUCK := 15.0
const DOOR_BROKEN := 5.0
const SIGHT_RANGE := 8.0
## The meter drops one point every DECAY_EVERY seconds while nothing happens.
const DECAY_EVERY := 5.0
## A hit within this time of the last one doesn't count again (one shove, one complaint).
const STRUCK_COOLDOWN := 1.0
## Something hitting him faster than this counts as a hit (m/s).
const STRUCK_SPEED := 2.0

const SPEED := 1.4
const FOLLOW_RANGE := 15.0
const KEEP_AWAY := 1.6
const EYE := 1.1
const LINES := ["GRANDPA_LINE_1", "GRANDPA_LINE_2", "GRANDPA_LINE_3", "GRANDPA_LINE_4", "GRANDPA_LINE_5", "GRANDPA_LINE_6"]
const LINE_EVERY := 6.0
## Holding E in front of him: he tells a long story and stands still (proposal from the design).
const STORY_MAX := 20.0
const STORY_COOLDOWN := 30.0

var complaint := 0.0
var has_called_lawyer := false
var _quiet := 0.0
var _since_struck := STRUCK_COOLDOWN
var _since_line := 0.0
var _line := 0
## The cop he is telling a story to, if any.
var listener: Cop
var _story_left := 0.0
var _story_wait := 0.0

@onready var _agent: NavigationAgent3D = $Agent
@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	$Bump.body_entered.connect(_on_bump)
	_bubble.hide()


## E on him starts a story; the cop has to keep holding E to keep him talking.
func prompt_key(_cop: Cop) -> String:
	return "" if listener else "PROMPT_GRANDPA"


func use(cop: Cop) -> void:
	start_story(cop)


func start_story(cop: Cop) -> bool:
	if listener:
		return false
	if _story_wait > 0.0:
		_say("GRANDPA_STORY_TIRED")
		return false
	listener = cop
	cop.listening_to = self
	_story_left = STORY_MAX
	_say("GRANDPA_STORY", STORY_MAX)
	return true


func end_story() -> void:
	if not listener:
		return
	listener.listening_to = null
	listener = null
	_story_wait = STORY_COOLDOWN
	_bubble.hide()


func is_telling_story() -> bool:
	return listener != null


func _physics_process(delta: float) -> void:
	_story_wait = maxf(_story_wait - delta, 0.0)
	if listener:
		_story_left -= delta
		if _story_left <= 0.0:
			end_story()
	_since_struck += delta
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	var cop := nearest_cop()
	var wish := Vector3.ZERO
	if cop and not listener and global_position.distance_to(cop.global_position) > KEEP_AWAY:
		_agent.target_position = cop.global_position
		if not _agent.is_navigation_finished():
			wish = _agent.get_next_path_position() - global_position
			wish.y = 0.0
	if wish.length() > 0.05:
		wish = wish.normalized() * SPEED
		look_at(global_position + wish, Vector3.UP, true)
	velocity.x = wish.x
	velocity.z = wish.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	_talk(delta, cop != null and not listener)


func nearest_cop() -> Cop:
	var best: Cop
	var best_distance := FOLLOW_RANGE
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var d := global_position.distance_to(cop.global_position)
		if d < best_distance:
			best = cop
			best_distance = d
	return best


## An ornament broke at `at`: it counts if he is close and can see it.
func saw_break(at: Vector3) -> bool:
	if not can_see(at):
		return false
	_raise(SAW_BREAK)
	return true


## A door came down (with the ram) near him.
func door_broken(at: Vector3) -> void:
	if global_position.distance_to(at) <= SIGHT_RANGE:
		_raise(DOOR_BROKEN)


## Pushed by a cop, hit by the ram or by something thrown.
func struck() -> bool:
	if _since_struck < STRUCK_COOLDOWN:
		return false
	_since_struck = 0.0
	_raise(STRUCK)
	_say("GRANDPA_HURT")
	return true


func can_see(at: Vector3) -> bool:
	var eye := global_position + Vector3.UP * EYE
	if eye.distance_to(at) > SIGHT_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(eye, at, 1)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


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
		_say("GRANDPA_LAWYER")
		lawyer_called.emit()


func _on_bump(body: Node3D) -> void:
	var speed := 0.0
	if body is Cop:
		speed = (body as Cop).velocity.length()
	elif body is RigidBody3D:
		speed = (body as RigidBody3D).linear_velocity.length()
	if speed > STRUCK_SPEED:
		struck()


func _talk(delta: float, following: bool) -> void:
	_since_line += delta
	if following and _since_line >= LINE_EVERY:
		_say(LINES[_line % LINES.size()])
		_line += 1


func _say(key: String, seconds := 3.0) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
