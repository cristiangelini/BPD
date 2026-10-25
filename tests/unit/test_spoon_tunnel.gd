extends GutTest

## The spoon tunnel jailbreak, step 1 (fuga-tunel.md): the fourth way out, the guard awake with the key on his belt,
## two spoons in each cell and the hole by each bunk, dug a scoop at a time.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_tunel.json"

var level: JailbreakLevel
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "tunnel"
	level.case_seed = 6262
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	level.guard.set_physics_process(false)
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func test_the_tunnel_is_one_of_the_ways_out() -> void:
	assert_true(JailbreakLevel.VARIANTS.has("tunnel"))
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=tunnel"])), "tunnel")
	assert_true(level.is_tunnel())
	assert_is(level.guard, ListeningGuard)
	assert_true(level.guard.key_on_belt, "the key is on his belt")
	assert_null(level.box, "no donuts")


func test_two_spoons_and_a_hole_in_each_cell() -> void:
	assert_eq(level.spoons.size(), 4)
	assert_eq(level.holes.size(), 2)
	await wait_seconds(0.5)
	for spoon in level.spoons:
		assert_false(level.outside_cells(spoon.global_position), "%s in a cell" % spoon.name)
		assert_gt(spoon.global_position.y, lot.origin.y - 0.05, "and not through the floor")
	for hole in level.holes:
		assert_false(level.outside_cells(hole.global_position), "%s in a cell" % hole.name)
		assert_between(hole.needed, TunnelHole.NEEDED_MIN, TunnelHole.NEEDED_MAX)
	var local_0 := lot.affine_inverse() * level.holes[0].global_position
	var local_1 := lot.affine_inverse() * level.holes[1].global_position
	assert_lt(local_0.x, StationRooms.CELL_SPLIT_X, "the first in the first cell")
	assert_gt(local_1.x, StationRooms.CELL_SPLIT_X, "the second in the other")


func test_digging_needs_a_spoon() -> void:
	var hole := level.holes[0]
	assert_eq(hole.prompt_key(cop), "PROMPT_NEED_SPOON")
	hole.use(cop)
	assert_eq(hole.scoops, 0)
	cop.handed(level.spoons[0])
	await wait_physics_frames(2)
	assert_eq(hole.prompt_key(cop), "PROMPT_DIG_TUNNEL")
	watch_signals(hole)
	hole.use(cop)
	assert_eq(hole.scoops, 1)
	assert_signal_emitted(hole, "scooped")
	hole.use(cop)
	assert_eq(hole.scoops, 1, "one scoop at a time")


func test_enough_scoops_and_its_through() -> void:
	var hole := level.holes[1]
	watch_signals(hole)
	for i in hole.needed - 1:
		hole.scoop()
	assert_false(hole.is_through())
	hole.scoop()
	assert_true(hole.is_through())
	assert_signal_emitted(hole, "dug_through")
	hole.scoop()
	assert_eq(hole.scoops, hole.needed, "no more to dig")


func test_a_fill_takes_back_a_part() -> void:
	var hole := level.holes[0]
	for i in 40:
		hole.scoop()
	hole.fill(1.0 / 3.0)
	assert_eq(hole.scoops, 40 - int(ceil(hole.needed / 3.0)))


func test_same_seed_same_holes_and_guests_get_the_scoops() -> void:
	var other := TunnelHole.new()
	other.cell = 0
	add_child_autofree(other)
	other.setup(6262)
	assert_eq(other.needed, level.holes[0].needed)
	level.holes[0].scoop()
	level.holes[0].scoop()
	other.apply_net_state(level.holes[0].net_state())
	assert_eq(other.scoops, 2)
