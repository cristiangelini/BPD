extends GutTest

## The roof robbery (robo-banco-techo.md, step 4a, decision 126): when the vault opens the gang goes up the hatch with
## the sacks, and the toy helicopter takes them to the nephew's cart one trip at a time; the case pays 100 for the
## nephew.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "roof":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _open_the_vault() -> void:
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)


## The trip at twenty times its speed.
func _hurry() -> void:
	bank.helicopter._path_speed *= 20.0


func test_up_the_roof_with_the_sacks() -> void:
	await _open_the_vault()
	assert_true(bank.roof_getaway)
	assert_eq(bank.roof_bags, bank.robbers.size(), "every loose robber took a sack up")
	assert_eq(bank.bags_taken, 0, "none in the cart yet")
	assert_null(bank.chase, "El Oso waits on the roof")
	assert_true(bank.helicopter.busy(), "the first trip is on")


func test_one_sack_per_trip_into_the_cart() -> void:
	await _open_the_vault()
	var sacks := bank.roof_bags
	_hurry()
	await wait_until(func() -> bool: return bank.bags_taken == 1, 5.0)
	assert_eq(bank.roof_bags, sacks - 1)
	assert_eq(bank.cart.get_child_count(), 1, "the sack shows in the cart")
	await wait_until(func() -> bool: return not bank.helicopter.busy() or bank.bags_taken == 2, 5.0)
	_hurry()
	await wait_until(func() -> bool: return bank.bags_taken == 2, 5.0)
	assert_eq(bank.bags_taken, 2, "back on the pad, off on the next trip")


func test_a_trip_takes_twenty_seconds() -> void:
	bank.helicopter.trip(BankLevel.CART_AT + Vector3.UP * BankLevel.CART_TOP)
	var length := 0.0
	var from := bank.helicopter.position
	for point in bank.helicopter._path:
		length += from.distance_to(point)
		from = point
	assert_almost_eq(length / bank.helicopter._path_speed, ToyHelicopter.TRIP_TIME, 0.01)


func test_after_the_sacks_el_oso_runs() -> void:
	await _open_the_vault()
	bank.roof_bags = 1
	_hurry()
	await wait_until(func() -> bool: return bank.chase != null, 8.0)
	assert_not_null(bank.chase, "the getaway is on")


func test_the_nephew_cuffed_midway_stops_it() -> void:
	await _open_the_vault()
	bank.nephew.cuffed(Handcuffs.SECONDS)
	assert_true(bank.helicopter.crashed)
	assert_eq(bank.roof_bags, 0, "the sacks stay on the roof")
	assert_eq(bank.bags_taken, 0)
	assert_not_null(bank.chase, "El Oso runs for the van")


func test_without_the_helicopter_the_base_getaway() -> void:
	bank.helicopter.global_position = bank.to_global(Vector3(BankLevel.HALF_X + 4.0, 0.1, 0))
	await wait_physics_frames(2)
	await _open_the_vault()
	assert_false(bank.roof_getaway)
	assert_eq(bank.bags_taken, bank.robbers.size())
	assert_not_null(bank.chase)


func test_the_case_pays_for_the_nephew() -> void:
	assert_eq(bank.case.brief()[0], "BRIEF_BANK_ROOF_A")
	var texts: Array = bank.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_BANK_NEPHEW")
	bank.case.boss_jailed = true
	bank.hostages_freed = bank.hostages.size()
	var before: int = bank.case.report().salary
	bank.nephew.cuffed(Handcuffs.SECONDS)
	assert_eq(bank.case.report().salary, before + BankCase.NEPHEW)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_BANK_ROOF_A", "BRIEF_BANK_ROOF_C", "HINT_ROOF_GETAWAY", "OBJ_BANK_NEPHEW", "OBJ_BANK_CART"]:
		assert_ne(tr(key), key, key)
