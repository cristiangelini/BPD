class_name CaseBriefing
extends CanvasLayer

## The comisario gives the case (allanamiento.md, "Charla del comisario y planilla"): one line at a time,
## E, click or Space for the next one. While it's on, the cops can look around but not move or use things.

signal finished

var lines: PackedStringArray = []
var index := 0

var _text: Label


func _ready() -> void:
	layer = 5
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -520
	panel.offset_right = 520
	panel.offset_top = -300
	panel.offset_bottom = -60
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var speaker := Label.new()
	speaker.text = "BRIEF_SPEAKER"
	speaker.add_theme_font_size_override("font_size", 30)
	speaker.add_theme_color_override("font_color", Color(1, 0.82, 0.3))
	box.add_child(speaker)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override("font_size", 26)
	box.add_child(_text)
	var more := Label.new()
	more.text = "BRIEF_CONTINUE"
	more.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	more.add_theme_font_size_override("font_size", 20)
	more.modulate = Color(1, 1, 1, 0.7)
	box.add_child(more)
	hide()


func start(new_lines: PackedStringArray) -> void:
	lines = new_lines
	index = 0
	_set_cops_listening(true)
	_text.text = lines[0]
	show()


func advance() -> void:
	if not visible:
		return
	index += 1
	if index < lines.size():
		_text.text = lines[index]
		return
	hide()
	_set_cops_listening(false)
	finished.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var next: bool = event.is_action_pressed("use") or event.is_action_pressed("jump") \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if next:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		advance()
		get_viewport().set_input_as_handled()


func _set_cops_listening(on: bool) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).in_briefing = on


static func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.18, 0.88)
	style.border_color = Color(1, 0.82, 0.3)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(24)
	return style
