extends GutTest

## Saving the campaign between shifts (docs/diseno/guardado.md).

const HOUSE := preload("res://scenes/levels/grandpa_house.tscn")
const TEST_PATH := "user://test_partidas/partida.json"


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	DirAccess.remove_absolute(TEST_PATH)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _report(total: int) -> Dictionary:
	return {"total": total, "approved": total >= ShiftReport.QUOTA}


func test_each_shift_has_its_own_case_always_the_same() -> void:
	var campaign := Campaign.start_new()
	var first := campaign.case_seed()
	assert_ne(first, 0)
	assert_eq(campaign.case_seed(), first, "the same shift, the same case")
	campaign.finish_shift("bingo", true, _report(900))
	assert_ne(campaign.case_seed(), first, "the next shift has another case")


func test_money_and_history_add_up_over_the_shifts() -> void:
	var campaign := Campaign.start_new()
	campaign.finish_shift("bingo", true, _report(900))
	campaign.finish_shift("museum", false, _report(-40))
	assert_eq(campaign.shift, 3)
	assert_eq(campaign.money, 860, "the group's money is every shift's total")
	assert_eq(campaign.history.size(), 2)
	assert_false(campaign.history[1].approved)


func test_a_saved_campaign_comes_back_with_the_same_money_items_and_cases() -> void:
	var campaign := Campaign.start_new()
	campaign.items.append("taser")
	campaign.finish_shift("bingo", true, _report(900))
	campaign.finish_shift("museum", true, _report(1200))
	var next_case := campaign.case_seed()
	assert_eq(campaign.save(), OK)
	var back := Campaign.load_saved()
	assert_not_null(back)
	assert_eq(back.shift, 3, "it picks up at shift 3")
	assert_eq(back.money, 2100)
	assert_eq(back.items, ["taser"])
	assert_eq(back.case_seed(), next_case, "with the case that was next")
	assert_eq(back.history, campaign.history)


func test_a_finished_campaign_cant_be_continued() -> void:
	assert_false(Campaign.can_continue(), "nothing saved")
	var campaign := Campaign.start_new()
	campaign.save()
	assert_true(Campaign.can_continue())
	for i in Campaign.SHIFTS:
		campaign.finish_shift("bingo", true, _report(900))
	campaign.save()
	assert_true(campaign.is_over())
	assert_false(Campaign.can_continue(), "after shift 5 the campaign is over")


func test_the_next_case_comes_from_the_campaign() -> void:
	var campaign := Campaign.start_new()
	assert_eq(PlaceDraw.next_seed(), campaign.case_seed())


func test_the_end_of_a_shift_saves_and_shows_the_campaign() -> void:
	var campaign := Campaign.start_new()
	var house: Node3D = HOUSE.instantiate()
	house.get_node("Cop").input_enabled = false
	house.case_seed = campaign.case_seed()
	add_child_autofree(house)
	await wait_process_frames(2)
	house.raid.finish_shift()
	assert_eq(campaign.shift, 2, "the campaign moved on to shift 2")
	var saved := Campaign.load_saved()
	assert_not_null(saved, "and was saved")
	assert_eq(saved.shift, 2)
	assert_true(house.get_node("ShiftScreen").get_node("%AgainButton").visible, "four shifts to go")
