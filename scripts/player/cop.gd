class_name Cop
extends CharacterBody3D

## First person cop: walk, run with stamina, crouch and jump (docs/diseno/escala.md).

const MOUSE_SENSITIVITY := 0.0025
## Render layer of the cop's own body: hidden from its own camera, but it still casts a shadow.
const OWN_BODY_LAYER := 20
## One skin color per player on the same blue uniform (decision 72; placeholder models from tools/modelgen).
const UNIFORMS: Array[PackedScene] = [
	preload("res://assets/models/cop_0.glb"), preload("res://assets/models/cop_1.glb"),
	preload("res://assets/models/cop_2.glb"), preload("res://assets/models/cop_3.glb"),
]
const RAM_SCENE := preload("res://scenes/tools/battering_ram.tscn")
const RAM_PICKUP_SCENE := preload("res://scenes/tools/ram_pickup.tscn")
## A dropped ram lands this far in front of the cop.
const DROP_AHEAD := 1.0

@export var input_enabled := true

var stamina := GameScale.RUN_STAMINA
var is_running := false
var is_crouching := false
## After running out of stamina, running waits until half of it is back.
var exhausted := false
## Found in one of the pots by the grandpa's front door.
var has_key := false
## The battering ram in hand, if this cop carries it. Hands are busy: no grabbing.
var ram: BatteringRam
var _stagger_left := 0.0
## While holding E on the grandpa he tells a story; this cop can't do anything else (allanamiento.md).
var listening_to: Grandpa
## The patrol car this cop sits in, if any: the body rides the seat and doesn't walk or collide.
var vehicle: PatrolCar
## The comisario is giving the case (CaseBriefing): the cop can look around but not move or use things.
var in_briefing := false

@onready var _shape: CollisionShape3D = $Shape
@onready var _head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var model: Node3D = $Model
@onready var _hint: Label = $Hud/Hint
@onready var _hint_timer: Timer = $Hud/Hint/Timer
@onready var _prompt: Label = $Hud/Prompt


func _ready() -> void:
	add_to_group("cops")
	InputSetup.ensure_actions()
	camera.fov = GameScale.FOV
	_apply_height(GameScale.COP_HEIGHT)
	_hint_timer.timeout.connect(_hint.hide)
	if input_enabled:
		_hide_from_own_camera()


## What the camera points at within reach (empty if nothing), ignoring the cop's own body.
func aim_hit(reach: float) -> Dictionary:
	var eye := camera.global_transform
	var query := PhysicsRayQueryParameters3D.create(eye.origin, eye.origin - eye.basis.z * reach)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)


func equip_ram() -> void:
	ram = RAM_SCENE.instantiate()
	ram.cop = self
	camera.add_child(ram)


## Lets go of the ram: it drops on the floor in front, where E picks it up again.
func drop_ram() -> RamPickup:
	if not ram:
		return null
	ram.queue_free()
	ram = null
	var pickup: RamPickup = RAM_PICKUP_SCENE.instantiate()
	var ahead := -global_basis.z * DROP_AHEAD
	get_parent().add_child(pickup)
	pickup.global_position = global_position + ahead
	pickup.rotation.y = rotation.y
	return pickup


## The key text (tr() key) for what this cop can do right now: what's in hand, else what the camera points at.
func current_prompt() -> String:
	if vehicle or in_briefing:
		return ""
	if $Grabber.held:
		return "PROMPT_HOLDING"
	if ram:
		return "PROMPT_RAM"
	var target := _usable_target()
	if target and target.has_method("prompt_key"):
		return target.prompt_key(self)
	var hit := aim_hit(GameScale.GRAB_REACH)
	if not hit.is_empty() and hit.collider is Grabbable:
		return hit.collider.prompt_key(self) if hit.collider.has_method("prompt_key") else "PROMPT_GRAB"
	return ""


## Loses balance for a while: can't move or charge the ram.
func stagger(seconds: float) -> void:
	_stagger_left = maxf(_stagger_left, seconds)


