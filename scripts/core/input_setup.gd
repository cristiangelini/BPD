class_name InputSetup
extends RefCounted

## Default key bindings (docs/diseno/allanamiento.md, "Controles").
## Registered at runtime so they can be remapped later from Options.

const KEYS := {
	"move_forward": KEY_W,
	"move_back": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"run": KEY_SHIFT,
	"crouch": KEY_CTRL,
	"jump": KEY_SPACE,
	"use": KEY_E,
	"drop": KEY_G,
	"checklist": KEY_Q,
	"ask": KEY_R,
	"flashlight": KEY_F,
	"talk": KEY_V,
	"radio": KEY_T,
	"siren": KEY_H,
	# On foot, in the jailbreak: humming to put the guard to sleep (in the car H is the siren).
	"hum": KEY_H,
	# On foot, in the club's waltz: the step on the first beat.
	"dance": KEY_H,
	# On foot, in the mimes' rehearsal: pressing on the invisible wall.
	"mime": KEY_H,
	"scoreboard": KEY_TAB,
	"map": KEY_M,
	"slot_1": KEY_1,
	"slot_2": KEY_2,
	"slot_3": KEY_3,
	"slot_4": KEY_4,
}

const MOUSE_BUTTONS := {
	"grab": MOUSE_BUTTON_LEFT,
	"throw": MOUSE_BUTTON_RIGHT,
	"hold_closer": MOUSE_BUTTON_WHEEL_DOWN,
	"hold_farther": MOUSE_BUTTON_WHEEL_UP,
}


static func ensure_actions() -> void:
	for action: String in KEYS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var key := InputEventKey.new()
		key.physical_keycode = KEYS[action]
		InputMap.action_add_event(action, key)
	for action: String in MOUSE_BUTTONS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var button := InputEventMouseButton.new()
		button.button_index = MOUSE_BUTTONS[action]
		InputMap.action_add_event(action, button)
