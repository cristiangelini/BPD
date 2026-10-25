extends GutTest

## The cleaning crew's jailbreak, step 4 (fuga-limpieza.md): stains to mop, the wet floor, the comisario who likes a
## clean floor and his "¿Te conozco?".

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_manchas.json"

var level: JailbreakLevel
var cop: Cop
var comisario: EarlyComisario
var stains: FloorStains
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "cleaning"
	level.case_seed = 555
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	comisario = level.guard as EarlyComisario
	comisario.set_physics_process(false)
	level.cleaner.set_physics_process(false)
	stains = level.stains
	stains.set_physics_process(false)
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _scrub(index: int, seconds: float) -> void:
	for i in int(seconds / 0.1):
		stains.scrub_at(stains.spots[index] + Vector3.UP * 0.1, 0.1)


func test_the_seed_puts_8_to_12_stains_on_the_floor() -> void:
	assert_between(stains.spots.size(), FloorStains.COUNT_MIN, FloorStains.COUNT_MAX)
	for i in stains.spots.size():
		assert_false(stains.is_clean(i))
	var other := FloorStains.new()
	add_child_autofree(other)
	other.setup(555, lot)
	assert_eq(other.spots, stains.spots, "same seed, same stains")


func test_scrubbing_cleans_a_stain_and_leaves_the_floor_wet() -> void:
	watch_signals(stains)
	_scrub(0, FloorStains.SCRUB / 2)
	assert_false(stains.is_clean(0), "not yet")
	_scrub(0, FloorStains.SCRUB / 2 + 0.2)
	assert_true(stains.is_clean(0))
	assert_signal_emitted(stains, "cleaned")
	assert_true(stains.wet_at(stains.spots[0]), "wet now")
	assert_eq(stains.scrub_at(stains.spots[0] + Vector3.UP * 0.1, 0.1), -1, "nothing left to scrub there")


func test_a_mop_held_high_doesnt_scrub() -> void:
	assert_eq(stains.scrub_at(stains.spots[0] + Vector3.UP * 1.0, 0.1), -1)


func test_the_wet_floor_dries() -> void:
	_scrub(0, FloorStains.SCRUB + 0.2)
	stains.set_physics_process(true)
	await wait_seconds(0.2)
	stains.wet[0] = 0.05
	await wait_seconds(0.2)
	assert_false(stains.wet_at(stains.spots[0]), "dry")


func test_a_stain_cleaned_in_front_of_him_calms_him_down() -> void:
	comisario.global_transform = Transform3D(lot.basis * Basis(Vector3.UP, 0.0), lot * Vector3(0, 0, 2.2))
	comisario.look = 0.0
	comisario.suspicion = 50.0
	comisario.saw_cleaning(lot * Vector3(0, 0, 5.0))
	assert_almost_eq(comisario.suspicion, 50.0 - EarlyComisario.SHINE, 0.01)
	assert_true(comisario.said().begins_with("EARLY_SHINE"))
	comisario.saw_cleaning(lot * Vector3(0, 0, -3.0))
	assert_almost_eq(comisario.suspicion, 50.0 - EarlyComisario.SHINE, 0.01, "not behind his back")


func _crew_in_front_of_him() -> void:
	comisario.global_transform = Transform3D(lot.basis * Basis(Vector3.UP, 0.0), lot * Vector3(0, 0, 2.2))
	comisario.look = 0.0
	cop.put_on_disguise("cleaner_cap", 0.0)
	cop.put_on_disguise("cleaner_vest", 0.0)
	cop.global_position = lot * Vector3(0, 0.1, 3.8)
	await wait_physics_frames(2)


func test_te_conozco_and_not_working_raises_it_at_once() -> void:
	await _crew_in_front_of_him()
	comisario._squint(0.1)
	assert_eq(comisario.squinting, cop, "he stops to look")
	assert_true(comisario.said().begins_with("EARLY_SQUINT"))
	var before := comisario.suspicion
	for i in int(EarlyComisario.SQUINT / 0.1) + 1:
		comisario._squint(0.1)
	assert_null(comisario.squinting)
	assert_almost_eq(comisario.suspicion, before + EarlyComisario.KNOWN, 0.01)
	comisario._squint(0.1)
	assert_null(comisario.squinting, "not the same cop again right away")


func test_te_conozco_working_lets_it_go() -> void:
	await _crew_in_front_of_him()
	var tool: CleaningTool = level.tools[0]
	cop.handed(tool)
	await wait_physics_frames(2)
	comisario._squint(0.1)
	for i in int(EarlyComisario.SQUINT / 0.1) + 1:
		tool._working_left = CleaningTool.WORKING_MEMORY
		comisario._squint(0.1)
	assert_eq(comisario.suspicion, 0.0)
	assert_true(comisario.said().begins_with("EARLY_SQUINT_OK"))


func test_a_plain_cop_doesnt_get_squinted_at() -> void:
	comisario.global_transform = Transform3D(lot.basis * Basis(Vector3.UP, 0.0), lot * Vector3(0, 0, 2.2))
	cop.global_position = lot * Vector3(0, 0.1, 3.8)
	await wait_physics_frames(2)
	comisario._squint(0.1)
	assert_null(comisario.squinting, "a plain cop is just caught")


func test_guests_see_the_same_stains() -> void:
	_scrub(1, FloorStains.SCRUB + 0.2)
	var state: Variant = stains.net_state()
	var other := FloorStains.new()
	add_child_autofree(other)
	other.setup(555, lot)
	other.apply_net_state(state)
	assert_true(other.is_clean(1))
	assert_true(other.wet_at(other.spots[1]))
