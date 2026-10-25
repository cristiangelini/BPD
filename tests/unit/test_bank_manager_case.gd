extends GutTest

## The manager's case (robo-banco-gerente.md, step 4, decision 124): the comisario's radio sends the cops to look after
## the manager; the boss manager in the patrol car solves it, El Oso alone doesn't; still loose when the vault opens,
## the gang loads his car and he drives off (the chase); caught early pays more, he goes to the interrogation, and the
## honest manager cuffed costs 200 in every robbery.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _bank(want := "manager") -> void:
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


func test_the_radio_tells_about_the_poor_manager() -> void:
	await _bank()
	assert_eq(bank.case.brief(), PackedStringArray(["BRIEF_BANK_MANAGER_A", "BRIEF_BANK_MANAGER_B",
		"BRIEF_BANK_MANAGER_C"]))


func test_el_oso_alone_does_not_solve_it_but_the_manager_does() -> void:
	await _bank()
	OwnerEscort.of(bank.boss).board()
	assert_true(bank.case.boss_jailed)
	assert_false(bank.case.solved(), "El Oso isn't the real boss")
	bank.manager.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(bank.manager).board()
	assert_true(bank.case.manager_jailed)
	assert_true(bank.case.solved())


func test_caught_before_the_vault_opens_pays_more() -> void:
	await _bank()
	bank.hostages_freed = bank.hostages.size()
	bank.manager.cuffed(Handcuffs.SECONDS)
	assert_true(bank.case.manager_early)
	OwnerEscort.of(bank.manager).board()
	assert_eq(bank.case.report().salary, BankCase.SALARY + BankCase.EARLY_MANAGER)


func test_the_planilla_asks_for_the_real_boss() -> void:
	await _bank()
	var texts := _texts(bank.case.rows())
	assert_has(texts, "OBJ_BANK_CUFF_BOSS")
	assert_has(texts, "OBJ_BANK_BACK_MANAGER")
	assert_does_not_have(texts, "OBJ_BANK_CUFF_OSO")


func test_loose_when_the_vault_opens_he_drives_off_with_the_gang() -> void:
	await _bank()
	var loose := 0
	for robber in bank.robbers:
		if BankLevel.is_loose(robber):
			loose += 1
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	assert_not_null(bank.chase)
	assert_eq(bank.chase.suspect_id, SuspectCar.MANAGER_CAR)
	assert_eq(bank.chase.who, "manager")
	assert_false(bank.manager.visible, "he's in his car")
	assert_false(is_instance_valid(bank.manager_car), "his parked car is the one that runs")
	assert_eq(bank.bags_taken, loose, "every loose robber took a sack")
	assert_has(_texts(bank.case.rows()), "OBJ_BANK_CATCH_MANAGER")


func test_caught_at_the_end_of_his_getaway_solves_it() -> void:
	await _bank()
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	bank.case._on_getaway_ended(true)
	assert_true(bank.case.manager_jailed)
	assert_true(bank.case.solved())
	assert_false(bank.case.manager_early)


func test_his_getaway_loses_it() -> void:
	await _bank()
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	bank.case._on_getaway_ended(false)
	assert_true(bank.case.escaped)
	assert_false(bank.case.solved())
	assert_eq(bank.case.report().salary, 0)


func test_already_cuffed_the_getaway_is_el_osos() -> void:
	await _bank()
	bank.manager.cuffed(Handcuffs.SECONDS)
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	assert_not_null(bank.chase)
	assert_eq(bank.chase.who, "oso")
	assert_true(is_instance_valid(bank.manager_car))
	bank.case._on_getaway_ended(false)
	await wait_seconds(BankCase.SHIFT_DELAY + 0.3)
	assert_false(bank.case.shift_over, "El Oso getting away doesn't end it")


func test_he_goes_to_the_interrogation() -> void:
	await _bank()
	bank.manager.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(bank.manager).board()
	var custody := bank.case.custody()
	assert_eq(custody.owner, "manager")
	assert_eq(custody.slips[0], "MANAGER_SLIP_1")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_manager"))


func test_the_honest_manager_cuffed_costs_200() -> void:
	await _bank("base")
	bank.case.boss_jailed = true
	bank.hostages_freed = bank.hostages.size()
	var base: int = bank.case.report().salary
	bank.manager.cuffed(Handcuffs.SECONDS)
	assert_true(bank.case.wrong_manager)
	assert_eq(bank.case.report().salary, base - BankCase.PER_WRONG_MANAGER)
	assert_has(_texts(bank.case.rows()), "OBJ_BANK_WRONG_MANAGER")
	assert_false(bank.case.manager_jailed)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_BANK_MANAGER_A", "HINT_ESCAPE_manager", "CHASE_MANAGER_LINE_1", "OBJ_BANK_CUFF_BOSS",
			"OBJ_BANK_CATCH_MANAGER", "OBJ_BANK_WRONG_MANAGER", "OBJ_BANK_BACK_MANAGER", "CRIME_owner_manager", "CONFESS_owner_manager",
			"MANAGER_SLIP_1"]:
		assert_ne(tr(key), key, key)
