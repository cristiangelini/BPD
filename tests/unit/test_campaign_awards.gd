extends GutTest

## The awards of the whole match (comisaria.md, "Cómo se gana"): the cops' stats add up shift by shift and the shift
## that ends the campaign hands them out.

func before_each() -> void:
	Campaign.save_path = "user://test_campaign_awards.json"


func after_each() -> void:
	DirAccess.remove_absolute(Campaign.save_path)
	Campaign.save_path = Campaign.SAVE_PATH


func _pay(total: int) -> Dictionary:
	return {"salary": total, "evidence": 0, "fines": 0, "total": total}


func test_stats_add_up_over_the_shifts() -> void:
	var campaign := Campaign.new()
	campaign.add_stats([{"meters_driven": 100.0, "photos": 2}, {"meters_driven": 50.0}])
	campaign.add_stats([{"meters_driven": 10.0}, {"meters_driven": 300.0, "photos": 1}])
	assert_almost_eq(float(campaign.cop_totals[0].meters_driven), 110.0, 0.01)
	assert_almost_eq(float(campaign.cop_totals[1].meters_driven), 350.0, 0.01)
	assert_eq(int(campaign.cop_totals[0].photos), 2)
	assert_eq(int(campaign.cop_totals[1].photos), 1)


func test_only_the_last_shift_hands_out_the_match_awards() -> void:
	var campaign := Campaign.new()
	campaign.add_stats([{"meters_driven": 100.0}, {"meters_driven": 50.0}])
	var first := _pay(5000)
	campaign.finish_shift("test", true, first)
	assert_false(first.has("game_awards"))
	campaign.shift = Campaign.SHIFTS
	campaign.add_stats([{"meters_driven": 0.0}, {"meters_driven": 80.0}])
	var last := _pay(5000)
	campaign.finish_shift("test", true, last)
	assert_true(campaign.is_promoted())
	var awards: Array = last.game_awards
	assert_eq(awards.size(), 1)
	assert_eq(awards[0].key, "AWARD_METERS_DRIVEN")
	assert_eq(awards[0].cop, 1, "50 + 80 beats 100 + 0")


func test_a_lost_match_hands_them_out_too() -> void:
	var campaign := Campaign.new()
	campaign.jailbreak_used = true
	campaign.add_stats([{"photos": 3}])
	var report := _pay(0)
	campaign.finish_shift("test", false, report)
	assert_true(campaign.is_over())
	assert_eq((report.game_awards as Array).size(), 1)


func test_the_totals_are_saved() -> void:
	var campaign := Campaign.new()
	campaign.add_stats([{"photos": 3}, {"photos": 1}])
	campaign.save()
	var loaded := Campaign.load_saved()
	assert_eq(loaded.cop_totals.size(), 2)
	assert_eq(int(loaded.cop_totals[0].photos), 3)
