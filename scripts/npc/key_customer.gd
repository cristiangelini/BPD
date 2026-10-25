class_name KeyCustomer
extends StaticBody3D

## Don Cosme (docs/diseno/ferreteria.md, "Don Cosme"), the hardware store's gossip: he has been waiting at the counter
## for an hour for his key copy. E on him: he asks for it. The cops can file it themselves in the key machine; bring
## him the new key and he tells what he saw (`clue`, set by the story). Every number here is (propuesta).

## He asked for his copy (the checklist can show the errand).
signal asked
## He got his key and told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_cosme.glb")
## The key reaches his hand from this close (dropped, thrown or carried up to him).
const HAND_RANGE := 1.0
## He calls cops closer than this, every CALL_EVERY seconds, until someone talks to him.
const CALL_RANGE := 7.0
const CALL_EVERY := 10.0

## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
var was_asked := false
var served := false
var _since_call := CALL_EVERY
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	add_child(MODEL.instantiate())
	var hand := Area3D.new()
	hand.name = "Hand"
	hand.collision_layer = 0
	hand.collision_mask = 4
	var reach := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = HAND_RANGE
	reach.shape = ball
	reach.position = Vector3(0, 0.9, 0.3)
	hand.add_child(reach)
	hand.body_entered.connect(_on_hand_entered)
	add_child(hand)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.05, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_COSME"


## E on him: the first time he asks for his copy; once he has it, he repeats what he saw.
func use(_cop: Cop) -> void:
	if served:
		_say(clue_speech if clue_speech != "" else "COSME_THANKS", 6.0)
		return
	_say("COSME_WAITING" if was_asked else "COSME_ASK", 5.0)
	if not was_asked:
		was_asked = true
		asked.emit()


## The new key reaches him: whoever holds it lets go, he pockets it and tells.
func take(key: Grabbable) -> void:
	if served:
		return
	served = true
	was_asked = true
	for cop in get_tree().get_nodes_in_group("cops"):
		var grabber := cop.get_node_or_null("Grabber")
		if grabber and grabber.held == key:
			grabber.release()
	key.queue_free()
	_say(clue_speech if clue_speech != "" else "COSME_THANKS", 8.0)
	told.emit(clue)


func _physics_process(delta: float) -> void:
	if was_asked:
		return
	_since_call += delta
	if _since_call < CALL_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= CALL_RANGE:
			_since_call = 0.0
			_say("COSME_CALL")
			return


func _on_hand_entered(body: Node3D) -> void:
	if body.is_in_group("key_copies"):
		take(body as Grabbable)


func _say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	var said := text
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
