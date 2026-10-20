class_name PoodleLady
extends StaticBody3D

## The poodle lady (docs/diseno/peluqueria.md, "La señora del caniche"), the salon's vecina: she waits in the reception
## for Fifí, her poodle, who is still in a cage. E on her: she asks for Fifí. Bring the poodle close to her and she
## takes it in her arms and tells what she saw (`clue`, set by the story). Every number here is (propuesta).

## She asked for Fifí (the checklist can show the errand).
signal asked
## She got Fifí back and told what she saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_senora.glb")
## Fifí reaches her arms from this close (dropped, thrown or carried up to her).
const ARMS_RANGE := 1.3
## She calls cops closer than this, every CALL_EVERY seconds, until someone talks to her.
const CALL_RANGE := 7.0
const CALL_EVERY := 10.0
## Where she holds Fifí, from her feet.
const ARMS := Vector3(0, 0.75, 0.45)

## The checklist line for what she saw, and the longer thing she says (both translated, set by the story).
var clue := ""
var clue_speech := ""
var was_asked := false
var returned := false
var poodle: Dog
var _since_call := CALL_EVERY
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	add_child(MODEL.instantiate())
	var arms := Area3D.new()
	arms.name = "Arms"
	arms.collision_layer = 0
	arms.collision_mask = 4
	var reach := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = ARMS_RANGE
	reach.shape = ball
	reach.position = Vector3(0, 0.8, 0.3)
	arms.add_child(reach)
	arms.body_entered.connect(_on_arms_entered)
	add_child(arms)
	_bubble = Label3D.new()
	_bubble.position = Vector3(0, 2.15, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LADY"


## E on her: the first time she asks for Fifí; once she has her, she repeats what she saw.
func use(_cop: Cop) -> void:
	if returned:
		_say(clue_speech if clue_speech != "" else "LADY_THANKS", 6.0)
		return
	_say("LADY_WAITING" if was_asked else "LADY_ASK", 5.0)
	if not was_asked:
		was_asked = true
		asked.emit()


## Fifí reaches her: whoever holds her lets go, she takes her in her arms and tells.
func take(dog: Dog) -> void:
	if returned:
		return
	returned = true
	was_asked = true
	for cop in get_tree().get_nodes_in_group("cops"):
		var grabber := cop.get_node_or_null("Grabber")
		if grabber and grabber.held == dog:
			grabber.release()
	poodle = dog
	dog.remove_from_group("dogs")
	dog.set_physics_process(false)
	dog.freeze = true
	dog.collision_layer = 0
	dog.collision_mask = 0
	dog.global_transform = global_transform.translated_local(ARMS)
	# Facing the same way she does, in her arms.
	dog._model.rotation.y = 0.0
	_say(clue_speech if clue_speech != "" else "LADY_THANKS", 8.0)
	told.emit(clue)


func _physics_process(delta: float) -> void:
	if poodle:
		poodle.global_transform = global_transform.translated_local(ARMS)
	if was_asked:
		return
	_since_call += delta
	if _since_call < CALL_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= CALL_RANGE:
			_since_call = 0.0
			_say("LADY_CALL")
			return


func _on_arms_entered(body: Node3D) -> void:
	if body is Dog and (body as Dog).poodle:
		take(body as Dog)


func _say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	var said := text
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
