class_name PauseMenu
extends CanvasLayer

## Esc during a case (online.md, "Menú con Esc"): go on, invite friends from Steam, the always open voice, or leave.
## Solo the game stops while it's open; online it can't, so the others keep playing. Child of Net, so it exists in
## every level without each one adding it.

var _net: Node
var _box: VBoxContainer
var _hint: Label
var _invite: Button
var _voice: CheckBox
var _leave: Button
## The mouse as it was before opening: captured while walking, free over the shift screen.
var _mouse_before := Input.MOUSE_MODE_CAPTURED


func _init(net: Node) -> void:
	_net = net
	name = "PauseMenu"
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color(0.06, 0.08, 0.15, 0.8)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_box = VBoxContainer.new()
	_box.set_anchors_preset(Control.PRESET_CENTER)
	_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_box.grow_vertical = Control.GROW_DIRECTION_BOTH
	_box.custom_minimum_size = Vector2(420, 0)
	_box.add_theme_constant_override("separation", 14)
	add_child(_box)
	var title := Label.new()
	title.text = "PAUSE_TITLE"
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(title)
	_hint = Label.new()
	_hint.text = "PAUSE_ONLINE_HINT"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 20)
	_box.add_child(_hint)
	_button("PAUSE_RESUME", close)
	_invite = _button("LOBBY_INVITE", func() -> void: _net.steam.invite())
	_voice = CheckBox.new()
	_voice.text = "LOBBY_VOICE_OPEN"
	_voice.add_theme_font_size_override("font_size", 20)
	_voice.toggled.connect(func(open: bool) -> void: _net.voice.set_always_open(open))
	_box.add_child(_voice)
	_leave = _button("PAUSE_LEAVE", leave)


func _button(key: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = key
	button.custom_minimum_size = Vector2(0, 48)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(on_pressed)
	_box.add_child(button)
	return button


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		close()
	elif get_tree().current_scene is Node3D:
		open()
	else:
		return
	get_viewport().set_input_as_handled()


func open() -> void:
	var online: bool = _net.is_online()
	_hint.visible = online
	_invite.visible = online and _net.is_steam() and _net.is_host()
	_voice.visible = online and _net.steam.available()
	_voice.set_pressed_no_signal(_net.voice.always_open)
	_leave.text = "PAUSE_LEAVE_ROOM" if online else "PAUSE_LEAVE"
	_mouse_before = Input.mouse_mode
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not online:
		get_tree().paused = true


func close() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = _mouse_before


## Leaves the room if there is one (a host closing it sends the others to the room screen) and goes to the menu.
func leave() -> void:
	visible = false
	get_tree().paused = false
	_net.leave()
	if _net.change_scenes:
		get_tree().change_scene_to_file(Lobby.MENU_SCENE)
