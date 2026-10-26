extends GutTest

## The town bank's case (robo-banco-pueblo.md, step 4, decision 127): the radio, El Conejo on the phone, the planilla
## (don Plácido out, El Conejo cuffed, his nerves), the pay (don Plácido left inside costs, carried out asleep pays
## more), El Conejo bolting into the chase with no sacks or the vault opening with two, and his interrogation.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var case: BankCase
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "town":
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
	assert_eq(case.brief(), PackedStringArray(["BRIEF_BANK_TOWN_A", "BRIEF_BANK_TOWN_B", "BRIEF_BANK_TOWN_C"]))
	var texts := _texts()
	assert_has(texts, "OBJ_BANK_CLERK")
	assert_has(texts, "OBJ_BANK_CUFF_CONEJO")
	assert_has(texts, "OBJ_BANK_CLERK_ASLEEP")
	assert_has(texts, "OBJ_BANK_BACK_CONEJO")
	assert_does_not_have(texts, "OBJ_BANK_CUFF_OSO")
	assert_does_not_have(texts, "OBJ_BANK_BACK")
	for text in texts:
		assert_false(text.contains("/0)"), "no hostages row: " + text)


func test_el_conejo_answers_the_phone() -> void:
	assert_eq(bank.phone.voice, "CONEJO")
	bank.phone.use(cop)
	assert_string_starts_with(bank.phone.said(), "CONEJO_PHONE_ASK_")


func test_cuffed_with_don_placido_carried_out_asleep_it_pays_more() -> void:
	bank.clerk.freeze = false
	bank.clerk.global_position = bank.to_global(Vector3(0, 0.2, BankLevel.HALF_Z + 3.0))
	await wait_physics_frames(3)
	assert_true(bank.clerk.out)
	case._jail_boss()
	assert_true(case.solved())
	assert_true(case.clerk_slept())
	assert_eq(case.report().salary, BankCase.SALARY + BankCase.CLERK_ASLEEP)
	assert_eq(case.custody().owner, "conejo")
	assert_eq(case.custody().slips[0], "CONEJO_SLIP_1")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_conejo"), "he can be interrogated")


func test_woken_up_once_it_doesnt_pay_the_extra() -> void:
	bank.clerk.wake("talk")
	bank.clerk.freeze = false
	bank.clerk.global_position = bank.to_global(Vector3(0, 0.2, BankLevel.HALF_Z + 3.0))
	await wait_physics_frames(3)
	case._jail_boss()
	assert_false(case.clerk_slept())
	assert_eq(case.report().salary, BankCase.SALARY)


func test_out_of_nerves_he_takes_the_van_with_don_placido_still_inside() -> void:
	bank.nerves.add(BankNerves.MAX)
	await wait_until(func() -> bool: return bank.chase != null, 30.0)
	assert_not_null(bank.chase)
	assert_eq(bank.chase.who, "conejo")
	assert_eq(bank.bags_taken, 0, "the vault was still shut")
	assert_eq(bank.drill.rate(), 0.0, "nobody holds the drill")
	assert_true(case.clerk_left)
	case._jail_boss()
	assert_eq(case.report().salary, BankCase.SALARY - BankCase.PER_CLERK)


func test_the_vault_open_he_takes_two_sacks() -> void:
	bank.drill.drilled = bank.drill.drill_time - 0.01
	await wait_until(func() -> bool: return bank.chase != null, 5.0)
	assert_eq(bank.bags_taken, BankLevel.TOWN_SACKS)
	assert_eq(bank.chase.who, "conejo")


func test_he_gets_away_and_the_case_is_lost() -> void:
	bank.nerves.add(BankNerves.MAX)
	await wait_until(func() -> bool: return bank.chase != null, 30.0)
	bank.chase.ended.emit(false)
	assert_true(case.escaped)
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)
