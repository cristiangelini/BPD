class_name Golfer
extends StaticBody3D

## A golfer standing by a hole (persecucion-lugares.md, "Ladrones en carrito de golf"): when a cop comes near he
## shouts "¡Fore!" and hits a ball at him. The balls bounce off the patrol car and do nothing. Every number here is
## (propuesta).

const MODEL := preload("res://assets/models/npc_cliente.glb")
const NEAR := 40.0
const SWING_EVERY := 6.0
const SHOUT_SECONDS := 1.5
const BALL_SPEED := 14.0
const BALL_SECONDS := 8.0
const BALL_RADIUS := 0.08

## Seconds before his first swing, so the 6 don't shout all at once.
var wait := 0.0
var swings := 0
var _shout: Label3D


func _ready() -> void:
	add_to_group("golfers")
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	add_child(MODEL.instantiate())
	_shout = Label3D.new()
	_shout.text = "SHOUT_FORE"
	_shout.position.y = 2.2
	_shout.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_shout.font_size = 64
	_shout.pixel_size = 0.006
	_shout.outline_size = 12
	_shout.hide()
	add_child(_shout)


func _physics_process(delta: float) -> void:
	wait -= delta
	if wait > 0.0:
		_shout.visible = wait > SWING_EVERY - SHOUT_SECONDS
		return
	var target := _nearest_cop()
	if target:
		swing(target.global_position)


## The nearest cop within NEAR, on foot or in the car.
func _nearest_cop() -> Node3D:
	var nearest: Node3D = null
	var best := NEAR
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var d := cop.global_position.distance_to(global_position)
		if d < best:
			best = d
			nearest = cop
	return nearest


## He shouts and hits a ball toward `at`, up in an arc.
func swing(at: Vector3) -> RigidBody3D:
	wait = SWING_EVERY
	swings += 1
	_shout.show()
	look_at(Vector3(at.x, global_position.y, at.z), Vector3.UP, true)
	var ball := RigidBody3D.new()
	ball.name = "Ball"
	ball.add_to_group("golf_balls")
	ball.mass = 0.05
	ball.collision_layer = 0
	ball.collision_mask = 1
	ball.physics_material_override = PhysicsMaterial.new()
	ball.physics_material_override.bounce = 0.6
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = BALL_RADIUS
	shape.shape = sphere
	ball.add_child(shape)
	var mesh := MeshInstance3D.new()
	var look := SphereMesh.new()
	look.radius = BALL_RADIUS
	look.height = BALL_RADIUS * 2
	mesh.mesh = look
	ball.add_child(mesh)
	get_parent().add_child(ball)
	var flat := Vector3(at.x - global_position.x, 0, at.z - global_position.z).normalized()
	ball.global_position = global_position + flat * 0.8 + Vector3.UP * 0.5
	ball.linear_velocity = (flat + Vector3.UP * 0.35).normalized() * BALL_SPEED
	get_tree().create_timer(BALL_SECONDS).timeout.connect(ball.queue_free)
	return ball
