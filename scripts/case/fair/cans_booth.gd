class_name CansBooth
extends Node3D

## The fun fair's cans booth (docs/diseno/allanamiento-parque.md, "Nube"): 3 cans stacked on the low shelf and 3 balls
## on the counter. Whoever knocks all 3 down with the balls wins, and Nube tells them what she saw. A can that falls, or
## the last ball off the counter, starts RESET seconds after which the cans stand up again and the balls come back.
## Built in the booth's space (the cans booth model's origin), its front to +z. Every number here is (propuesta).

## All 3 cans are down: `cop` threw the last ball (null if nobody did).
signal won(cop: Cop)
## The cans stood up again with some still standing after a throw.
signal missed

const CAN_RADIUS := 0.05
const CAN_HEIGHT := 0.14
const CAN_KG := 0.15
const BALL_RADIUS := 0.06
const BALL_KG := 0.3
const SHELF_TOP := 1.03
const SHELF_Z := -0.75
## The prizes' shelf above, where something can be hidden among the teddies.
const PRIZE_SHELF_TOP := 1.93
const COUNTER_TOP := 1.06
const COUNTER_Z := 0.8
const RESET := 5.0
## A can this far from where it stood, or this tilted, is down.
const MOVED := 0.12
const TILT := 0.6
const CAN_COLORS := [Color(0.85, 0.2, 0.2), Color(0.95, 0.75, 0.2), Color(0.25, 0.55, 0.9)]
const BALL_COLOR := Color(0.95, 0.95, 0.9)

var cans: Array[RigidBody3D] = []
var balls: Array[Grabbable] = []
## Seconds left before the cans stand up again; negative while nothing is counting.
var reset_left := -1.0
var wins := 0
var _can_homes: Array[Vector3] = []
var _ball_homes: Array[Vector3] = []
var _settled := false
## All 3 cans fell since they last stood up.
var _won := false


func _ready() -> void:
	var shelf := PlaceBuilder.new(self)
	shelf.shape(shelf.body(Vector3(0, SHELF_TOP - 0.03, SHELF_Z)), Vector3(2.6, 0.06, 0.4))
	shelf.shape(shelf.body(Vector3(0, PRIZE_SHELF_TOP - 0.03, -0.78)), Vector3(2.6, 0.06, 0.35))
	var half := CAN_RADIUS + 0.005
	_can_homes = [
		Vector3(-half, SHELF_TOP + CAN_HEIGHT / 2, SHELF_Z), Vector3(half, SHELF_TOP + CAN_HEIGHT / 2, SHELF_Z),
		Vector3(0, SHELF_TOP + CAN_HEIGHT * 1.5 + 0.005, SHELF_Z),
	]
	for i in 3:
		# A Grabbable, so online the host's cans are the ones that fall (PropSync); knocked down by hand there's no
		# thrower, and no prize.
		var can := Grabbable.new()
		can.name = "Can%d" % i
		can.collision_layer = 4
		can.collision_mask = 15
		can.mass = CAN_KG
		var shape := CollisionShape3D.new()
		var cylinder := CylinderShape3D.new()
		cylinder.radius = CAN_RADIUS
		cylinder.height = CAN_HEIGHT
		shape.shape = cylinder
		can.add_child(shape)
		can.add_child(_mesh_cylinder(CAN_RADIUS, CAN_HEIGHT, CAN_COLORS[i]))
		can.position = _can_homes[i]
		add_child(can)
		cans.append(can)
	for i in 3:
		var ball := Grabbable.new()
		ball.name = "Ball%d" % i
		ball.collision_layer = 4
		ball.collision_mask = 15
		ball.mass = BALL_KG
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = BALL_RADIUS
		shape.shape = sphere
		ball.add_child(shape)
		var look := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = BALL_RADIUS
		mesh.height = BALL_RADIUS * 2
		look.mesh = mesh
		look.material_override = _material(BALL_COLOR)
		ball.add_child(look)
		_ball_homes.append(Vector3(0.35 + i * 0.2, COUNTER_TOP + BALL_RADIUS, COUNTER_Z))
		ball.position = _ball_homes[i]
		add_child(ball)
		balls.append(ball)
	get_tree().create_timer(0.5).timeout.connect(func() -> void: _settled = true)


func is_down(index: int) -> bool:
	var can := cans[index]
	var off := can.position - _can_homes[index]
	off.y = 0.0
	return off.length() > MOVED or can.global_basis.y.dot(global_basis.y) < TILT \
		or can.position.y < _can_homes[index].y - 0.05


func down_count() -> int:
	var count := 0
	for i in cans.size():
		if is_down(i):
			count += 1
	return count


func balls_on_counter() -> int:
	var count := 0
	for i in balls.size():
		if balls[i].position.distance_to(_ball_homes[i]) < 0.3 and not balls[i].is_held():
			count += 1
	return count


## The cop who last threw a ball, if any.
func last_thrower() -> Cop:
	var best: Grabbable
	for ball in balls:
		if ball.let_go_at >= 0 and (best == null or ball.let_go_at > best.let_go_at):
			best = ball
	if best == null:
		return null
	var grabber := instance_from_id(best.last_holder) as Node
	return grabber.get_parent() as Cop if grabber else null


## The cans stand up again and the balls nobody holds come back to the counter.
func restack() -> void:
	reset_left = -1.0
	_won = false
	for i in cans.size():
		_put(cans[i], _can_homes[i])
	for i in balls.size():
		if not balls[i].is_held():
			_put(balls[i], _ball_homes[i])
			balls[i].let_go_at = -1


## Online only the host decides a win or a miss; the guests' cans and balls only follow it (PropSync).
func _physics_process(delta: float) -> void:
	if not _settled or not multiplayer.is_server():
		return
	var down := down_count()
	if down == cans.size() and not _won:
		_won = true
		wins += 1
		won.emit(last_thrower())
	if reset_left < 0.0 and (down > 0 or balls_on_counter() == 0):
		reset_left = RESET
	if reset_left < 0.0:
		return
	reset_left -= delta
	if reset_left < 0.0:
		if not _won:
			missed.emit()
		restack()


func _put(body: RigidBody3D, at: Vector3) -> void:
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	body.transform = Transform3D(Basis.IDENTITY, at)
	body.sleeping = false


func _mesh_cylinder(radius: float, height: float, color: Color) -> MeshInstance3D:
	var look := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	look.mesh = mesh
	look.material_override = _material(color)
	return look


func _material(color: Color) -> StandardMaterial3D:
	var look := StandardMaterial3D.new()
	look.albedo_color = color
	look.roughness = 0.5
	return look
