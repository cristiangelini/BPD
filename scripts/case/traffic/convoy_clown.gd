class_name ConvoyClown
extends Grabbable

## A clown out of a clown car at the traffic control (control-payasos.md, "Cómo es", steps 3 and 4): opening the
## car's door lets out its clowns, who wander off juggling around the car. The car won't move until they're all back
## in: a clown carried or pushed to within BOARD_REACH of the door gets back in by himself. Grabbed, he complains.
## E on the driver asks for his license; with the circus's sponge in hand, E scrubs his makeup off, a bit each time,
## so his face can be held up against the license's photo (control-payasos.md, step 5).
## Light, so one cop can carry him (a circus clown is mostly air and makeup). Every number here is (propuesta).

signal boarded(clown: ConvoyClown)

const MODEL := preload("res://assets/models/npc_payaso.glb")
const MASS := 18.0
const SPEED := 1.1
## He wanders to a spot this far from the door, then picks another one.
const WANDER := Vector2(2.5, 5.0)
const BOARD_REACH := 1.0
## Out this long before he can get back in, so he doesn't hop straight back in when he gets out.
const OUT_AT_LEAST := 2.0
const LINES := 6
## E with the sponge this many times cleans his face, as in the circus.
const SCRUBS := CircusClown.SCRUBS
const SAY_SECONDS := 3.0
const BALLS := 3
const BALL_COLORS: Array[Color] = [Color(0.9, 0.15, 0.15), Color(0.2, 0.5, 0.95), Color(0.95, 0.85, 0.2)]

## The car he came out of.
var car: QueueCar
## The one who was at the wheel (step 3 gives him away).
var is_driver := false
## ConvoyTraits: his wig, nose and gloves show.
var traits := {}
var out_for := 0.0
var makeup_on := true
var _scrubbed := 0
var _model: Node3D
var _target := Vector3.ZERO
var _rng := RandomNumberGenerator.new()
var _balls: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _complained := 0


func _ready() -> void:
	add_to_group("convoy_clowns")
	mass = MASS
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	_model.name = "Model"
	add_child(_model)
	ConvoyTraits.dress(_model, traits)
	_balls = Node3D.new()
	_balls.name = "Juggling"
	_balls.position = Vector3(0, 1.75, 0.3)
	add_child(_balls)
	for i in BALLS:
		var ball := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.07
		sphere.height = 0.14
		ball.mesh = sphere
		var material := StandardMaterial3D.new()
		material.albedo_color = BALL_COLORS[i]
		ball.material_override = material
		_balls.add_child(ball)
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
	_rng.seed = hash([name, car.plate if car else ""])
	_pick_target()


func prompt_key(cop: Cop) -> String:
	if cop and cop.get_node("Grabber").held is ClownSponge and makeup_on:
		return "PROMPT_CLOWN_SCRUB"
	if is_driver:
		return "PROMPT_PAPERS"
	return "PROMPT_CONVOY_CLOWN"


## E on him: with the sponge, a scrub; the driver hands his license; the others say they don't drive.
func use(cop: Cop) -> void:
	if cop and cop.get_node("Grabber").held is ClownSponge and makeup_on:
		scrub()
	elif is_driver and is_instance_valid(car):
		car.papers_checked = true
		say(DriverTraits.license_text(car.driver))
	else:
		say(tr("CONVOY_NOT_DRIVER"))


## One scrub with the sponge; after SCRUBS his face is clean and his glasses show, if he wears them.
func scrub() -> void:
	_scrubbed += 1
	if _scrubbed < SCRUBS:
		say(tr("CLOWN_SCRUB"))
		return
	makeup_on = false
	ConvoyTraits.show_face(_model, traits, true)
	say(tr("CLOWN_FACE_CLEAN"))


func hold(holder_id: int, point: Vector3) -> void:
	if not is_held():
		say(tr("CONVOY_CLOWN_LINE_%d" % (_complained % LINES)))
		_complained += 1
	super(holder_id, point)


func say(text: String) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = SAY_SECONDS


func saying() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	super(delta)
	out_for += delta
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	for i in _balls.get_child_count():
		var turn := out_for * 4.0 + TAU * i / BALLS
		(_balls.get_child(i) as Node3D).position = Vector3(cos(turn) * 0.25, sin(turn) * 0.3 + 0.1, 0)
	if not is_instance_valid(car):
		return
	if out_for >= OUT_AT_LEAST and _flat(global_position - car.door_point()).length() < BOARD_REACH:
		board()
		return
	if is_held():
		return
	var wish := _flat(_target - global_position)
	if wish.length() < 0.3:
		_pick_target()
		return
	wish = wish.normalized() * SPEED
	linear_velocity.x = wish.x
	linear_velocity.z = wish.z
	rotation.y = atan2(wish.x, wish.z)


## Back in the car: gone from the street.
func board() -> void:
	if is_queued_for_deletion():
		return
	for id: int in holders.keys():
		var grabber := instance_from_id(id) as Grabber
		if grabber and grabber.held == self:
			grabber.release()
	boarded.emit(self)
	queue_free()


## Somewhere out from its door, on the driver's side (the car's +X), ahead or behind.
func _pick_target() -> void:
	if not is_instance_valid(car):
		return
	var away := car.global_basis.x
	var turn := _rng.randf_range(-1.2, 1.2)
	_target = car.door_point() + away.rotated(Vector3.UP, turn) * _rng.randf_range(WANDER.x, WANDER.y)


func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0, v.z)
