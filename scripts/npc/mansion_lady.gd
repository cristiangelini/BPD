class_name MansionLady
extends StaticBody3D

## Señora Ofelia Monedero (escena-gato.md, "El lugar"): the richest woman in the city, in her silk dressing gown and
## pearls, fanning herself in the hall. E on her, she talks about Duquesa and about how much everything costs, a
## different line each time. A cat brought to her in a cop's arms or in the crate (escena-gato.md, "Entregarla"): Duquesa
## she takes in her arms ("¡Mi bebé!"); any other she sends off by her name. Every number here is (propuesta).

signal got_duchess
signal got_wrong_cat(cat: MansionCat)

const MODEL := preload("res://assets/models/npc_ofelia.glb")
const LINES := 5
## How close a cat has to come to her (in arms or in the crate) for her to look at it.
const TAKE_REACH := 1.4
## Where Duquesa sits in her arms.
const ARMS := Vector3(0, 0.95, 0.38)

var duchess_home := false

var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("mansion_lady")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MANSION_LADY"


func use(_cop: Cop) -> void:
	say("MANSION_LADY_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


## A cat brought to her: Duquesa goes to her arms for good; another one she sends off, and it runs to hide.
func receive(cat: MansionCat) -> void:
	if cat.crate:
		cat.crate.let_out()
	cat.free_from_arms()
	if not cat.duchess:
		say(tr("MANSION_LADY_WRONG_CAT") % tr(cat.cat_name))
		cat.escape()
		got_wrong_cat.emit(cat)
		return
	duchess_home = true
	cat.home = true
	cat.freeze = true
	cat.collision_layer = 0
	cat.collision_mask = 0
	cat.reparent(self)
	cat.position = ARMS
	cat.rotation = Vector3.ZERO
	say("MANSION_LADY_MY_BABY")
	got_duchess.emit()


func _physics_process(delta: float) -> void:
	_look_for_cats()
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _look_for_cats() -> void:
	if duchess_home:
		return
	for node in get_tree().get_nodes_in_group("mansion_cats"):
		var cat := node as MansionCat
		if cat.home or not (cat.is_held() or (cat.crate and cat.crate.is_held())):
			continue
		if _flat_distance(cat.global_position) < TAKE_REACH:
			receive(cat)
			return


func _flat_distance(to: Vector3) -> float:
	return Vector2(to.x - global_position.x, to.z - global_position.z).length()
