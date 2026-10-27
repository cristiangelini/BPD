class_name KaraokeSinger
extends StaticBody3D

## A customer of the karaoke (allanamiento-karaoke.md, step 2). They wait by their table until the karaoke gives them
## their turn, walk up the steps to microphone 1 and sing about SING_TIME seconds, a line over their head every
## LINE_EVERY, then walk back. They complain (5 to the complaint, at most once every COMPLAIN_EVERY seconds each) when
## the microphone isn't in its stand, a cop takes it while they sing or a cop stands on the stage with them. E on one
## tells a line about the karaoke. Every number here is (propuesta).

## They complained loud enough for the owner to hear it (Rosaura adds it to the complaint, step 3).
signal complained(singer: KaraokeSinger)
## Their turn is over and they're back by their table.
signal turn_over(singer: KaraokeSinger)

const MODELS := {
	"cliente": preload("res://assets/models/npc_cliente.glb"),
	"clienta": preload("res://assets/models/npc_clienta.glb"),
	"invitado": preload("res://assets/models/npc_invitado.glb"),
	"invitado_b": preload("res://assets/models/npc_invitado_b.glb"),
	"fan": preload("res://assets/models/npc_fan.glb"),
	"huesped": preload("res://assets/models/npc_huesped.glb"),
}
const SCALE := 0.95
const SING_TIME := 20.0
const LINE_EVERY := 4.0
const COMPLAINT := 5.0
const COMPLAIN_EVERY := 10.0
const SAY_TIME := 3.5
## Seconds for each stretch of the walk up to the microphone (and back).
const STRETCH := 1.2
const SING_LINES := ["KARAOKE_SING_1", "KARAOKE_SING_2", "KARAOKE_SING_3", "KARAOKE_SING_4", "KARAOKE_SING_5"]
const TALK_LINES := ["KARAOKE_SINGER_TALK_1", "KARAOKE_SINGER_TALK_2", "KARAOKE_SINGER_TALK_3"]

@export var look := "cliente"
var karaoke: Karaoke
## Where they wait (karaoke space), and whether it's their turn (walking up, singing or walking back) or singing now.
var home := Vector3.ZERO
var on_turn := false
var singing := false
var sing_left := 0.0
var rng := RandomNumberGenerator.new()
var complaints := 0
## Online, a guest's copy: the host's customer sings and complains, this one only follows (NpcSync).
var follower := false
var _since_complaint := COMPLAIN_EVERY
var _line_left := 0.0
var _next_talk := 0
var _bubble: Label3D
var _bubble_left := 0.0
var _walk: Tween


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODELS[look].instantiate()
	model.scale = Vector3.ONE * SCALE
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	# They wait facing the stage (-Z); the models face +Z.
	rotation.y = PI


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_SINGER"


func use(_cop: Cop) -> void:
	say(TALK_LINES[_next_talk % TALK_LINES.size()])
	_next_talk += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Says it, and it counts for the complaint unless they complained a moment ago.
func complain(key: String) -> void:
	say(key)
	if follower or _since_complaint < COMPLAIN_EVERY:
		return
	_since_complaint = 0.0
	complaints += 1
	complained.emit(self)


## Their turn: up the steps to microphone 1, then they sing (or complain if it isn't in its stand).
func start_turn() -> void:
	on_turn = true
	var spot := karaoke.singer_spot()
	_go([karaoke.steps_foot(), karaoke.steps_top(), spot], _at_mic)


func _at_mic() -> void:
	rotation.y = 0.0
	if not karaoke.mics[0].in_stand:
		complain("KARAOKE_SINGER_NO_MIC")
		_end_turn()
		return
	singing = true
	sing_left = SING_TIME
	_line_left = 0.0


## Done (or stopped): back down the steps to their table.
func _end_turn() -> void:
	singing = false
	_go([karaoke.steps_top(), karaoke.steps_foot(), home], func() -> void:
		rotation.y = PI
		on_turn = false
		turn_over.emit(self))


## Walks through `points` (karaoke space) one stretch at a time, then calls `done`.
func _go(points: Array, done: Callable) -> void:
	if _walk:
		_walk.kill()
	_walk = create_tween()
	for point: Vector3 in points:
		_walk.tween_property(self, "position", point, STRETCH)
	_walk.tween_callback(done)


func _physics_process(delta: float) -> void:
	_since_complaint += delta
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if not singing:
		return
	if karaoke.mics[0].is_held():
		complain("KARAOKE_SINGER_GRABBED")
		_end_turn()
		return
	if karaoke.cop_on_stage():
		complain("KARAOKE_SINGER_IN_WAY")
	sing_left -= delta
	_line_left -= delta
	if _line_left <= 0.0 and _bubble_left <= 0.0:
		_line_left = LINE_EVERY
		say(SING_LINES[rng.randi() % SING_LINES.size()])
	if sing_left <= 0.0:
		_end_turn()
