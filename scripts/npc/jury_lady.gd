class_name JuryLady
extends StaticBody3D

## The lady of the jury (escena-del-crimen.md, "Las pistas"): she sat at the jury's table and, if the witness is one
## of the case's clues, saw the culprit's apron. E on her tells it; cuffed or shouted at, she's offended and says
## nothing more for the whole case.

const MODEL := preload("res://assets/models/npc_senora.glb")
const SHOUT_REACH := 5.0

var case: CrimeSceneCase
## She saw the culprit's apron.
var knows := false
var offended := false
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("jury_lady")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_JURY_LADY"


func use(_cop: Cop) -> void:
	if offended:
		_say("WITNESS_OFFENDED")
	elif knows and case:
		case.found("witness")
		_say(tr("WITNESS_SAW") % tr("APRON_" + str(case.culprit().apron)), 6.0)
	else:
		_say("WITNESS_NOTHING")


func cuffed(_seconds: float) -> void:
	offend()


## A cop shouted: if he was close, she takes offense.
func shouted_by(cop: Cop) -> void:
	if cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		offend()


func offend() -> void:
	if offended:
		return
	offended = true
	_say("WITNESS_OFFENDED")
	if knows and case:
		case.ruin("witness")


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds
