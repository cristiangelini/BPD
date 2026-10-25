extends GutTest

## The bank's robbers and hostages (robo-banco.md, step 2, decision 102): four robbers with animal masks at their
## tasks, each with their own cone, El Oso as the boss, the pig not looking while he eats, and the hostages on the
## hall's floor, a different set of neighbors for each seed.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func before_each() -> void:
	bank = LEVEL.instantiate()
	# A base robbery's seed: the party (robo-banco-rehenes.md) has its own tests.
	bank.case_seed = 4
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _robber(animal: String) -> BankRobber:
	for robber in bank.robbers:
		if robber.animal == animal:
			return robber
	return null


## Puts the cop `meters` in front of `robber`'s face, straight ahead.
func _in_front(robber: BankRobber, meters: float) -> void:
	robber.look = 0.0
	cop.global_position = robber.global_position + robber.facing() * meters + Vector3.UP * 0.1
	await wait_physics_frames(2)


func test_four_robbers_and_el_oso_is_the_boss() -> void:
	assert_eq(bank.robbers.size(), 4)
	assert_eq(bank.boss, _robber("oso"))
	assert_true(bank.boss.is_boss())
	for robber in bank.robbers:
		assert_true(bank.inside(robber.global_position), robber.animal + " inside")


func test_the_rabbit_watches_the_door_and_the_duck_the_vault() -> void:
	var door := bank.global_transform * Vector3(BankLevel.ENTRANCE_X, 1, BankLevel.HALF_Z)
	var rabbit := _robber("conejo")
	assert_gt(rabbit.facing().dot((door - rabbit.global_position).normalized()), 0.5)
	var duck := _robber("pato")
	# On the floor's plane: the door's middle is a meter up, the duck's feet on the floor.
	var to_vault := bank.vault_door.global_position - duck.global_position
	to_vault.y = 0.0
	assert_gt(duck.facing().dot(to_vault.normalized()), 0.9)


func test_a_robber_sees_a_cop_in_front_and_says_so() -> void:
	var rabbit := _robber("conejo")
	watch_signals(rabbit)
	await _in_front(rabbit, 1.2)
	assert_true(rabbit.sees_cop(cop))
	rabbit._physics_process(0.0)
	assert_signal_emitted(rabbit, "spotted")
	assert_eq(rabbit.said(), "ROBBER_CONEJO_SPOT")


func test_nobody_sees_behind_their_back() -> void:
	var duck := _robber("pato")
	await _in_front(duck, -2.0)
	assert_false(duck.sees_cop(cop))


func test_the_duck_sees_less_far_than_el_oso() -> void:
	assert_lt(BankRobber.SIGHT["pato"].y, BankRobber.SIGHT["oso"].y)
	# Out in the open hall, looking west across it.
	var duck := _robber("pato")
	duck.position = Vector3(4.0, BankLevel.FLOOR_TOP, 4.0)
	duck.rotation.y = PI / 2
	await _in_front(duck, BankRobber.SIGHT["pato"].y + 1.0)
	assert_false(duck.sees_cop(cop), "too far for the duck")


func test_the_pig_sees_nothing_while_he_eats() -> void:
	var pig := _robber("chancho")
	await _in_front(pig, 1.0)
	assert_true(pig.sees_cop(cop))
	pig._eat(BankRobber.EAT_EVERY)
	assert_true(pig.is_eating())
	assert_eq(pig.said(), "ROBBER_CHANCHO_EAT")
	assert_false(pig.sees_cop(cop))


func test_the_hostages_are_on_their_floor() -> void:
	assert_eq(bank.hostages.size(), BankLevel.HOSTAGES)
	for hostage in bank.hostages:
		assert_true(bank.in_hostage_area(hostage.global_position))
		assert_true(BankHostage.LOOKS.has(hostage.look))


func test_a_hostage_and_a_robber_have_lines() -> void:
	bank.hostages[0].use(cop)
	assert_true(bank.hostages[0].said().begins_with("HOSTAGE_"))
	bank.boss.use(cop)
	assert_true(bank.boss.said().begins_with("ROBBER_OSO_"))


func test_another_seed_brings_other_hostages() -> void:
	var other: BankLevel = LEVEL.instantiate()
	other.case_seed = 99
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	var a := bank.hostages.map(func(h: BankHostage) -> String: return h.look)
	var b := other.hostages.map(func(h: BankHostage) -> String: return h.look)
	assert_ne(a, b)
