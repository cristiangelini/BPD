extends GutTest

## The vent jailbreak, step 2 (fuga-ventilacion.md): up the open grille into the duct, crawling, the big one stuck,
## the dead ends and the way down into the office, and the guard hearing whoever scrambles over his head.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TEST_PATH := "user://test_partidas/fuga_ventilacion_ducto.json"

var level: JailbreakLevel
var cop: Cop
var guard: VentGuard
var grille: VentGrille
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
	guard = level.guard as VentGuard
	guard.set_physics_process(false)
	grille = level.grilles[0]
	for i in VentGrille.TURNS * VentGrille.SCREWS:
		grille.turn()
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _on_bunk() -> void:
	cop.global_position = lot * Vector3(8.3, 0.55, 1.6)
	await wait_physics_frames(1)


func test_up_the_grille_and_crawling_in_the_duct() -> void:
	await _on_bunk()
	grille.use(cop)
	await wait_physics_frames(3)
	assert_true(level.duct.contains(cop.global_position), "in the duct")
	assert_true(cop.crawling)
	assert_true(cop.is_crouching, "down on all fours")
	assert_eq(cop.current_speed(), Cop.CRAWL_SPEED, "slow")
	cop.step(0.1, Vector2(0, -1), true, false, false)
	assert_eq(cop.current_speed(), Cop.CRAWL_RUN_SPEED, "scrambling")


func test_the_duct_doesnt_let_you_stand_up() -> void:
	await _on_bunk()
	grille.use(cop)
	await wait_physics_frames(2)
	cop.step(0.1, Vector2.ZERO, false, false, false)
	assert_true(cop.is_crouching, "the top is too low")


func test_the_big_one_gets_stuck() -> void:
	var friend: Cop = COP_SCENE.instantiate()
	friend.uniform = 1
	friend.input_enabled = false
	level.add_child(friend)
	await wait_physics_frames(1)
	var big := level.big_cop()
	big.global_position = lot * Vector3(8.3, 0.55, 1.6)
	await wait_physics_frames(1)
	grille.use(big)
	await wait_physics_frames(2)
	assert_false(level.duct.contains(big.global_position), "he doesn't fit")
	var other: Cop = cop if big == friend else friend
	other.global_position = lot * Vector3(8.3, 0.55, 1.6)
	await wait_physics_frames(1)
	grille.use(other)
	await wait_physics_frames(2)
	assert_true(level.duct.contains(other.global_position), "the other one does")
	friend.queue_free()


func test_one_stub_goes_down_to_the_office_the_others_are_dead_ends() -> void:
	var duct := level.duct
	assert_true(duct.office_hatch.into_office)
	assert_almost_eq(duct.office_hatch.position.x, VentDuct.STUBS[duct.exit_stub], 0.01)
	var same := VentDuct.new()
	add_child_autofree(same)
	same.build(7171, [8.3, 12.7] as Array[float])
	assert_eq(same.exit_stub, duct.exit_stub, "same seed, same way out")
	var seen := {}
	for s in 40:
		seen[hash(["vent exit", s]) % VentDuct.STUBS.size()] = true
	assert_eq(seen.size(), VentDuct.STUBS.size(), "any of the three")
	for x in VentDuct.STUBS:
		assert_true(duct.contains(lot * Vector3(x, VentDuct.FLOOR_Y + 0.3, VentDuct.STUB_END + 0.3)), "every stub is duct")


func test_down_into_the_office_and_back_into_a_cell() -> void:
	await _on_bunk()
	grille.use(cop)
	await wait_physics_frames(2)
	level.duct.office_hatch.use(cop)
	await wait_physics_frames(2)
	var local := lot.affine_inverse() * cop.global_position
	assert_false(level.duct.contains(cop.global_position))
	assert_lt(local.z, StationRooms.SPLIT_Z, "in the back row")
	assert_lt(absf(local.x), StationRooms.BACK_X, "in the office")
	assert_lt(local.y, 0.5, "on its floor")
	level.duct.cell_hatches[1].use(cop)
	await wait_physics_frames(2)
	assert_false(level.outside_cells(cop.global_position), "back in a cell")


func test_scrambling_over_his_head_he_hears_crawling_he_doesnt() -> void:
	await _on_bunk()
	grille.use(cop)
	await wait_physics_frames(2)
	var at := lot * Vector3(8.0, VentDuct.FLOOR_Y + 0.1, VentDuct.MAIN_Z)
	cop.global_position = at
	level._duct_last.clear()
	level._crawl(0.1)
	cop.global_position = at + Vector3(Cop.CRAWL_SPEED * 0.1, 0, 0)
	level._crawl(0.1)
	assert_false(guard.hears_duct(), "crawling slowly is quiet")
	cop.global_position += Vector3(Cop.CRAWL_RUN_SPEED * 0.1, 0, 0)
	level._crawl(0.1)
	assert_true(guard.hears_duct(), "scrambling is a bong")
	assert_true(guard.said().begins_with("VENT_GUARD_CEILING"))
	assert_eq(guard.alarm(), VentGuard.DUCT_NOISE)


func test_a_catch_brings_them_down_from_the_duct() -> void:
	await _on_bunk()
	grille.use(cop)
	await wait_physics_frames(2)
	guard.catch()
	await wait_physics_frames(2)
	assert_false(level.duct.contains(cop.global_position))
	assert_false(level.outside_cells(cop.global_position))
	assert_true(grille.is_open(), "the grille stays off")
