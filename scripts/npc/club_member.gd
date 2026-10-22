class_name ClubMember
extends StaticBody3D

## A grandparent at the club's bingo tables (infiltracion.md, step 2b), or Doña Chela at the bingo stand. E on one tells
## a bit of gossip, a different line each time. Each one has a suspicion meter that ClubSuspicion fills from what they
## see (step 4), with a "?" or a "!" over their head. They don't move yet, so online every PC has the same ones; their
## meters come from the host through ClubSuspicion.

## A cop cuffed them (the handcuffs, on every PC).
signal cuffed_now(member: ClubMember)

const MODELS := {
	"abuelo": preload("res://assets/models/npc_abuelo.glb"),
	"abuela": preload("res://assets/models/npc_abuela.glb"),
	"chela": preload("res://assets/models/npc_chela.glb"),
}
const SCALES := {"abuelo": 0.82, "abuela": 0.8, "chela": 0.85}
const GOSSIP_LINES := 12
const CHELA_LINES := 4
const SAY_TIME := 4.0
## What a grandparent sees: a wide cone in front of them (they turn their heads) and not far, at their eyes' height.
const SIGHT_ANGLE := deg_to_rad(140.0)
const SIGHT_RANGE := 9.0
const EYE_HEIGHT := 1.15
## Over these, a "?" and then a "!" over their head.
const DOUBT := 50.0
const ALARM := 80.0

@export var look := "abuela"
## Which gossip line comes next (a different start for each, from the seed).
var next_line := 0
## 0 to 100: at 100 they shout that the cops are cops (ClubSuspicion).
var suspicion := 0.0
var _bubble: Label3D
var _bubble_left := 0.0
var _mark: Label3D
var _cuffed_left := 0.0


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
	_mark = Label3D.new()
	_mark.name = "Mark"
	_mark.position = Vector3(0, 1.6, 0)
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.pixel_size = 0.006
	_mark.font_size = 64
	_mark.outline_size = 12
	_mark.hide()
	add_child(_mark)


func is_chela() -> bool:
	return look == "chela"


func set_suspicion(value: float) -> void:
	suspicion = value
	_mark.visible = suspicion >= DOUBT
	_mark.text = "!" if suspicion >= ALARM else "?"
	_mark.modulate = Color(1, 0.25, 0.2) if suspicion >= ALARM else Color(1, 0.85, 0.3)


## Whether they see `cop`'s chest: in their cone, near enough and with no wall in between.
func sees_cop(cop: Cop) -> bool:
	var eye := global_position + Vector3.UP * EYE_HEIGHT
	var at := cop.global_position + Vector3.UP
	var flat := Vector3(at.x - eye.x, 0, at.z - eye.z)
	if flat.length() > SIGHT_RANGE or flat.length() < 0.01:
		return false
	if (-global_basis.z).angle_to(flat.normalized()) > SIGHT_ANGLE / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or hit.collider == cop


## The handcuffs: stays put, complains, and the case hears it (InfiltrationCase).
func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	say("CHELA_CUFFED" if is_chela() else "NPC_POLICE_ABUSE")
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


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
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
