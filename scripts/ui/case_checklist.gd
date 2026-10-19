class_name CaseChecklist
extends CanvasLayer

## The planilla: Q opens and closes the list of what to do in the case (CaseObjectives).
## A small "[Q] Planilla" reminder stays in the corner while it's closed.

const DONE := Color(0.45, 1, 0.5)
const TODO := Color(1, 1, 1)
const NEXT := Color(1, 0.82, 0.3)
const STATUS := Color(1, 0.6, 0.5)

var _panel: PanelContainer
var _rows: VBoxContainer
var _reminder: Label


func _ready() -> void:
	layer = 4
	_reminder = Label.new()
	_reminder.text = "HUD_CHECKLIST_HINT"
	_reminder.anchor_left = 1.0
	_reminder.anchor_right = 1.0
	_reminder.offset_left = -260
	_reminder.offset_right = -20
	_reminder.offset_top = 16
	_reminder.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_reminder.add_theme_font_size_override("font_size", 20)
	_reminder.add_theme_constant_override("outline_size", 6)
	add_child(_reminder)
	_panel = PanelContainer.new()
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.offset_left = -560
	_panel.offset_right = -20
	_panel.offset_top = 16
	_panel.add_theme_stylebox_override("panel", CaseBriefing._panel_style())
	add_child(_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	_panel.add_child(box)
	var title := Label.new()
	title.text = "OBJ_TITLE"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", NEXT)
	box.add_child(title)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 6)
	box.add_child(_rows)
	set_open(false)


func is_open() -> bool:
	return _panel.visible


func set_open(open: bool) -> void:
	_panel.visible = open
	_reminder.visible = not open


func toggle() -> void:
	set_open(not is_open())


## Redraws the rows from CaseObjectives.rows().
func show_rows(list: Array[Dictionary]) -> void:
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	var next := CaseObjectives.next_step(list)
	for i in list.size():
		var row: Dictionary = list[i]
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = 480
		label.add_theme_font_size_override("font_size", 22)
		var mark := "" if row.status else ("[x] " if row.done else "[ ] ")
		label.text = mark + tr(row.text)
		label.add_theme_color_override("font_color",
			STATUS if row.status else DONE if row.done else NEXT if i == next else TODO)
		_rows.add_child(label)


func row_texts() -> PackedStringArray:
	var texts: PackedStringArray = []
	for label: Label in _rows.get_children():
		texts.append(label.text)
	return texts


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("checklist"):
		toggle()
