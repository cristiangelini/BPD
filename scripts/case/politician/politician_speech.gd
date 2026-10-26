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
## The double's outrages at the lectern (politico-doble.md, step 2).
const OUTRAGES := 10

var politician: Politician
var speaking := false
var over := false
## Seconds of speech left.
var left := SPEECH_TIME
var bar: ProgressBar
## Online, a guest's speech: the host's decides when it starts and how much is left (PoliticianCase.snapshot).
var follower := false
## The double at the lectern (DoubleSwap), null when he isn't: each line is one of his outrages instead, and a stain on
## the real deputy's image.
var impostor: Politician
var outrages := 0
## The key of each line, with the line's number (the birthday party has its own, politico-cumple.md).
var line_key := "SPEECH_LUSTRE_%d"
## The bar's title (the parade has its own, politico-descapotable.md).
var title_key := "HUD_SPEECH"
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


## Holds the next line for `seconds`, so what he just said (back at the lectern) is seen.
func hold_lines(seconds: float) -> void:
	_line_left = maxf(_line_left, seconds)


func _physics_process(delta: float) -> void:
	if over or follower:
		_show()
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
	if impostor and _line_left <= 0.0 and left > 0.0:
		_line_left = LINE_EVERY
		_outrage()
	# Off the stage he greets instead (PoliticianWalks); the clock goes on.
	elif _line_left <= 0.0 and left > 0.0 and not politician.off_stage():
		_line_left = LINE_EVERY
		politician.say(line_key % _order[_next % _order.size()], LINE_EVERY - 1.0)
		_next += 1
	if left <= 0.0:
		speaking = false
		over = true
		politician.say("SPEECH_LUSTRE_END")
		finished.emit()
	_show()


## The double says something outrageous into the microphone, in the deputy's name: a stain on his image.
func _outrage() -> void:
	impostor.say("DOUBLE_OUTRAGE_%d" % ((outrages + _order[0]) % OUTRAGES + 1), LINE_EVERY - 1.0)
	outrages += 1
	politician.stain(Politician.SHAME, politician.global_position + Vector3.UP)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "SpeechHud"
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12.0
	var title := Label.new()
	title.text = title_key
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
