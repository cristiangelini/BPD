extends GutTest

## The seed bank's jars (robo-banco-semillas.md, step 3, decision 129): glass, so one that hits something fast breaks
## and a big plant grows there, and a cop running with one lets go of it; set down gently, it doesn't. When the drill
## opens the vault, the robbers run in for a jar each and out to the van; one cuffed on the way sets it down.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "seeds":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _pato() -> BankRobber:
	for robber in bank.robbers:
		if robber.animal == "pato":
			return robber
	return null


func test_all_eight_home_in_the_vault() -> void:
	await wait_physics_frames(10)
	assert_eq(bank.seed_bank.jars_home(), BankSeeds.JARS)
	assert_eq(bank.seed_bank.jars_broken(), 0)


func test_a_jar_hitting_the_floor_fast_breaks_and_a_plant_grows_there() -> void:
	var jar: SeedJar = bank.seed_bank.jars[0]
	watch_signals(jar)
	jar.freeze = false
	jar.global_position = bank.to_global(Vector3(-5.0, 1.5, 4.0))
	jar.linear_velocity = Vector3(0, -9.0, 0)
	await wait_until(func() -> bool: return jar.broken, 3.0)
	assert_true(jar.broken, "it broke")
	assert_signal_emitted(jar, "broke")
	assert_false(jar.visible)
	assert_eq(bank.seed_bank.jars_broken(), 1)
	assert_eq(bank.seed_bank.plants.size(), 1, "a plant grows")
	var plant := bank.seed_bank.plants[0]
	var flat := bank.to_local(plant.global_position)
	assert_almost_eq(Vector2(flat.x, flat.z), Vector2(-5.0, 4.0), Vector2.ONE * 0.6, "where it broke")
	assert_ne(plant.collision_layer & bank.get_node("Cop").collision_mask, 0, "in the cops' way")
	await wait_seconds(BankSeeds.PLANT_GROW + 0.2)
	assert_almost_eq(plant.get_node("Look").scale, Vector3.ONE, Vector3.ONE * 0.01, "grown")


func test_set_down_gently_it_doesnt_break() -> void:
	var jar: SeedJar = bank.seed_bank.jars[0]
	jar.freeze = false
	jar.global_position = bank.to_global(Vector3(-5.0, 0.6, 4.0))
	await wait_seconds(1.0)
	assert_false(jar.broken, "a short drop is fine")
	assert_eq(bank.seed_bank.plants.size(), 0)


func test_a_cop_running_with_it_lets_go() -> void:
	var cop: Cop = bank.get_node("Cop")
	var jar: SeedJar = bank.seed_bank.jars[0]
	cop.global_position = jar.global_position + Vector3(-1.0, 0, 0)
	cop.get_node("Grabber").grab(jar)
	assert_false(jar.holders.is_empty(), "in hand")
	cop.is_running = true
	await wait_seconds(SeedJar.TRIP_TIME + 0.3)
	assert_true(jar.holders.is_empty(), "it slipped out of his hand")


func test_the_robbers_run_in_for_a_jar_and_out_to_the_van() -> void:
	var pato := _pato()
	bank.drill.drilled = bank.drill.drill_time
	await wait_until(func() -> bool: return bank.seed_bank.jars.any(
		func(jar: SeedJar) -> bool: return jar.carried_by == pato), 15.0)
	var jar: SeedJar = bank.seed_bank.jars.filter(func(j: SeedJar) -> bool: return j.carried_by == pato)[0]
	assert_true(pato.running, "the duck runs off with a jar")
	await wait_until(func() -> bool: return pato.in_van, 30.0)
	assert_true(pato.in_van)
	await wait_physics_frames(2)
	assert_false(jar.visible, "the jar went with him")
	assert_false(jar.broken)
	assert_gte(bank.seed_bank.jars_taken, 1)
	assert_eq(bank.bags_taken, bank.seed_bank.jars_taken)


func test_cuffed_on_the_way_he_sets_it_down_unbroken() -> void:
	var pato := _pato()
	bank.drill.drilled = bank.drill.drill_time
	await wait_until(func() -> bool: return bank.seed_bank.jars.any(
		func(jar: SeedJar) -> bool: return jar.carried_by == pato), 15.0)
	var jar: SeedJar = bank.seed_bank.jars.filter(func(j: SeedJar) -> bool: return j.carried_by == pato)[0]
	pato.surrendered = true
	pato.cuffed(Handcuffs.SECONDS)
	await wait_seconds(1.0)
	assert_null(jar.carried_by, "he set it down")
	assert_false(jar.broken, "gently")
	assert_false(pato.running)
