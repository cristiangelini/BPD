extends GutTest

## End of shift: pay, quota and joke awards (docs/diseno/allanamiento.md, "Cómo se gana y cómo se pierde").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func test_a_solved_case_pays_salary_and_evidence_minus_fines() -> void:
	var report := ShiftReport.pay(true, [1000.0, 420.4], 60)
	assert_eq(report.salary, 500)
	assert_eq(report.evidence, 1420)
	assert_eq(report.total, 500 + 1420 - 60)
	assert_true(report.approved)


func test_a_failed_case_pays_nothing_but_still_fines() -> void:
	var report := ShiftReport.pay(false, [1000.0], 40)
	assert_eq(report.salary, 0)
	assert_eq(report.evidence, 0)
	assert_eq(report.total, -40)
	assert_false(report.approved)


func test_below_the_quota_is_suspended() -> void:
	# Salary 500 + a battered tin worth 250 = 750, under the 800 quota.
	assert_false(ShiftReport.pay(true, [250.0], 0).approved)
	assert_true(ShiftReport.pay(true, [300.0], 0).approved, "exactly the quota is enough")


func test_awards_go_to_the_highest_and_skip_zeros() -> void:
	var awards := ShiftReport.awards([
		{"ram_misses": 2, "story_seconds": 0.0, "meters_driven": 10.0},
		{"ram_misses": 5, "story_seconds": 0.0, "meters_driven": 3.0},
	])
	assert_eq(awards.size(), 2, "nobody listened to a story")
	assert_eq(awards[0].key, "AWARD_RAM_MISSES")
	assert_eq(awards[0].cop, 1)
	assert_eq(awards[1].key, "AWARD_METERS_DRIVEN")
	assert_eq(awards[1].cop, 0)


func test_the_house_shows_the_shift_screen_with_the_pay() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.get_node("Cop").input_enabled = false
	house.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(30)
	var tin := house.main_evidence()
	tin.global_position = house.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	house.mark(house.suspicions.find(house.story.id))
	house.car.enter(house.get_node("Cop"))
	house.finish_shift()
	var screen: ShiftScreen = house.get_node("ShiftScreen")
	assert_true(screen.visible)
	assert_eq(screen.get_node("%Verdict").text, tr("SHIFT_APPROVED"), "500 + 1000 is over the quota")
	assert_true(house.shift_over)
