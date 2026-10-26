class_name TalentInmate
extends CharacterBody3D

## One of the inmates at the prison's talent show (carcel-talentos.md, step 2): sat on a bench in front of the stage
## (AUDIENCE) or up on it with a bow tie and a microphone, announcing the acts (HOST). Step 3: the ones in an act
## (PERFORMER) wait behind the curtain with their act's things (the magician's top hat, the juggler's balls, the
## ventriloquist's dummy...) until it's their turn. They say things in a bubble and cheer with a little hop. Step 4: an
## offended one in the audience (`angry`) stands up booing and throws the canteen's food (RallyThrowable, like the
## riot); E calms them and they sit back down. Every number here is (propuesta).

signal calmed(inmate: TalentInmate)

enum Role { AUDIENCE, HOST, PERFORMER }

const MODEL := preload("res://assets/models/npc_preso.glb")
const SAY_TIME := 3.0
## Sat down, the body is this much lower (on the bench).
const SIT_DROP := 0.35
const HOP := 0.25
const HOP_TIME := 0.15
const BOW := Color(0.8, 0.1, 0.15)
const MIC := Color(0.15, 0.15, 0.17)
const BLACK := Color(0.08, 0.08, 0.1)
const WHITE := Color(0.95, 0.95, 0.92)
const BALLS: Array[Color] = [Color(0.9, 0.2, 0.2), Color(0.2, 0.6, 0.9), Color(0.95, 0.8, 0.2)]
const JUGGLE_TIME := 0.5
const FOODS: Array[String] = ["mash", "jelly", "chicken", "yogurt"]
const HAND := Vector3(0.25, 1.4, 0)
const FLIGHT := 0.9
const MISS := 0.8
const CHEST := 1.1
const BOOS := 3

var role := Role.AUDIENCE
## A performer's act (TalentPlan.ACTS).
var act := ""
## Offended (step 4): stood up, booing and throwing food.
var angry := false
var seated := false
## A guest's copy (step 7): the host's one decides.
var follower := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("talent_inmates")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	if role == Role.HOST:
		# The bow tie at the neck and the microphone in hand.
		_model.add_child(CopTool.piece(CopTool.box(Vector3(0.22, 0.09, 0.04)), BOW, Vector3(0, 1.1, 0.28)))
		_model.add_child(CopTool.piece(CopTool.cylinder(0.025, 0.22), MIC, Vector3(0.36, 0.85, 0.3)))
		_model.add_child(CopTool.piece(CopTool.cylinder(0.045, 0.06), MIC, Vector3(0.36, 0.98, 0.3)))
	if role == Role.PERFORMER:
		_props()
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	set_seated(seated)


## What a performer carries for their act.
func _props() -> void:
	match act:
		"magician":
			_model.add_child(CopTool.piece(CopTool.cylinder(0.3, 0.03), BLACK, Vector3(0, 1.5, 0)))
			_model.add_child(CopTool.piece(CopTool.cylinder(0.18, 0.32), BLACK, Vector3(0, 1.66, 0)))
			_model.add_child(CopTool.piece(CopTool.cylinder(0.02, 0.4), BLACK, Vector3(0.4, 0.9, 0.25),
				Vector3(0.6, 0, 0)))
		"choir":
			_model.add_child(CopTool.piece(CopTool.box(Vector3(0.3, 0.38, 0.03)), BLACK, Vector3(0, 0.85, 0.42),
				Vector3(-0.4, 0, 0)))
		"smoke":
			_model.add_child(CopTool.piece(CopTool.box(Vector3(0.5, 0.06, 0.06)), Color(0.9, 0.3, 0.7),
				Vector3(0, 1.1, 0.3)))
		"juggler":
			for i in BALLS.size():
				var ball := CopTool.piece(_ball(0.07), BALLS[i], Vector3(-0.3 + i * 0.3, 1.5, 0.35))
				ball.name = "Ball%d" % i
				_model.add_child(ball)
				var up := ball.create_tween().set_loops()
				up.tween_interval(i * JUGGLE_TIME / 3)
				up.tween_property(ball, "position:y", 2.0, JUGGLE_TIME).set_trans(Tween.TRANS_SINE)
				up.tween_property(ball, "position:y", 1.3, JUGGLE_TIME).set_trans(Tween.TRANS_SINE)
		"ventriloquist":
			var dummy := Node3D.new()
			dummy.name = "Dummy"
			dummy.position = Vector3(0.42, 0.75, 0.3)
			_model.add_child(dummy)
			dummy.add_child(CopTool.piece(CopTool.box(Vector3(0.2, 0.3, 0.15)), Color(0.3, 0.3, 0.6)))
			dummy.add_child(CopTool.piece(_ball(0.11), Color(0.95, 0.8, 0.65), Vector3(0, 0.26, 0)))
		"plates":
			for x: float in [-0.45, 0.45]:
				_model.add_child(CopTool.piece(CopTool.cylinder(0.012, 0.8), WHITE, Vector3(x, 1.2, 0.3)))
				_model.add_child(CopTool.piece(CopTool.cylinder(0.16, 0.02), WHITE, Vector3(x, 1.62, 0.3)))
		"spoons":
			for x: float in [-0.4, 0.4]:
				_model.add_child(CopTool.piece(CopTool.box(Vector3(0.04, 0.22, 0.02)), Color(0.75, 0.77, 0.8),
					Vector3(x, 0.9, 0.35)))
		"poet":
			_model.add_child(CopTool.piece(CopTool.box(Vector3(0.22, 0.3, 0.01)), WHITE, Vector3(0.3, 1.0, 0.4),
				Vector3(-0.5, 0, 0)))


static func _ball(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 8
	mesh.rings = 4
	return mesh


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CALM_AUDIENCE" if angry else ""


## E on an offended one: they calm down and sit back on their bench (the host decides, online).
func use(cop: Cop) -> void:
	if not angry or follower:
		return
	set_angry(false)
	say("TALENT_CALMED")
	cop.show_hint("HINT_AUDIENCE_CALMED")
	calmed.emit(self)


## Offended (stood up, booing) or calm (sat back down).
func set_angry(on: bool) -> void:
	angry = on
	set_seated(not on)
	if on:
		say("TALENT_BOO_%d" % randi_range(1, BOOS))


## Throws a `kind` of food to land on `target` (world space), facing it. Returns what flies.
func throw_at(target: Vector3, kind: String) -> RallyThrowable:
	var to := target - global_position
	to.y = 0.0
	if to.length() > 0.1:
		look_at(global_position - to, Vector3.UP)
	var food := RallyThrowable.new()
	food.kind = kind
	get_parent().add_child(food, true)
	add_collision_exception_with(food)
	food.add_collision_exception_with(self)
	food.launch(global_transform * HAND, target, FLIGHT)
	return food


## On stage (shown, bumped into) or waiting behind the curtain (not seen).
func set_on_stage(on: bool) -> void:
	visible = on
	collision_layer = 8 if on else 0


## On the bench (lower) or standing.
func set_seated(on: bool) -> void:
	seated = on
	if _model:
		_model.position.y = -SIT_DROP if on else 0.0


## Turned to look at `at` (world space).
func face(at: Vector3) -> void:
	var away := global_position - (at - global_position)
	away.y = global_position.y
	if away.distance_to(global_position) > 0.01:
		look_at(away, Vector3.UP)


## A little hop where they are (clapping an act).
func cheer() -> void:
	var rest := -SIT_DROP if seated else 0.0
	var hop := create_tween()
	hop.tween_property(_model, "position:y", rest + HOP, HOP_TIME)
	hop.tween_property(_model, "position:y", rest, HOP_TIME)


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
