class_name Cat
extends Grabbable

## Michi, the grandpa's cat (investigacion.md, "Más personajes en la casa"). It sleeps on top of a hiding spot and
## won't move; picking it up makes it meow, and the grandpa hears it. Once awake it weaves between the cops' feet:
## a cop who walks into it trips, and the grandpa gets angry.

signal meowed(at: Vector3)
signal tripped(cop: Cop)

const SPEED := 1.6
## It circles this far around the cop it follows.
const WEAVE := 0.7
const WEAVE_RATE := 1.8
const FOLLOW_RANGE := 10.0
## A cop moving faster than this within TRIP_RANGE trips over it (propuesta).
const TRIP_SPEED := 2.5
const TRIP_RANGE := 0.55
const TRIP_SECONDS := 1.2
const TRIP_COOLDOWN := 4.0
const MEOW_COOLDOWN := 3.0

var awake := false
var _weave := 0.0
var _trip_wait := 0.0
var _meow_wait := 0.0

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	_bubble.hide()


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CAT_ASLEEP" if not awake else "PROMPT_CAT"


func hold(holder_id: int, point: Vector3) -> void:
	if not is_held():
		meow()
	awake = true
	super(holder_id, point)


func meow() -> void:
	if _meow_wait > 0.0:
		return
	_meow_wait = MEOW_COOLDOWN
	_bubble.text = "CAT_MEOW"
	_bubble.show()
	get_tree().create_timer(1.5).timeout.connect(_bubble.hide)
	meowed.emit(global_position)


func _physics_process(delta: float) -> void:
	super(delta)
	_trip_wait = maxf(_trip_wait - delta, 0.0)
	_meow_wait = maxf(_meow_wait - delta, 0.0)
	if not awake or is_held():
		return
	var cop := _nearest_cop()
	if not cop:
		return
	_weave += delta * WEAVE_RATE
	var target := cop.global_position + Vector3(cos(_weave), 0, sin(_weave)) * WEAVE
	var wish := target - global_position
	wish.y = 0.0
	if wish.length() > 0.05:
		wish = wish.normalized() * SPEED
		linear_velocity.x = wish.x
		linear_velocity.z = wish.z
		rotation.y = atan2(wish.x, wish.z)
	_check_trip()


func _check_trip() -> void:
	if _trip_wait > 0.0:
		return
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var flat := Vector2(cop.velocity.x, cop.velocity.z).length()
		var d := Vector2(cop.global_position.x - global_position.x, cop.global_position.z - global_position.z).length()
		if flat > TRIP_SPEED and d < TRIP_RANGE and not cop.vehicle:
			trip(cop)
			return


func trip(cop: Cop) -> void:
	_trip_wait = TRIP_COOLDOWN
	cop.stagger(TRIP_SECONDS)
	cop.show_hint("HINT_TRIPPED_CAT")
	meow()
	tripped.emit(cop)


func _nearest_cop() -> Cop:
	var best: Cop
	var best_distance := FOLLOW_RANGE
	for node in get_tree().get_nodes_in_group("cops"):
		var d := global_position.distance_to((node as Cop).global_position)
		if d < best_distance and (node as Cop).vehicle == null:
			best = node
			best_distance = d
	return best
