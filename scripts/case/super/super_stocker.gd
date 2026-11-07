class_name SuperStocker
extends StaticBody3D

## Lalo, the supermarket's stocker and its gossip (allanamiento-super.md, "Don Ofertón y Lalo"). He spends the day
## building a pyramid of cans in front of him and only talks while he works: a cop who drops HAND_OVER cans by his hands,
## one at a time, hears, without him looking up, where he saw Don Ofertón hide something (`clue`, set by the story).
## Once per cop. If his pyramid falls before the last can (a cop or something fast hits it), the count starts over for
## everyone. E on him only gets him asking for cans. Every number here is (propuesta).

## A cop handed him the cans and he told what he saw: the checklist line, already translated.
signal told(text: String)
## His pyramid fell.
signal pyramid_fell

const MODEL := preload("res://assets/models/npc_lalo.glb")
const SCALE := 0.8
const HAND_OVER := 3
## How close to him a dropped can has to be, and how long he takes with each one.
const HAND_RANGE := 1.2
const TAKE_EVERY := 1.0
## His pyramid, in front of him: the base he already has, and how hard something has to hit it to knock it down.
const PYRAMID_AT := Vector3(0, 0, 0.8)
const BASE_CANS := 3
const KNOCK_SPEED := 1.5
const IDLE_LINES := ["LALO_IDLE_1", "LALO_IDLE_2", "LALO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The checklist line for what he saw and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## How many cans each cop has handed him on this pyramid, and the cops he already talked to.
var handed := {}
var listeners := {}
var has_told := false
var _take_wait := 0.0
var _since_idle := 0.0
var _idle_line := 0
var _cans: Array[MeshInstance3D] = []
var _bubble: Label3D


func _ready() -> void:
	add_to_group("super_stockers")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.3
	shape.shape = capsule
	shape.position.y = 0.65
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * SCALE
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.6
	add_child(_bubble)
	var area := Area3D.new()
	area.name = "Pyramid"
	area.collision_layer = 0
	area.collision_mask = 6
	var box := CollisionShape3D.new()
	var size := BoxShape3D.new()
	size.size = Vector3(0.6, 0.6, 0.4)
	box.shape = size
	box.position = PYRAMID_AT + Vector3(0, 0.3, 0)
	area.add_child(box)
	add_child(area)
	area.body_entered.connect(_on_pyramid_hit)
	_stack(BASE_CANS)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_LALO"


## E on him: he won't stop working to chat.
func use(cop: Cop) -> void:
	_say("LALO_AGAIN" if listeners.has(cop) else "LALO_HAND_ME", 4.0)


## How many cans his pyramid has now.
func cans() -> int:
	return _cans.size()


## A can dropped by his hands by `cop`: on the pyramid, and at the last one, what he saw.
func take(can: Node3D, cop: Cop) -> void:
	can.queue_free()
	_stack(1)
	if listeners.has(cop):
		_say("LALO_THANKS_0")
		return
	handed[cop] = handed.get(cop, 0) + 1
	if handed[cop] < HAND_OVER:
		_say("LALO_THANKS_%d" % handed[cop])
		return
	handed.erase(cop)
	listeners[cop] = true
	if clue_speech == "":
		_say("LALO_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


## The pyramid falls: back to its base, and nobody's cans count anymore.
func knock_down() -> void:
	if _cans.size() <= BASE_CANS and handed.is_empty():
		return
	handed.clear()
	while _cans.size() > BASE_CANS:
		_cans.pop_back().queue_free()
	_say("LALO_FELL")
	pyramid_fell.emit()


func _on_pyramid_hit(body: Node3D) -> void:
	if body is Cop or (body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > KNOCK_SPEED):
		knock_down()


## The cans on his pyramid: rows of 3, 2 and 1, then 3 again on top, each one half a can in from the one below.
func _stack(count: int) -> void:
	for n in count:
		var i := _cans.size()
		var row := i / 3
		var col := i % 3
		var mesh := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.05
		cylinder.bottom_radius = 0.05
		cylinder.height = 0.12
		mesh.mesh = cylinder
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.85, 0.25, 0.2) if i % 2 == 0 else Color(0.95, 0.8, 0.25)
		mesh.material_override = material
		mesh.position = PYRAMID_AT + Vector3((col - 1) * 0.1 + (row % 2) * 0.05, 0.06 + row * 0.12, 0)
		add_child(mesh)
		_cans.append(mesh)


## The supermarket's cans lying loose by his hands, one at a time.
func _physics_process(delta: float) -> void:
	_take_wait -= delta
	if _take_wait <= 0.0:
		for node in get_tree().get_nodes_in_group("super_cans"):
			var can := node as Grabbable
			if not can.is_held() and can.global_position.distance_to(global_position) < HAND_RANGE:
				var grabber: Node = instance_from_id(can.last_holder) as Node if can.last_holder != 0 else null
				if grabber and grabber.get_parent() is Cop:
					_take_wait = TAKE_EVERY
					take(can, grabber.get_parent())
					break
	_since_idle += delta
	if _since_idle < IDLE_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= TALK_RANGE:
			_say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return


func _say(key: String, seconds := 3.0) -> void:
	_since_idle = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if is_instance_valid(_bubble) and _bubble.text == said:
			_bubble.hide())
