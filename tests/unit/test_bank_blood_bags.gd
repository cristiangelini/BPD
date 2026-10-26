extends GutTest

## The blood bank's bags (robo-banco-sangre.md, step 3, decision 128): six in the fridge, cold; out of the cold they
## warm up and spoil, and back in the fridge or the patrol car's cooler they cool again. When the drill opens the
## fridge, the robbers run in for a bag each and out to the van; one cuffed on the way drops it.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "blood":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_six_bags_cold_in_the_fridge() -> void:
	assert_eq(bank.blood_bank.bags.size(), BankBlood.BAGS)
	await wait_physics_frames(10)
	for bag in bank.blood_bank.bags:
		assert_true(bag.cold(), bag.name + " is in the fridge")
		assert_eq(bag.warmth, 0.0)
	assert_eq(bank.blood_bank.bags_cold(), BankBlood.BAGS)


func test_out_of_the_cold_it_warms_and_spoils() -> void:
	var bag: BloodBag = bank.blood_bank.bags[0]
	bag.global_position = bank.to_global(Vector3(-5.0, 0.3, 3.0))
	await wait_physics_frames(10)
	assert_false(bag.cold(), "in the hall it's warm")
	assert_gt(bag.warmth, 0.0, "it warms up")
	watch_signals(bag)
	bag.warmth = 0.999
	await wait_physics_frames(10)
	assert_true(bag.spoiled, "and spoils")
	assert_signal_emitted(bag, "spoiled_now")
	assert_eq(bank.blood_bank.bags_spoiled(), 1)
	bag.global_position = bank.to_global(Vector3(11.25, 0.6, -7.0))
	await wait_physics_frames(10)
	assert_true(bag.spoiled, "spoiled for good")


func test_the_fridge_and_the_cooler_cool_it_again() -> void:
	var bag: BloodBag = bank.blood_bank.bags[0]
	bag.warmth = 0.5
	await wait_physics_frames(30)
	assert_lt(bag.warmth, 0.5, "in the fridge it cools down")
	assert_true(bank.blood_bank.is_cold(bank.car.global_transform * BankBlood.COOLER_AT), "the cooler is cold")
	assert_false(bank.blood_bank.is_cold(bank.car.global_transform * Vector3(0, 1.0, 1.0)), "the front seat isn't")
	assert_not_null(bank.car.get_node_or_null("Cooler"))


func test_the_robbers_run_in_for_a_bag_and_out_to_the_van() -> void:
	var pato: BankRobber
	for robber in bank.robbers:
		if robber.animal == "pato":
			pato = robber
	bank.drill.drilled = bank.drill.drill_time
	await wait_until(func() -> bool: return bank.blood_bank.bags.any(
		func(bag: BloodBag) -> bool: return bag.carried_by == pato), 15.0)
	var bag: BloodBag = bank.blood_bank.bags.filter(func(b: BloodBag) -> bool: return b.carried_by == pato)[0]
	assert_true(pato.running, "the duck runs off with a bag")
	assert_false(bag.cold(), "warming up in his hands")
	await wait_until(func() -> bool: return pato.in_van, 30.0)
	assert_true(pato.in_van)
	await wait_physics_frames(2)
	assert_false(bag.visible, "the bag went with him")
	assert_gte(bank.blood_bank.bags_taken, 1)
	assert_eq(bank.bags_taken, bank.blood_bank.bags_taken)


func test_cuffed_on_the_way_he_drops_it() -> void:
	var pato: BankRobber
	for robber in bank.robbers:
		if robber.animal == "pato":
			pato = robber
	bank.drill.drilled = bank.drill.drill_time
	await wait_until(func() -> bool: return bank.blood_bank.bags.any(
		func(bag: BloodBag) -> bool: return bag.carried_by == pato), 15.0)
	var bag: BloodBag = bank.blood_bank.bags.filter(func(b: BloodBag) -> bool: return b.carried_by == pato)[0]
	pato.surrendered = true
	pato.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(3)
	assert_null(bag.carried_by, "he dropped it")
	assert_false(bag.freeze, "it falls")
	assert_false(pato.running)


func test_el_conde_takes_a_bag_to_the_van_and_the_getaway_starts() -> void:
	bank.drill.drilled = bank.drill.drill_time
	await wait_until(func() -> bool: return bank.blood_bank.bags.any(
		func(bag: BloodBag) -> bool: return bag.carried_by == bank.boss), 20.0)
	assert_true(bank.blood_bank.bags.any(func(bag: BloodBag) -> bool: return bag.carried_by == bank.boss),
		"El Conde got to the fridge from behind the counter")
	await wait_until(func() -> bool: return bank.chase != null, 40.0)
	assert_not_null(bank.chase, "in the van, the getaway is on")
