class_name GlowPrint
extends FlourPrint

## The culprit's moon-boot print in the dome room (escena-planetario.md, "Las pistas"): glow paint from the freshly
## painted stars, so it only shows in the dark (`set_dark`), pointing to where the stone went. A photo of it in the
## dark notes the boot size; a cop who steps on it in the dark wipes it out (with the lights on nobody knows it's
## there, and nothing happens).

const GLOW := Color(0.45, 1.0, 0.35)

var dark := false


func _ready() -> void:
	super()
	# No flour patch: only the two soles, shining.
	(get_child(0) as Node3D).visible = false
	var shine := StandardMaterial3D.new()
	shine.albedo_color = GLOW
	shine.emission_enabled = true
	shine.emission = GLOW
	shine.emission_energy_multiplier = 2.0
	for sole in _soles:
		sole.material_override = shine
	set_dark(false)


func set_dark(on: bool) -> void:
	dark = on
	visible = on


func photo_clues() -> Dictionary:
	return super() if dark else {}


func _physics_process(delta: float) -> void:
	if dark:
		super(delta)
