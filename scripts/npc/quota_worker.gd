class_name QuotaWorker
extends StaticBody3D

## Nilda (docs/diseno/fabrica.md, "Nilda"), the operator of the eyes machine and the doll factory's gossip. She's
## behind with her quota and can't stop to talk: E on her and she says so. A cop who puts QUOTA dolls from the belt in
## her box gives her a break, and she tells what she saw Fermín hide (`clue`, set by the story). Every number here is
## (propuesta).

## She asked for help with her quota.
signal asked
## Her quota is done and she told what she saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_operaria.glb")
const QUOTA := 5
## Her box of finished dolls, beside her (in her own space, she faces +z).
const BOX_AT := Vector3(1.1, 0, 0.2)
const BOX_SIZE := Vector3(0.7, 0.5, 0.6)
## She grumbles at cops closer than this, every CALL_EVERY seconds, until someone talks to her.
const CALL_RANGE := 6.0
const CALL_EVERY := 10.0
const BUSY_LINES := ["NILDA_BUSY_1", "NILDA_BUSY_2", "NILDA_BUSY_3"]

## The checklist line for what she saw, and the longer thing she says (both translated, set by the story).
var clue := ""
var clue_speech := ""
var was_asked := false
var packed := 0
var served := false
var _since_call := CALL_EVERY
var _busy_line := 0
var _bubble: Label3D
var _count: Label3D


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
	var build := PlaceBuilder.new(self)
	build.open_box(BOX_AT, BOX_SIZE, "top", Color(0.72, 0.56, 0.36))
	var box := Area3D.new()
	box.name = "Box"
	box.collision_layer = 0
	box.collision_mask = 4
	var inside := CollisionShape3D.new()
	var space := BoxShape3D.new()
	space.size = BOX_SIZE - Vector3(0.1, 0.1, 0.1)
	inside.shape = space
	inside.position = BOX_AT + Vector3(0, BOX_SIZE.y / 2, 0)
	box.add_child(inside)
	box.body_entered.connect(_on_box_entered)
	add_child(box)
	_count = _label(BOX_AT + Vector3(0, BOX_SIZE.y + 0.3, 0), 32)
	_count.text = "0/%d" % QUOTA
	_count.hide()
	_bubble = _label(Vector3(0, 2.05, 0), 40)
	_bubble.name = "Bubble"
	_bubble.hide()


func _label(at: Vector3, size: int) -> Label3D:
	var label := Label3D.new()
	label.position = at
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.004
	label.outline_size = 10
	label.font_size = size
	label.width = 700.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	return label


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_NILDA"


## E on her: the first time she explains the deal; once her quota is done, she repeats what she saw.
func use(_cop: Cop) -> void:
	if served:
		_say(clue_speech if clue_speech != "" else "NILDA_THANKS", 6.0)
		return
	_say("NILDA_WAITING" if was_asked else "NILDA_ASK", 5.0)
	if not was_asked:
		was_asked = true
		_count.show()
		asked.emit()


## A doll lands in her box: it counts, and the box is emptied so it never fills up.
func pack(doll: Node3D) -> void:
	if served:
		return
	packed += 1
	_count.text = "%d/%d" % [packed, QUOTA]
	_count.show()
	for cop in get_tree().get_nodes_in_group("cops"):
		var grabber := cop.get_node_or_null("Grabber")
		if grabber and grabber.held == doll:
			grabber.release()
	doll.queue_free()
	if packed >= QUOTA:
		served = true
		was_asked = true
		_say(clue_speech if clue_speech != "" else "NILDA_THANKS", 8.0)
		told.emit(clue)


## Online: whether she asked, how many dolls she has and whether she told (NpcSync).
func net_state() -> Variant:
	return [was_asked, packed, served]


func apply_net_state(state: Variant) -> void:
	was_asked = state[0]
	packed = state[1]
	served = state[2]


func _physics_process(delta: float) -> void:
	if was_asked:
		return
	_since_call += delta
	if _since_call < CALL_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= CALL_RANGE:
			_since_call = 0.0
			_say(BUSY_LINES[_busy_line % BUSY_LINES.size()])
			_busy_line += 1
			return


func _on_box_entered(body: Node3D) -> void:
	if body.is_in_group("factory_dolls"):
		pack(body)


func _say(key: String, seconds := 3.0) -> void:
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
