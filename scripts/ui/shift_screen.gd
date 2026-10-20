class_name ShiftScreen
extends CanvasLayer

## End of shift screen: how the case went, the pay line by line, the quota and the joke awards.
## Placeholder layout until the HUD art exists; every text goes through tr().

signal play_again
signal back_to_menu

@onready var _case_result: Label = %CaseResult
@onready var _lines: GridContainer = %Lines
@onready var _verdict: Label = %Verdict
@onready var _awards: VBoxContainer = %Awards


func _ready() -> void:
	hide()
	%AgainButton.pressed.connect(play_again.emit)
	%MenuButton.pressed.connect(back_to_menu.emit)


## `report` comes from ShiftReport.pay(), `awards` from ShiftReport.awards().
func show_report(solved: bool, report: Dictionary, broken_ornaments: int, awards: Array[Dictionary]) -> void:
	_case_result.text = "SHIFT_CASE_SOLVED" if solved else "SHIFT_CASE_FAILED"
	_case_result.modulate = Color(0.45, 1, 0.5) if solved else Color(1, 0.4, 0.35)
	for child in _lines.get_children():
		child.queue_free()
	_line(tr("SHIFT_SALARY"), report.salary)
	_line(tr("SHIFT_EVIDENCE"), report.evidence)
	_line(tr("SHIFT_FINES") % broken_ornaments, -report.fines)
	_line(tr("SHIFT_TOTAL"), report.total, true)
	_line(tr("SHIFT_QUOTA"), report.quota)
	_verdict.text = "SHIFT_APPROVED" if report.approved else "SHIFT_SUSPENDED"
	_verdict.modulate = Color(0.45, 1, 0.5) if report.approved else Color(1, 0.4, 0.35)
	for child in _awards.get_children():
		child.queue_free()
	for award in awards:
		var label := Label.new()
		label.text = tr(award.key) % [tr("COP_NAME") % (award.cop + 1), roundi(award.value)]
		label.add_theme_font_size_override("font_size", 22)
		_awards.add_child(label)
	%AwardsTitle.visible = not awards.is_empty()
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## The campaign's line under the pay: which shift this was, the group's money and whether the campaign is over.
func show_campaign(shift: int, shifts: int, money: int, over: bool) -> void:
	_line(tr("SHIFT_TURN") % [shift, shifts], money, true)
	if over:
		_verdict.text = tr(_verdict.text) + "\n" + tr("SHIFT_CAMPAIGN_OVER")


func _line(text: String, amount: int, bold := false) -> void:
	var name_label := Label.new()
	name_label.text = text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var amount_label := Label.new()
	amount_label.text = ("%+d" % amount) if amount < 0 else str(amount)
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for label in [name_label, amount_label]:
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		label.add_theme_font_size_override("font_size", 30 if bold else 24)
		_lines.add_child(label)
	if amount < 0:
		amount_label.modulate = Color(1, 0.45, 0.4)
