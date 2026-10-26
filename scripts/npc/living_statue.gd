class_name LivingStatue
extends StaticBody3D

## The living statue on the museum's steps (escena-museo.md, "Las pistas"): a street artist painted gold who never
## moves, with his hat on the ground for coins. Without a coin, E on him gets nothing but a stare. With a coin in the
## hat (StatueCoin) he talks without moving his lips: if the witness is one of the case's clues, he saw whether the
## culprit's glasses shone in the moonlight. Cuffed or shouted at, he's offended and goes back to being a statue for
## the whole case, like the circus's tamer. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_estatua.glb")
const SHOUT_REACH := 5.0
## Where the hat lies, by his feet.
const HAT_AT := Vector3(0.62, 0.05, 0.25)
const GOLD := Color(0.95, 0.78, 0.3)

var case: CrimeSceneCase
## He saw whether the culprit wears glasses.
var knows := false
var tipped := false
var offended := false
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("living_statue")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.3, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 800.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_STATUE"


func use(_cop: Cop) -> void:
	if offended:
		say("STATUE_OFFENDED")
	elif not tipped:
		say("STATUE_STILL")
	elif knows and case:
		case.found("witness")
		say("STATUE_SAW_GLASSES" if case.culprit().glasses else "STATUE_SAW_NO_GLASSES", 6.0)
	else:
		say("STATUE_NOTHING")


## A coin in the hat: it shines there, and he's ready to talk.
func tip(cop: Cop) -> void:
	if not tipped:
		var coin := CylinderMesh.new()
		coin.top_radius = 0.03
		coin.bottom_radius = 0.03
		coin.height = 0.008
		PlaceBuilder.new(self).mesh(coin, HAT_AT, GOLD)
	tipped = true
	use(cop)


func cuffed(_seconds: float) -> void:
	offend()


## A cop shouted: if he was close, he takes offense.
func shouted_by(cop: Cop) -> void:
	if cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		offend()


func offend() -> void:
	if offended:
		return
	offended = true
	say("STATUE_OFFENDED")
	if knows and case:
		case.ruin("witness")


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
