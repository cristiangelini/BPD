extends GutTest

## The blood bank (robo-banco-sangre.md, step 1, decision 128): a ninth of the seeds, the power cut at night with the
## ceiling lamps off and candles burning, the vault a white fridge full of blood bags, the hostages with a band-aid
## and the gang in vampire capes and fangs.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func _bank(want := "blood") -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_a_ninth_of_the_seeds_and_the_arg_forces_it() -> void:
	var bloods := 0
	for seed_ in range(1, 901):
		if BankLevel.variant(seed_, PackedStringArray()) == "blood":
			bloods += 1
	assert_between(bloods, 65, 135)
	for seed_ in range(1, 20):
		assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=blood"])), "blood")
	for seed_ in [1, 2, 3, 4]:
		assert_ne(BankLevel.variant(seed_, PackedStringArray()), "blood", "the old test seeds stay the same")


func test_the_power_is_cut_and_candles_burn() -> void:
	await _bank()
	assert_true(bank.blood)
	assert_not_null(bank.blood_bank)
	assert_false(bank.lamps.is_empty())
	for lamp in bank.lamps:
		assert_false(lamp.visible, "the ceiling lamps are off")
	assert_eq(bank.blood_bank.candles.size(), BankBlood.CANDLES.size(), "the candles are lit")
	var sun: DirectionalLight3D = bank.get_node("Sun")
	assert_lt(sun.light_energy, 0.2, "it's night")
	var env: Environment = (bank.get_node("Environment") as WorldEnvironment).environment
	assert_almost_eq(env.ambient_light_energy, BankBlood.NIGHT_AMBIENT, 0.01)


func test_the_sign_and_the_fridge() -> void:
	await _bank()
	var texts: Array[String] = []
	for label in bank.find_children("*", "Label3D", true, false):
		texts.append((label as Label3D).text)
	assert_has(texts, "PLACE_BANK_BLOOD")
	assert_has(texts, "BANK_FRIDGE", "the vault is a fridge")
	assert_does_not_have(texts, "BANK_VAULT")
	assert_not_null(bank.blood_bank.get_node_or_null("Drop"), "with its red drop")


func test_the_gang_are_vampires_and_the_hostages_gave_blood() -> void:
	await _bank()
	assert_eq(bank.robbers.size(), 4, "the whole gang")
	for robber in bank.robbers:
		assert_true(robber.vampire)
		assert_not_null(robber.find_child("Cape", true, false), robber.animal + " has a cape")
		assert_eq(robber.find_children("Fang*", "", true, false).size(), 2, "and two fangs")
	assert_false(bank.hostages.is_empty())
	for hostage in bank.hostages:
		assert_not_null(hostage.get_node_or_null("BandAid"))


func test_the_others_are_lit_and_not_vampires() -> void:
	await _bank("base")
	assert_false(bank.blood)
	assert_null(bank.blood_bank)
	for lamp in bank.lamps:
		assert_true(lamp.visible)
	for robber in bank.robbers:
		assert_null(robber.find_child("Cape", true, false))
