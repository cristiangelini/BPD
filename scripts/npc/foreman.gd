class_name Foreman
extends CharacterBody3D

## Fermín, the foreman of the doll factory "Sonrisas" (docs/diseno/fabrica.md, "El capataz"). He walks up and down
## the factory floor along the belt. Like Tobías he fills the complaint meter (denuncia) and calls his lawyer at 100,
## and lets something slip when asked (R). The belt doesn't stop: if a cop presses the red button he blows his
## whistle, the complaint goes up and he walks to the button to start it again. His weak spot: when something jams
## the belt he goes to clear it and spends UNJAM_TIME seconds bent over the machine, seeing nothing.
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
## Seeing a porcelain doll or a plaster mold broken.
const SAW_BREAK := 10.0
## A cop stopped his belt.
const BELT_STOPPED := 15.0
const ASKED := 5.0
const ASKS := 2
const CUFFED := 15.0
const ASK_COOLDOWN := 3.0
const SIGHT_RANGE := 16.0
const EYE := 1.4
const DECAY_EVERY := 5.0
const STRUCK_COOLDOWN := 1.0
const STRUCK_SPEED := 2.0
const WALK_SPEED := 1.4
## Close enough to a point of his walk to head to the next one.
const REACH := 0.25
## He waits a little at each end of his walk, looking at the belt.
const END_PAUSE := 2.0
## Clearing a jam: how long, and what he mutters meanwhile.
const UNJAM_TIME := 15.0
const FIX_LINES := ["FOREMAN_FIX_1", "FOREMAN_FIX_2", "FOREMAN_FIX_3"]
const TALK_RANGE := 6.0
const LINES := ["FOREMAN_LINE_1", "FOREMAN_LINE_2", "FOREMAN_LINE_3", "FOREMAN_LINE_4"]
const LINE_EVERY := 7.0

var complaint := 0.0
var has_called_lawyer := false
var slips: Array[String] = []
var asked := 0
## His walk along the belt, in the factory's space, back and forth (set by the factory before he's added).
var route: Array[Vector3] = []
## Where he stands to press the red button, and where to clear each machine (id -> spot).
var button_spot := Vector3.ZERO
var machine_spots := {}
var belt: ConveyorBelt
## How long clearing a jam takes him (UNJAM_TIME; tests shorten it).
var unjam_time := UNJAM_TIME
## The points he's walking to, in order; empty while he patrols.
var _path: Array[Vector3] = []
## What he does when the path ends: "", "button" or "jam".
var _errand := ""
var _index := 1
var _step := 1
var _pause := 0.0
var _fix_left := 0.0
var _fix_line := 0
var _fix_at := Vector3.ZERO
var _ask_wait := 0.0
var _quiet := 0.0
var _since_struck := STRUCK_COOLDOWN
var _since_line := 0.0
var _line := 0
var _cuffed_left := 0.0

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	$Bump.body_entered.connect(_on_bump)
	_bubble.hide()
	if belt:
		belt.stopped.connect(_on_belt_stopped)
		belt.started.connect(_on_belt_started)
		belt.jammed.connect(_on_belt_jammed)


## Puts him at a point of his walk, heading on to the next one.
func start_at(index: int) -> void:
	global_position = route[index]
	_step = 1 if index + 1 < route.size() else -1
	_index = index + _step
	_path.clear()
	_errand = ""


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	return escort.prompt_key(cop) if escort and escort.handles_use() else ""


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)


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
		_say("FOREMAN_NOTHING")
		return false
	if asked >= ASKS or asked >= slips.size():
		_say("FOREMAN_OFFENDED")
		return false
	_ask_wait = ASK_COOLDOWN
	_raise(ASKED)
	var line := slips[asked]
	asked += 1
	_say(line, 5.0)
	slipped.emit(line)
	return true


func is_fixing() -> bool:
	return _fix_left > 0.0


## What he's busy with: "" (walking his round), "button" or "jam" (on his way or at it).
func errand() -> String:
	return "jam" if is_fixing() else _errand


func _physics_process(delta: float) -> void:
	_since_struck += delta
	_ask_wait -= delta
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	var walk := Vector3.ZERO
	if is_fixing():
		_fix(delta)
	elif not is_cuffed():
		walk = _walk(delta)
	velocity.x = walk.x
	velocity.z = walk.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	if walk != Vector3.ZERO:
		_face(global_position + walk)
	_since_line += delta
	var cop := _nearest_cop(TALK_RANGE)
	if cop and _since_line >= LINE_EVERY and _errand == "" and not is_fixing():
		_say(LINES[_line % LINES.size()])
		_line += 1


