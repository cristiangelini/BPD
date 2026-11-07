class_name ZooKeeper
extends StaticBody3D

## One of the six keepers (escena-zoo.md, "Los seis cuidadores"): the same green overalls, rubber boots and cap as the
## other five. Under the cap, their own hair (tinted); their boots (stretched to their size), their teeth (shown when
## they bite) and, if a parrot pecked them, a band-aid on the right hand, seen while their rubber gloves are off. E on
## them, they tell which animal they look after and so what they smell of. Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_cuidador.glb")
## Boot sizes stretch the boots from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)

## KeeperTraits.draw: name, hair, shoe, teeth, pecked, smell.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("zoo_keepers")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", KeeperTraits.HAIRS[traits.hair])
	part("teeth").visible = false
	part("bandage").visible = traits.pecked
	wear_gloves(false)
	var size := inverse_lerp(KeeperTraits.SHOE_MIN, KeeperTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.1
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_KEEPER_TALK"


## E on them: the animal they look after, and so their smell.
func use(_cop: Cop) -> void:
	say(tr("KEEPER_SMELL_%s" % traits.smell))


## The rubber gloves on (feeding time) or off: on, they cover the hands and the band-aid.
func wear_gloves(on: bool) -> void:
	part("glove_left").visible = on
	part("glove_right").visible = on
	part("bandage").visible = traits.pecked and not on


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


## A part of their model by name (cap, hair, teeth, legs, bandage, glove_left, glove_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
