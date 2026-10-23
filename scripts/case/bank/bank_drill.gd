class_name BankDrill
extends Node3D

## The robbers' drill at the vault's door (robo-banco.md, step 3, decision 102): it runs from the start and takes
## DRILL_TIME seconds to get through. When a robber sees a cop and shouts it, the gang gets nervous and the drill runs
## faster for NERVOUS seconds; El Oso on the phone (step 5) can stop it for a while (pause) or, lied to, speed it up
## the same way (hurry). A bar at the top of the screen shows how far it went. When it gets through, `opened` goes off:
## the vault's door swings open and the robbers run with the money (step 6). Online it runs on the host and a guest's
## follows it (`follower`, BankCase's snapshot). Every number here is (propuesta).

signal opened

const MODEL := preload("res://assets/models/bank_drill.glb")
const DRILL_TIME := 480.0
const NERVOUS := 20.0
const NERVOUS_RATE := 1.5
## Where the bit comes out of the model's nose, how long it is and how fast it spins (radians a second).
const BIT_AT := Vector3(0, 1.05, 0.31)
const BIT_LENGTH := 0.25
const BIT_SPIN := 30.0

## Seconds of drilling done (out of DRILL_TIME).
var drilled := 0.0
var nervous_left := 0.0
var paused_left := 0.0
var is_open := false
## A guest's: only shows the host's (apply_net_state).
var follower := false
var bar: ProgressBar
var _bit: MeshInstance3D
var _hud: CanvasLayer
var _state: Label


func _ready() -> void:
	add_to_group("bank_drill")
	add_child(MODEL.instantiate())
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.01
	mesh.bottom_radius = 0.05
	mesh.height = BIT_LENGTH
	mesh.radial_segments = 6
	_bit = MeshInstance3D.new()
	_bit.name = "Bit"
	_bit.mesh = mesh
	_bit.position = BIT_AT + Vector3(0, 0, BIT_LENGTH / 2)
	_bit.rotation.x = PI / 2
	var steel := StandardMaterial3D.new()
	steel.albedo_color = Color(0.75, 0.78, 0.82)
	steel.metallic = 0.6
	_bit.material_override = steel
	add_child(_bit)
	_build_hud()


## Hooks the robbers: each one that spots a cop, or a hostage being led out, makes the gang nervous.
func watch(robbers: Array[BankRobber]) -> void:
	for robber in robbers:
		robber.spotted.connect(func(_robber: BankRobber, _cop: Node3D) -> void: hurry(NERVOUS))
		robber.saw_hostage.connect(func(_robber: BankRobber, _hostage: Node3D) -> void: hurry(NERVOUS))


## How many drilling seconds go by each second right now.
func rate() -> float:
	if is_open or paused_left > 0.0:
		return 0.0
	return NERVOUS_RATE if nervous_left > 0.0 else 1.0


## Faster for `seconds`: a robber saw a cop, or El Oso found out he was lied to.
func hurry(seconds: float) -> void:
	nervous_left = maxf(nervous_left, seconds)


## Stopped for `seconds` (El Oso got what he asked for).
func pause(seconds: float) -> void:
	paused_left += seconds


func progress() -> float:
	return drilled / DRILL_TIME


## Seconds left at the normal rate.
func time_left() -> float:
	return maxf(DRILL_TIME - drilled, 0.0)


func _physics_process(delta: float) -> void:
	if is_open or follower:
		return
	drilled = minf(drilled + rate() * delta, DRILL_TIME)
	nervous_left = maxf(nervous_left - delta, 0.0)
	paused_left = maxf(paused_left - delta, 0.0)
	if drilled >= DRILL_TIME:
		is_open = true
		opened.emit()
	_show()


## What a guest's drill shows (BankCase.snapshot).
func net_state() -> Array:
	return [snappedf(drilled, 0.1), snappedf(nervous_left, 0.1), snappedf(paused_left, 0.1), is_open]


func apply_net_state(state: Array) -> void:
	drilled = state[0]
	nervous_left = state[1]
	paused_left = state[2]
	if state[3] and not is_open:
		is_open = true
		opened.emit()
	_show()


func _process(delta: float) -> void:
	_bit.rotate_object_local(Vector3.UP, BIT_SPIN * rate() * delta)


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_hud.name = "DrillHud"
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12.0
	var title := Label.new()
	title.text = "HUD_DRILL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 6)
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.max_value = DRILL_TIME
	bar.show_percentage = false
	bar.modulate = Color(1, 0.55, 0.2)
	box.add_child(bar)
	_state = Label.new()
	_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state.add_theme_constant_override("outline_size", 6)
	box.add_child(_state)
	_hud.add_child(box)
	add_child(_hud)
	_show()


func _show() -> void:
	bar.value = drilled
	if is_open:
		_state.text = "HUD_DRILL_OPEN"
	elif paused_left > 0.0:
		_state.text = "HUD_DRILL_PAUSED"
	elif nervous_left > 0.0:
		_state.text = "HUD_DRILL_NERVOUS"
	else:
		_state.text = ""
	_state.modulate = Color(0.5, 1, 0.5) if paused_left > 0.0 else Color(1, 0.4, 0.3)
