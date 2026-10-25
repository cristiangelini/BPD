extends GutTest

## The cleaning crew's jailbreak, step 2 (fuga-limpieza.md): Clotilde opens each cell to mop it and locks it again,
## with the key ring on her cart, and can't do either without it.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_limpiadora.json"

var level: JailbreakLevel
var cleaner: Cleaner


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "cleaning"
	level.case_seed = 31337
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cleaner = level.cleaner
	# The tests run her round and keep the comisario out of it.
	cleaner.set_physics_process(false)
	level.guard.set_physics_process(false)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


## Runs her round until she's doing `kind` (or gives up after `seconds`).
func _until(kind: String, seconds := 200.0) -> void:
	for i in int(seconds / 0.1):
		if cleaner.doing() == kind:
			return
		cleaner.run(0.1)


func test_only_the_cleaning_jailbreak_has_her() -> void:
	assert_not_null(cleaner)
	assert_not_null(level.get_node_or_null("CleaningCart"))
	assert_true(cleaner.keys_on_cart(), "the key ring starts on her cart")
	assert_false(level.cart_key.is_in_group("guard_clues"), "the comisario doesn't mind the keys on the cart")


func test_she_opens_a_cell_while_she_mops_it_and_locks_it_after() -> void:
	_until("mop")
	var cell := cleaner.mopping_cell()
	assert_eq(cell, cleaner.first_cell, "the seed's cell first")
	var door: CellDoor = level.city.cell_doors[cell]
	assert_false(door.locked)
	assert_true(door.is_open, "open while she mops")
	assert_true(level.city.cell_doors[1 - cell].locked, "the other one stays locked")
	_until("lock")
	cleaner.run(0.1)
	assert_true(door.locked, "locked again")
	_until("mop")
	assert_eq(cleaner.mopping_cell(), 1 - cell, "then the other cell")


func test_without_the_keys_she_cant_lock_the_cell() -> void:
	_until("mop")
	var door: CellDoor = level.city.cell_doors[cleaner.mopping_cell()]
	level.cart_key.global_position += Vector3(0, 0, 3)
	await wait_physics_frames(2)
	assert_false(cleaner.keys_on_cart())
	_until("keys", 60.0)
	for i in 100:
		cleaner.run(0.1)
	assert_eq(cleaner.doing(), "keys", "she waits for her keys")
	assert_true(cleaner.said().begins_with("CLEANER_NO_KEYS"), "and asks for them")
	assert_false(door.locked, "the cell stays open")


func test_a_catch_sends_her_back_to_the_cart_with_the_keys() -> void:
	_until("mop")
	level.cart_key.global_position += Vector3(0, 0, 3)
	level.guard.catch()
	await wait_physics_frames(2)
	assert_eq(cleaner.step, 0, "a new round")
	assert_eq(cleaner.doing(), "rest")
	assert_true(cleaner.keys_on_cart(), "the keys back on the cart")
	for door in level.city.cell_doors:
		assert_true(door.locked)


func test_guests_follow_her_doors() -> void:
	_until("mop")
	var state: Array = cleaner.net_state()
	for door in level.city.cell_doors:
		door.lock()
	cleaner.apply_net_state(state)
	var cell := cleaner.mopping_cell()
	assert_false(level.city.cell_doors[cell].locked)
	assert_true(level.city.cell_doors[cell].is_open)
