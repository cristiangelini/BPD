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


## Someone the cuffs close on, floating in front of the cop.
class Cuffable:
	extends StaticBody3D
	var cuffed_for := 0.0

	func cuffed(seconds: float) -> void:
		cuffed_for = seconds

	func is_cuffed() -> bool:
		return cuffed_for > 0.0


func _cop() -> Cop:
	var cop: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	cop.belt_select(0)
	return cop


## A person in front of the cop at the origin, renamed until they're one who offers (or not, with `offers` false).
func _person(offers := true) -> Cuffable:
	var person := Cuffable.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	person.add_child(shape)
	person.position = Vector3(0, GameScale.EYE_HEIGHT, -1.0)
	add_child_autofree(person)
	for i in 200:
		person.name = "Person%d" % i
		if (Handcuffs.offer_of(person) > 0) == offers:
			break
	return person


func test_someone_who_offers_isnt_cuffed_until_the_second_click() -> void:
	var cop := _cop()
	var person := _person()
	await wait_physics_frames(2)
	var cuffs: Handcuffs = cop.belt.held_tool()
	cuffs.press()
	assert_false(person.is_cuffed(), "the first click gets an offer")
	assert_true(cuffs.has_offer())
	assert_ne(cuffs.prompt_key(), "PROMPT_HANDCUFFS", "the prompt says E takes it")
	cuffs.press()
	assert_true(person.is_cuffed(), "clicking again refuses it and cuffs")
	assert_false(cuffs.has_offer())


func test_taking_the_bribe_leaves_them_free_and_pays_the_shift() -> void:
	var campaign := Campaign.start_new()
	var cop := _cop()
	var person := _person()
	await wait_physics_frames(2)
	var cuffs: Handcuffs = cop.belt.held_tool()
	cuffs.press()
	var amount := cuffs._offer_amount
	assert_true(cop.use(), "E takes it")
	assert_false(person.is_cuffed())
	assert_eq(campaign.shift_bribes, amount)
	assert_eq(cop.stats.bribes, 1, "for the joke award")
	cuffs._wait = 0.0
	cuffs.press()
	assert_true(person.is_cuffed(), "they don't offer twice")


func test_most_people_just_get_cuffed() -> void:
	var cop := _cop()
	var person := _person(false)
	await wait_physics_frames(2)
	(cop.belt.held_tool() as Handcuffs).press()
	assert_true(person.is_cuffed())


func test_an_offer_runs_out() -> void:
	var cop := _cop()
	_person()
	await wait_physics_frames(2)
	var cuffs: Handcuffs = cop.belt.held_tool()
	cuffs.press()
	cuffs._offer_left = 0.01
	await wait_physics_frames(2)
	assert_false(cuffs.has_offer())
	assert_false(cop.use(), "E does nothing once it's gone")
