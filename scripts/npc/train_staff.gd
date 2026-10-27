class_name TrainStaff
extends StaticBody3D

## The train's staff (escena-tren.md, "El lugar"): don Silbato the engine driver in the locomotive, Picadora the
## ticket inspector and señor Mostaza with his food cart. E on one: a line of theirs, a different one each time. What
## each does in the case (the brake, the tickets, the cart going by) comes in step 4. Every number here is (propuesta).

const MODELS := {
	"engineer": preload("res://assets/models/npc_maquinista.glb"),
	"inspector": preload("res://assets/models/npc_guarda_tren.glb"),
	"vendor": preload("res://assets/models/npc_mostaza.glb"),
}
const LINES := 3

## engineer, inspector or vendor.
var role := "engineer"
var train: Train
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("train_staff")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	add_child(MODELS[role].instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	if _selling():
		return "PROMPT_TRAIN_VENDOR_BUY"
	return "PROMPT_TRAIN_" + role.to_upper()


## With the case on, señor Mostaza sells: buying something keeps him and his cart still a while (TrainClues.buy).
func use(cop: Cop) -> void:
	if _selling():
		train.clues.buy(cop)
		return
	say("TRAIN_%s_LINE_%d" % [role.to_upper(), _lines_said % LINES])
	_lines_said += 1


func _selling() -> bool:
	return role == "vendor" and train != null and train.clues != null


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
