extends GutTest

## The train's clues (escena-tren.md, step 4b): the showcase's prints, the soot footprint that señor Mostaza's cart
## wipes unless someone buys from him, the hair the open window's wind takes and the bitten sandwich.

const LEVEL := preload("res://scenes/levels/train.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A seed whose case has all these clues.
func _seed_with(kinds: Array[String]) -> int:
	for seed_value in range(1, 400):
		var plan := CrimePlan.draw(MagicianTraits.draw(seed_value), seed_value, MagicianTraits.CLUES)
		if kinds.all(func(kind: String) -> bool: return plan.clues.has(kind)):
			return seed_value
	return -1


func _level(seed_value: int) -> TrainLevel:
	var level: TrainLevel = LEVEL.instantiate()
	level.case_seed = seed_value
	add_child_autofree(level)
	return level


func test_the_clues_go_in_their_cars() -> void:
	var seed_value := _seed_with(["footprint", "hair", "bite"])
	assert_ne(seed_value, -1)
	var level := _level(seed_value)
	await wait_physics_frames(2)
	var train := level.train
	var clues := train.clues
	assert_not_null(clues)
	var luggage := Train.CAR_NAMES.find("luggage")
	assert_eq(train.car_of(clues.showcase.global_position), luggage)
	assert_eq(train.car_of(clues.footprint.global_position), luggage)
	assert_eq(train.car_of(level.case.items.hair.global_position), luggage)
	assert_eq(train.car_of(level.case.items.bite.global_position), Train.CAR_NAMES.find("dining"))
	assert_eq(train.car_of(train.bags.global_position), Train.CAR_NAMES.find("dining"))
	assert_eq(clues.footprint.shoe, level.case.culprit().shoe)
	await wait_physics_frames(30)
	assert_gt(level.case.items.hair.global_position.y, Train.FLOOR_Y + 1.0, "the hair stays on the sill")


func test_the_cart_wipes_the_footprint_on_its_round() -> void:
	var level := _level(_seed_with(["footprint"]))
	await wait_physics_frames(2)
	var clues := level.train.clues
	clues.cart_wait = 0.0
	clues.cart_next = 0
	for i in 2000:
		clues.push_cart(0.05)
		if clues.footprint.wiped:
			break
	assert_true(clues.footprint.wiped, "the cart went over it")
	assert_true(level.case.ruined.has("footprint"))
	assert_lt(level.train.vendor.position.distance_to(level.train.cart.position), 1.0, "señor Mostaza pushes it")


func test_buying_keeps_the_cart_still_and_costs_the_salary() -> void:
	var level := _level(_seed_with(["footprint"]))
	await wait_physics_frames(2)
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	var clues := level.train.clues
	clues.cart_wait = 1.0
	assert_eq(level.train.vendor.prompt_key(cop), "PROMPT_TRAIN_VENDOR_BUY")
	level.train.vendor.use(cop)
	assert_eq(clues.cart_wait, TrainClues.CART_HOLD)
	assert_eq(level.case.spent, TrainClues.PRICE)
	assert_eq(level.train.vendor.said(), "TRAIN_VENDOR_SOLD")
	var report := ShiftReport.pay(true, [], level.case.spent)
	assert_eq(report.fines, TrainClues.PRICE, "it comes off the salary")


func test_the_open_window_blows_the_hair_away_unless_bagged() -> void:
	var level := _level(_seed_with(["hair"]))
	await wait_physics_frames(2)
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	var window := level.train.clues.window
	window.use(cop)
	assert_true(window.open)
	assert_true(level.case.ruined.has("hair"), "the wind took it")
	assert_eq(window.prompt_key(cop), "PROMPT_TRAIN_WINDOW_SHUT")


func test_touching_the_showcase_covers_the_prints() -> void:
	var level := _level(_seed_with(["prints"]))
	await wait_physics_frames(2)
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	var showcase := level.train.clues.showcase
	assert_true(showcase.has_prints)
	showcase.use(cop)
	assert_eq(showcase.dusted(cop), "PRINTS_SHOWCASE_SMUDGED")
	assert_true(level.case.ruined.has("prints"))
	var clean := _level(_seed_with(["prints"]))
	await wait_physics_frames(2)
	assert_eq(clean.train.clues.showcase.dusted(cop), "PRINTS_SHOWCASE")
	assert_true(clean.case.clues_found.has("prints"))


func test_each_clue_has_its_line() -> void:
	var level := _level(11)
	await wait_physics_frames(2)
	for kind: String in MagicianTraits.CLUES:
		var line := level.case.clue_line(kind)
		assert_false(line.begins_with("CLUE_"), kind + " has a text")
		assert_ne(tr("CLUE_TRAIN_RUINED_" + kind), "CLUE_TRAIN_RUINED_" + kind)
		assert_ne(tr("HINT_TRAIN_RUINED_" + kind), "HINT_TRAIN_RUINED_" + kind)
