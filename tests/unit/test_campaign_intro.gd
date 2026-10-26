extends GutTest

## The story of the match (comisaria.md, "El objetivo de la partida", decision 106): on the campaign's first shift
## the comisario's first talk opens with the city wanting to close the station, once.

var _briefing: CaseBriefing


func before_each() -> void:
	Campaign.current = null
	CaseBriefing._intro_heard = -1
	_briefing = CaseBriefing.new()
	add_child_autofree(_briefing)


func after_each() -> void:
	Campaign.current = null


func test_the_first_shift_opens_with_the_story() -> void:
	Campaign.start_new()
	assert_true(CaseBriefing.intro_due())
	_briefing.start(PackedStringArray(["BRIEF_A"]))
	assert_eq(_briefing.lines.size(), CaseBriefing.INTRO.size() + 1)
	assert_eq(_briefing.lines[0], "BRIEF_INTRO_A")
	assert_eq(_briefing.lines[-1], "BRIEF_A", "the case comes after the story")


func test_the_story_is_told_once_per_level() -> void:
	Campaign.start_new()
	_briefing.start(PackedStringArray(["BRIEF_A"]))
	_briefing.start(PackedStringArray(["BRIEF_B"]))
	assert_eq(_briefing.lines, PackedStringArray(["BRIEF_B"]))


func test_later_shifts_go_straight_to_the_case() -> void:
	var campaign := Campaign.start_new()
	campaign.finish_shift("raid", true, {"total": 900})
	assert_false(CaseBriefing.intro_due())
	_briefing.start(PackedStringArray(["BRIEF_A"]))
	assert_eq(_briefing.lines, PackedStringArray(["BRIEF_A"]))


func test_no_story_without_a_campaign() -> void:
	assert_false(CaseBriefing.intro_due())
	_briefing.start(PackedStringArray(["BRIEF_A"]))
	assert_eq(_briefing.lines.size(), 1)
