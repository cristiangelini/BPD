class_name ClubMember
extends StaticBody3D

## A grandparent at the club's bingo tables (infiltracion.md, step 2b), or Doña Chela at the bingo stand. E on one tells
## a bit of gossip, a different line each time. Suspicion, the clues they drop and Doña Chela's bingo come in the next
## steps. They don't move yet, so online every PC has the same ones without syncing them.

const MODELS := {
	"abuelo": preload("res://assets/models/npc_abuelo.glb"),
	"abuela": preload("res://assets/models/npc_abuela.glb"),
	"chela": preload("res://assets/models/npc_chela.glb"),
}
const SCALES := {"abuelo": 0.82, "abuela": 0.8, "chela": 0.85}
const GOSSIP_LINES := 12
const CHELA_LINES := 4
const SAY_TIME := 4.0

@export var look := "abuela"
## Which gossip line comes next (a different start for each, from the seed).
var next_line := 0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("club_members")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODELS[look].instantiate()
	model.scale = Vector3.ONE * SCALES[look]
	# The models face +Z; the member faces -Z like everyone else.
	model.rotation.y = PI
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


func is_chela() -> bool:
	return look == "chela"


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_CHELA" if is_chela() else "PROMPT_TALK_GRANDPARENT"


func use(_cop: Cop) -> void:
	if is_chela():
		say("CHELA_%d" % (next_line % CHELA_LINES))
	else:
		say("CLUB_GOSSIP_%d" % (next_line % GOSSIP_LINES))
	next_line += 1


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
