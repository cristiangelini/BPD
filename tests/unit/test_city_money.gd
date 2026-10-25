extends GutTest

## The street events' money on the end of shift report (ciudad-viva.md): it adds to the case's pay, once.

const SCREEN_SCENE := preload("res://scenes/ui/shift_screen.tscn")


func _events_paid(money: int) -> CityEvents:
	var events := CityEvents.new()
	add_child_autofree(events)
	events.pay(money)
	return events


func test_the_street_pays_on_top_of_the_case() -> void:
	_events_paid(60)
	CityEvents.shift_earned += 40
	var report := ShiftReport.pay(true, [250.0], 0)
	assert_false(report.approved, "500 + 250 is under the quota")
	CityEvents.add_to(report)
	assert_eq(report.street, 100)
	assert_eq(report.total, 850)
	assert_true(report.approved, "with the street's 100 it makes it")
	CityEvents.add_to(report)
	assert_eq(report.total, 850, "counted once")
	assert_eq(CityEvents.shift_earned, 0, "and started over")


func test_a_new_city_starts_the_shift_at_zero() -> void:
	_events_paid(80)
	_events_paid(0)
	assert_eq(CityEvents.shift_earned, 0)


func test_the_campaign_banks_the_street_money() -> void:
	var campaign := Campaign.new()
	_events_paid(50)
	var report := ShiftReport.pay(true, [1000.0], 0)
	campaign.finish_shift("test", true, report)
	assert_eq(report.street, 50)
	assert_eq(campaign.money, 500 + 1000 + 50)


func test_the_shift_screen_shows_the_street_line() -> void:
	var screen: ShiftScreen = SCREEN_SCENE.instantiate()
	add_child_autofree(screen)
	_events_paid(60)
	var awards: Array[Dictionary] = []
	screen.show_report(true, ShiftReport.pay(true, [1000.0], 0), 0, awards)
	await wait_frames(1)
	var texts: Array[String] = []
	for label in screen.get_node("%Lines").get_children():
		if not label.is_queued_for_deletion():
			texts.append((label as Label).text)
	assert_has(texts, tr("SHIFT_STREET"))
	assert_has(texts, "60")


func test_no_street_line_when_the_street_paid_nothing() -> void:
	var screen: ShiftScreen = SCREEN_SCENE.instantiate()
	add_child_autofree(screen)
	_events_paid(0)
	var awards: Array[Dictionary] = []
	screen.show_report(true, ShiftReport.pay(true, [1000.0], 0), 0, awards)
	var texts: Array[String] = []
	for label in screen.get_node("%Lines").get_children():
		if not label.is_queued_for_deletion():
			texts.append((label as Label).text)
	assert_does_not_have(texts, tr("SHIFT_STREET"))
