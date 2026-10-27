class_name FarmHen
extends Grabbable

## One of Don Florencio's hens (docs/diseno/allanamiento-granja.md, "Las gallinas"): it pecks its way around the yard,
## a cop who runs into it trips, and a cop running close scares it off, flapping (Don Florencio counts it if he sees it).
## It's carried like anything of 2 kg, flapping all the way. Left inside the hen house's run (`run`, in the farm's space)
## it stays there pecking: that's what Pancho wants. Every number here is (propuesta).

## A cop running this close scared it: where, so Don Florencio can see it.
signal scared(at: Vector3)

const MODEL := preload("res://assets/models/farm_chicken.glb")
const KG := 2.0
const SPEED := 0.9
const FLEE_SPEED := 3.2
const FLEE_TIME := 1.0
const PECK_EVERY := 2.5
const SCARE_RANGE := 2.0
const SCARE_COOLDOWN := 4.0
## A cop moving faster than this within TRIP_RANGE trips over it.
const TRIP_SPEED := 2.5
const TRIP_RANGE := 0.5
const TRIP_SECONDS := 1.0
const TRIP_COOLDOWN := 3.0

## Where it pecks around and the run in front of the hen house, both in the farm's space (set before it's added).
var yard := Rect2()
var run := Rect2()
var farm: Node3D
## Same seed, same pecking.
var rng := RandomNumberGenerator.new()
var _target := Vector3.ZERO
var _peck_left := 0.0
var _flee_left := 0.0
var _flee := Vector3.ZERO
var _scare_wait := 0.0
var _trip_wait := 0.0
var _beat := 0.0
var _model: Node3D
var _bubble: Label3D


func _ready() -> void:
	mass = KG
	collision_layer = 4
	collision_mask = 15
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.26, 0.36, 0.36)
	shape.shape = box
	shape.position.y = 0.18
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.text = "HEN_CLUCK"
	_bubble.position = Vector3(0, 0.7, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.hide()
	add_child(_bubble)
	_target = position


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HEN"


func hold(holder_id: int, point: Vector3) -> void:
	if not is_held():
		_cluck()
	super(holder_id, point)


## Inside the hen house's run, on the ground.
func is_cooped() -> bool:
	if is_held() or not farm:
		return false
	var at := farm.to_local(global_position)
	return run.has_point(Vector2(at.x, at.z))


func _physics_process(delta: float) -> void:
	super(delta)
	_beat += delta
	_scare_wait = maxf(_scare_wait - delta, 0.0)
	_trip_wait = maxf(_trip_wait - delta, 0.0)
	if is_held():
		# Flapping in the cop's hands.
		_model.rotation.z = sin(_beat * 30.0) * 0.25
		return
	_model.rotation.z = 0.0
	if not farm:
		return
	_watch_cops()
	var wish := Vector3.ZERO
	if _flee_left > 0.0:
		_flee_left -= delta
		wish = _flee * FLEE_SPEED
	else:
		_peck_left -= delta
		if _peck_left <= 0.0:
			_peck_left = PECK_EVERY * rng.randf_range(0.6, 1.4)
			var area := run if is_cooped() else yard
			_target = farm.to_global(Vector3(rng.randf_range(area.position.x, area.end.x), 0,
				rng.randf_range(area.position.y, area.end.y)))
		var to := _target - global_position
		to.y = 0.0
		if to.length() > 0.2:
			wish = to.normalized() * SPEED
	if wish != Vector3.ZERO:
		linear_velocity.x = wish.x
		linear_velocity.z = wish.z
		rotation.y = atan2(wish.x, wish.z)
		_model.position.y = absf(sin(_beat * 12.0)) * 0.04


## A cop who runs into it trips; one running close scares it off.
func _watch_cops() -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if cop.vehicle:
			continue
		var flat := Vector2(cop.velocity.x, cop.velocity.z).length()
		var away := global_position - cop.global_position
		away.y = 0.0
		var d := away.length()
		if _trip_wait <= 0.0 and flat > TRIP_SPEED and d < TRIP_RANGE:
			_trip_wait = TRIP_COOLDOWN
			cop.stagger(TRIP_SECONDS)
			cop.show_hint("HINT_TRIPPED_HEN")
			_cluck()
		if _scare_wait <= 0.0 and cop.is_running and flat > GameScale.WALK_SPEED and d < SCARE_RANGE:
			_scare_wait = SCARE_COOLDOWN
			_flee_left = FLEE_TIME
			_flee = away.normalized() if d > 0.01 else Vector3.FORWARD
			_cluck()
			scared.emit(global_position)


func _cluck() -> void:
	_bubble.show()
	get_tree().create_timer(1.2).timeout.connect(_bubble.hide)
