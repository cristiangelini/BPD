class_name OfficePrinter
extends Node3D

## The insurance office's giant printer (docs/diseno/seguros.md, "Su distracción"): its green button sends 500 copies,
## it spits a burst of sheets and jams until the floor boss fixes it. It faces +z. Every number here is (propuesta).

signal jammed

const SIZE := Vector3(1.4, 1.3, 0.9)
const BODY := Color(0.86, 0.86, 0.84)
const TRAY := Color(0.95, 0.95, 0.93)
const GREEN := Color(0.2, 0.75, 0.3)

var is_jammed := false
## Times it was sent to print.
var jobs := 0
var button: PushButton


func _ready() -> void:
	var build := PlaceBuilder.new(self)
	build.box(Vector3(0, SIZE.y / 2, 0), SIZE, BODY)
	build.mesh_box(Vector3(0, SIZE.y - 0.15, SIZE.z / 2 + 0.1), Vector3(0.9, 0.04, 0.3), TRAY)
	build.mesh_box(Vector3(-0.35, SIZE.y + 0.02, 0.15), Vector3(0.4, 0.04, 0.3), Color(0.2, 0.2, 0.23))
	button = PushButton.new()
	button.prompt = "PROMPT_PRINTER_BUTTON"
	button.color = GREEN
	button.position = Vector3(0.45, SIZE.y - 0.25, SIZE.z / 2 + 0.04)
	add_child(button)
	button.pressed.connect(print_copies)


## 500 copies: a burst of sheets out of the tray and it jams. Pressing it jammed only tells the cop so.
func print_copies(cop: Cop = null) -> void:
	if is_jammed:
		if cop:
			cop.show_hint("HINT_PRINTER_JAMMED")
		return
	is_jammed = true
	jobs += 1
	var burst := PaperPile.new()
	burst.position = Vector3(0, SIZE.y - 0.13, SIZE.z / 2 + 0.1)
	add_child(burst)
	burst.scatter()
	get_tree().create_timer(PaperPile.SHEET_LIFE + 0.5).timeout.connect(burst.queue_free)
	jammed.emit()


## The floor boss cleared the jam: it prints again.
func fix() -> void:
	is_jammed = false
