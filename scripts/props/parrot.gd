class_name Parrot
extends Evidence

## Pepe, the parrot who repeats the bank's safe code (casa-equivocada.md, "El loro que sabe la clave"). He sits on
## one of his `perches`; when a cop comes nearer than FLEE he flies to the perch farthest from every cop, unless every
## perch has a cop near it: then he's cornered and stays. After TIRED_AFTER flights in a row he rests REST seconds and
## lets himself be grabbed. Once a cop grabs him (or his owner takes him) he's caught: plain evidence from then on.
## Every few seconds he says numbers. It runs on the host. Every number here is (propuesta).

signal flew(to: Vector3)

enum State { PERCHED, FLYING, RESTING, CAUGHT }

const FLEE := 2.5
const FLIGHT := 0.8
const ARC := 0.8
const TIRED_AFTER := 5
const REST := 6.0
const TALK_EVERY := 6.0
## How high his middle sits over the perch.
const OVER_PERCH := 0.15

var state := State.PERCHED
## Where he can land, in world space (the surface under his feet).
var perches: Array[Vector3] = []
var perch := 0
var flights := 0
var _from := Vector3.ZERO
var _flown := 0.0
var _rest_left := 0.0
var _talk_left := 2.0
var _bubble: Label3D


func _ready() -> void:
	super._ready()
	freeze = true
	_bubble = Label3D.new()
	_bubble.position = Vector3(0, 0.45, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 32
	_bubble.hide()
	add_child(_bubble)


## Puts him on perch i at once.
func land_on(i: int) -> void:
	perch = i
	global_position = perch_point(i)


func perch_point(i: int) -> Vector3:
	return perches[i] + Vector3.UP * OVER_PERCH


func hold(holder_id: int, point: Vector3) -> void:
	_caught()
	super.hold(holder_id, point)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state == State.CAUGHT or not multiplayer.is_server():
		return
	_chatter(delta)
	match state:
		State.PERCHED:
			# His owner picked him up (he lets her): no more flying.
			if global_position.distance_to(perch_point(perch)) > 0.05:
				_caught()
			elif flights >= TIRED_AFTER:
				state = State.RESTING
				_rest_left = REST
			elif _nearest_cop_distance(global_position) < FLEE:
				var to := flee_perch()
				if to >= 0:
					_take_off(to)
		State.FLYING:
			_flown += delta
			var t := minf(_flown / FLIGHT, 1.0)
			global_position = _from.lerp(perch_point(perch), t) + Vector3.UP * ARC * sin(t * PI)
			if t >= 1.0:
				state = State.PERCHED
				flew.emit(global_position)
		State.RESTING:
			_rest_left -= delta
			if _rest_left <= 0.0:
				flights = 0
				state = State.PERCHED


## The perch farthest from every cop, if it's out of their reach; -1 if he's cornered.
func flee_perch() -> int:
	var best := -1
	var best_distance := FLEE
	for i in perches.size():
		if i == perch:
			continue
		var d := _nearest_cop_distance(perch_point(i))
		if d > best_distance:
			best = i
			best_distance = d
	return best


func cornered() -> bool:
	return state == State.PERCHED and _nearest_cop_distance(global_position) < FLEE and flee_perch() < 0


func _take_off(to: int) -> void:
	_from = global_position
	perch = to
	_flown = 0.0
	flights += 1
	state = State.FLYING


func _caught() -> void:
	if state == State.CAUGHT:
		return
	state = State.CAUGHT
	freeze = false


func _nearest_cop_distance(from: Vector3) -> float:
	var best := INF
	for node in get_tree().get_nodes_in_group("cops"):
		best = minf(best, from.distance_to((node as Node3D).global_position))
	return best


## Numbers, the safe's code, loud enough to hear from the sidewalk.
func _chatter(delta: float) -> void:
	_talk_left -= delta
	if _talk_left > 0.0:
		return
	_talk_left = TALK_EVERY
	say(tr("PARROT_NUMBERS"))


func say(text: String) -> void:
	_bubble.text = text
	_bubble.show()
	get_tree().create_timer(2.5).timeout.connect(func() -> void:
		if _bubble.text == text:
			_bubble.hide())


func said() -> String:
	return _bubble.text if _bubble.visible else ""
