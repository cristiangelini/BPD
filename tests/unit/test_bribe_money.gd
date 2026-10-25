extends GutTest

## The bribe jailbreak, step 1 (fuga-soborno.md): the campaign keeps the bribes' money, the jailbreak draws the bribe
## only while they have it, the money lies in four wads on the bunks, E on the bars calls the guard, who says his
## price, the wads paid through the bars add up, and paid in full he drops the key inside the cell and reads the paper.
## What he got comes out of the campaign's money.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_soborno_plata.json"

var level: JailbreakLevel
var guard: BribeGuard
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _level(case_seed := 5151) -> void:
	level = LEVEL.instantiate()
	level.variant = "bribe"
	level.case_seed = case_seed
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as BribeGuard
	guard.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func _wads() -> Array:
	return level.get_children().filter(func(node: Node) -> bool:
		return node is BillWad and not node.is_queued_for_deletion())


func _step(seconds: float) -> void:
	for i in int(seconds * 30):
		guard._physics_process(1.0 / 30.0)


func _keys() -> Array:
	return level.get_children().filter(func(node: Node) -> bool: return node is CellKey)


func test_the_campaign_keeps_the_bribes_money() -> void:
	var campaign := Campaign.start_new()
	campaign.money = 1000
	campaign.take_bribe(150)
	campaign.take_bribe(250)
	assert_eq(campaign.bribe_money, 400)
	campaign.investigation = true
	campaign.take_bribe(200, true)
	assert_eq(campaign.bribe_money, 400, "one the agent saw doesn't count")
	campaign.finish_shift("test", true, {"total": 0})
	assert_eq(campaign.bribe_money, 400 - Bribes.CAUGHT_FINE, "and his fine comes out of it")
	campaign.bribe_money = 700
	assert_eq(campaign.bribe_fund(), 700)
	campaign.money = 300
	assert_eq(campaign.bribe_fund(), 300, "never more than the group's money")
	campaign.save()
	assert_eq(Campaign.load_saved().bribe_money, 700, "saved")
	campaign.pay_guard(250)
	assert_eq(campaign.money, 50)
	assert_eq(campaign.bribe_money, 450)


func test_drawn_only_with_the_money() -> void:
	var drawn := {}
	var with_money := {}
	for drawn_seed in range(1, 400):
		var way := JailbreakLevel.pick_variant(drawn_seed, PackedStringArray(), 0)
		drawn[way] = true
		var paid := JailbreakLevel.pick_variant(drawn_seed, PackedStringArray(), BribeGuard.PRICE_MIN)
		with_money[paid] = true
	assert_false(drawn.has("bribe"), "not without the money")
	assert_true(with_money.has("bribe"))
	assert_eq(with_money.size(), JailbreakLevel.VARIANTS.size(), "in ninths")
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=bribe"])), "bribe")


func test_the_price_and_the_wads() -> void:
	for case_seed in range(1, 60):
		var price := BribeGuard.price_for(case_seed, 1000)
		assert_between(price, BribeGuard.PRICE_MIN, BribeGuard.PRICE_MAX)
		assert_eq(price % BribeGuard.PRICE_STEP, 0)
		assert_lte(BribeGuard.price_for(case_seed, 260), 250, "never more than they have")
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var wads := BillWad.split(420, 4, 50, rng)
	assert_eq(wads.size(), 4)
	assert_eq(wads.reduce(func(sum: int, amount: int) -> int: return sum + amount, 0), 400)
	assert_true(wads.all(func(amount: int) -> bool: return amount >= 50))
	assert_eq(BillWad.split(150, 4, 50, rng).size(), 0, "not enough for four")


func test_four_wads_with_the_campaigns_money() -> void:
	var campaign := Campaign.start_new()
	campaign.money = 2000
	campaign.bribe_money = 650
	await _level()
	var wads := _wads()
	assert_eq(wads.size(), 4)
	assert_eq(wads.reduce(func(sum: int, wad: BillWad) -> int: return sum + wad.amount, 0), 650)
	for wad: BillWad in wads:
		assert_false(level.outside_cells(wad.global_position), "%s is in a cell" % wad.name)
	assert_lte(guard.price, 650)
	assert_true(guard.key_on_belt)


func test_called_he_comes_and_says_his_price() -> void:
	await _level()
	var door: CellDoor = level.city.cell_doors[0]
	assert_eq(door.prompt_key(cop), "PROMPT_CALL_GUARD")
	door.use(cop)
	assert_eq(guard.stage, "coming")
	assert_true(door.locked, "still locked")
	_step(12.0)
	assert_eq(guard.stage, "at_bars")
	assert_eq(guard.line, "BRIBE_GUARD_PRICE")
	assert_eq(guard.line_number, guard.price)
	assert_almost_eq(guard.global_position.distance_to(door.global_position), 0.9, 0.6, "at the door")
	assert_eq(door.prompt_key(cop), "PROMPT_CELL_LOCKED", "nothing more to do with empty hands")
	_step(BribeGuard.WAIT_TIME + 1.0)
	assert_ne(guard.stage, "at_bars", "tired of waiting, he goes back")
	_step(12.0)
	assert_eq(guard.stage, "")


func test_the_wads_add_up_and_paid_he_drops_the_key() -> void:
	await _level()
	var door: CellDoor = level.city.cell_doors[1]
	door.use(cop)
	_step(12.0)
	assert_eq(guard.stage, "at_bars")
	var wads := _wads()
	wads.sort_custom(func(a: BillWad, b: BillWad) -> bool: return a.amount < b.amount)
	var given := 0
	for wad: BillWad in wads:
		cop.handed(wad)
		assert_eq(door.prompt_key(cop), "PROMPT_PAY_GUARD")
		door.use(cop)
		given += wad.amount
		assert_eq(guard.stage, "counting")
		await wait_physics_frames(2)
		assert_false(is_instance_valid(wad) and wad.is_inside_tree(), "he keeps it")
		_step(BribeGuard.COUNT_TIME + 0.1)
		assert_eq(guard.paid, given)
		if guard.is_paid():
			break
		assert_eq(guard.line, "BRIBE_GUARD_SHORT")
		assert_eq(guard.line_number, guard.price - given)
	assert_true(guard.is_paid())
	assert_true(guard.line.begins_with("BRIBE_GUARD_DEAL"))
	assert_false(guard.key_on_belt)
	var keys := _keys()
	assert_eq(keys.size(), 1, "the key dropped")
	assert_false(level.outside_cells(keys[0].global_position), "inside the cell")
	assert_eq(door.prompt_key(cop), "PROMPT_CELL_LOCKED", "nothing more to pay")
	_step(12.0)
	assert_eq(guard.stage, "reading", "back at his desk with the paper")
	assert_lt(guard.facing().dot(lot.basis * Vector3(0, 0, -1)), -0.5, "his back to the cells")


func test_what_he_got_comes_out_of_the_campaign() -> void:
	var campaign := Campaign.start_new()
	campaign.money = 1500
	campaign.bribe_money = 600
	campaign.jailed = true
	await _level()
	guard.paid = 350
	level.finish("escaped")
	assert_eq(campaign.money, 1150)
	assert_eq(campaign.bribe_money, 250)
