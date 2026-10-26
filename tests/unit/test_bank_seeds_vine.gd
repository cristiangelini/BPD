extends GutTest

## The seed bank's vines (robo-banco-semillas.md, step 2, decision 129): a gardener who sees a cop throws seeds and a
## vine wall grows between them, stopping cops but not the gang, drying up after a while; pruning shears cut it.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
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


func _vines() -> Array[Node]:
	return get_tree().get_nodes_in_group("bank_vines")


func test_two_pruning_shears_wait_on_the_counter() -> void:
	assert_eq(bank.seed_bank.shears.size(), 2)
	for pair in bank.seed_bank.shears:
		assert_true(pair.freeze, "still on the counter")
		assert_gt(bank.to_local(pair.global_position).y, 1.0, "up on the counter")


func test_a_gardener_who_sees_a_cop_throws_seeds_and_a_vine_grows_between_them() -> void:
	var robber := bank.robbers[0]
	cop.global_position = robber.global_position + Vector3(4.0, 0.0, 0.0)
	robber.spotted.emit(robber, cop)
	assert_eq(_vines().size(), 1, "a vine")
	var vine: BankVine = _vines()[0]
	var between := robber.global_position.distance_to(vine.global_position)
	assert_almost_eq(between, 2.0, 0.05, "halfway to the cop")
	assert_false(vine.is_grown(), "it grows")
	await wait_seconds(BankVine.GROW_TIME + 0.3)
	assert_true(vine.is_grown(), "full in a few seconds")
	assert_ne(vine.collision_layer & cop.collision_mask, 0, "it stops the cops")
	assert_eq(vine.collision_layer & robber.collision_mask, 0, "but the gang go through it")
	robber.spotted.emit(robber, cop)
	assert_eq(_vines().size(), 1, "not again so soon")


func test_it_dries_up_by_itself() -> void:
	var vine := bank.seed_bank.grow_vine(bank.to_global(Vector3(0, 0, 4)), Vector3.FORWARD)
	vine.grown = 1.0
	vine.life_left = 0.1
	await wait_seconds(0.3)
	assert_true(vine.drying)
	assert_eq(vine.collision_layer, 0, "nothing stops anyone there")
	await wait_seconds(BankVine.DRY_TIME + 0.3)
	assert_false(is_instance_valid(vine), "gone")


func test_only_shears_cut_it_snip_by_snip() -> void:
	var vine := bank.seed_bank.grow_vine(bank.to_global(Vector3(0, 0, 4)), Vector3.FORWARD)
	vine.use(cop)
	assert_eq(vine.snips_left, BankVine.SNIPS, "bare hands do nothing")
	assert_eq(vine.prompt_key(cop), "PROMPT_VINE")
	var pair: PruningShears = bank.seed_bank.shears[0]
	cop.global_position = pair.global_position + Vector3(0, 0, 1.0)
	cop.get_node("Grabber").grab(pair)
	assert_eq(vine.prompt_key(cop), "PROMPT_CUT_VINE")
	for i in BankVine.SNIPS - 1:
		vine.use(cop)
	assert_false(vine.drying, "not yet")
	vine.use(cop)
	assert_true(vine.drying, "cut")
	assert_eq(vine.collision_layer, 0)

