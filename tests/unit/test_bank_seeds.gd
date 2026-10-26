extends GutTest

## The seed bank (robo-banco-semillas.md, step 1, decision 129): a tenth of the seeds, pots in the hall, glass jars of
## seeds in the vault instead of money, hostages holding small pots and the gang in straw hats and green aprons.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func _bank(want := "seeds") -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_a_tenth_of_the_seeds_and_the_arg_forces_it() -> void:
	var drawn := 0
	for seed_ in range(1, 1001):
		if BankLevel.variant(seed_, PackedStringArray()) == "seeds":
			drawn += 1
	assert_between(drawn, 65, 135)
	for seed_ in range(1, 20):
		assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=seeds"])), "seeds")
	for seed_ in [1, 2, 3, 4]:
		assert_ne(BankLevel.variant(seed_, PackedStringArray()), "seeds", "the old test seeds stay the same")


func test_the_sign_the_pots_and_the_leaf() -> void:
	await _bank()
	assert_true(bank.seeds)
	assert_not_null(bank.seed_bank)
	var texts: Array[String] = []
	for label in bank.find_children("*", "Label3D", true, false):
		texts.append((label as Label3D).text)
	assert_has(texts, "PLACE_BANK_SEEDS")
	assert_eq(bank.seed_bank.pots.size(), BankSeeds.POTS.size(), "pots in the hall")
	assert_not_null(bank.seed_bank.get_node_or_null("Leaf"), "a green leaf over the vault")


func test_the_vault_holds_seed_jars_waiting_on_their_shelves() -> void:
	await _bank()
	assert_eq(bank.seed_bank.jars.size(), BankSeeds.JARS)
	var start: Array[Vector3] = []
	for jar in bank.seed_bank.jars:
		assert_true(jar.freeze, "waiting still on its shelf")
		start.append(jar.global_position)
		var inside := bank.to_local(jar.global_position)
		assert_true(BankBlood.FRIDGE.has_point(Vector2(inside.x, inside.z)), "inside the vault")
	await wait_physics_frames(30)
	for i in bank.seed_bank.jars.size():
		assert_almost_eq(bank.seed_bank.jars[i].global_position, start[i], Vector3.ONE * 0.01, "it doesn't fall")
	var colors := {}
	for jar in bank.seed_bank.jars:
		colors[jar.color] = true
	assert_eq(colors.size(), BankSeeds.JARS, "each jar its own seeds")


func test_the_gang_are_gardeners_and_the_hostages_hold_pots() -> void:
	await _bank()
	assert_eq(bank.robbers.size(), 4, "the whole gang")
	for robber in bank.robbers:
		assert_true(robber.gardener)
		assert_not_null(robber.find_child("StrawHat", true, false), robber.animal + " has a straw hat")
		assert_not_null(robber.find_child("Apron", true, false), "and an apron")
		assert_eq(robber.find_child("WateringCan", true, false) != null, robber.animal == "oso",
			"only El Oso carries the watering can")
	assert_false(bank.hostages.is_empty())
	for hostage in bank.hostages:
		assert_not_null(hostage.get_node_or_null("HostagePot"))


func test_the_others_have_no_seeds() -> void:
	await _bank("base")
	assert_false(bank.seeds)
	assert_null(bank.seed_bank)
	assert_eq(get_tree().get_nodes_in_group("seed_jars").size(), 0)
	for robber in bank.robbers:
		assert_null(robber.find_child("StrawHat", true, false))
