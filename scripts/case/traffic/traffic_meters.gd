class_name TrafficMeters
extends CanvasLayer

## The traffic control's meters at the top of the screen (control-transito.md): the queue's patience and, under it,
## the wanted car's clues known so far.

var queue: TrafficQueue
var patience_bar: ProgressBar
var clues_label: Label


func _ready() -> void:
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	add_child(box)
	var title := Label.new()
	title.text = "HUD_QUEUE_PATIENCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 6)
	box.add_child(title)
	patience_bar = ProgressBar.new()
	patience_bar.custom_minimum_size = Vector2(320, 18)
	patience_bar.max_value = TrafficQueue.FULL
	patience_bar.show_percentage = false
	patience_bar.modulate = Color(1, 0.55, 0.25)
	box.add_child(patience_bar)
	clues_label = Label.new()
	clues_label.add_theme_constant_override("outline_size", 6)
	clues_label.modulate = Color(1, 0.95, 0.7)
	box.add_child(clues_label)
	queue.patience_changed.connect(func(value: float) -> void: patience_bar.value = value)


func show_clues(text: String) -> void:
	clues_label.text = text
