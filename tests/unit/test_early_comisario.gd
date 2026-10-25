extends GutTest

## The cleaning crew's jailbreak, step 1 (fuga-limpieza.md): drawn half the time, at dawn, with no guard at the desk
## and the comisario walking his round, catching them like the guard.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_limpieza.json"

var level: JailbreakLevel
var cop: Cop
var comisario: EarlyComisario
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "cleaning"
	level.case_seed = 4242
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	comisario = level.guard as EarlyComisario
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func test_the_variant_is_drawn_by_the_seed_and_forced_by_the_arg() -> void:
	assert_eq(JailbreakLevel.pick_variant(0, PackedStringArray()), "donut", "without a seed from Play, the donut")
	var seen := {}
	for drawn in range(1, 60):
		var picked := JailbreakLevel.pick_variant(drawn, PackedStringArray(), BribeGuard.PRICE_MIN)
		assert_eq(picked, JailbreakLevel.pick_variant(drawn, PackedStringArray(), BribeGuard.PRICE_MIN), "same seed, same way out")
		seen[picked] = true
	assert_eq(seen.size(), JailbreakLevel.VARIANTS.size(), "all come up (the bribe too, with the money)")
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=cleaning"])), "cleaning")
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=donut"])), "donut")


func test_no_guard_desk_no_donuts_and_the_comisario_instead() -> void:
	assert_not_null(comisario, "the early comisario watches")
	assert_null(level.get_node_or_null("NightGuard"))
	assert_null(level.box, "no box of donuts")
	assert_true(level.sticks.is_empty(), "nothing to fish with")
	for door in level.city.cell_doors:
		assert_true(door.locked, "the cells are locked")


func test_he_walks_his_round_and_stops() -> void:
	var stops := {}
	for i in 2000:
		comisario._walk(0.1)
		if not comisario.is_walking():
			stops[comisario.target] = true
	for i in EarlyComisario.ROUND.size():
		if EarlyComisario.ROUND[i][2] != "":
			assert_true(stops.has(i), "he stops at %s" % EarlyComisario.ROUND[i][2])
		else:
			assert_false(stops.has(i), "and walks past the doors")


func test_he_says_something_at_each_stop() -> void:
	comisario.wait_left = 0.0
	for i in 400:
		comisario._walk(0.1)
		if not comisario.is_walking():
			break
	assert_false(comisario.is_walking())
	assert_true(comisario.said().begins_with("EARLY_"), "he says something where he stops")


func test_a_cop_out_of_the_cells_gets_caught_and_put_back() -> void:
	comisario.set_physics_process(false)
	# He's at the cells room's door, looking in.
	comisario.target = 4
	comisario.global_transform = Transform3D(lot.basis * Basis(Vector3.UP, PI / 2), lot * EarlyComisario.ROUND[4][0])
	comisario.look = 0.0
	cop.global_position = lot * Vector3(9.0, 0.1, 6.4)
	await wait_physics_frames(2)
	for i in 30:
		comisario._watch(0.1)
	assert_eq(comisario.times_caught, 1)
	await wait_physics_frames(2)
	assert_false(level.outside_cells(cop.global_position), "back in a cell")
	assert_eq(cop._hint.text, "HINT_COMISARIO_CAUGHT")


func test_singing_doesnt_put_him_to_sleep() -> void:
	for i in 60:
		comisario.heard_singing(cop)
		comisario._hear_lullaby(0.1)
	assert_false(comisario.is_asleep())


func test_the_third_catch_loses_without_the_pajamas() -> void:
	comisario.set_physics_process(false)
	for i in JailbreakLevel.CATCHES:
		comisario.catch()
	assert_eq(comisario.said(), "EARLY_SUSPENDED", "he suspends them himself")
	await wait_seconds(JailbreakLevel.LOST_DELAY + 0.3)
	assert_eq(comisario.outcome, "lost")
	assert_null(level.get_node_or_null("PajamaComisario"), "nobody calls him in his pajamas")
