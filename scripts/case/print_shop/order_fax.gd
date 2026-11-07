class_name OrderFax
extends OfficePrinter

## The print shop's fax of urgent orders (docs/diseno/allanamiento-imprenta.md, "Su distracción, el fax de pedidos
## urgentes"): E on its green "enviar prueba" button and an urgent order comes out; Don Renglón goes to read it and set
## it in type at the chibalete with his back to everything (the floor boss's fix, on the same body). It works once
## every REST seconds, and the third time he catches on. Built on the fax's table, facing +z. Every number here is
## (propuesta).

## The button was pressed but this time he knows it's his own number.
signal caught_on

const FAX_MODEL := preload("res://assets/models/fax_machine.glb")
const REST := 45.0
## The orders that take him away; from the next one on he catches on.
const FOOLS := 2

## Seconds left before an order takes him away again.
var rest_left := 0.0
var sends := 0
var distractions := 0
## The order sheet sticking out of the fax while he is busy with it.
var order: MeshInstance3D


func _ready() -> void:
	var look: Node3D = FAX_MODEL.instantiate()
	add_child(look)
	var build := PlaceBuilder.new(self)
	build.shape(build.body(Vector3(0, 0.1, 0)), Vector3(0.45, 0.2, 0.35))
	button = PushButton.new()
	button.prompt = "PROMPT_PRINT_SHOP_FAX"
	button.color = Color(0.25, 0.7, 0.3)
	button.position = Vector3(0.18, 0.25, 0.2)
	button.scale = Vector3(0.5, 0.5, 0.5)
	add_child(button)
	button.pressed.connect(send)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.21, 0.3, 0.004)
	order = MeshInstance3D.new()
	order.mesh = mesh
	order.position = Vector3(0, 0.32, -0.16)
	order.rotation.x = -0.3
	order.material_override = build.material(Color(0.98, 0.96, 0.85))
	order.hide()
	add_child(order)


## "Enviar prueba": an urgent order comes out and he goes to set it, unless he got one less than REST seconds ago, or
## it's the third time and he catches on.
func send(_cop: Cop = null) -> void:
	sends += 1
	if is_jammed or rest_left > 0.0:
		return
	if distractions >= FOOLS:
		caught_on.emit()
		rest_left = REST
		return
	distractions += 1
	is_jammed = true
	jobs += 1
	rest_left = REST
	order.show()
	jammed.emit()


## He's done setting the order.
func fix() -> void:
	is_jammed = false
	order.hide()


func is_busy() -> bool:
	return is_jammed


func _physics_process(delta: float) -> void:
	rest_left = maxf(rest_left - delta, 0.0)
