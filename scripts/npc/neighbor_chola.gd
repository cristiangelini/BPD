class_name NeighborChola
extends CharacterBody3D

## Doña Chola, the innocent neighbor of the wrong house (docs/diseno/casa-equivocada.md, step 2): she watches her soap
## opera in the living, knows nothing and is delighted to have visitors. But the cops came in without a reason, so her
## complaint rises twice as fast as the grandpa's (what she sees break, being pushed, a door rammed) and at 100 she
## calls her lawyer. A cop who holds E by her for APOLOGY_TIME says sorry: the complaint drops APOLOGY, once per cop,
## and then she offers mate; whoever takes it (E) hears a bit of gossip about the neighbor (the true story's clue,
## set by the case). Every number here is (propuesta).

signal complaint_changed(value: float)
signal lawyer_called
signal gossiped(text: String)

const MAX_COMPLAINT := 100.0
const SAW_BREAK := 20.0
const STRUCK := 30.0
const DOOR_BROKEN := 10.0
const STRUCK_COOLDOWN := 1.0
const STRUCK_SPEED := 2.0
const DECAY_EVERY := 5.0
const SIGHT_RANGE := 8.0
const EYE := 1.3
const APOLOGY_TIME := 3.0
const APOLOGY := 20.0
## Walking further than this from her while saying sorry stops it.
const REACH := 2.5
const TALK_RANGE := 6.0
const LINES := ["CHOLA_LINE_1", "CHOLA_LINE_2", "CHOLA_LINE_3", "CHOLA_LINE_4"]
const LINE_EVERY := 8.0

var complaint := 0.0
var has_called_lawyer := false
## What she tells over a mate; empty until the case gives her the story's gossip.
var gossip := ""
## The cops who already said sorry, and those who already took the mate.
var apologized: Array[Cop] = []
var mate_taken: Array[Cop] = []
## The cop saying sorry right now, and how long they've been at it.
var apologizing: Cop
var _apology := 0.0
var _quiet := 0.0
var _since_struck := STRUCK_COOLDOWN
var _since_line := 0.0
var _line := 0

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	add_to_group("cholas")
	$Bump.body_entered.connect(_on_bump)
	_bubble.hide()


func prompt_key(cop: Cop) -> String:
	if apologizing:
		return ""
	if not apologized.has(cop):
		return "PROMPT_APOLOGIZE"
	return "PROMPT_TAKE_MATE" if not mate_taken.has(cop) else ""


## E: a cop who hasn't said sorry starts (and has to hold E); one who has takes the mate.
func use(cop: Cop) -> void:
	if apologizing:
		return
	if not apologized.has(cop):
		apologizing = cop
		cop.turning = self
		_apology = 0.0
		_say("CHOLA_LISTENING", APOLOGY_TIME)
		return
	if mate_taken.has(cop):
		return
	mate_taken.append(cop)
	if gossip == "":
		_say("CHOLA_NO_GOSSIP", 5.0)
		return
	_say(gossip, 6.0)
	gossiped.emit(gossip)


## E let go (or walked off) before the apology was done.
func end_turn(cop: Cop) -> void:
	if apologizing != cop:
		return
	apologizing = null
	if is_instance_valid(cop) and cop.turning == self:
		cop.turning = null


func _physics_process(delta: float) -> void:
	_since_struck += delta
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	if apologizing:
		_apologize(delta)
		return
	var cop := _nearest_cop(TALK_RANGE)
	if cop:
		_face(cop.global_position)
	_since_line += delta
	if cop and _since_line >= LINE_EVERY:
		_say(LINES[_line % LINES.size()])
		_line += 1


func _apologize(delta: float) -> void:
	var cop := apologizing
	if not is_instance_valid(cop) or cop.turning != self or cop.global_position.distance_to(global_position) > REACH:
		end_turn(cop)
		return
	_face(cop.global_position)
	_apology += delta
	if _apology < APOLOGY_TIME:
		return
	end_turn(cop)
	apologized.append(cop)
	_set_complaint(complaint - APOLOGY)
	_say("CHOLA_FORGIVEN", 5.0)


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
	_say("CHOLA_HURT")
	return true


## A door of her house came down with the ram: she hears it from anywhere.
func door_broken() -> void:
	_raise(DOOR_BROKEN)
	_say("CHOLA_DOOR")


## Something broke at `at`: it counts if she can see it.
func saw(at: Vector3, points := SAW_BREAK) -> bool:
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
	_say("CHOLA_SAW")
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
		_say("CHOLA_LAWYER")
		lawyer_called.emit()


func _on_bump(body: Node3D) -> void:
	var speed := 0.0
	if body is Cop:
		speed = (body as Cop).velocity.length()
	elif body is RigidBody3D:
		speed = (body as RigidBody3D).linear_velocity.length()
	if speed > STRUCK_SPEED:
		struck()


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _say(key: String, seconds := 3.0) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	var said_key := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said_key:
			_bubble.hide())
