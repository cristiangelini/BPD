class_name ToolBelt
extends Node

## The cop's 4 tool slots (docs/diseno/herramientas.md, decision 35): 1 to 4 takes that tool out, the same key puts
## it away. With a tool in hand left click uses it instead of grabbing. F turns the flashlight on and off anytime.

const SLOTS := 4
const HUD_IDLE := Color(1, 1, 1, 0.55)
const HUD_IN_HAND := Color(1, 0.82, 0.3)

## Until the armory exists everyone carries the same four.
var tools: Array[CopTool] = []
## Slot in hand, or -1 with the hands free.
var current := -1
var flashlight: Flashlight
var cop: Cop
var _labels: Array[Label] = []


func _init(owner_cop: Cop) -> void:
	cop = owner_cop
	name = "Belt"


func _ready() -> void:
	tools = [Handcuffs.new(), Flashlight.new(), PhotoCamera.new(), PrintKit.new()]
	for item in tools:
		item.cop = cop
		cop.camera.add_child(item)
	flashlight = tools[1]
	# Only the player at the keys sees the slots; other cops' belts work the same without them.
	if cop.input_enabled:
		_build_hud()


func held_tool() -> CopTool:
	return tools[current] if current >= 0 else null


## Takes the tool in `index` out; if it's already in hand, puts it away. Returns whether the hands changed.
func select(index: int) -> bool:
	if index == current:
		holster()
		return true
	if index < 0 or index >= tools.size():
		return false
	if cop.ram:
		cop.show_hint("HINT_DROP_RAM_FIRST")
		return false
	if cop.is_cuffed():
		cop.show_hint("HINT_CUFFED")
		return false
	cop.get_node("Grabber").release()
	holster()
	current = index
	tools[current].set_in_hand(true)
	_refresh_hud()
	return true


func holster() -> void:
	if current >= 0:
		tools[current].release()
		tools[current].set_in_hand(false)
	current = -1
	_refresh_hud()


func _unhandled_input(event: InputEvent) -> void:
	if not cop.input_enabled or cop.vehicle or cop.in_briefing:
		return
	if event.is_action_pressed("flashlight"):
		cop.act("belt_flashlight", cop)
		return
	if _checklist_open():
		return
	for i in SLOTS:
		if event.is_action_pressed("slot_%d" % (i + 1)):
			cop.act("belt_select", cop, [i])


func _physics_process(_delta: float) -> void:
	var in_hand := held_tool()
	if not in_hand or not cop.input_enabled:
		return
	if Input.is_action_just_pressed("grab") and not cop.is_busy():
		in_hand.press()
	elif Input.is_action_just_released("grab"):
		in_hand.release()


## With the checklist open, 1 to 3 mark suspicions (RaidCase) instead.
func _checklist_open() -> bool:
	var checklist := get_tree().get_first_node_in_group("checklist") as CaseChecklist
	return checklist != null and checklist.is_open()


func _build_hud() -> void:
	var row := HBoxContainer.new()
	row.anchor_left = 1.0
	row.anchor_right = 1.0
	row.anchor_top = 1.0
	row.anchor_bottom = 1.0
	row.offset_left = -620
	row.offset_right = -20
	row.offset_top = -50
	row.offset_bottom = -16
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 18)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cop.get_node("Hud").add_child(row)
	for i in tools.size():
		var label := Label.new()
		label.text = "%d %s" % [i + 1, tr(tools[i].name_key)]
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_constant_override("outline_size", 6)
		row.add_child(label)
		_labels.append(label)
	_refresh_hud()


func _refresh_hud() -> void:
	for i in _labels.size():
		_labels[i].modulate = HUD_IN_HAND if i == current else HUD_IDLE
