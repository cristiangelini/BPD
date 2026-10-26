class_name FootballReferee
extends CharacterBody3D

## The referee (politico-futbol.md, step 5, decision 179), bought by concejal Tito Barullo. He follows the play from the
## south side of the ball and every CALL_EVERY seconds whistles a free kick for the Veterans right by the deputy's goal,
## and a handball too. The clues: an envelope with money peeking out of his pocket (E on him, `found_clue("envelope")`)
## and the thumbs up he gives Barullo in the stand every THUMBS_EVERY seconds (a cop within SEE of him sees it,
## `found_clue("thumbs")`); the campaign pin on his cap is just there. Cuffed, he protests, and E walks him to the patrol
## car (OwnerEscort); from then on nobody whistles against the deputy. Every number here is (propuesta).

signal found_clue(kind: String)
signal cuffed_now(referee: FootballReferee)
signal called

const MODEL := preload("res://assets/models/npc_arbitro.glb")
const SAY_TIME := 3.0
const SPEED := 2.5
const THERE := 0.5
## Where he stands: this far south of the ball, inside the field.
const BESIDE := 6.0
const CALL_EVERY := 20.0
const THUMBS_EVERY := 15.0
const SEE := 12.0
const CALLS := 3
const TALKS := 3
## The free kick: this far in front of the west goal, and how far off its middle.
const FREE_KICK := 8.0
const FREE_KICK_SPREAD := 3.0
const ENVELOPE := Color(0.93, 0.87, 0.7)
const MONEY := Color(0.35, 0.65, 0.35)
const PIN := Color(0.16, 0.6, 0.29)

var pitch: FootballPitch
var barullo: RallyFan
var playing := false
## A guest's copy (NpcSync): the host's whistles.
var follower := false
var calls := 0
var clues: Array[String] = []
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _cuffed_left := 0.0
var _call_left := CALL_EVERY
var _thumbs_left := THUMBS_EVERY
var _talk := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("football_referees")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	_model.name = "Model"
	# The models face +Z; he faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	# The envelope out of his shirt pocket, a bill sticking out of it, and Barullo's green pin on his cap (model space).
	_model.add_child(_box("Envelope", Vector3(0.16, 0.1, 0.02), Vector3(0.22, 0.95, 0.31), ENVELOPE))
	_model.add_child(_box("Money", Vector3(0.12, 0.05, 0.015), Vector3(0.22, 1.02, 0.31), MONEY))
	_model.add_child(_box("Pin", Vector3(0.07, 0.07, 0.02), Vector3(0.12, 1.46, 0.19), PIN))
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)
	_rng.seed = hash(["referee", name])


func _box(node_name: String, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var box := MeshInstance3D.new()
	box.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	box.material_override = material
	box.position = at
	return box


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_REFEREE"


## E: one of his excuses, and the envelope sticking out of his pocket is seen.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	if follower:
		return
	say("FOOTBALL_REFEREE_TALK_%d" % (_talk % TALKS + 1))
	_talk += 1
	_find("envelope", cop)


func _find(kind: String, cop: Cop) -> void:
	if clues.has(kind):
		return
	clues.append(kind)
	cop.show_hint("HINT_FOOTBALL_REFEREE_%s" % kind.to_upper())
	found_clue.emit(kind)


## The handcuffs: he protests, and the case hears it.
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if follower:
		return
	say("FOOTBALL_REFEREE_CUFFED")
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Neither cuffed, nor being walked to the patrol car, nor in it: still whistling.
func loose() -> bool:
	var escort := OwnerEscort.of(self)
	return not is_cuffed() and not (escort and (escort.escorted_by or escort.in_car))


## A free kick for the Veterans by the deputy's goal (for a handball or for nothing at all).
func call_foul() -> void:
	if not loose() or follower:
		return
	_call_left = CALL_EVERY
	calls += 1
	var spot := FootballPitch.goal_at(-1.0) + Vector3(FREE_KICK, 0, _rng.randf_range(-FREE_KICK_SPREAD,
		FREE_KICK_SPREAD))
	pitch.score.put_ball(pitch.to_global(spot))
	say("FOOTBALL_REFEREE_CALL_%d" % ((calls - 1) % CALLS + 1))
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_FOOTBALL_FREE_KICK")
	called.emit()


## A thumbs up at Barullo in the stand; a cop close enough sees it.
func thumbs_up() -> void:
	_thumbs_left = THUMBS_EVERY
	if barullo:
		_face(barullo.global_position)
		barullo.say("FOOTBALL_BARULLO_NOD")
	say("FOOTBALL_REFEREE_THUMBS")
	for cop: Node in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) < SEE:
			_find("thumbs", cop as Cop)
			return


## What the escort calls (OwnerEscort): a line for `seconds`; he has no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key)
	_bubble_left = seconds


func _raise(_points: float) -> void:
	pass


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	if follower or not loose() or not playing:
		_go(Vector3.ZERO)
		return
	_call_left -= delta
	_thumbs_left -= delta
	if _call_left <= 0.0:
		call_foul()
	if _thumbs_left <= 0.0:
		thumbs_up()
	var spot := pitch.to_local(pitch.ball.global_position) - FootballPitch.CENTER + Vector3(0, 0, BESIDE)
	spot.x = clampf(spot.x, -FootballPitch.HALF_LENGTH, FootballPitch.HALF_LENGTH)
	spot.z = clampf(spot.z, -FootballPitch.HALF_WIDTH, FootballPitch.HALF_WIDTH)
	var to := pitch.to_global(FootballPitch.CENTER + spot) - global_position
	to.y = 0.0
	if to.length() < THERE:
		_go(Vector3.ZERO)
		_face(pitch.ball.global_position)
	else:
		_go(to.normalized() * SPEED)


func _go(wish: Vector3) -> void:
	if wish.length() > 0.05:
		look_at(global_position + wish, Vector3.UP)
	velocity.x = wish.x
	velocity.z = wish.z
	move_and_slide()


func _face(at: Vector3) -> void:
	var flat := Vector3(at.x, global_position.y, at.z)
	if flat.distance_to(global_position) > 0.1:
		look_at(flat, Vector3.UP)


func _process(delta: float) -> void:
	# The escort turns him with his +Z ahead.
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
