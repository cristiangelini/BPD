class_name PoliticianSpeech
extends Node

## Deputy Lustre's speech at the plaza (proteccion-politico.md, step 1, decision 103), the clock of the case: he waits
## at the lectern for his guard and starts when the first cop gets within START_REACH of him. Then he speaks for
## SPEECH_TIME seconds, a line every LINE_EVERY (LINES of them, in an order the seed draws), and `finished` goes off:
## the shift ends there (step 6). A bar at the top of the screen shows how much is left. Every number here is
## (propuesta).

signal started
signal finished

const SPEECH_TIME := 360.0
const LINE_EVERY := 10.0
const LINES := 12
const START_REACH := 25.0
## While he waits, he complains about his late guard this often.
const WAIT_EVERY := 15.0

var politician: Politician
var speaking := false
var over := false
## Seconds of speech left.
var left := SPEECH_TIME
var bar: ProgressBar
var _order: Array[int] = []
var _next := 0
var _line_left := 0.0
var _wait_left := 0.0
var _state: Label


func setup(speaker: Politician, case_seed: int) -> void:
	politician = speaker
	for i in LINES:
		_order.append(i + 1)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["speech", case_seed])
	for i in range(_order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := _order[i]
		_order[i] = _order[j]
		_order[j] = swap


func _ready() -> void:
	_build_hud()


func start() -> void:
	if speaking or over:
		return
	speaking = true
	_line_left = 0.0
	started.emit()


func _physics_process(delta: float) -> void:
	if over:
		return
	if not speaking:
		for cop: Node3D in get_tree().get_nodes_in_group("cops"):
			if cop.global_position.distance_to(politician.global_position) < START_REACH:
				start()
				break
	if not speaking:
		_wait_left -= delta
		if _wait_left <= 0.0:
			_wait_left = WAIT_EVERY
			politician.say("POLITICIAN_WAITING")
		_show()
		return
	left = maxf(left - delta, 0.0)
	_line_left -= delta
	if _line_left <= 0.0 and left > 0.0:
		_line_left = LINE_EVERY
		politician.say("SPEECH_LUSTRE_%d" % _order[_next % _order.size()], LINE_EVERY - 1.0)
		_next += 1
	if left <= 0.0:
		speaking = false
		over = true
		politician.say("SPEECH_LUSTRE_END")
		finished.emit()
	_show()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "SpeechHud"
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12.0
	var title := Label.new()
	title.text = "HUD_SPEECH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 6)
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.max_value = SPEECH_TIME
	bar.show_percentage = false
	bar.modulate = Color(0.45, 0.65, 1)
	box.add_child(bar)
	_state = Label.new()
	_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state.add_theme_constant_override("outline_size", 6)
	box.add_child(_state)
	hud.add_child(box)
	add_child(hud)
	_show()


func _show() -> void:
	bar.value = SPEECH_TIME - left
	if over:
		_state.text = "HUD_SPEECH_OVER"
	elif not speaking:
		_state.text = "HUD_SPEECH_WAITING"
	else:
		_state.text = tr("HUD_SPEECH_LEFT") % [int(left) / 60, int(left) % 60]
