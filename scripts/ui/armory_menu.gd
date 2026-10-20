class_name ArmoryMenu
extends CanvasLayer

## The armero's list (docs/diseno/comisaria.md, "La armería"): the cash box on top, one row per item with its price and
## whether the station owns it. W and S pick a row, E takes it (or buys it), Esc or Q closes. While open, the cop it
## was opened for can look around but not walk or use things.

var armory: Armory
var cop: Cop
var selected := 0

var _cash: Label
var _rows: VBoxContainer
var _message: Label

func _ready() -> void:
	layer = 5
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -360
	panel.offset_right = 360
	panel.offset_top = -220
	panel.offset_bottom = 220
	panel.add_theme_stylebox_override("panel", CaseBriefing._panel_style())
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var title := Label.new()
	title.text = "ARMORY_TITLE"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(1, 0.82, 0.3))
	box.add_child(title)
	_cash = Label.new()
	_cash.add_theme_font_size_override("font_size", 22)
	box.add_child(_cash)
	_rows = VBoxContainer.new()
	_rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_rows)
	_message = Label.new()
	_message.add_theme_font_size_override("font_size", 20)
	_message.add_theme_color_override("font_color", Color(1, 0.6, 0.5))
	box.add_child(_message)
	var keys := Label.new()
	keys.text = "ARMORY_KEYS"
	keys.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	keys.add_theme_font_size_override("font_size", 18)
	keys.modulate = Color(1, 1, 1, 0.7)
	box.add_child(keys)
	hide()


func open(with_armory: Armory, for_cop: Cop) -> void:
	armory = with_armory
	cop = for_cop
	cop.in_menu = true
	selected = 0
	_message.text = ""
	_redraw()
	show()


func close() -> void:
	if not visible:
		return
	hide()
	cop.in_menu = false


func move(rows: int) -> void:
	selected = posmod(selected + rows, armory.ids().size())
	_redraw()


## E on the selected row: takes or buys it (online the host decides, Armero.armory_choose). Taking closes the list,
## so the cop leaves with it in hand.
func choose() -> void:
	var id: String = armory.ids()[selected]
	var armero := get_parent()
	if armero.has_method("armory_choose"):
		cop.act("armory_choose", armero, [id])
		return
	var owned := armory.owns(id)
	show_result(armory.choose(id, cop), owned)


## What came of the chosen row: `owned` means it was taken, not bought.
func show_result(error: String, owned: bool) -> void:
	_message.text = error
	_redraw()
	if error == "" and owned:
		close()


func redraw() -> void:
	_redraw()


func _redraw() -> void:
	_cash.text = tr("ARMORY_CASH") % armory.wallet.money
	for row in _rows.get_children():
		row.queue_free()
	var ids := armory.ids()
	for i in ids.size():
		var item: Dictionary = armory.items[ids[i]]
		var price: String = tr("ARMORY_FREE") if item.price == 0 else "$%d" % item.price
		var action: String = tr("ARMORY_TAKE") if armory.owns(ids[i]) else tr("ARMORY_BUY")
		if armory.is_stock(ids[i]) and armory.owns(ids[i]):
			action += " (%d)" % armory.count(ids[i])
		var row := Label.new()
		row.text = "%s %s · %s · %s\n    %s" % ["▶" if i == selected else "  ", tr(item.name), price, action, tr(item.about)]
		row.add_theme_font_size_override("font_size", 22)
		if i == selected:
			row.add_theme_color_override("font_color", Color(1, 0.82, 0.3))
		_rows.add_child(row)


func _input(event: InputEvent) -> void:
	if not visible or not cop.input_enabled:
		return
	if event.is_action_pressed("move_forward"):
		move(-1)
	elif event.is_action_pressed("move_back"):
		move(1)
	elif event.is_action_pressed("use"):
		choose()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("checklist"):
		close()
	else:
		return
	get_viewport().set_input_as_handled()
