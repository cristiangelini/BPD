class_name FloorBoss
extends CharacterBody3D

## Mirta, the floor boss of "Seguros Todo Tranquilo" (docs/diseno/seguros.md, "La jefa de piso"). She walks the aisles
## between the cubicles making sure everyone "works". Like Fermín she fills the complaint meter (denuncia) and calls
## her lawyer at 100, and lets something slip when asked (R). Everything goes by form: a pile of papers flying where she
## sees it raises the complaint. Her weak spot: when someone sends 500 copies to the giant printer it jams, and she
## spends FIX_TIME seconds fighting its tray, her back to the office, seeing nothing.
## She is innocent: she can't be knocked out or arrested. Every number here is (propuesta).

signal complaint_changed(value: float)
signal lawyer_called
## A cop pushed her.
signal hurt
## She let slip where something is (asked with R): the line, already translated.
signal slipped(text: String)
## E on them, when the place gives them a use_prompt (Chispita's balloons).
signal used(cop: Cop)

const MAX_COMPLAINT := 100.0
const STRUCK := 15.0
const DOOR_BROKEN := 5.0
## Seeing a monitor or a glass trophy broken.
const SAW_BREAK := 10.0
## Seeing a cop open the reception's till.
const SAW_TILL := 10.0
## Seeing a pile of papers fly.
const SAW_PAPERS := 10.0
const ASKED := 5.0
const ASKS := 2
const CUFFED := 15.0
const ASK_COOLDOWN := 3.0
const SIGHT_RANGE := 14.0
const EYE := 1.4
const DECAY_EVERY := 5.0
const STRUCK_COOLDOWN := 1.0
const STRUCK_SPEED := 2.0
const WALK_SPEED := 1.3
## Close enough to a point of her walk to head to the next one.
const REACH := 0.25
## She waits a little at each end of her walk, looking over the cubicles.
const END_PAUSE := 2.0
## Fighting the jammed printer: how long, and what she mutters meanwhile.
const FIX_TIME := 15.0
const FIX_LINES := ["FIX_1", "FIX_2", "FIX_3"]
const TALK_RANGE := 6.0
const LINES := ["LINE_1", "LINE_2", "LINE_3", "LINE_4"]
const LINE_EVERY := 7.0

## The start of every line of hers (BOSS_LINE_1, ...): another owner on the same body speaks with their own (CHEF).
@export var voice := "BOSS"
var complaint := 0.0
var has_called_lawyer := false
var slips: Array[String] = []
var asked := 0
## Her walk between the cubicles, in the office's space, back and forth (set by the office before she's added).
var route: Array[Vector3] = []
## Where she stands to fight the printer, and the printer itself.
var printer_spot := Vector3.ZERO
var printer: OfficePrinter
## How long fixing the printer takes her (FIX_TIME; tests shorten it).
var fix_time := FIX_TIME
## Where she looks while at it, in the world, if not at the printer (the gym's profe gives his class to the mirror).
var fix_facing := Vector3.INF
## What E on them says, if the place has something for it ("" = nothing, unless they're being escorted).
var use_prompt := ""
## The points she's walking to, in order; empty while she patrols.
var _path: Array[Vector3] = []
var _errand := ""
var _index := 1
var _step := 1
var _pause := 0.0
var _fix_left := 0.0
var _fix_line := 0
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
	if printer:
		printer.jammed.connect(_on_printer_jammed)


## Puts her at a point of her walk, heading on to the next one.
func start_at(index: int) -> void:
	global_position = route[index]
	_step = 1 if index + 1 < route.size() else -1
	_index = index + _step
	_path.clear()
	_errand = ""


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	return escort.prompt_key(cop) if escort and escort.handles_use() else use_prompt


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
	elif use_prompt != "":
		used.emit(cop)


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	_raise(CUFFED)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## R on her: a question. She lets slip where something is hidden, but only the first ASKS times.
func ask(_cop: Cop) -> bool:
	if _ask_wait > 0.0:
		return false
	if slips.is_empty():
		_say(_key("NOTHING"))
		return false
	if asked >= ASKS or asked >= slips.size():
		_say(_key("OFFENDED"))
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


## What she's busy with: "" (walking her round) or "printer" (on her way or at it).
func errand() -> String:
	return "printer" if is_fixing() else _errand


## Online: whether she's fighting the printer and whether it's jammed, for the guests' copies. A guest's printer jams
## with the host's (the button's press runs on every PC) and clears when the host's is clear again.
func net_state() -> Variant:
	return [is_fixing(), printer != null and printer.is_jammed]


func apply_net_state(state: Variant) -> void:
	_fix_left = fix_time if state[0] else 0.0
	if not state[1] and printer and printer.is_jammed:
		printer.fix()


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
		_say(_key(LINES[_line % LINES.size()]))
		_line += 1


## The velocity of her next step: along her errand's path, or back and forth along her round.
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


## Walks along her route to the point nearest `spot`, then to the spot.
func _go(spot: Vector3, errand_name: String) -> void:
	var goal := _nearest_index(spot)
	_path.clear()
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
	if done == "printer" and printer and printer.is_jammed:
		_fix_left = fix_time
		_fix_line = 0
		_say(_key(FIX_LINES[0]), fix_time / FIX_LINES.size())
	else:
		_back_to_route()


func _back_to_route() -> void:
	_path = [route[_index]]


## Bent over the printer's tray, one line per part, until it prints again.
func _fix(delta: float) -> void:
	if fix_facing != Vector3.INF:
		_face(fix_facing)
	elif printer:
		_face(printer.global_position)
	_fix_left -= delta
	if _fix_left <= 0.0:
		_fix_left = 0.0
		if printer:
			printer.fix()
		_say(_key("FIX_DONE"))
		_back_to_route()
		return
	var part := fix_time / FIX_LINES.size()
	var line := mini(int((fix_time - _fix_left) / part), FIX_LINES.size() - 1)
	if line != _fix_line:
		_fix_line = line
		_say(_key(FIX_LINES[line]), part)


func _nearest_index(spot: Vector3) -> int:
	var best := 0
	for i in route.size():
		if route[i].distance_to(spot) < route[best].distance_to(spot):
			best = i
	return best


func _on_printer_jammed() -> void:
	_say(_key("PRINTER"))
	if not is_fixing():
		_go(printer_spot, "printer")


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
	_say(_key("HURT"))
	hurt.emit()
	return true


## Something pleased her: the complaint goes down `points` and she says `line`.
func praise(points: float, line: String) -> void:
	_set_complaint(complaint - points)
	_say(line)


func door_broken() -> void:
	_raise(DOOR_BROKEN)
	_say(_key("DOOR"))


## Something happened at `at`: if she sees it, the complaint goes up `points` and she says `line`.
func saw(at: Vector3, points: float, line := "") -> bool:
	if not can_see(at):
		return false
	_raise(points)
	_say(line if line != "" else _key("SAW"))
	return true


## Whether `at` is in her sight: close enough, nothing in between, and she isn't fighting the printer.
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
		_say(_key("LAWYER"))
		lawyer_called.emit()


## Pushed by a running cop, or by something rolling into her (a chair with a cop on it counts).
func _on_bump(body: Node3D) -> void:
	var speed := 0.0
	if body is Cop:
		speed = (body as Cop).velocity.length()
	elif body is RigidBody3D:
		speed = (body as RigidBody3D).linear_velocity.length()
	if speed > STRUCK_SPEED:
		struck()


## One of her lines, in her voice: "HURT" -> "BOSS_HURT".
func _key(line: String) -> String:
	return voice + "_" + line


func _say(key: String, seconds := 3.0) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
