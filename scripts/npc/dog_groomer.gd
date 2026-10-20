class_name DogGroomer
extends CharacterBody3D

## Ramiro, the dog groomer of "Pelito Feliz" (docs/diseno/peluqueria.md, "El peluquero y los perros"). He cuts dogs
## all the time and doesn't leave his table. Like Marta he fills the complaint meter (denuncia) and calls his lawyer at
## 100, and lets something slip when asked (R). His weak spot: a cop who sits in the waiting armchair with a dog in
## arms gets the dog's whole life story, and while he tells it he doesn't watch the salon.
## He is innocent: he can't be knocked out or arrested. Every number here is (propuesta).

signal complaint_changed(value: float)
signal lawyer_called
## A cop pushed him.
signal hurt
## He let slip where something is (asked with R): the line, already translated.
signal slipped(text: String)

const MAX_COMPLAINT := 100.0
const STRUCK := 15.0
const DOOR_BROKEN := 5.0
## Seeing a shampoo bottle or a collar broken.
const SAW_BREAK := 10.0
## A dog barks because a cop bumped into it or dropped it hard: he hears it from anywhere in the salon.
const DOG_BARKED := 5.0
## Each question (R) raises the complaint; the first ASKS get a slip, then he won't answer.
const ASKED := 5.0
## A cop lifted the towel off one of his human customers (human salon story).
const UNMASKED := 10.0
const ASKS := 2
const ASK_COOLDOWN := 3.0
const SIGHT_RANGE := 8.0
const EYE := 1.4
## The meter drops one point every DECAY_EVERY seconds while nothing happens.
const DECAY_EVERY := 5.0
const STRUCK_COOLDOWN := 1.0
const STRUCK_SPEED := 2.0
## The dog's life story: how long it lasts, how long before he tells another, and the lines it goes through.
const DOG_STORY := 15.0
const DOG_STORY_COOLDOWN := 30.0
const DOG_STORY_LINES := ["GROOMER_DOG_STORY_1", "GROOMER_DOG_STORY_2", "GROOMER_DOG_STORY_3"]
const TALK_RANGE := 6.0
const LINES := ["GROOMER_LINE_1", "GROOMER_LINE_2", "GROOMER_LINE_3", "GROOMER_LINE_4"]
const LINE_EVERY := 7.0

var complaint := 0.0
var has_called_lawyer := false
## What he lets slip when asked, in order (each story fills it from the case seed).
var slips: Array[String] = []
var asked := 0
## The cop in the armchair hearing the dog's story, if any.
var listener: Cop
var _story_left := 0.0
var _story_wait := 0.0
var _story_line := 0
var _ask_wait := 0.0
var _quiet := 0.0
var _since_struck := STRUCK_COOLDOWN
var _since_line := 0.0
var _line := 0

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	$Bump.body_entered.connect(_on_bump)
	_bubble.hide()


## R on him: a question. He lets slip where something is hidden, but only the first ASKS times.
func ask(_cop: Cop) -> bool:
	if _ask_wait > 0.0:
		return false
	if slips.is_empty():
		_say("GROOMER_NOTHING")
		return false
	if asked >= ASKS or asked >= slips.size():
		_say("GROOMER_OFFENDED")
		return false
	_ask_wait = ASK_COOLDOWN
	_raise(ASKED)
	var line := slips[asked]
	asked += 1
	_say(line, 5.0)
	slipped.emit(line)
	return true


## Starts the dog's life story for `cop`, sitting in the armchair with a dog. False if he's already telling one or
## told one too recently.
func start_dog_story(cop: Cop) -> bool:
	if listener:
		return false
	if _story_wait > 0.0:
		_say("GROOMER_STORY_TIRED")
		return false
	listener = cop
	_story_left = DOG_STORY
	_story_line = 0
	_say(DOG_STORY_LINES[0], DOG_STORY / DOG_STORY_LINES.size())
	return true


func end_dog_story() -> void:
	if not listener:
		return
	listener = null
	_story_wait = DOG_STORY_COOLDOWN
	_bubble.hide()


func is_telling_story() -> bool:
	return listener != null


func _physics_process(delta: float) -> void:
	_since_struck += delta
	_ask_wait -= delta
	_story_wait -= delta
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	if listener:
		_tell(delta)
		return
	var cop := _nearest_cop(TALK_RANGE)
	if cop:
		_face(cop.global_position)
	_since_line += delta
	if cop and _since_line >= LINE_EVERY:
		_say(LINES[_line % LINES.size()])
		_line += 1


## Faces the listener and goes on with the story, one line per part, until it runs out.
func _tell(delta: float) -> void:
	_face(listener.global_position)
	_story_left -= delta
	if _story_left <= 0.0:
		end_dog_story()
		return
	var part := DOG_STORY / DOG_STORY_LINES.size()
	var line := mini(int((DOG_STORY - _story_left) / part), DOG_STORY_LINES.size() - 1)
	if line != _story_line:
		_story_line = line
		_say(DOG_STORY_LINES[line], part)


func _face(at: Vector3) -> void:
	var to := at - global_position
	to.y = 0.0
	if to.length() > 0.1:
		look_at(global_position + to, Vector3.UP, true)


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
	_say("GROOMER_HURT")
	hurt.emit()
	return true


## A door came down with the ram: he hears it from anywhere in the salon, story or not.
func door_broken() -> void:
	_raise(DOOR_BROKEN)
	_say("GROOMER_DOOR")


## One of his dogs barked: a cop bumped into it or threw it.
func dog_barked(_at: Vector3) -> void:
	_raise(DOG_BARKED)
	_say("GROOMER_DOG")


## A human customer walks in (human salon story): he throws a towel over their head and swears it's a dog.
func cover_customer() -> void:
	_say("GROOMER_TOWEL")


## A cop lifted the towel off one of them: he heard it from anywhere, and it counts.
func customer_unmasked() -> void:
	_raise(UNMASKED)
	_say("GROOMER_UNMASKED")


## Something happened at `at` (a bottle broke): it counts if he can see it, and not while he tells the dog's story.
func saw(at: Vector3, points: float) -> bool:
	if listener:
		return false
	var eye := global_position + Vector3.UP * EYE
	if eye.distance_to(at) > SIGHT_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(eye, at, 1)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	# What blocks the view only counts if it's something in between, not the thing he's looking at.
	if not hit.is_empty() and (hit.position as Vector3).distance_to(at) > 0.4:
		return false
	_raise(points)
	_say("GROOMER_SAW")
	return true


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
		_say("GROOMER_LAWYER")
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
