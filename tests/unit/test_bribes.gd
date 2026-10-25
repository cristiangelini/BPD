extends GutTest

## Bribes and the internal affairs investigation (docs/diseno/sobornos.md, decisions 190 to 192).

const TEST_PATH := "user://test_partidas/sobornos.json"


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.current = null


func _report(total: int) -> Dictionary:
	return {"total": total}


func test_about_one_in_four_offer_and_always_the_same_amount() -> void:
	var offers := 0
	for i in 400:
		var amount := Bribes.offer(1234, "Npc%d" % i)
		assert_eq(Bribes.offer(1234, "Npc%d" % i), amount, "the same person offers the same on every PC")
		if amount > 0:
			offers += 1
			assert_has(Bribes.AMOUNTS, amount)
	assert_between(offers, 60, 140, "about one in four people offer")


func test_each_person_has_one_of_the_phrases() -> void:
	var key := Bribes.phrase_key(1234, "Npc1")
	assert_eq(key, Bribes.phrase_key(1234, "Npc1"))
	var number := int(key.trim_prefix("BRIBE_OFFER_"))
	assert_between(number, 1, Bribes.PHRASES)


func test_a_bribe_adds_to_the_shift_total() -> void:
	var campaign := Campaign.start_new()
	assert_false(campaign.take_bribe(200))
	var report := _report(700)
	campaign.finish_shift("bingo", true, report, 800)
	assert_eq(report.bribes, 200)
	assert_eq(report.total, 900, "the bribe helps make the quota")
	assert_true(report.approved)
	assert_eq(campaign.money, 900)
	assert_eq(campaign.shift_bribes, 0, "the next shift starts with no bribes")


func test_three_bribes_open_an_investigation() -> void:
	var campaign := Campaign.start_new()
	campaign.take_bribe(100)
	campaign.take_bribe(100)
	var report := _report(900)
	campaign.finish_shift("bingo", true, report)
	assert_false(campaign.investigation)
	assert_false(report.has("investigation"))
	campaign.take_bribe(150)
	report = _report(900)
	campaign.finish_shift("museum", true, report)
	assert_true(campaign.investigation, "the third bribe of the campaign opens it")
	assert_eq(report.investigation, "opened")


func test_bribes_away_from_the_agent_still_count() -> void:
	var campaign := Campaign.start_new()
	campaign.investigation = true
	assert_false(campaign.take_bribe(250, false))
	var report := _report(800)
	campaign.finish_shift("bingo", true, report)
	assert_eq(report.total, 1050)
	assert_eq(report.agent_fine, 0)


func test_a_bribe_the_agent_sees_is_fined_and_the_second_suspends() -> void:
	var campaign := Campaign.start_new()
	campaign.investigation = true
	assert_true(campaign.take_bribe(200, true), "the agent catches it")
	var report := _report(1200)
	campaign.finish_shift("bingo", true, report)
	assert_eq(report.bribes, 0, "a caught bribe doesn't count")
	assert_eq(report.agent_fine, Bribes.CAUGHT_FINE)
	assert_eq(report.total, 1200 - Bribes.CAUGHT_FINE)
	assert_false(campaign.is_over())
	campaign.take_bribe(200, true)
	report = _report(1500)
	campaign.finish_shift("museum", true, report)
	assert_eq(report.investigation, "suspended")
	assert_true(campaign.suspended, "the second catch ends the campaign")
	assert_true(campaign.is_over())


func test_a_seen_bribe_without_investigation_counts() -> void:
	var campaign := Campaign.start_new()
	assert_false(campaign.take_bribe(100, true), "no agent, nobody to see it")
	assert_eq(campaign.bribes_taken, 1)


func test_two_clean_shifts_close_the_investigation() -> void:
	var campaign := Campaign.start_new()
	campaign.investigation = true
	campaign.bribes_taken = 3
	campaign.finish_shift("bingo", true, _report(900))
	assert_true(campaign.investigation, "one clean shift isn't enough")
	campaign.take_bribe(100)
	campaign.finish_shift("museum", true, _report(1000))
	assert_eq(campaign.clean_shifts, 0, "a bribe starts the count again")
	campaign.finish_shift("radio", true, _report(1100))
	var report := _report(1200)
	campaign.finish_shift("club", true, report)
	assert_eq(report.investigation, "closed")
	assert_false(campaign.investigation)
	assert_eq(campaign.bribes_taken, 0, "the record is clean again")


func test_the_record_is_saved_between_shifts() -> void:
	var campaign := Campaign.start_new()
	campaign.bribes_taken = 4
	campaign.investigation = true
	campaign.clean_shifts = 1
	campaign.agent_catches = 1
	assert_eq(campaign.save(TEST_PATH), OK)
	var loaded := Campaign.load_saved(TEST_PATH)
	assert_eq(loaded.bribes_taken, 4)
	assert_true(loaded.investigation)
	assert_eq(loaded.clean_shifts, 1)
	assert_eq(loaded.agent_catches, 1)


func test_an_old_save_has_a_clean_record() -> void:
	var loaded := Campaign.from_dict({"seed": 5, "shift": 2})
	assert_eq(loaded.bribes_taken, 0)
	assert_false(loaded.investigation)
