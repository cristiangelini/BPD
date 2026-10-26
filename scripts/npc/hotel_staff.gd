class_name HotelStaff
extends StaticBody3D

## The Hotel Gran Siesta's people who aren't guests (escena-hotel.md, "El lugar"): don Bostezo the concierge, asleep
## behind the desk; señora Perlita, who was robbed; Tito the bellboy, with a suitcase always in hand; and doña Escoba
## the maid, upstairs with her laundry cart. E on any of them gets one of their lines, a different one each time. What
## they do in the case (the concierge's lie, the witness, the maid who wipes clues) comes in steps 3 and 4. Every
## number here is (propuesta).

## Who they can be: their model, the prompt and how many lines they have (HOTEL_<WHO>_LINE_<n>).
const WHO := {
	"concierge": {"model": "res://assets/models/npc_conserje.glb", "lines": 4},
	"perlita": {"model": "res://assets/models/npc_perlita.glb", "lines": 4},
	"bellboy": {"model": "res://assets/models/npc_botones.glb", "lines": 4},
	"maid": {"model": "res://assets/models/npc_mucama.glb", "lines": 4},
	"guest": {"model": "res://assets/models/npc_huesped.glb", "lines": 6},
}
## The maid's laundry cart, in front of her: its model, where it stands and its collision box.
const CART_MODEL := "res://assets/models/laundry_cart.glb"
const CART_AT := Vector3(0, 0, 0.95)
const CART_SIZE := Vector3(0.62, 0.9, 1.0)

var who := "guest"
var cart: StaticBody3D
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("hotel_people")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = (load(WHO[who].model) as PackedScene).instantiate()
	add_child(_model)
	if who == "maid":
		_cart()
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


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOTEL_" + who.to_upper()


## E on them: their next line.
func use(_cop: Cop) -> void:
	say(line_key(_lines_said))
	_lines_said += 1


## The key of their line number n (it goes round).
func line_key(n: int) -> String:
	return "HOTEL_%s_LINE_%d" % [who.to_upper(), n % int(WHO[who].lines)]


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 4.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of their model by name (towel, hair, cucumbers, glasses, teeth; yawn; suitcase; hat).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


## The laundry cart she pushes: a box nobody walks through.
func _cart() -> void:
	cart = StaticBody3D.new()
	cart.name = "Cart"
	cart.position = CART_AT
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = CART_SIZE
	shape.shape = box
	shape.position.y = CART_SIZE.y / 2.0
	cart.add_child(shape)
	cart.add_child((load(CART_MODEL) as PackedScene).instantiate())
	add_child(cart)
