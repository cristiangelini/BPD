class_name Cop
extends CharacterBody3D

## First person cop: walk, run with stamina, crouch and jump (docs/diseno/escala.md).

const MOUSE_SENSITIVITY := 0.0025

@export var input_enabled := true

var stamina := GameScale.RUN_STAMINA
var is_running := false
var is_crouching := false
## After running out of stamina, running waits until half of it is back.
var exhausted := false

@onready var _shape: CollisionShape3D = $Shape
@onready var _head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera


func _ready() -> void:
	InputSetup.ensure_actions()
	camera.fov = GameScale.FOV
	_apply_height(GameScale.COP_HEIGHT)


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look(event.relative * MOUSE_SENSITIVITY)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	# Without local input someone else drives this cop through step() (tests, later the network).
	if not input_enabled:
		return
	var wish := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	step(delta, wish, Input.is_action_pressed("run"), Input.is_action_pressed("crouch"),
		Input.is_action_just_pressed("jump"))


## Rotates the view: x turns the body, y tilts the head.
func look(amount: Vector2) -> void:
	rotate_y(-amount.x)
	_head.rotation.x = clampf(_head.rotation.x - amount.y, deg_to_rad(-89.0), deg_to_rad(89.0))


## One movement tick. Kept apart from input so tests can drive it.
func step(delta: float, wish: Vector2, want_run: bool, want_crouch: bool, want_jump: bool) -> void:
	_update_crouch(want_crouch)
	var moving := wish.length() > 0.1
	if stamina <= 0.0:
		exhausted = true
	elif stamina >= GameScale.RUN_STAMINA * GameScale.STAMINA_RESUME:
		exhausted = false
	is_running = want_run and moving and not is_crouching and not exhausted
	if is_running:
		stamina = maxf(stamina - delta, 0.0)
	else:
		stamina = minf(stamina + delta * GameScale.RUN_STAMINA / GameScale.STAMINA_RECOVERY, GameScale.RUN_STAMINA)

	var direction := (transform.basis * Vector3(wish.x, 0.0, wish.y)).normalized()
	var speed := current_speed()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if is_on_floor():
		if want_jump and not is_crouching:
			velocity.y = GameScale.jump_velocity()
	else:
		velocity.y -= GameScale.GRAVITY * delta
	move_and_slide()


func current_speed() -> float:
	if is_crouching:
		return GameScale.CROUCH_SPEED
	if is_running:
		return GameScale.RUN_SPEED
	return GameScale.WALK_SPEED


func _update_crouch(want_crouch: bool) -> void:
	if want_crouch == is_crouching:
		return
	if not want_crouch and _blocked_above():
		return
	is_crouching = want_crouch
	_apply_height(GameScale.CROUCH_HEIGHT if is_crouching else GameScale.COP_HEIGHT)


func _apply_height(height: float) -> void:
	var capsule := _shape.shape as CapsuleShape3D
	capsule.height = height
	_shape.position.y = height / 2.0
	_head.position.y = height - (GameScale.COP_HEIGHT - GameScale.EYE_HEIGHT)


func _blocked_above() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	var standing := CapsuleShape3D.new()
	standing.radius = GameScale.COP_RADIUS
	standing.height = GameScale.COP_HEIGHT
	query.shape = standing
	query.transform = global_transform.translated(Vector3.UP * (GameScale.COP_HEIGHT / 2.0 + 0.05))
	query.exclude = [get_rid()]
	return not get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
