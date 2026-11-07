class_name DonaRamona
extends AnimatableBody3D

## Doña Ramona (docs/diseno/allanamiento-jugueteria.md, "Doña Ramona"), the toy store's gossip: a grandmother buying
## gifts for her 14 grandchildren, walking the front aisle back and forth and stopping to look at the shelves. Without a
## toy she's busy; a cop who hands her one (E with a toy off a shelf) solved a gift and hears where she saw don Cucho
## put something away (`clue`, set by the story). Once per cop. The store sets `route`, in its space. Every number here
## is (propuesta).

## A cop gave her a toy and she told what she saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_dona_ramona.glb")
const WALK_SPEED := 0.7
## How long she looks at the shelves at each end of her walk, and how long she stands still after talking.
const LOOK := 6.0
const LISTEN := 4.0
const SIZE := Vector3(0.7, 1.6, 0.6)

## The checklist line for what she saw, and the longer thing she tells (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The points she walks between, in the parent's space.
var route: Array[Vector3] = []
## The cops who already gave her a toy, and the gifts she has so far.
var givers := {}
var gifts := 0
var has_told := false
var _index := 1
var _wait := 0.0
var _bubble: Label3D


func _ready() -> void:
	sync_to_physics = false
	collision_layer = 1
	collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var look: Node3D = MODEL.instantiate()
	look.scale = Vector3.ONE * 0.9
	add_child(look)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 34
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	if not route.is_empty():
		position = route[0]


func prompt_key(cop: Cop) -> String:
	return "PROMPT_GIVE_TOY" if cop.get_node("Grabber").held is ShelfToy else "PROMPT_TALK_RAMONA"


## E on her: a toy solves a gift and buys what she saw, once per cop; without one she's busy.
func use(cop: Cop) -> void:
	_wait = maxf(_wait, LISTEN)
	_face(cop.global_position)
	var grabber: Grabber = cop.get_node("Grabber")
	var held := grabber.held
	if not held is ShelfToy:
		_say("RAMONA_BUSY", 3.0)
		return
	grabber.release()
	held.queue_free()
	SchoolPupil.tell_hands(cop)
	gifts += 1
	if givers.has(cop):
		_say("RAMONA_AGAIN", 4.0)
		return
	givers[cop] = true
	if clue_speech == "":
		_say("RAMONA_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if route.size() < 2:
		return
	if _wait > 0.0:
		_wait -= delta
		return
	var to := route[_index]
	var left := to - position
	left.y = 0.0
	if left.length() <= WALK_SPEED * delta:
		position = Vector3(to.x, position.y, to.z)
		_index = (_index + 1) % route.size()
		_wait = LOOK
		return
	position += left.normalized() * WALK_SPEED * delta
	_face(to)


func _face(at: Vector3) -> void:
	var to := at - global_position
	to.y = 0.0
	if to.length() > 0.1:
		rotation.y = atan2(to.x, to.z)


func _say(key: String, seconds := 3.0) -> void:
	_bubble.text = key
	_bubble.show()
	var said_now := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said_now:
			_bubble.hide())
