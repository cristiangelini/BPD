extends GutTest

## The sorry robber's case (robo-banco-arrepentido.md, step 5, decision 123): the comisario's radio about the robber who
## called crying, hints when he's turned and when he's tied, the planilla with his helps, +50 a help in the pay, and no
## sack for him when the vault opens.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _bank(want := "sorry") -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	cop.global_position = bank.car.global_position + Vector3(3, 0.1, 0)
	await wait_physics_frames(1)


func _texts(rows: Array[Dictionary]) -> Array[String]:
	var texts: Array[String] = []
	for row in rows:
		texts.append(row.text)
	return texts


func test_the_radio_tells_about_the_crying_robber() -> void:
	await _bank()
	assert_eq(bank.case.brief(), PackedStringArray(["BRIEF_BANK_SORRY_A", "BRIEF_BANK_SORRY_B", "BRIEF_BANK_SORRY_C"]))


func test_each_help_done_adds_to_the_pay() -> void:
	await _bank()
	bank.case.boss_jailed = true
	bank.hostages_freed = bank.hostages.size()
	var base: int = bank.case.report().salary
	bank.sorry.helps_done = ["door", "drill"] as Array[String]
	assert_eq(bank.case.helps(), 2)
	assert_eq(bank.case.report().salary, base + 2 * BankCase.PER_HELP)


func test_unsolved_the_helps_pay_nothing() -> void:
	await _bank()
	bank.sorry.helps_done = ["door", "drill", "hostages"] as Array[String]
	assert_eq(bank.case.report().salary, 0)


func test_everyone_hears_it_when_he_is_turned_and_when_he_is_tied() -> void:
	await _bank()
	assert_false(bank.case.sorry_turned)
	bank.sorry.try_turn(cop)
	assert_true(bank.case.sorry_turned)
	bank.sorry.tie(bank.sorry.global_position, 0.0)
	assert_true(bank.case.sorry_tied)


func test_the_planilla_shows_him_and_his_helps() -> void:
	await _bank()
	bank.sorry.helps_done = ["door"] as Array[String]
	var rows := bank.case.rows()
	var texts := _texts(rows)
	assert_has(texts, "OBJ_BANK_SORRY")
	assert_has(texts, tr("OBJ_BANK_SORRY_HELPS") % [1, BankRobber.HELPS.size()])


func test_no_sorry_rows_in_the_base_robbery() -> void:
	await _bank("base")
	assert_does_not_have(_texts(bank.case.rows()), "OBJ_BANK_SORRY")
	assert_eq(bank.case.helps(), 0)


func test_when_the_vault_opens_he_takes_no_sack_and_waits() -> void:
	await _bank()
	var loose := 0
	for robber in bank.robbers:
		if BankLevel.is_loose(robber):
			loose += 1
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	assert_true(bank.drill.is_open)
	assert_eq(bank.bags_taken, loose - 1, "everyone but him took a sack")
	assert_true(bank.sorry.visible, "he stays")
	assert_true(bank.sorry.surrendered, "and lets himself be cuffed")
	assert_eq(bank.sorry.said(), "ROBBER_SORRY_WAIT")
	assert_eq(bank.sorry.next_help(), "")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_BANK_SORRY_A", "HINT_BANK_SORRY_TURNED", "HINT_BANK_SORRY_TIED", "OBJ_BANK_SORRY",
			"ROBBER_SORRY_WAIT", "ROBBER_TRAITOR", "PROMPT_UNTIE_SORRY"]:
		assert_ne(tr(key), key, key)
