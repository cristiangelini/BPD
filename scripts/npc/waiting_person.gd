class_name WaitingPerson
extends StaticBody3D

## Someone in the station's waiting room in the fire drill jailbreak (docs/diseno/fuga-simulacro.md, step 1): it's
## daytime, and people came to report something, complain or deliver a pizza. They stand or wait by the benches and
## grumble now and then. The drill (step 2) walks them out the front door to the meeting point on the sidewalk and,
## when it's over, back to their spot. Every number here is (propuesta).

## Who can be there, by model.
const KINDS: Array[String] = ["senora", "repartidor", "abuelo", "abuela", "vecina", "cliente", "clienta",
	"periodista", "portero", "abogado", "panadera", "heladero"]
const CHAT_MIN := 12.0
const CHAT_MAX := 30.0
const LINES := 10
const DRILL_LINES := 5
const BUBBLE_TIME := 4.0
const RADIUS := 0.35
const HEIGHT := 1.6
const WALK_SPEED := 1.2
## The slow ones (the grandparents) walk at this part of it.
const SLOW: Array[String] = ["abuelo", "abuela"]
const SLOW_FACTOR := 0.6
## Out the front door, in the station's lot space.
const DOOR_IN := Vector3(0, 0, 8.0)
const DOOR_OUT := Vector3(0, 0, 10.2)

var kind := "senora"
## The station's lot, where they wait inside and where they stand in the drill (the level sets them).
var station_lot: Transform3D
var home: Vector3
var meeting: Vector3
var _path: Array[Vector3] = []
var _rng := RandomNumberGenerator.new()
var _chat_left := 0.0
var _bubble: Label3D
var _bubble_left := 0.0


## Who this one is, and when they first say something.
func set_up(person_kind: String, person_seed: int) -> void:
	kind = person_kind
	_rng.seed = person_seed
	_chat_left = _rng.randf_range(CHAT_MIN, CHAT_MAX)


func _ready() -> void:
	add_to_group("waiting_people")
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = RADIUS
	capsule.height = HEIGHT
	shape.shape = capsule
	shape.position.y = HEIGHT / 2
	add_child(shape)
	add_child(load("res://assets/models/npc_%s.glb" % kind).instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.position.y = 2.0
	_bubble.font_size = 40
	_bubble.outline_size = 10
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.visible = false
	add_child(_bubble)


## The alarm: out to the meeting point.
func evacuate() -> void:
	_path = [station_lot * DOOR_IN, station_lot * DOOR_OUT, meeting]
	say("WAITING_DRILL_%d" % _rng.randi_range(0, DRILL_LINES - 1))


## The drill's over: back inside to their spot.
func go_back() -> void:
	_path = [station_lot * DOOR_OUT, station_lot * DOOR_IN, home]


func is_walking() -> bool:
	return not _path.is_empty()


func _walk(delta: float) -> void:
	var to := _path[0] - global_position
	to.y = 0.0
	var step := WALK_SPEED * (SLOW_FACTOR if SLOW.has(kind) else 1.0) * delta
	if to.length() > 0.01:
		global_basis = Basis.looking_at(-to.normalized())
	if to.length() > step:
		global_position += to.normalized() * step
		return
	global_position = Vector3(_path[0].x, global_position.y, _path[0].z)
	_path.pop_front()


func _physics_process(delta: float) -> void:
	if not _path.is_empty():
		_walk(delta)
	if _bubble_left > 0.0:
		_bubble_left -= delta
		_bubble.visible = _bubble_left > 0.0
	_chat_left -= delta
	if _chat_left <= 0.0:
		_chat_left = _rng.randf_range(CHAT_MIN, CHAT_MAX)
		say("WAITING_LINE_%d" % _rng.randi_range(0, LINES - 1))


func say(key: String) -> void:
	_bubble.text = key
	_bubble.visible = true
	_bubble_left = BUBBLE_TIME


## Online: guests make the same people from the same seed; NpcSync only moves them and their bubble.
func net_state() -> Variant:
	return kind


func apply_net_state(_state: Variant) -> void:
	pass
