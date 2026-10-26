extends GutTest

## The bribe jailbreak, step 3 (fuga-soborno.md): paid, the guard reads a page with his back to the cells, hears what
## lands and who runs, and when the page is over he turns around: a cop he sees out of the cells is a catch. Caught,
## he keeps the money and asks for more, the key back on his belt and the wads back on the bunks.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_soborno_diario.json"

var level: JailbreakLevel
var guard: BribeGuard
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "bribe"
	level.case_seed = 5151
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as BribeGuard
	guard.set_physics_process(false)
	guard.camera = null
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _step(seconds: float) -> void:
	for i in int(seconds * 30):
		guard._physics_process(1.0 / 30.0)


## Paid in full at cell 0's bars and back at his desk with the paper.
func _paid_and_reading() -> void:
	level.city.cell_doors[0].use(cop)
	_step(12.0)
	guard.paid = guard.price
	guard.at_cell = 0
	guard._deal()
	_step(12.0)
	await wait_physics_frames(2)


func test_he_reads_a_page_with_his_back_to_the_cells() -> void:
	assert_between(guard.page, BribeGuard.PAGE_MIN, BribeGuard.PAGE_MAX)
	await _paid_and_reading()
	assert_eq(guard.stage, "reading")
	assert_between(guard.reading_left, 0.1, guard.page, "the page started")
	cop.global_position = lot * Vector3(10.5, 0.1, 6.0)
	_step(2.0)
	assert_eq(guard.times_caught, 0, "out in front of him, but he's reading")
	assert_eq(guard.suspicion, 0.0)


func test_the_page_over_he_catches_who_he_sees_out() -> void:
	await _paid_and_reading()
	cop.global_position = lot * Vector3(10.5, 0.1, 6.0)
	await wait_physics_frames(2)
	_step(guard.page + 0.5)
	assert_eq(guard.times_caught, 1)
	assert_eq(guard.line, "BRIBE_GUARD_LOOKED_BACK")


func test_out_of_sight_when_the_page_is_over() -> void:
	await _paid_and_reading()
	# Out the front door, on the sidewalk.
	cop.global_position = lot * Vector3(0, 0.3, StationRooms.HALF_Z + 2.0)
	await wait_physics_frames(2)
	_step(guard.page + 0.5)
	assert_eq(guard.times_caught, 0)
	assert_eq(guard.stage, "", "an ordinary guard again")
	assert_eq(guard.line, "BRIBE_GUARD_PAGE_OVER")


func test_he_hears_what_lands_and_who_runs() -> void:
	await _paid_and_reading()
	guard.look_at_noise(lot * Vector3(10.5, 0, 6.0), 2.0, "GUARD_NOISE_0")
	assert_eq(guard.suspicion, BribeGuard.NOISE_SUSPICION)
	assert_true(guard.line.begins_with("BRIBE_GUARD_HEARD_"))
	assert_eq(guard.stage, "reading", "still reading")
	cop.global_position = lot * Vector3(10.5, 0.1, 6.0)
	cop.velocity = Vector3(GameScale.RUN_SPEED, 0, 0)
	guard._hear_running(1.0)
	assert_almost_eq(guard.suspicion, BribeGuard.NOISE_SUSPICION + BribeGuard.RUN_SUSPICION, 0.01)
	cop.velocity = Vector3(GameScale.WALK_SPEED, 0, 0)
	guard._hear_running(1.0)
	assert_almost_eq(guard.suspicion, BribeGuard.NOISE_SUSPICION + BribeGuard.RUN_SUSPICION, 0.01, "walking is quiet")


func test_caught_he_keeps_the_money_and_asks_for_more() -> void:
	var wads := level.get_children().filter(func(node: Node) -> bool: return node is BillWad)
	var asked := guard.price
	await _paid_and_reading()
	var outside: BillWad = wads[0]
	outside.global_position = lot * Vector3(10.5, 0.3, 6.0)
	cop.global_position = lot * Vector3(10.5, 0.1, 6.0)
	await wait_physics_frames(2)
	_step(guard.page + 0.5)
	await wait_physics_frames(3)
	assert_eq(guard.times_caught, 1)
	assert_eq(guard.paid, asked, "the money stays his")
	assert_eq(guard.price, asked + BribeGuard.PRICE_RISE)
	assert_false(guard.is_paid())
	assert_true(guard.key_on_belt, "the key back on his belt")
	assert_eq(level.get_children().filter(func(node: Node) -> bool:
		return node is CellKey and not node.is_queued_for_deletion()).size(), 0, "the dropped one taken away")
	assert_false(level.outside_cells(cop.global_position), "back in a cell")
	assert_false(level.outside_cells(outside.global_position), "the wad back on a bunk")
	assert_eq(level.city.cell_doors[1].prompt_key(cop), "PROMPT_CALL_GUARD", "and he can be called again")
