class_name Gossip
extends Node3D

## The gossiping customer (docs/diseno/panaderia.md, "La panadera"): a regular who stands in the shop reading the
## paper and knows everything about Marta. E on him: he wants a loaf. Bring one to him (any loaf, held or thrown)
## and he eats it and tells what he saw (`clue`, set by the bakery). He plays the vecina's part, so nothing scares
## him off. Every number here is (propuesta).

## He asked for his loaf (the checklist shows the errand).
signal asked
## He got his loaf and told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_cliente.glb")
const PAPER := Color(0.92, 0.9, 0.82)
## He calls cops closer than this, every PSST_EVERY seconds, until someone talks to him.
const PSST_RANGE := 5.0
const PSST_EVERY := 10.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the bakery).
var clue := ""
var clue_speech := ""
var was_asked := false
var fed := false
var _since_psst := PSST_EVERY
## Cuffed by a cop: complains and says nothing until free (herramientas.md).
var _cuffed_left := 0.0
var _bubble: Label3D


func _ready() -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	body.add_child(shape)
	body.add_child(MODEL.instantiate())
	var paper := MeshInstance3D.new()
	var sheet := BoxMesh.new()
	sheet.size = Vector3(0.45, 0.32, 0.02)
	paper.mesh = sheet
	var material := StandardMaterial3D.new()
	material.albedo_color = PAPER
	paper.material_override = material
	paper.position = Vector3(0, 1.15, 0.35)
	paper.rotation.x = -0.3
	body.add_child(paper)
	add_child(body)

	# A loaf touching him (in a cop's hands or thrown) reaches him.
	var hands := Area3D.new()
	hands.name = "Hands"
	hands.collision_layer = 0
	hands.collision_mask = 4
	var reach := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.2, 1.4, 1.2)
	reach.shape = box
	reach.position.y = 0.9
	hands.add_child(reach)
	hands.body_entered.connect(_on_hands_entered)
	add_child(hands)

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
	return "PROMPT_GOSSIP"


## E on him: the first time he asks for a loaf; once he ate it, he repeats what he saw.
func use(_cop: Cop) -> void:
	if is_cuffed():
		_say("NPC_CUFFED_QUIET")
		return
	if fed:
		_say(clue_speech, 6.0)
		return
	_say("GOSSIP_WAITING" if was_asked else "GOSSIP_ASK", 5.0)
	if not was_asked:
		was_asked = true
		asked.emit()


## A loaf reaches him: he eats it and tells. If it hid something, he bites on it and it falls out.
func feed(loaf: Bread) -> void:
	if fed or loaf.is_broken:
		return
	fed = true
	was_asked = true
	loaf.eaten()
	_say(clue_speech, 8.0)
	told.emit(clue)


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if was_asked or is_cuffed():
		return
	_since_psst += delta
	if _since_psst < PSST_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= PSST_RANGE:
			_since_psst = 0.0
			_say("GOSSIP_PSST")
			return


func _on_hands_entered(body: Node3D) -> void:
	if body is Bread:
		feed(body as Bread)


func _say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	var said := text
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
