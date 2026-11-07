class_name PrintShopKid
extends StaticBody3D

## Tipito (docs/diseno/allanamiento-imprenta.md, "Tipito, el aprendiz"), the print shop's apprentice and its gossip.
## He sorts the chibalete's type and he's always missing one letter: `wanted`, drawn by the seed among the wooden
## letters lying around the shop. Whoever brings him that one gets told what he saw Don Renglón hide (`clue`, set by
## the story), once per cop; another letter only gets "Esa no, esa es la Q". E on him gets him asking for his letter.
## Every number here is (propuesta).

## A cop brought him his letter and he told what he saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_tipito.glb")
## He's young and small: his model is scaled down.
const SCALE := 0.8
## A letter a cop handled lately, this close to him (m), was brought to him.
const GIVE_RANGE := 1.5
const HANDLED := 3.0
## He doesn't repeat himself about the same letter sooner than this.
const REPEAT := 4.0
const IDLE_LINES := ["TIPITO_IDLE_1", "TIPITO_IDLE_2", "TIPITO_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0

## The letter he's missing.
var wanted := "Ñ"
## The checklist line for what he saw, and the longer thing he says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops he already told.
var listeners := {}
var has_told := false
var letters_brought := 0
## What he said to the cops (not his idle lines), so the guests' Tipito says it too.
var news_count := 0
var news := ""
var _since_idle := 0.0
var _idle_line := 0
## Letter node id -> seconds until he talks about it again.
var _quiet := {}
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.25
	shape.shape = capsule
	shape.position.y = 0.62
	add_child(shape)
	var look: Node3D = MODEL.instantiate()
	look.scale = Vector3.ONE * SCALE
	add_child(look)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.75, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TIPITO"


## E on him: he asks for his letter.
func use(cop: Cop) -> void:
	_tell("TIPITO_AGAIN" if listeners.has(cop) else tr("TIPITO_ASK") % wanted, 5.0)


## A letter reached him from `cop`: the right one gets the gossip the first time for that cop, another gets told off.
func take(letter: WoodenLetter, cop: Cop) -> void:
	_quiet[letter.get_instance_id()] = REPEAT
	if letter.letter != wanted:
		_tell(tr("TIPITO_WRONG") % letter.letter, 3.0)
		return
	letters_brought += 1
	if cop == null or listeners.has(cop):
		_tell("TIPITO_THANKS", 3.0)
		return
	listeners[cop] = true
	if clue_speech == "":
		_tell("TIPITO_NOTHING", 5.0)
		return
	_tell(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


## Online, what the guests' Tipito takes from the host's (PrintShop.net_state): what he said, he says it there too.
func net_state() -> Array:
	return [news_count, news, has_told, letters_brought]


func apply_net_state(state: Array) -> void:
	if state[0] > news_count:
		_say(state[1], 6.0)
	news_count = state[0]
	news = state[1]
	has_told = state[2]
	letters_brought = state[3]


func _physics_process(delta: float) -> void:
	for id: int in _quiet.keys():
		_quiet[id] -= delta
		if _quiet[id] <= 0.0:
			_quiet.erase(id)
	# Online the letters are the host's: he takes them there.
	for node in get_tree().get_nodes_in_group("wooden_letters") if multiplayer.is_server() else []:
		var letter := node as WoodenLetter
		if letter == null or _quiet.has(letter.get_instance_id()):
			continue
		if letter.global_position.distance_to(global_position + Vector3.UP * 0.6) > GIVE_RANGE:
			continue
		var cops := letter.handling_cops(HANDLED)
		if not cops.is_empty():
			take(letter, cops[0])
	_since_idle += delta
	if _since_idle < IDLE_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= TALK_RANGE:
			_say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return


## Something he says to the cops, which the guests hear too.
func _tell(key: String, seconds: float) -> void:
	news_count += 1
	news = key
	_say(key, seconds)


func _say(key: String, seconds := 3.0) -> void:
	_since_idle = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
