class_name PostCarrier
extends StaticBody3D

## One of the six mail carriers (escena-correo.md, "Los seis carteros"): the same cap, yellow vest, leather bag and
## gloves as the other five. Under the cap, their own hair (tinted); their shoes (stretched to their size), their teeth
## (shown when they bite), their tongue (shown when they stick it out, step 3) and the tag of their route on the bag.
## E on them, they tell which route they cover. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_postal.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4
const PINK := Color(0.95, 0.5, 0.55)

## CarrierTraits.draw: name, hair, shoe, teeth, blue, route.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("post_carriers")
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
	_tint("hair", CarrierTraits.HAIRS[traits.hair])
	_tint("tag", PostOffice.ROUTE_COLORS[traits.route])
	_tint("tongue", PINK)
	part("teeth").visible = false
	part("tongue").visible = false
	var size := inverse_lerp(CarrierTraits.SHOE_MIN, CarrierTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_CARRIER_TALK"


## E on them: a line about their route (a different one each time, in an order that starts at their number), which
## always says which route they cover.
func use(_cop: Cop) -> void:
	say(tr("CARRIER_LINE_%d" % ((index + _lines_said) % LINES)) % route_name())
	_lines_said += 1


## The route they cover, translated ("el recorrido rojo").
func route_name() -> String:
	return tr("ROUTE_%s" % traits.route)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of their model by name (cap, hair, teeth, tongue, legs, tag, glove_left, glove_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
