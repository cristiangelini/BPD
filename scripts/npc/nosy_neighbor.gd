class_name NosyNeighbor
extends StaticBody3D

## Doña Pepa, the gossip of 30A (docs/diseno/edificio.md, "El encargado y la vecina"): she watches everything through
## her peephole, but only talks if someone walks her dog. E takes Cuqui's leash (one hand busy: no grabbing); a whole
## lap of the hallway, out to its far end and back to her door in at least LAP_TIME s, and she tells what she saw go in
## and out of 30B. Once per cop. Every number here is (propuesta).

## She told a cop what she saw: the line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_pepa.glb")
const LAP_TIME := 10.0
## Back at her door: this close.
const HOME := 1.6
const LINES := ["PEPA_LINE_1", "PEPA_LINE_2", "PEPA_LINE_3"]
const LINE_EVERY := 8.0
const TALK_RANGE := 5.0

## What she saw, one per cop who walks Cuqui (the case fills it; a vague line otherwise).
var tips: Array[String] = []
## Where the hallway's far end is, in the parent's space: the lap must get past this x.
var far_x := 0.0
var dog: LeashedDog
## The cops who already walked Cuqui.
var walkers: Array[Cop] = []
var _walker: Cop
var _reached_far := false
var _walk_time := 0.0
var _since_line := 0.0
var _line := 0
var _bubble: Label3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	var model := MODEL.instantiate()
	model.scale = Vector3.ONE * 0.85
	add_child(model)
	_bubble = Label3D.new()
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.position.y = 1.8
	_bubble.hide()
	add_child(_bubble)
	dog = LeashedDog.new()
	dog.owner_npc = self
	dog.position = position + basis.z * 0.8 + basis.x * 0.6
	get_parent().add_child.call_deferred(dog)


func prompt_key(cop: Cop) -> String:
	if _walker or walkers.has(cop) or cop.leash:
		return ""
	return "PROMPT_WALK_DOG"


## E: the leash to this cop, and off for a lap.
func use(cop: Cop) -> void:
	if prompt_key(cop) == "":
		return
	_walker = cop
	_reached_far = false
	_walk_time = 0.0
	cop.leash = dog
	dog.walker = cop
	_say("PEPA_TAKE_HIM")


func walker() -> Cop:
	return _walker


func _physics_process(delta: float) -> void:
	_since_line += delta
	if _walker:
		_walk(delta)
	elif _since_line >= LINE_EVERY and _nearest_cop() != null:
		_say(LINES[_line % LINES.size()])
		_line += 1


func _walk(delta: float) -> void:
	if not is_instance_valid(_walker) or _walker.leash != dog or absf(_walker.global_position.y - global_position.y) > 2.0:
		# Let go, or gone in the elevator: Cuqui runs home and nothing was walked.
		_end_walk(false)
		return
	_walk_time += delta
	var at := get_parent_node_3d().to_local(_walker.global_position)
	var home := get_parent_node_3d().to_local(global_position)
	if signf(at.x - far_x) == signf(home.x - far_x) * -1.0 or absf(at.x - far_x) < 0.3:
		_reached_far = true
	if _reached_far and _walk_time >= LAP_TIME and at.distance_to(home) < HOME:
		_end_walk(true)


func _end_walk(done: bool) -> void:
	var cop := _walker
	_walker = null
	dog.walker = null
	if is_instance_valid(cop) and cop.leash == dog:
		cop.leash = null
	if not done:
		_say("PEPA_CUQUI_BACK")
		return
	walkers.append(cop)
	var text := tips[walkers.size() - 1] if walkers.size() <= tips.size() else tr("PEPA_TIP_VAGUE")
	_say(text, 6.0)
	told.emit(text)


func _nearest_cop() -> Cop:
	for node in get_tree().get_nodes_in_group("cops"):
		if (node as Cop).global_position.distance_to(global_position) < TALK_RANGE:
			return node
	return null


func _say(key: String, seconds := 3.0) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
