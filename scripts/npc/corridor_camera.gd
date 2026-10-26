class_name CorridorCamera
extends Node3D

## The security camera of the bribe jailbreak (docs/diseno/fuga-soborno.md, step 2): on the corridor's ceiling in front
## of the cells, it turns slowly from one cell's door to the other's, holding on each for `hold` seconds (the seed draws
## HOLD_MIN to HOLD_MAX, and which cell it starts on). A red light points where it looks. While it looks at a cell the
## guard won't take a bribe through its bars (BribeGuard). It runs on the host; the guests follow it (NpcSync).
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/corridor_camera.glb")
const HOLD_MIN := 6.0
const HOLD_MAX := 10.0
## Seconds it takes to turn from one cell to the other (it watches neither meanwhile).
const TURN_TIME := 1.5
const LIGHT_COLOR := Color(1.0, 0.16, 0.1)

## Where each cell's door is, in the world (the level sets them): it looks at one of them.
var doors: Array[Vector3] = []
var hold := HOLD_MIN
## The cell it looks at or turns to, and the seconds left there (holding) or turning.
var cell := 0
var left := 0.0
var turning := false
var _model: Node3D


## The camera for this jailbreak's seed: how long it holds and which cell it starts on.
func setup(case_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["corridor camera", case_seed])
	hold = snappedf(rng.randf_range(HOLD_MIN, HOLD_MAX), 0.5)
	cell = rng.randi_range(0, 1)
	left = hold


func _ready() -> void:
	add_to_group("corridor_cameras")
	_model = MODEL.instantiate()
	add_child(_model)
	var light := SpotLight3D.new()
	light.name = "RedLight"
	light.light_color = LIGHT_COLOR
	light.light_energy = 1.5
	light.spot_range = 5.0
	light.spot_angle = 18.0
	light.position = Vector3(0, -0.34, 0.2)
	# Down along the lens, toward the floor in front of the door.
	light.basis = Basis.looking_at(Vector3(0, -0.7, 0.7))
	_model.add_child(light)
	_face(1.0)


## Whether it's looking at cell `which` now.
func watching(which: int) -> bool:
	return not turning and cell == which


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	step(delta)


func step(delta: float) -> void:
	left -= delta
	if left <= 0.0:
		if turning:
			turning = false
			left = hold
		else:
			turning = true
			cell = 1 - cell
			left = TURN_TIME
	_face(1.0 - left / TURN_TIME if turning else 1.0)


## Turned toward `cell`, `weight` of the way from the other one.
func _face(weight: float) -> void:
	if not _model or doors.size() < 2:
		return
	var from := _yaw_to(doors[1 - cell])
	var to := _yaw_to(doors[cell])
	_model.rotation.y = lerp_angle(from, to, clampf(weight, 0.0, 1.0))


func _yaw_to(at: Vector3) -> float:
	var local := global_transform.affine_inverse() * at
	return atan2(local.x, local.z)


## Online (NpcSync): where it looks.
func net_state() -> Variant:
	return [cell, left, turning]


func apply_net_state(state: Variant) -> void:
	cell = state[0]
	left = state[1]
	turning = state[2]
	_face(1.0 - left / TURN_TIME if turning else 1.0)
