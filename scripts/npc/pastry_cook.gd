class_name PastryCook
extends StaticBody3D

## One of the six cooks of the pastry contest (escena-del-crimen.md): all floury and alike, told apart by the color of
## the apron, the glasses, the hand that holds the whisk, the size of the shoes and, under the hat, the hair.
## The cops make his file for the board (escena-del-crimen.md, "Los sospechosos: fichas para el tablero"): a photo
## (he hides his face from the flash for a moment), his prints (floury: E with the print kit in hand cleans his hand
## first), his teeth (give him a donut or a loaf to bite) and his hair (E asks him to take off the hat; one of them
## won't until he gets something to eat). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_pastelero.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
## Seconds he covers his face after a photo.
const COVER_SECONDS := 3.0

## CookTraits.draw: name, apron, hair, glasses, left, shoe, teeth.
var traits := {}
## His table's number, from 0.
var index := 0
var case: CrimeSceneCase
## E with the print kit cleaned the flour off his hand.
var hand_clean := false
var hat_off := false
## He won't take off the hat until he gets something to eat.
var stubborn := false
var _model: Node3D
var _cover_left := 0.0
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("pastry_cooks")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("apron", CookTraits.APRONS[traits.apron])
	_tint("hair", CookTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	# A lefty holds the whisk in the other hand.
	part("whisk").scale.x = -1.0 if traits.left else 1.0
	var size := inverse_lerp(CookTraits.SHOE_MIN, CookTraits.SHOE_MAX, traits.shoe)
	(_model.find_child("legs_cook_shoes", true, false) as Node3D).scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if _food(cop):
		return "PROMPT_COOK_FEED"
	if cop.belt and cop.belt.held_tool() is PrintKit and not hand_clean:
		return "PROMPT_COOK_CLEAN"
	return "PROMPT_COOK_HAT" if not hat_off else "PROMPT_COOK_TALK"


## E on him: food in hand, he bites it; the print kit in hand, the cop cleans his hand; else the hat.
func use(cop: Cop) -> void:
	var food := _food(cop)
	if food:
		feed(food)
	elif cop.belt and cop.belt.held_tool() is PrintKit and not hand_clean:
		hand_clean = true
		say("COOK_CLEAN_%d" % (index % CookTraits.COUNT))
	elif not hat_off:
		ask_hat()
	else:
		say("COOK_TALK")


## Bites a donut from the box or the loaf: his teeth for the file. A stubborn one takes off the hat for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("COOK_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	say("COOK_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_hat()


func ask_hat() -> void:
	if stubborn:
		say("COOK_HAT_NO")
		return
	_take_off_hat()


func _take_off_hat() -> void:
	hat_off = true
	part("cap").visible = false
	say("COOK_HAT_OFF")
	_file("hair")


## The camera's flash in his face (PhotoCamera): the photo counts unless he's still covering from the last one.
func photographed(_cop: Cop) -> void:
	if _cover_left > 0.0:
		say("COOK_COVERED")
		return
	_cover_left = COVER_SECONDS
	say("COOK_NO_PHOTOS")
	_file("photo")


## The print kit on him (PrintKit): a floury smudge until his hand is clean, then his prints.
func dusted(_cop: Cop) -> String:
	if not hand_clean:
		return "PRINTS_FLOUR"
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


func covering() -> bool:
	return _cover_left > 0.0


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_cover_left = maxf(_cover_left - delta, 0.0)
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _food(cop: Cop) -> Node:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.file_part(index, what)


## A part of his model by name (apron, hair, glasses, whisk, cap...).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
