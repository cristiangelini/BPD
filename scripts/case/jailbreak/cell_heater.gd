class_name CellHeater
extends StaticBody3D

## The old electric heater in each cell in the fire drill jailbreak (docs/diseno/fuga-simulacro.md, step 1): a cop with
## the bunk's blanket in hand holds it against it with E, and it smokes while the cop stays by it with the blanket.
## SMOKE_ALARM seconds of smoke in a row and the cell's smoke detector rings; letting go or walking away starts it
## over. `slow` (step 2: the "NO TOCAR" sign after a drill) makes it take longer. Every number here is (propuesta).

signal smoked

const MODEL := preload("res://assets/models/cell_heater.glb")
const SIZE := Vector3(0.6, 0.55, 0.25)
const SMOKE_ALARM := 8.0
## How far from the heater the cop with the blanket can be.
const REACH := 1.4

var cell := 0
var detector: SmokeDetector
var slow := 1.0
## Who holds the blanket against it, and for how long it has been smoking.
var smoker: Cop
var smoke := 0.0
var _puffs: CPUParticles3D


func _ready() -> void:
	add_to_group("cell_heaters")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	add_child(MODEL.instantiate())
	_puffs = CPUParticles3D.new()
	_puffs.position = Vector3(0, SIZE.y + 0.1, 0.1)
	_puffs.amount = 24
	_puffs.lifetime = 2.5
	_puffs.direction = Vector3.UP
	_puffs.spread = 25.0
	_puffs.initial_velocity_min = 0.3
	_puffs.initial_velocity_max = 0.6
	_puffs.gravity = Vector3(0, 0.2, 0)
	_puffs.scale_amount_min = 1.5
	_puffs.scale_amount_max = 3.0
	var puff := SphereMesh.new()
	puff.radius = 0.15
	puff.height = 0.3
	var grey := StandardMaterial3D.new()
	grey.albedo_color = Color(0.25, 0.25, 0.27, 0.55)
	grey.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grey.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = grey
	_puffs.mesh = puff
	_puffs.emitting = false
	add_child(_puffs)


func is_smoking() -> bool:
	return smoker != null


func prompt_key(cop: Cop) -> String:
	if smoker == cop:
		return "PROMPT_HEATER_STOP"
	if smoker:
		return ""
	return "PROMPT_HEATER_SMOKE" if _blanket_of(cop) else "PROMPT_HEATER"


func use(cop: Cop) -> void:
	if smoker == cop:
		stop()
	elif not smoker and _blanket_of(cop):
		smoker = cop
		_puffs.emitting = true
	elif not smoker:
		cop.show_hint("HINT_HEATER_BLANKET")


func stop() -> void:
	smoker = null
	smoke = 0.0
	_puffs.emitting = false


func _blanket_of(cop: Cop) -> CellBlanket:
	return cop.get_node("Grabber").held as CellBlanket


func _physics_process(delta: float) -> void:
	if not smoker:
		return
	if not is_instance_valid(smoker) or not _blanket_of(smoker) \
			or smoker.global_position.distance_to(global_position) > REACH:
		stop()
		return
	smoke += delta
	if smoke >= SMOKE_ALARM * slow:
		stop()
		smoked.emit()
		if detector:
			detector.ring()


## Online (NpcSync): smoking or not (the host decides).
func net_state() -> Variant:
	return [smoker != null, smoke]


func apply_net_state(state: Variant) -> void:
	_puffs.emitting = state[0]
	smoke = state[1]
