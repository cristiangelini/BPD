extends GutTest

## The vent jailbreak, step 1 (fuga-ventilacion.md): the fifth way out, the guard awake with no key, a loose grille high
## on each cell's wall, loosened screw by screw from the bunk, and the cop who doesn't fit drawn by the seed.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_ventilacion.json"

var level: JailbreakLevel
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "vent"
	level.case_seed = 7171
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


func test_the_vent_is_one_of_the_ways_out() -> void:
	assert_true(JailbreakLevel.VARIANTS.has("vent"))
	assert_eq(JailbreakLevel.VARIANTS.size(), 5, "in fifths")
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=vent"])), "vent")
	assert_true(level.is_vent())
	assert_is(level.guard, VentGuard)
	assert_false(level.guard.key_on_belt, "no key on him")
	assert_null(level.box, "no donuts")


func test_a_grille_high_on_each_cells_wall() -> void:
	assert_eq(level.grilles.size(), 2)
	for grille in level.grilles:
		assert_false(level.outside_cells(grille.global_position + Vector3(0, 0, 0.3)), "%s faces into a cell" % grille.name)
		assert_almost_eq(grille.global_position.y - lot.origin.y, VentGrille.HEIGHT, 0.01)
	var local_0 := lot.affine_inverse() * level.grilles[0].global_position
	var local_1 := lot.affine_inverse() * level.grilles[1].global_position
	assert_lt(local_0.x, StationRooms.CELL_SPLIT_X)
	assert_gt(local_1.x, StationRooms.CELL_SPLIT_X)


func test_from_the_floor_its_too_high() -> void:
	var grille := level.grilles[0]
	cop.global_position = lot * Vector3(8.3, 0.05, 2.4)
	await wait_physics_frames(1)
	assert_eq(grille.prompt_key(cop), "PROMPT_VENT_TOO_HIGH")
	grille.use(cop)
	assert_eq(grille.turns, 0)
	cop.global_position = lot * Vector3(8.3, 0.55, 1.6)
	assert_eq(grille.prompt_key(cop), "PROMPT_VENT_SCREW", "on the bunk")
	grille.use(cop)
	assert_eq(grille.turns, 1)
	grille.use(cop)
	assert_eq(grille.turns, 1, "one turn at a time")


func test_screw_by_screw_until_it_drops() -> void:
	var grille := level.grilles[1]
	watch_signals(grille)
	for i in VentGrille.TURNS * VentGrille.SCREWS - 1:
		grille.turn()
	assert_eq(grille.screws_left, 1)
	assert_false(grille.is_open())
	grille.turn()
	assert_true(grille.is_open())
	assert_signal_emitted(grille, "opened")
	assert_eq(grille.prompt_key(cop), "")


func test_guests_get_the_screws() -> void:
	var grille := level.grilles[0]
	for i in VentGrille.TURNS + 1:
		grille.turn()
	var other := VentGrille.new()
	add_child_autofree(other)
	other.apply_net_state(grille.net_state())
	assert_eq(other.screws_left, VentGrille.SCREWS - 1)
	assert_eq(other.turns, 1)


func test_the_big_one_is_drawn_and_nobody_when_alone() -> void:
	assert_null(level.big_cop(), "alone, everyone fits")
	var friend: Cop = load("res://scenes/player/cop.tscn").instantiate()
	friend.uniform = 1
	friend.input_enabled = false
	level.add_child(friend)
	await wait_physics_frames(1)
	var big := level.big_cop()
	assert_not_null(big)
	assert_eq(big, level.big_cop(), "always the same one")
	friend.queue_free()
