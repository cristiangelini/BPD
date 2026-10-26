class_name VipTray
extends StaticBody3D

## The little shelf on the bars of Rulo's VIP cell (carcel-vip.md, step 3), sticking out into the corridor: what's put
## on it and let go of is something brought to him (`put`). E on it is the rest of what he asks for: a foot massage
## (MASSAGE presses) or an applause (two cops at once). E with something of his in hand puts it on the shelf. Every
## number here is (propuesta).

signal put(item: Grabbable)
signal pressed(cop: Cop)

const SIZE := Vector3(0.5, 0.04, 0.6)
const HEIGHT := 1.0

var requests: VipRequests
var _area: Area3D


func _ready() -> void:
	collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = HEIGHT
	add_child(shape)
	add_child(CopTool.piece(CopTool.box(SIZE), VipPlan.GOLD, Vector3(0, HEIGHT, 0)))
	_area = Area3D.new()
	_area.name = "OnTray"
	_area.collision_layer = 0
	_area.collision_mask = 4
	var zone := CollisionShape3D.new()
	var space := BoxShape3D.new()
	space.size = Vector3(SIZE.x, 0.5, SIZE.z)
	zone.shape = space
	zone.position.y = HEIGHT + 0.27
	_area.add_child(zone)
	add_child(_area)
	_area.body_exited.connect(_on_left)


func _physics_process(_delta: float) -> void:
	for body in _area.get_overlapping_bodies():
		if body is Grabbable and not (body as Grabbable).is_held() and not body.is_in_group("vip_offered"):
			body.add_to_group("vip_offered")
			put.emit(body)


## Something he didn't want is offered again once it's off the shelf.
func _on_left(body: Node3D) -> void:
	if body.is_in_group("vip_offered"):
		body.remove_from_group("vip_offered")


func prompt_key(cop: Cop) -> String:
	return requests.tray_prompt(cop) if requests else ""


## E: put what's in hand on the shelf, or the massage and the applause (ActionSync runs it on every PC).
func use(cop: Cop) -> void:
	var held: Grabbable = cop.get_node("Grabber").held
	if held:
		cop.get_node("Grabber").release()
		held.global_position = global_position + Vector3.UP * (HEIGHT + 0.05)
		held.linear_velocity = Vector3.ZERO
		return
	pressed.emit(cop)
