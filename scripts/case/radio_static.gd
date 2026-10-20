class_name RadioStatic
extends Node

## The cop radio in the pirate radio story (RadioRig): while a cop holds the radio key, their screen shows the static
## bars and they hear the hiss, louder the closer they are to the transmitter.

const MIX_RATE := 22050
## Hiss volume at 1 bar and at the most bars (propuesta).
const QUIET_DB := -24.0
const LOUD_DB := -4.0

var transmitter: Node3D
## Cop -> the label on their screen.
var _labels: Dictionary = {}
var _hiss: AudioStreamPlayer


func _ready() -> void:
	_hiss = AudioStreamPlayer.new()
	_hiss.stream = hiss_sound()
	add_child(_hiss)


func _process(_delta: float) -> void:
	var loudest := 0
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.input_enabled:
			loudest = maxi(loudest, listen(cop, Input.is_action_pressed("radio")))
	if loudest == 0:
		_hiss.stop()
		return
	_hiss.volume_db = lerpf(QUIET_DB, LOUD_DB, float(loudest - 1) / (RadioRig.MAX_BARS - 1))
	if not _hiss.playing:
		_hiss.play()


## Shows (on) or hides the static bars on this cop's screen; returns the bars shown, 0 when off.
func listen(cop: Cop, on: bool) -> int:
	var label: Label = _labels.get(cop)
	if label == null:
		label = _make_label()
		cop.get_node("Hud").add_child(label)
		_labels[cop] = label
	label.visible = on and is_instance_valid(transmitter)
	if not label.visible:
		return 0
	var bars := RadioRig.static_level(cop.global_position, transmitter.global_position)
	label.text = tr("HUD_RADIO_STATIC") % ("■".repeat(bars) + "□".repeat(RadioRig.MAX_BARS - bars))
	return bars


func _make_label() -> Label:
	var label := Label.new()
	label.name = "RadioStatic"
	label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	label.offset_left = -300.0
	label.offset_right = 300.0
	label.offset_top = 90.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_constant_override("outline_size", 8)
	label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.75))
	label.hide()
	return label


## A placeholder hiss until there's real sound: one second of looping noise.
static func hiss_sound() -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(MIX_RATE * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for i in MIX_RATE:
		data.encode_s16(i * 2, int(rng.randf_range(-1.0, 1.0) * 9000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_end = MIX_RATE
	wav.data = data
	return wav
