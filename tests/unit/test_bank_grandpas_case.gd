extends GutTest

## The grandpa robbers' case (robo-banco-abuelos.md, step 5, decision 122): the comisario's radio, the hint when the
## first one passes for a hostage, and the true hostages cuffed by mistake on the planilla and off the pay.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _start(want: String) -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _robber(animal: String) -> BankRobber:
	for robber in bank.robbers:
		if robber.animal == animal:
			return robber
	return null


func _texts(rows: Array[Dictionary]) -> Array:
	return rows.map(func(row: Dictionary) -> String: return row.text)


func test_the_comisario_tells_about_the_grandpas() -> void:
	await _start("grandpas")
	assert_eq(bank.case.brief(), PackedStringArray(["BRIEF_BANK_GRANDPAS_A", "BRIEF_BANK_GRANDPAS_B",
		"BRIEF_BANK_GRANDPAS_C"]))


func test_the_first_one_hiding_warns_everyone_once() -> void:
	await _start("grandpas")
	var rabbit := _robber("conejo")
	rabbit.unmask()
	rabbit.spotted.emit(rabbit, cop)
	assert_true(bank.case.grandpa_hid)
	assert_eq((cop.get_node("Hud/Hint") as Label).text, "HINT_BANK_GRANDPA_HID")


func test_el_oso_seeing_a_cop_is_no_hiding() -> void:
	await _start("grandpas")
	bank.boss.spotted.emit(bank.boss, cop)
	assert_false(bank.case.grandpa_hid)


func test_a_true_hostage_cuffed_protests_and_costs() -> void:
	await _start("grandpas")
	var hostage := bank.hostages[0]
	var before := bank.case.missed()
	hostage.cuffed(Handcuffs.SECONDS)
	assert_true(hostage.is_cuffed())
	assert_eq(hostage.said(), "HOSTAGE_CUFFED")
	assert_eq(hostage.prompt_key(cop), "", "cuffed, nobody leads them out")
	assert_eq(bank.case.wrong_cuffs, 1)
	assert_eq(bank.case.missed(), before + BankCase.PER_WRONG_CUFF)
	hostage.cuffed(Handcuffs.SECONDS)
	assert_eq(bank.case.wrong_cuffs, 1, "the same one counts once")
	assert_has(_texts(bank.case.rows()), tr("OBJ_BANK_WRONG_CUFFS") % 1)


func test_cuffing_a_grandpa_robber_costs_nothing() -> void:
	await _start("grandpas")
	var duck := _robber("pato")
	duck.unmask()
	duck.global_position = duck.hide_at
	await wait_physics_frames(2)
	duck.cuffed(Handcuffs.SECONDS)
	assert_eq(bank.case.wrong_cuffs, 0)


func test_the_cuffs_on_a_hostage_run_out() -> void:
	await _start("grandpas")
	var hostage := bank.hostages[1]
	hostage.cuffed(0.2)
	await wait_seconds(0.5)
	assert_false(hostage.is_cuffed())
	assert_eq(hostage.prompt_key(cop), "PROMPT_LEAD_HOSTAGE")


func test_the_young_gangs_robbery_doesnt_charge_for_it() -> void:
	await _start("base")
	bank.hostages[0].cuffed(Handcuffs.SECONDS)
	assert_eq(bank.case.wrong_cuffs, 0)
	assert_does_not_have(_texts(bank.case.rows()), "OBJ_BANK_GRANDPAS")


func test_the_planilla_warns_about_the_grandpas() -> void:
	await _start("grandpas")
	assert_has(_texts(bank.case.rows()), "OBJ_BANK_GRANDPAS")


func test_the_pay_with_a_slipped_grandpa_and_a_wrong_cuff() -> void:
	await _start("grandpas")
	bank.hostages[0].cuffed(Handcuffs.SECONDS)
	var pig := _robber("chancho")
	pig.slip_out()
	bank.case.boss_jailed = true
	var expected := BankCase.SALARY - BankCase.PER_HOSTAGE * bank.hostages.size() - BankCase.PER_BAG \
		- BankCase.PER_WRONG_CUFF
	assert_eq(bank.case.report().salary, maxi(expected, 0))
