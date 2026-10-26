extends GutTest

## The seed bank's case (robo-banco-semillas.md, step 4, decision 129): the radio, El Oso the gardener on the phone,
## the planilla (the jars back in the vault), the pay (broken jars cost like taken ones, all of them home pay more) and
## the green van with its pots in the chase.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var case: BankCase
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "seeds":
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
	assert_eq(case.brief(), PackedStringArray(["BRIEF_BANK_SEEDS_A", "BRIEF_BANK_SEEDS_B", "BRIEF_BANK_SEEDS_C"]))
	var texts := _texts()
	assert_has(texts, "OBJ_BANK_CUFF_OSO", "El Oso is the one to cuff")
	assert_has(texts, "OBJ_BANK_ALL_JARS")
	assert_has(texts, tr("OBJ_BANK_SEED_JARS") % [BankSeeds.JARS, BankSeeds.JARS], "all the jars home")


func test_el_oso_answers_the_phone_as_a_gardener() -> void:
	assert_eq(bank.phone.voice, "GARDENER")
	bank.phone.use(cop)
	assert_string_starts_with(bank.phone.said(), "GARDENER_PHONE_ASK_")
	for request in BankPhone.REQUESTS:
		for kind in ["ASK_", "KEPT_"]:
			var key: String = "GARDENER_PHONE_" + kind + request.to_upper()
			assert_ne(tr(key), key, key + " has a text")


func test_all_the_jars_home_pay_more_and_a_broken_one_costs() -> void:
	await wait_physics_frames(5)
	bank.hostages_freed = bank.hostages.size()
	case._jail_boss()
	assert_true(case.solved())
	assert_true(case.all_jars_home())
	assert_eq(case.report().salary, BankCase.SALARY + BankCase.ALL_JARS)
	bank.seed_bank.jars[0].shatter()
	assert_false(case.all_jars_home())
	assert_eq(case.report().salary, BankCase.SALARY - BankCase.PER_BAG)
	assert_eq(case.custody().owner, "oso")


func test_the_green_van_and_the_chase() -> void:
	assert_not_null(bank.van.get_node_or_null("RoofPots"), "the gang came in a green van with pots")
	bank.drill.drilled = bank.drill.drill_time
	await wait_until(func() -> bool: return bank.chase != null, 40.0)
	assert_not_null(bank.chase)
	assert_eq(bank.chase.who, "oso")
	assert_not_null(bank.chase.truck.get_node_or_null("RoofPots"), "he gets away in it")
	assert_gte(bank.bags_taken, 1, "with the jars he took")
	assert_eq(bank.bags_taken, bank.seed_bank.jars_taken)
