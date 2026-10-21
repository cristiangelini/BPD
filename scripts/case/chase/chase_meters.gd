class_name ChaseMeters
extends CanvasLayer

## The chase's meters at the top of the screen (persecucion.md): the clock, the distance, the damages and, for the
## school bus, the parents' complaint. The chase level shows them all shift long; a chase in the middle of another
## case (persecucion-final.md), only while it lasts.

var case: ChaseCase
## How far down (px) they start: in the middle of a raid, under its complaint meter.
var top := 12.0
var distance_bar: ProgressBar
var clock: Label
var damage_label: Label
## The school bus's parents' complaint, only for him.
var complaint_bar: ProgressBar


func _ready() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = top
	add_child(box)
	clock = Label.new()
	clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock.add_theme_font_size_override("font_size", 32)
	clock.add_theme_constant_override("outline_size", 8)
	box.add_child(clock)
	var title := Label.new()
	title.text = "HUD_DISTANCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	distance_bar = ProgressBar.new()
	distance_bar.custom_minimum_size = Vector2(320, 18)
	distance_bar.max_value = ChaseCase.ESCAPED
	distance_bar.show_percentage = false
	distance_bar.modulate = Color(1, 0.45, 0.35)
	box.add_child(distance_bar)
	if case.suspect_id == "school_bus":
		var parents := Label.new()
		parents.text = "HUD_PARENTS"
		parents.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(parents)
		complaint_bar = ProgressBar.new()
		complaint_bar.custom_minimum_size = Vector2(320, 18)
		complaint_bar.max_value = ChaseCase.COMPLAINT_FULL
		complaint_bar.show_percentage = false
		complaint_bar.modulate = Color(1, 0.8, 0.3)
		box.add_child(complaint_bar)
		case.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)
	damage_label = Label.new()
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.modulate = Color(1, 0.5, 0.4)
	damage_label.add_theme_constant_override("outline_size", 6)
	damage_label.hide()
	box.add_child(damage_label)
	show_meters(case.distance, case.time_left)
	case.meters_changed.connect(show_meters)
	case.damages.crashed.connect(func(fines: int) -> void:
		damage_label.text = tr("HUD_DAMAGES") % fines
		damage_label.show())


func show_meters(distance: float, time_left: float) -> void:
	distance_bar.value = distance
	clock.text = "%d:%02d" % [int(ceilf(time_left)) / 60, int(ceilf(time_left)) % 60]
