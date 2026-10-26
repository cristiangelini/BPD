class_name LabOven
extends OfficePrinter

## The cake lab's soufflé oven (docs/diseno/laboratorio.md, "Su distracción"): E on its red knob turns it up to the
## max, the alarm rings and smoke comes out of the door until chef Bruno saves his soufflé (the floor boss's fix, on
## the same body). Built like the other ovens, its front to +z. Every number here is (propuesta).

const OVEN_SIZE := Vector3(1.2, 1.6, 0.9)
const MODEL := preload("res://assets/models/lab_oven.glb")
const SMOKE := Color(0.35, 0.33, 0.32, 0.7)
const ALARM := Color(1.0, 0.25, 0.15)

var _alarm: OmniLight3D
var _smoke: MeshInstance3D


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(0, OVEN_SIZE.y / 2, 0), OVEN_SIZE, Color(0.72, 0.74, 0.77))
	add_child(MODEL.instantiate())
	button = PushButton.new()
	button.prompt = "PROMPT_OVEN_KNOB"
	button.position = Vector3(0.4, 1.4, OVEN_SIZE.z / 2 + 0.04)
	add_child(button)
	button.pressed.connect(print_copies)
	_alarm = OmniLight3D.new()
	_alarm.light_color = ALARM
	_alarm.light_energy = 2.0
	_alarm.omni_range = 4.0
	_alarm.position = Vector3(0, 1.9, 0.6)
	_alarm.visible = false
	add_child(_alarm)
	var puff := SphereMesh.new()
	puff.radius = 0.5
	puff.height = 0.8
	var material := StandardMaterial3D.new()
	material.albedo_color = SMOKE
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff.material = material
	_smoke = MeshInstance3D.new()
	_smoke.mesh = puff
	_smoke.position = Vector3(0, 1.7, 0.7)
	_smoke.visible = false
	add_child(_smoke)


## Up to the max: the alarm, the smoke, and the chef comes running. Turning it again while it burns only tells the
## cop so.
func print_copies(cop: Cop = null) -> void:
	if is_jammed:
		if cop:
			cop.show_hint("HINT_OVEN_BURNING")
		return
	is_jammed = true
	jobs += 1
	_alarm.visible = true
	_smoke.visible = true
	jammed.emit()


## The chef saved the soufflé: the oven is back to normal.
func fix() -> void:
	is_jammed = false
	_alarm.visible = false
	_smoke.visible = false
