class_name FakeTicketsRig
extends PrintShopRig

## The fake tickets (allanamiento-imprenta.md, "Las entradas truchas"): Don Renglón prints tickets for the sold-out
## concert of Los Desafinados. A cop who steps this close to where the box was hidden comes away with a ticket stuck to
## the sole, the story's own clue (on the checklist the first time). And a line of fans waits outside the door,
## screaming each time a cop goes in or out. Every number here is (propuesta).

signal screamed

const FAN_MODEL := preload("res://assets/models/npc_fan.glb")
const STICK_RANGE := 1.5
const CHECK_EVERY := 0.25
const FANS := 5
## The fans' line along the sidewalk, east of the door, and how often they can scream.
const LINE_FROM := Vector3(-4.6, 0.0, 10.4)
const LINE_STEP := 1.0
const SCREAM_REST := 3.0
const TICKET_PINK := Color(0.94, 0.48, 0.66)

## The cops who already have a ticket stuck to the sole.
var stuck := {}
var noticed := false
var fans: Array[Node3D] = []
var screams := 0
var _since := 0.0
var _rest := 0.0


func setup(place: PrintShop) -> void:
	super.setup(place)
	for i in FANS:
		var fan: Node3D = FAN_MODEL.instantiate()
		fan.position = LINE_FROM + Vector3(LINE_STEP * i, PrintShop.FLOOR_TOP, 0.0)
		fan.rotation.y = -PI / 2 + (i % 2) * 0.3
		shop.add_child(fan)
		fans.append(fan)
	var door := Area3D.new()
	door.name = "FansDoor"
	door.collision_layer = 0
	door.collision_mask = 2
	door.position = Vector3(PrintShop.ENTRANCE_X, 1.0, PrintShop.HALF_Z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(PrintShop.ENTRANCE_HALF * 2, 2.0, 0.6)
	shape.shape = box
	door.add_child(shape)
	shop.add_child(door)
	door.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop:
			scream())


## Where the box was hidden, in the shop's space.
func hiding_spot() -> Vector3:
	return PrintShop.SPOTS[shop.hidden_spots[0]].at


## The fans see the door move: "¡¡Aaah!! ¿Hay entradas?", unless they just screamed.
func scream() -> void:
	if _rest > 0.0:
		return
	_rest = SCREAM_REST
	screams += 1
	shop.raid.float_label(tr("PRINT_SHOP_FANS_SCREAM"), shop.to_global(LINE_FROM + Vector3(2.0, 2.4, 0)),
		TICKET_PINK)
	screamed.emit()


func _physics_process(delta: float) -> void:
	_rest = maxf(_rest - delta, 0.0)
	_since += delta
	if _since < CHECK_EVERY:
		return
	_since = 0.0
	var spot := shop.to_global(hiding_spot())
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var flat := Vector2(cop.global_position.x - spot.x, cop.global_position.z - spot.z)
		if flat.length() <= STICK_RANGE and not stuck.has(cop):
			stick(cop as Cop)


## A ticket sticks to the cop's sole; the first one is a clue.
func stick(cop: Cop) -> void:
	if stuck.has(cop):
		return
	stuck[cop] = true
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.16, 0.005, 0.07)
	var ticket := MeshInstance3D.new()
	ticket.name = "SoleTicket"
	ticket.mesh = mesh
	var paint := StandardMaterial3D.new()
	paint.albedo_color = TICKET_PINK
	ticket.material_override = paint
	ticket.position = Vector3(0.2, 0.01, 0.0)
	ticket.rotation.y = 0.6
	cop.model.add_child(ticket)
	cop.show_hint("HINT_TICKET_SOLE")
	if not noticed:
		noticed = true
		shop.raid.add_clue(tr("CLUE_TICKET_SOLE"))
