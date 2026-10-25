extends GutTest

## The party's case (robo-banco-rehenes.md, step 5, decision 121): the comisario's radio about the hostages who don't
## want to leave, the hint the first time a fan warns the gang, and the planilla with the fans and the croissants.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _open(party: bool) -> void:
	bank = LEVEL.instantiate()
	bank.case_seed = 3 if party else 4
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_the_seeds_these_tests_take() -> void:
	assert_true(BankLevel.is_party(3, PackedStringArray()))
	assert_false(BankLevel.is_party(4, PackedStringArray()))


func test_the_comisario_tells_about_the_party() -> void:
	await _open(true)
	assert_eq(bank.case.brief(), PackedStringArray(["BRIEF_BANK_PARTY_A", "BRIEF_BANK_PARTY_B",
		"BRIEF_BANK_PARTY_C"]))


func test_the_base_robbery_keeps_its_radio() -> void:
	await _open(false)
	assert_eq(bank.case.brief()[0], "BRIEF_BANK_A")
	for row in bank.case.rows():
		assert_ne(row.text, "OBJ_BANK_FANS")


func test_the_first_fan_who_warns_the_gang_shows_a_hint() -> void:
	await _open(true)
	var fan: BankHostage
	for hostage in bank.hostages:
		if hostage.snitch != "":
			fan = hostage
	fan.snitched.emit(fan, cop)
	assert_true(bank.case.fans_heard)
	assert_eq((cop.get_node("Hud/Hint") as Label).text, "HINT_BANK_FANS")
	(cop.get_node("Hud/Hint") as Label).text = ""
	fan.snitched.emit(fan, cop)
	assert_eq((cop.get_node("Hud/Hint") as Label).text, "", "only the first time")


func test_the_planilla_shows_the_fans_and_the_croissants() -> void:
	await _open(true)
	var texts: Array[String] = []
	for row in bank.case.rows():
		texts.append(row.text)
	assert_has(texts, "OBJ_BANK_FANS")
	bank.croissant_tray.use(cop)
	var croissants := false
	for row in bank.case.rows():
		if row.status and str(row.text).contains(str(BankCroissantTray.CROISSANTS - 1)):
			croissants = true
	assert_true(croissants, "the croissants left")


func test_taking_a_party_hostage_shows_how_they_behave() -> void:
	await _open(true)
	bank.hostages[0].use(cop)
	assert_eq(bank.hostages[0].led_by, cop)
	assert_eq((cop.get_node("Hud/Hint") as Label).text, "HINT_BANK_PARTY_LEAD")


func test_the_snapshot_carries_the_fans_and_the_tray() -> void:
	await _open(true)
	bank.case.fans_heard = true
	bank.croissant_tray.set_left(2)
	var state: Dictionary = bank.case.snapshot()
	bank.case.fans_heard = false
	bank.croissant_tray.set_left(BankCroissantTray.CROISSANTS)
	bank.case.apply_snapshot(state)
	assert_true(bank.case.fans_heard)
	assert_eq(bank.croissant_tray.left, 2)


func test_a_fed_hostage_shows_fed_on_a_guest() -> void:
	await _open(true)
	var hostage: BankHostage = bank.hostages[0]
	hostage.fed = true
	hostage._turn(1.0)
	var state := hostage.net_state()
	hostage.fed = false
	hostage._turn(0.0)
	hostage.apply_net_state(state)
	assert_true(hostage.fed)
	assert_almost_eq(hostage.head_look, 1.0, 0.01)
