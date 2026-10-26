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
## Where the internal affairs investigation went this shift (Campaign.finish_shift), "" if nowhere.
var _investigation := ""
## The inspector's report on the last shift (inspeccion.md), from the shift's report so every PC has it; empty if none.
var _inspection := {}


func _ready() -> void:
	hide()
	%AgainButton.pressed.connect(play_again.emit)
	%MenuButton.pressed.connect(back_to_menu.emit)


## `report` comes from ShiftReport.pay(), `awards` from ShiftReport.awards(). `fines_key` says what the fines were
## for (broken ornaments, or a chase's crashes), with `broken_ornaments` as its count.
func show_report(solved: bool, report: Dictionary, broken_ornaments: int, awards: Array[Dictionary],
		fines_key := "SHIFT_FINES") -> void:
	_case_result.text = "SHIFT_CASE_SOLVED" if solved else "SHIFT_CASE_FAILED"
	_case_result.modulate = Color(0.45, 1, 0.5) if solved else Color(1, 0.4, 0.35)
	for child in _lines.get_children():
		child.queue_free()
	_line(tr("SHIFT_SALARY"), report.salary)
	_line(tr("SHIFT_EVIDENCE"), report.evidence)
	CityEvents.add_to(report)
	if report.street > 0:
		_line(tr("SHIFT_STREET"), report.street)
	_line(tr(fines_key) % broken_ornaments, -report.fines)
	# Bribes and the internal affairs agent's fines (sobornos.md), only when there were any.
	if report.get("bribes", 0) > 0:
		_line(tr("SHIFT_BRIBES"), report.bribes)
	if report.get("agent_fine", 0) > 0:
		_line(tr("SHIFT_AGENT_FINE"), -report.agent_fine)
	_line(tr("SHIFT_TOTAL"), report.total, true)
	# On the inspection's shift the quota doesn't count: her report does (show_campaign).
	_inspection = {}
	if report.has("inspection"):
		_inspection = {"score": report.inspection, "best": report.get("inspection_best", ""),
			"worst": report.get("inspection_worst", "")}
	else:
		_line(tr("SHIFT_QUOTA"), report.quota)
	_investigation = report.get("investigation", "")
	_verdict.text = tr("SHIFT_APPROVED" if report.approved else "SHIFT_SUSPENDED")
	if _investigation != "":
		_verdict.text += "\n" + tr("SHIFT_INVESTIGATION_" + _investigation.to_upper())
	_verdict.modulate = Color(0.45, 1, 0.5) if report.approved else Color(1, 0.4, 0.35)
	for child in _awards.get_children():
		child.queue_free()
	for award in awards:
		var label := Label.new()
		label.text = tr(award.key) % [tr("COP_NAME") % (award.cop + 1), roundi(award.value)]
		label.add_theme_font_size_override("font_size", 22)
		_awards.add_child(label)
	%AwardsTitle.visible = not awards.is_empty()
	_show_game_awards(report.get("game_awards", []))
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## The campaign's line under the pay: which shift this was and the group's money. When the campaign is over, the
## verdict says how: promoted after the last shift, or lost for missing the quota (decision 88). The first missed
## quota of a campaign sends the cops to their own cells instead (decision 99).
func show_campaign(shift: int, shifts: int, money: int, over: bool, promoted := false) -> void:
	_line(tr("SHIFT_TURN") % [shift, shifts], money, true)
	if over and not _inspection.is_empty():
		_show_inspection(_inspection)
		_verdict.text = tr("SHIFT_PROMOTED" if promoted else "SHIFT_INSPECTION_FAILED")
	elif over:
		var lost := "SHIFT_CAMPAIGN_LOST_AGENT" if _investigation == "suspended" else "SHIFT_CAMPAIGN_LOST"
		_verdict.text = tr(_verdict.text) + "\n" + tr("SHIFT_PROMOTED" if promoted else lost)
	elif Campaign.current and Campaign.current.jailed:
		_verdict.text = tr(_verdict.text) + "\n" + tr("SHIFT_JAILED")


## The inspector's report read out on the last shift (inspeccion.md): her score, and what she liked and hated most.
func _show_inspection(inspection: Dictionary) -> void:
	_line(tr("SHIFT_INSPECTION"), int(inspection.score), true)
	for part in [["best", "SHIFT_INSPECTION_BEST"], ["worst", "SHIFT_INSPECTION_WORST"]]:
		var kind: String = inspection.get(part[0], "")
		if kind == "":
			continue
		var label := Label.new()
		label.text = tr(part[1]) % tr("INSPECTOR_SAW_" + kind.to_upper())
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		label.add_theme_font_size_override("font_size", 22)
		_lines.add_child(label)
		_lines.add_child(Control.new())


## The awards of the whole match under the shift's, when the match is over (Campaign.finish_shift).
func _show_game_awards(game_awards: Array) -> void:
	if game_awards.is_empty():
		return
	var title := Label.new()
	title.text = "SHIFT_GAME_AWARDS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	_awards.add_child(title)
	for award: Dictionary in game_awards:
		var label := Label.new()
		label.text = tr(award.key) % [tr("COP_NAME") % (int(award.cop) + 1), roundi(award.value)]
		label.add_theme_font_size_override("font_size", 22)
		_awards.add_child(label)


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
