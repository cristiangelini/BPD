extends GutTest

## The blood bank's case (robo-banco-sangre.md, step 4, decision 128): the radio, El Conde on the phone, the planilla
## (El Conde cuffed, the bags still cold), the pay (spoiled bags cost like taken ones, all of them cold pay more), the
## black hearse with its coffin and the chase, and his interrogation.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var case: BankCase
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "blood":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	case = bank.case


func _texts() -> Array[String]:
	var texts: Array[String] = []
	for row in case.rows():
		texts.append(str(row.text))
	return texts


func test_the_radio_and_the_planilla() -> void:
	assert_eq(case.brief(), PackedStringArray(["BRIEF_BANK_BLOOD_A", "BRIEF_BANK_BLOOD_B", "BRIEF_BANK_BLOOD_C"]))
	var texts := _texts()
	assert_has(texts, "OBJ_BANK_CUFF_CONDE")
	assert_has(texts, "OBJ_BANK_BACK_CONDE")
	assert_has(texts, "OBJ_BANK_ALL_BAGS")
	assert_does_not_have(texts, "OBJ_BANK_CUFF_OSO")
	assert_has(texts, tr("OBJ_BANK_BLOOD_BAGS") % [BankBlood.BAGS, BankBlood.BAGS], "all the bags cold")


func test_el_conde_answers_the_phone() -> void:
	assert_eq(bank.phone.voice, "CONDE")
	bank.phone.use(cop)
	assert_string_starts_with(bank.phone.said(), "CONDE_PHONE_ASK_")


func test_all_the_bags_cold_pay_more_and_a_spoiled_one_costs() -> void:
	bank.hostages_freed = bank.hostages.size()
	case._jail_boss()
	assert_true(case.solved())
	assert_true(case.all_bags_cold())
	assert_eq(case.report().salary, BankCase.SALARY + BankCase.ALL_BAGS)
	var bag: BloodBag = bank.blood_bank.bags[0]
	bag.spoiled = true
	assert_false(case.all_bags_cold())
	assert_eq(case.report().salary, BankCase.SALARY - BankCase.PER_BAG)
	assert_eq(case.custody().owner, "conde")
	assert_eq(case.custody().slips[0], "CONDE_SLIP_1")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_conde"), "he can be interrogated")


func test_the_hearse_and_the_chase() -> void:
	assert_not_null(bank.van.get_node_or_null("Coffin"), "the gang came in a hearse")
	bank.drill.drilled = bank.drill.drill_time
	await wait_until(func() -> bool: return bank.chase != null, 40.0)
	assert_not_null(bank.chase)
	assert_eq(bank.chase.who, "conde")
	assert_not_null(bank.chase.truck.get_node_or_null("Coffin"), "he gets away in it")
	assert_gte(bank.bags_taken, 1, "with the bags he took")
	assert_eq(bank.bags_taken, bank.blood_bank.bags_taken)


func test_he_gets_away_and_the_case_is_lost() -> void:
	bank._run_getaway(false)
	bank.chase.ended.emit(false)
	assert_true(case.escaped)
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)
