class_name BirthdayPinata
extends StaticBody3D

## The piñata under the mirror ball at the birthday party raid (docs/diseno/allanamiento-cumple.md, step 3): E whacks
## it (it swings), and the HITS-th whack breaks it: it's gone and candies rain on the floor under it. The cop who broke
## it is the one Tomasito talks to. Its model hangs from its rope, centered on this body. Every number here is
## (propuesta).

signal broken(cop: Cop)

const MODEL := preload("res://assets/models/birthday_pinata.glb")
const HITS := 3
const SIZE := Vector3(0.7, 0.7, 0.4)
## A whack can't come sooner than this after the last one.
const WHACK_GAP := 0.4
const SWING := 0.5
const CANDIES := 14
const CANDY_COLORS: Array[Color] = [Color(0.95, 0.25, 0.3), Color(0.3, 0.6, 0.95), Color(0.98, 0.85, 0.2),
	Color(0.5, 0.85, 0.4), Color(0.85, 0.4, 0.9)]

var hits := 0
var is_broken := false
## The candies lie this far below its center (the hall's floor).
var drop := 1.7
var _model: Node3D
var _since := WHACK_GAP
var _swing := 0.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)


func prompt_key(_cop: Cop) -> String:
	return "" if is_broken else "PROMPT_PINATA"


func use(cop: Cop) -> void:
	if is_broken or _since < WHACK_GAP:
		return
	_since = 0.0
	hits += 1
	_swing = SWING
	if hits >= HITS:
		_break(cop)


func _break(cop: Cop) -> void:
	is_broken = true
	_model.visible = false
	collision_layer = 0
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["pinata candies", hits])
	for i in CANDIES:
		var candy := MeshInstance3D.new()
		var look := BoxMesh.new()
		look.size = Vector3(0.08, 0.03, 0.05)
		candy.mesh = look
		var material := StandardMaterial3D.new()
		material.albedo_color = CANDY_COLORS[i % CANDY_COLORS.size()]
		candy.material_override = material
		var angle := rng.randf_range(0.0, TAU)
		candy.position = Vector3(cos(angle), 0, sin(angle)) * rng.randf_range(0.2, 1.2) + Vector3.DOWN * (drop - 0.015)
		candy.rotation.y = rng.randf_range(0.0, PI)
		add_child(candy)
	broken.emit(cop)


func _process(delta: float) -> void:
	_since += delta
	if _swing > 0.0:
		_swing = maxf(_swing - delta, 0.0)
		_model.rotation.z = sin(_swing * 20.0) * _swing * 0.6
