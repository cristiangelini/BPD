class_name IntercomPanel
extends OfficePrinter

## The intercom board by the Las Palomas building's glass door (docs/diseno/edificio.md, "Su distracción"): E rings a
## flat at random, a neighbor complains about "a leak on the 12th" and Don Evaristo goes up to fix it (the floor boss's
## fix, out of sight). Once every COOLDOWN s: pressing it before only tells the cop so. It faces +z. Every number here
## is (propuesta). Its other button calls Don Evaristo himself to the door, for the warrant.

## A cop pressed the manager's button.
signal manager_called(cop: Cop)

const COOLDOWN := 60.0
const PANEL := Vector3(0.36, 0.6, 0.06)
const BRASS := Color(0.78, 0.66, 0.36)

## Seconds until the neighbors answer again.
var cooldown_left := 0.0
var manager_button: PushButton


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(0, 0, -PANEL.z / 2), PANEL, BRASS)
	for row in 6:
		for column in 2:
			build.mesh_box(Vector3(-0.08 + column * 0.16, 0.2 - row * 0.07, 0.005), Vector3(0.1, 0.04, 0.01), Color(0.95, 0.93, 0.85))
	button = PushButton.new()
	button.prompt = "PROMPT_INTERCOM"
	button.color = Color(0.2, 0.2, 0.22)
	button.position = Vector3(0, -0.24, 0.04)
	add_child(button)
	button.pressed.connect(print_copies)
	manager_button = PushButton.new()
	manager_button.prompt = "PROMPT_INTERCOM_MANAGER"
	manager_button.color = Color(0.2, 0.55, 0.85)
	manager_button.position = Vector3(0, 0.38, 0.04)
	add_child(manager_button)
	manager_button.pressed.connect(func(cop: Cop) -> void: manager_called.emit(cop))


func _process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)


## A ring: the leak on the 12th calls Don Evaristo away. While he's up there, or before the neighbors forgive the
## last ring, nobody answers.
func print_copies(cop: Cop = null) -> void:
	if is_jammed or cooldown_left > 0.0:
		if cop:
			cop.show_hint("HINT_INTERCOM_WAIT")
		return
	is_jammed = true
	jobs += 1
	cooldown_left = COOLDOWN
	jammed.emit()
