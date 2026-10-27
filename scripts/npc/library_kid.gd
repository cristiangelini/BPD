class_name LibraryKid
extends StaticBody3D

## Tomasito (escena-biblioteca.md, "Las pistas"): the boy in pajamas with dinosaurs who fell asleep reading in the
## children's corner, lying on the rug with his picture book. E on him, he mumbles in his sleep; during the case, E
## reads him a story in a whisper (STORY_SECONDS, staying by him), and at the end he tells, half asleep, what kind of
## book the one he saw with the Golden Book was reading, if the witness is one of the case's clues. Every number here
## is (propuesta).

const MODEL := preload("res://assets/models/npc_tomasito.glb")
## A boy: the grown-up body, smaller.
const SIZE := 0.6
const MUMBLES := 3
## How long the story takes, in seconds.
const STORY_SECONDS := 10.0
## The reading cop has to stay this close, in meters.
const STORY_REACH := 2.0

var case: CrimeSceneCase
## He saw the culprit with the book: the witness is one of the case's clues.
var knows := false
## The kind of book the one he saw was reading (the culprit's genre).
var saw := ""
var reading := false
## The story was read to the end.
var heard := false
## Woke up scared in the blackout: he only wants his mom.
var scared := false
var _reader: Cop
var _story_left := 0.0

var _bubble: Label3D
var _bubble_left := 0.0
var _mumbles := 0


func _ready() -> void:
	add_to_group("library_kid")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.7, 0.4, 1.1)
	shape.shape = box
	shape.position.y = 0.2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	# Lying on his back on the rug, head to -Z.
	model.scale = Vector3.ONE * SIZE
	model.rotation.x = -PI / 2
	model.position = Vector3(0, 0.25, 0.5)
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.0
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	if reading:
		return "PROMPT_KID_LISTENING"
	return "PROMPT_KID_STORY" if case and not heard and not scared else "PROMPT_KID"


func use(cop: Cop) -> void:
	if reading:
		return
	if scared:
		say("KID_SCARED")
		return
	if case and not heard:
		reading = true
		_reader = cop
		_story_left = STORY_SECONDS
		if cop:
			cop.show_hint("HINT_KID_STORY_READING")
		return
	say("KID_MUMBLE_%d" % (_mumbles % MUMBLES))
	_mumbles += 1


## The story stopped halfway (the cop walked off): it has to start again.
func interrupt() -> void:
	if not reading:
		return
	reading = false
	if _reader:
		_reader.show_hint("HINT_KID_STORY_STOPPED")


## The blackout woke him up scared (LibraryNoise.blackout): if nobody read him his story yet, he won't tell anything.
func scare() -> void:
	if heard or scared:
		return
	interrupt()
	scared = true
	say("KID_SCARED")
	if knows and case:
		case.ruin("witness")


## The end of the story: he says what he saw, or just asks for another one.
func story_read() -> void:
	reading = false
	heard = true
	if knows:
		say(tr("KID_SAW") % tr("GENRE_" + saw), 6.0)
		if case:
			case.found("witness")
	else:
		say("KID_STORY_DONE", 4.0)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	if reading:
		_story_left -= delta
		if _reader and is_instance_valid(_reader) and _reader.global_position.distance_to(global_position) > STORY_REACH:
			interrupt()
		elif _story_left <= 0.0:
			story_read()
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
