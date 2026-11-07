class_name TheaterGhost
extends StaticBody3D

## One of the six ghost actors (escena-teatro.md, "Los seis fantasmas"): the same white sheet with two eye holes,
## gloves and plastic chains as the other five. Under the sheet, their own hair (tinted); their shoes peeking out
## (stretched to their size), their teeth (shown when they bite) and the patch of their embroidery on the hem. The cops
## make their file for the board (step 3) with E and what's in hand: the camera's flash (their photo: the shoes), the
## print kit (their prints; a glove comes off), a donut or a loaf (they bite it: their teeth). With empty hands: first
## they tell which embroidery is theirs and why, then the sheet comes off (their hair; one is too shy until they get
## something to eat), then they sing a note (deep or not). Each goes to their file (CrimeSceneCase.guard_part). A honey
## lozenge before they sing clears their voice: the note goes to the file, but says nothing (step 6). Every number here
## is (propuesta).

const MODEL := preload("res://assets/models/npc_fantasma.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
## Seconds their teeth show.
const SHOW_SECONDS := 2.5

## GhostTraits.draw: name, hair, shoe, teeth, deep, embroidery.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var talked := false
var sheet_on := true
## Too shy to take off the sheet until they get something to eat ("sin sábana me da vergüenza").
var shy := false
var sang := false
## A honey lozenge cleared their voice before they sang.
var cleared := false
var _teeth_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("theater_ghosts")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", GhostTraits.HAIRS[traits.hair])
	_tint("embroidery", GhostTraits.EMBROIDERY_COLORS[traits.embroidery])
	part("teeth").visible = false
	var size := inverse_lerp(GhostTraits.SHOE_MIN, GhostTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if cop and _food(cop):
		return "PROMPT_GHOST_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_GHOST_PRINTS"
	if talked and sheet_on:
		return "PROMPT_GHOST_SHEET"
	if talked and not sang:
		return "PROMPT_GHOST_SING"
	return "PROMPT_GHOST_TALK"


## E on them: food in hand, they bite it; with empty hands their embroidery, the sheet, a note and then their
## embroidery again. (The print kit and the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop) if cop else null
	var held: Node = cop.get_node("Grabber").held if cop else null
	if food:
		feed(food)
	elif held is HoneyLozenge:
		cop.get_node("Grabber").release()
		take_lozenge(held as HoneyLozenge)
	elif talked and sheet_on:
		ask_sheet()
	elif talked and not sang:
		sing()
	else:
		talk()


## Their embroidery and why it is theirs: it goes to their file.
func talk() -> void:
	say(tr("GHOST_EMBROIDERY_%s" % traits.embroidery))
	if not talked:
		talked = true
		_file("embroidery")


## Bites a donut from the box or the loaf: their teeth for the file. A shy one takes off the sheet for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("GHOST_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = SHOW_SECONDS
	part("teeth").visible = true
	say("GHOST_BITES")
	_file("teeth")
	if shy and sheet_on:
		shy = false
		_take_off_sheet()


func ask_sheet() -> void:
	if shy:
		say("GHOST_SHEET_NO")
		return
	_take_off_sheet()


func _take_off_sheet() -> void:
	sheet_on = false
	part("sheet").visible = false
	say("GHOST_SHEET_OFF")
	_file("hair")


## A honey lozenge: if they haven't sung yet, their voice is clear now and nobody will tell whether it's deep.
func take_lozenge(lozenge: HoneyLozenge) -> void:
	if lozenge:
		lozenge.eat()
	if sang:
		say("GHOST_LOZENGE_LATE")
		return
	cleared = true
	say("GHOST_LOZENGE")


## They sing a note of the founder's aria: deep or not, for the file. Cleared by a lozenge, a clean note that tells
## nothing.
func sing() -> void:
	sang = true
	if cleared:
		say("GHOST_SING_CLEARED")
		if case:
			case.file_part(index, "voice")
		return
	say("GHOST_SING_DEEP" if traits.deep else "GHOST_SING_HIGH")
	_file("voice")
	# The founder's aria was sung deep that night: hearing a deep voice tells it's a clue.
	if traits.deep and case:
		case.found("voice")


## The camera's flash in their face (PhotoCamera): their photo, with their shoes under the hem.
func photographed(_cop: Cop) -> void:
	say("GHOST_FLASH")
	_file("photo")


## The print kit on them (PrintKit): their prints (the right glove comes off for it).
func dusted(_cop: Cop) -> String:
	part("glove_right").visible = false
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	if _teeth_left > 0.0:
		_teeth_left -= delta
		part("teeth").visible = _teeth_left > 0.0
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _food(cop: Cop) -> Node:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.guard_part(index, what)


## A part of their model by name (sheet, hair, teeth, legs, embroidery, glove_left, glove_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
