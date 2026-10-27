class_name StrengthTester
extends OfficePrinter

## The fun fair's strength tester (docs/diseno/allanamiento-parque.md, "Su distracción"): E on its pad with the mallet
## in hand is a swing, and something heavy thrown hard on the pad counts too. A good hit sends the puck up to the bell
## and Don Tómbola runs to hand over the prize, his back to the fair (the floor boss's fix, on the same body); a weak
## one leaves the cop a second staring at the mallet. He comes once every REST seconds, and the third time he catches
## on. Its front, with the pad, to +z. Every number here is (propuesta).

## The bell rang but this time Don Tómbola knows what's going on.
signal caught_on

const MODEL := preload("res://assets/models/strength_tester.glb")
const MALLET_MODEL := preload("res://assets/models/fair_mallet.glb")
const BASE := Vector3(1.2, 0.3, 0.9)
const PAD_AT := Vector3(0, 0.38, 0.15)
const RAIL_Z := -0.2
const PUCK_LOW := 0.55
const PUCK_HIGH := 3.95
const REST := 45.0
## A swing rings the bell this often.
const RING_CHANCE := 0.6
## kg times m/s of something landing on the pad that rings it (a 4 kg mallet thrown at 5 m/s).
const RING_IMPULSE := 20.0
const MALLET_KG := 4.0
const MALLET_SIZE := Vector3(0.32, 0.2, 1.1)
## The rings that take Don Tómbola to the prize; from the next one on he catches on.
const FOOLS := 2
## How long a weak swing leaves the cop staring at the mallet.
const STARE := 1.0

var mallet: Grabbable
## The fair's seed: which swings ring.
var case_seed := 0
## Seconds left before the bell takes him away again.
var rest_left := 0.0
var rings := 0
var distractions := 0
var _rng := RandomNumberGenerator.new()
var _puck: MeshInstance3D
var _ding: Label3D


func _ready() -> void:
	_rng.seed = hash(["strength tester", case_seed])
	var build := PlaceBuilder.new(self)
	build.shape(build.body(Vector3(0, BASE.y / 2, 0)), BASE)
	build.shape(build.body(Vector3(0, 2.2, -0.3)), Vector3(0.7, 4.4, 0.2))
	add_child(MODEL.instantiate())
	var puck_mesh := CylinderMesh.new()
	puck_mesh.top_radius = 0.08
	puck_mesh.bottom_radius = 0.08
	puck_mesh.height = 0.1
	_puck = MeshInstance3D.new()
	_puck.mesh = puck_mesh
	_puck.material_override = build.material(Color(0.82, 0.23, 0.23))
	_puck.position = Vector3(0, PUCK_LOW, RAIL_Z)
	add_child(_puck)
	button = PushButton.new()
	button.prompt = "PROMPT_FAIR_HIT"
	button.color = Color(0.1, 0.1, 0.12)
	button.position = PAD_AT + Vector3(0, 0.1, 0)
	button.rotation.x = -PI / 2
	add_child(button)
	button.pressed.connect(swing)
	var pad := Area3D.new()
	pad.collision_layer = 0
	pad.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.6, 0.4, 0.6)
	shape.shape = box
	pad.add_child(shape)
	pad.position = PAD_AT + Vector3(0, 0.2, 0)
	add_child(pad)
	pad.body_entered.connect(_on_pad_hit)
	_ding = Label3D.new()
	_ding.text = "FAIR_DING"
	_ding.font_size = 90
	_ding.pixel_size = 0.008
	_ding.outline_size = 14
	_ding.modulate = Color(1.0, 0.85, 0.3)
	_ding.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_ding.position = Vector3(0, PUCK_HIGH + 0.9, RAIL_Z)
	_ding.visible = false
	add_child(_ding)


## The mallet beside the tester, to be picked up (the fair adds it to the level so it can be carried away).
func make_mallet() -> Grabbable:
	mallet = ClubEvidence.make_item("Mallet", MALLET_MODEL, MALLET_SIZE, MALLET_KG)
	(mallet.get_child(1) as Node3D).position = Vector3(0, -MALLET_SIZE.y / 2, -0.03)
	return mallet


## E on the pad: with the mallet in hand, a swing that rings the bell RING_CHANCE of the times.
func swing(cop: Cop = null) -> void:
	if cop and cop.get_node("Grabber").held != mallet:
		cop.show_hint("HINT_FAIR_NEED_MALLET")
		return
	if _rng.randf() < RING_CHANCE:
		ring()
	elif cop:
		cop.knock_back(Vector3.ZERO, STARE)
		cop.show_hint("HINT_FAIR_WEAK_HIT")


## The puck flies up and the bell rings: Don Tómbola comes for the prize, unless he came less than REST seconds ago, or
## it's the third time and he catches on.
func ring() -> void:
	rings += 1
	_ding.visible = true
	var tween := create_tween()
	tween.tween_property(_puck, "position:y", PUCK_HIGH, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(0.6)
	tween.tween_callback(func() -> void: _ding.visible = false)
	tween.tween_property(_puck, "position:y", PUCK_LOW, 0.8).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	if is_jammed or rest_left > 0.0:
		return
	if distractions >= FOOLS:
		caught_on.emit()
		rest_left = REST
		return
	distractions += 1
	is_jammed = true
	jobs += 1
	rest_left = REST
	jammed.emit()


## The prize is handed over: he goes back to his round.
func fix() -> void:
	is_jammed = false


func is_giving_prize() -> bool:
	return is_jammed


func _process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)


## Something heavy thrown hard on the pad rings it too.
func _on_pad_hit(body: Node3D) -> void:
	var item := body as RigidBody3D
	if item and item.mass * item.linear_velocity.length() >= RING_IMPULSE:
		ring()
