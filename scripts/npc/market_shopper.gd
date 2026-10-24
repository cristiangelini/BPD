class_name MarketShopper
extends StaticBody3D

## A shopper at a market stall's counter (politico-mercado.md, step 1), one of the usual neighbors. E on them: a line
## about the market, a different one each time. Cuffed, they complain like any neighbor.

const MODELS := {
	"cliente": preload("res://assets/models/npc_cliente.glb"),
	"clienta": preload("res://assets/models/npc_clienta.glb"),
	"senora": preload("res://assets/models/npc_senora.glb"),
	"vecina": preload("res://assets/models/npc_vecina.glb"),
}
const LOOKS: Array[String] = ["cliente", "clienta", "senora", "vecina"]
const LINES := 8
const SAY_TIME := 4.0

@export var look := "cliente"
## Which line comes next (the market draws a different start for each).
var next_line := 0
var _bubble: Label3D
var _bubble_left := 0.0
var _cuffed_left := 0.0


func _ready() -> void:
	add_to_group("market_shoppers")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	var model: Node3D = MODELS[look].instantiate()
	# The models face +Z; the shopper faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	_bubble = make_bubble()
	add_child(_bubble)


## A speech bubble over an NPC's head, hidden until they say something.
static func make_bubble() -> Label3D:
	var bubble := Label3D.new()
	bubble.name = "Bubble"
	bubble.position = Vector3(0, 1.9, 0)
	bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bubble.no_depth_test = true
	bubble.pixel_size = 0.004
	bubble.outline_size = 8
	bubble.font_size = 36
	bubble.width = 900.0
	bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bubble.hide()
	return bubble


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_SHOPPER"


func use(_cop: Cop) -> void:
	say("SHOPPER_%d" % (next_line % LINES))
	next_line += 1


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


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
