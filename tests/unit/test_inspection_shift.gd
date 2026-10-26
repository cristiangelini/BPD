extends GutTest

## The last shift is the inspection (inspeccion.md, step 4, decision 107): the comisario brings the inspector in, only
## her report decides (60 of 100 with the case's +25), and failing it closes the station with no jailbreak.

var _briefing: CaseBriefing


func before_each() -> void:
	Campaign.current = null
	CaseBriefing._intro_heard = -1
	_briefing = CaseBriefing.new()
	add_child_autofree(_briefing)


func after_each() -> void:
	Campaign.current = null


func _last_shift(score: int) -> Campaign:
	var campaign := Campaign.start_new()
	campaign.shift = Campaign.SHIFTS
	campaign.inspection = {"score": score, "best": "cuffed", "worst": "crash"}
	return campaign


func test_the_comisario_brings_her_in() -> void:
	Campaign.start_new().shift = Campaign.SHIFTS
	_briefing.start(PackedStringArray(["BRIEF_A"]))
	assert_eq(_briefing.lines[0], "BRIEF_INSPECTION_A")
	assert_eq(_briefing.lines[-1], "BRIEF_A")


func test_a_good_report_saves_the_station_even_short_of_the_quota() -> void:
	var campaign := _last_shift(InspectionReport.PASS - InspectionReport.SOLVED)
	var report := {"total": 100}
	campaign.finish_shift("raid", true, report)
	assert_true(report.approved)
	assert_eq(report.inspection, InspectionReport.PASS)
	assert_true(campaign.is_promoted())
	assert_eq(campaign.last_inspection.best, "solved")


func test_a_bad_report_closes_it_with_no_jailbreak() -> void:
	var campaign := _last_shift(30)
	var report := {"total": 5000}
	campaign.finish_shift("raid", true, report)
	assert_false(report.approved, "the money doesn't save it")
	assert_true(campaign.suspended)
	assert_false(campaign.jailed)
	assert_true(campaign.is_over())


func test_a_lost_case_adds_nothing() -> void:
	var report := InspectionReport.final({"score": 50, "best": "", "worst": "hit"}, false)
	assert_eq(report.score, 50)
	assert_false(report.approved)


func test_the_summary_names_the_best_and_the_worst() -> void:
	var notes := InspectionReport.new()
	autofree(notes)
	notes.note("cuffed")
	notes.note("cuffed")
	notes.note("evidence")
	notes.note("donut")
	notes.note("hit")
	var summary := notes.summary()
	assert_eq(summary.best, "cuffed")
	assert_eq(summary.worst, "hit")