## The velocity of his next step: along his errand's path, or back and forth along the belt.
func _walk(delta: float) -> Vector3:
	var target: Vector3
	if not _path.is_empty():
		target = _path[0]
	else:
		if route.size() < 2:
			return Vector3.ZERO
		if _pause > 0.0:
			_pause -= delta
			return Vector3.ZERO
		target = route[_index]
	var to := target - global_position
	to.y = 0.0
	if to.length() > REACH:
		return to.normalized() * WALK_SPEED
	if not _path.is_empty():
		_path.pop_front()
		if _path.is_empty():
			_arrive()
		return Vector3.ZERO
	if _index + _step < 0 or _index + _step >= route.size():
		_step = -_step
		_pause = END_PAUSE
	_index += _step
	return Vector3.ZERO


## Walks along his route to the point nearest `spot`, then to the spot.
func _go(spot: Vector3, errand_name: String) -> void:
	var goal := _nearest_index(spot)
	_path.clear()
	# He's between the point he left and the one ahead: he sets off from whichever is on the way.
	var behind := clampi(_index - _step, 0, route.size() - 1)
	var i := behind if absi(goal - behind) < absi(goal - _index) else _index
	_path.append(route[i])
	while i != goal:
		i += 1 if goal > i else -1
		_path.append(route[i])
	_path.append(spot)
	_errand = errand_name
	_index = goal


func _arrive() -> void:
	var done := _errand
	_errand = ""
	if done == "button":
		if belt and not belt.running:
			belt.start()
			_say("FOREMAN_BELT_ON")
		_back_to_route()
	elif done == "jam":
		if belt and belt.jammed_by != null:
			_fix_left = unjam_time
			_fix_line = 0
			_say(FIX_LINES[0], unjam_time / FIX_LINES.size())
		else:
			_back_to_route()


func _back_to_route() -> void:
	_path = [route[_index]]


## Bent over the jammed machine, one line per part, until it moves again.
func _fix(delta: float) -> void:
	_face(_fix_at)
	_fix_left -= delta
	if _fix_left <= 0.0:
		_fix_left = 0.0
		if belt:
			belt.unjam()
		_say("FOREMAN_FIX_DONE")
		_back_to_route()
		return
	var part := unjam_time / FIX_LINES.size()
	var line := mini(int((unjam_time - _fix_left) / part), FIX_LINES.size() - 1)
	if line != _fix_line:
		_fix_line = line
		_say(FIX_LINES[line], part)


func _nearest_index(spot: Vector3) -> int:
	var best := 0
	for i in route.size():
		if route[i].distance_to(spot) < route[best].distance_to(spot):
			best = i
	return best


func _on_belt_stopped(_cop: Cop) -> void:
	_raise(BELT_STOPPED)
	_say("FOREMAN_BELT_STOPPED")
	if not is_fixing():
		_go(button_spot, "button")


func _on_belt_started() -> void:
	if _errand == "button":
		_errand = ""
		_back_to_route()


func _on_belt_jammed(_body: Node3D) -> void:
	var spot: Vector3 = machine_spots.get(belt.jammed_at, button_spot)
	_fix_at = belt.machine_at(belt.jammed_at)
	_go(spot, "jam")


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


func struck() -> bool:
	if _since_struck < STRUCK_COOLDOWN:
		return false
	_since_struck = 0.0
	_raise(STRUCK)
	_say("FOREMAN_HURT")
	hurt.emit()
	return true


func door_broken() -> void:
	_raise(DOOR_BROKEN)
	_say("FOREMAN_DOOR")


func saw(at: Vector3, points: float) -> bool:
	if not can_see(at):
		return false
	_raise(points)
	_say("FOREMAN_SAW")
	return true


## Whether `at` is in his sight: close enough, nothing in between, and he isn't bent over a machine.
func can_see(at: Vector3) -> bool:
	if is_fixing():
		return false
	var eye := global_position + Vector3.UP * EYE
	if eye.distance_to(at) > SIGHT_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(eye, at, 1)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
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
		_say("FOREMAN_LAWYER")
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