func is_staggered() -> bool:
	return _stagger_left > 0.0


## Busy: staggered, listening to the grandpa, sitting in the car or hearing the comisario. No walking, grabbing or ramming.
func is_busy() -> bool:
	return is_staggered() or listening_to != null or vehicle != null or in_briefing


## Rides `seat` of `car`, facing forward, until stand_up(). Lets go of whatever it was holding.
func sit_in(car: PatrolCar, seat: Node3D) -> void:
	$Grabber.release()
	vehicle = car
	velocity = Vector3.ZERO
	_shape.disabled = true
	reparent(seat, false)
	transform = Transform3D.IDENTITY
	_head.rotation.x = 0.0


## Gets out of the car and stands at `at` (world position), turned to `yaw`.
func stand_up(at: Vector3, yaw: float) -> void:
	var world := vehicle.get_parent()
	vehicle = null
	reparent(world, false)
	global_transform = Transform3D(Basis(Vector3.UP, yaw), at + Vector3.UP * 0.1)
	_shape.disabled = false


## Shows a short line at the bottom of this cop's screen. `key` is a tr() key.
func show_hint(key: String) -> void:
	_hint.text = key
	_hint.show()
	_hint_timer.start()


## Swaps the body for the skin of player `index` (0 to 3).
func set_uniform(index: int) -> void:
	var old: Node3D = get_node("Model")
	var fresh: Node3D = UNIFORMS[index % UNIFORMS.size()].instantiate()
	fresh.transform = old.transform
	remove_child(old)
	old.queue_free()
	fresh.name = "Model"
	add_child(fresh)
	model = fresh
	if input_enabled and is_node_ready():
		_hide_from_own_camera()


func _hide_from_own_camera() -> void:
	for mesh in model.find_children("*", "VisualInstance3D", true, false):
		(mesh as VisualInstance3D).layers = 1 << (OWN_BODY_LAYER - 1)
	camera.cull_mask &= ~(1 << (OWN_BODY_LAYER - 1))


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look(event.relative * MOUSE_SENSITIVITY)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("drop"):
		drop_ram()
	elif event.is_action_pressed("use"):
		if vehicle:
			vehicle.exit(self)
		else:
			use()
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	# Without local input someone else drives this cop through step() (tests, later the network).
	if not input_enabled:
		return
	var prompt := current_prompt()
	_prompt.text = prompt
	_prompt.visible = prompt != ""
	if vehicle:
		return
	if listening_to and not Input.is_action_pressed("use"):
		listening_to.end_story()
	var wish := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	step(delta, wish, Input.is_action_pressed("run"), Input.is_action_pressed("crouch"),
		Input.is_action_just_pressed("jump"))


## Uses what the camera points at (a pot, a door...), if it can be used. Returns true if something was used.
func use() -> bool:
	var target := _usable_target()
	if not target:
		return false
	target.use(self)
	return true


## What the camera points at within reach that can be used with E (a door's body is a child of the door).
func _usable_target() -> Node:
	var hit := aim_hit(GameScale.GRAB_REACH)
	if hit.is_empty():
		return null
	var target: Node = hit.collider
	if not target.has_method("use"):
		target = target.get_parent()
	return target if target.has_method("use") else null


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

	_stagger_left = maxf(_stagger_left - delta, 0.0)
	var direction := (transform.basis * Vector3(wish.x, 0.0, wish.y)).normalized()
	var speed := 0.0 if is_busy() else current_speed()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if is_on_floor():
		if want_jump and not is_crouching:
			velocity.y = GameScale.jump_velocity()
	else:
		velocity.y -= GameScale.GRAVITY * delta
	move_and_slide()


func current_speed() -> float:
	var factor := BatteringRam.SPEED_FACTOR if ram else 1.0
	if is_crouching:
		return GameScale.CROUCH_SPEED * factor
	if is_running:
		return GameScale.RUN_SPEED * factor
	return GameScale.WALK_SPEED * factor


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
