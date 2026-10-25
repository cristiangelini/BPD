class_name HardwareMan
extends CharacterBody3D

## Tobías, the hardware man of "El Tornillo Flojo" (docs/diseno/ferreteria.md, "El ferretero"). He serves behind his
## counter and doesn't leave it. Like Marta and Ramiro he fills the complaint meter (denuncia) and calls his lawyer at
## 100, and lets something slip when asked (R). His weak spot: a cop who rings the counter bell asks for "a 3/8 fine
## thread screw", and he spends SCREW_SEARCH seconds with his back turned, looking for it in the screw wall.
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
## Seeing a paint can or a screw jar broken.
const SAW_BREAK := 10.0
## Each question (R) raises the complaint; the first ASKS get a slip, then he won't answer.
const ASKED := 5.0
const ASKS := 2
## Being cuffed (herramientas.md): he can be taken away to be interrogated (OwnerEscort).
const CUFFED := 15.0
const ASK_COOLDOWN := 3.0
const SIGHT_RANGE := 13.0
const EYE := 1.4
## The meter drops one point every DECAY_EVERY seconds while nothing happens.
const DECAY_EVERY := 5.0
const STRUCK_COOLDOWN := 1.0
const STRUCK_SPEED := 2.0
## Looking for the screw: how long, how long before he looks for another, and what he mutters meanwhile.
const SCREW_SEARCH := 15.0
const SCREW_COOLDOWN := 30.0
const SCREW_LINES := ["HARDWARE_SCREW_1", "HARDWARE_SCREW_2", "HARDWARE_SCREW_3"]
const TALK_RANGE := 6.0
const LINES := ["HARDWARE_LINE_1", "HARDWARE_LINE_2", "HARDWARE_LINE_3", "HARDWARE_LINE_4"]
const LINE_EVERY := 7.0

var complaint := 0.0
var has_called_lawyer := false
## What he lets slip when asked, in order (each story fills it from the case seed).
var slips: Array[String] = []
var asked := 0
## Where he looks while searching for the screw (the screw wall), in the store's space; set by the store.
var screw_wall := Vector3.ZERO
var _search_left := 0.0
var _search_wait := 0.0
var _search_line := 0
var _ask_wait := 0.0
var _quiet := 0.0
var _since_struck := STRUCK_COOLDOWN
var _since_line := 0.0
var _line := 0
## Cuffed by a cop: he stays at his counter, not serving, until it runs out.
var _cuffed_left := 0.0

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	$Bump.body_entered.connect(_on_bump)
	_bubble.hide()


## E on him only does something while he's cuffed: a cop takes him away (OwnerEscort).
func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	return escort.prompt_key(cop) if escort and escort.handles_use() else ""


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)


## A cop cuffed him for `seconds`, and he complains.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	_raise(CUFFED)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## R on him: a question. He lets slip where something is hidden, but only the first ASKS times.
func ask(_cop: Cop) -> bool:
	if _ask_wait > 0.0:
		return false
	if slips.is_empty():
		_say("HARDWARE_NOTHING")
		return false
	if asked >= ASKS or asked >= slips.size():
		_say("HARDWARE_OFFENDED")
		return false
	_ask_wait = ASK_COOLDOWN
	_raise(ASKED)
	var line := slips[asked]
	asked += 1
	_say(line, 5.0)
	slipped.emit(line)
	return true


## A cop asked for the 3/8 screw: he turns to the screw wall and looks for it. False if he's already looking, is
## cuffed, or looked too recently.
func look_for_screw() -> bool:
	if is_searching() or is_cuffed():
		return false
	if _search_wait > 0.0:
		_say("HARDWARE_SCREW_TIRED")
		return false
	_search_left = SCREW_SEARCH
	_search_line = 0
	_say(SCREW_LINES[0], SCREW_SEARCH / SCREW_LINES.size())
	return true


func is_searching() -> bool:
	return _search_left > 0.0


func _physics_process(delta: float) -> void:
	_since_struck += delta
	_ask_wait -= delta
	_search_wait -= delta
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	if is_searching():
		_search(delta)
		return
	var cop := _nearest_cop(TALK_RANGE)
	if cop:
		_face(cop.global_position)
	_since_line += delta
	if cop and _since_line >= LINE_EVERY:
		_say(LINES[_line % LINES.size()])
		_line += 1


## Back to the shop, rummaging in the screw wall, one line per part, until he gives up: there are none left.
func _search(delta: float) -> void:
	_face(screw_wall)
	_search_left -= delta
	if _search_left <= 0.0:
		_search_left = 0.0
		_search_wait = SCREW_COOLDOWN
		_say("HARDWARE_SCREW_DONE")
		return
	var part := SCREW_SEARCH / SCREW_LINES.size()
	var line := mini(int((SCREW_SEARCH - _search_left) / part), SCREW_LINES.size() - 1)
	if line != _search_line:
		_search_line = line
		_say(SCREW_LINES[line], part)


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


## Pushed by a cop or hit by something thrown: it also ends his search.
func struck() -> bool:
	if _since_struck < STRUCK_COOLDOWN:
		return false
	_since_struck = 0.0
	_search_left = 0.0
	_raise(STRUCK)
	_say("HARDWARE_HURT")
	hurt.emit()
	return true


## A door came down with the ram: he hears it from anywhere in the store, searching or not.
func door_broken() -> void:
	_raise(DOOR_BROKEN)
	_say("HARDWARE_DOOR")


## Something happened at `at` (a can broke): it counts if he can see it, and not while he looks for the screw.
func saw(at: Vector3, points: float) -> bool:
	if not can_see(at):
		return false
	_raise(points)
	_say("HARDWARE_SAW")
	return true


## Whether `at` is in his sight: close enough, nothing in between, and he isn't busy with the screw wall.
func can_see(at: Vector3) -> bool:
	if is_searching():
		return false
	var eye := global_position + Vector3.UP * EYE
	if eye.distance_to(at) > SIGHT_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(eye, at, 1)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	# What blocks the view only counts if it's something in between, not the thing he's looking at.
	return hit.is_empty() or (hit.position as Vector3).distance_to(at) <= 0.4


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
		_say("HARDWARE_LAWYER")
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
