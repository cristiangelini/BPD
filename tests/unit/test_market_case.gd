extends GutTest

## The market walk as a case (politico-mercado.md, step 6, decision 120): the photo at the ribbon solves it, the second
## bad sample sends the deputy home and loses it, the pay counts image, the toilet run and the vendor, and a loose
## spiteful vendor runs off on his vegetable trike.

const LEVEL := preload("res://scenes/levels/market.tscn")

var market: MarketLevel
var case: MarketCase


func before_each() -> void:
	market = LEVEL.instantiate()
	market.case_seed = 7
	market.get_node("Cop").input_enabled = false
	add_child_autofree(market)
	await wait_physics_frames(2)
	case = market.case


func test_the_comisario_tells_it_in_his_office() -> void:
	assert_false(case.tip_given, "not before seeing him")
	case.give_tip()
	assert_true(case.tip_given)


func test_the_photo_solves_it() -> void:
	market.spite.spiteful.cuffed(Handcuffs.SECONDS)
	market.tour.finished.emit()
	assert_true(case.photo_done)
	assert_true(case.solved())
	assert_null(case.chase, "the vendor is cuffed: nobody runs")
	await wait_seconds(MarketCase.SHIFT_DELAY + 0.5)
	assert_true(case.shift_over)


func test_going_home_loses_it() -> void:
	market.toilet_run.went_home.emit()
	assert_true(case.went_home)
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)
	market.tour.finished.emit()
	assert_false(case.photo_done, "no photo once he's gone")


func test_the_pay_counts_image_toilet_and_vendor() -> void:
	case.photo_done = true
	market.image.lose(15.0)
	assert_eq(case.report().salary, MarketCase.SALARY - 15 * MarketCase.PER_POINT)
	market.toilet_run.ran.emit(1)
	assert_eq(case.report().salary, MarketCase.SALARY - 15 * MarketCase.PER_POINT - MarketCase.TOILET_RUN)
	assert_false(case.report().approved, "the toilet run and 15 points leave it under the quota")
	market.spite.jailed.emit()
	var pay := case.report()
	assert_eq(pay.salary, MarketCase.SALARY - 15 * MarketCase.PER_POINT - MarketCase.TOILET_RUN + MarketCase.VENDOR)
	assert_eq(pay.quota, MarketCase.QUOTA)
	assert_true(pay.approved, "the spiteful vendor detained brings it back over")


func test_a_loose_vendor_runs_off_on_the_trike() -> void:
	var vendor := market.spite.spiteful
	market.tour.finished.emit()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.VEGGIE_TRIKE)
	assert_eq(case.chase.who, "vendor")
	assert_false(vendor.visible, "he left on it")
	assert_false(case.shift_over, "the shift waits for the chase")
	case._on_chase_ended(true)
	assert_true(case.vendor_detained(), "caught, he counts as detained")
	case._on_chase_ended(false)
	assert_false(case.vendor_detained())
	assert_true(case.solved(), "got away, it's solved all the same")


func test_the_trike_loses_veggies_in_the_curves() -> void:
	market.tour.finished.emit()
	var veggie := case.chase.drops.drop_furniture(true) as ChaseFurniture
	assert_true(veggie.veggie)
	assert_lt(veggie.piece, ChaseDrops.VEGGIES.size())
	assert_eq(veggie.net_setup().veggie, true, "online the guests' copy is a veggie too")


func test_the_trike_rides_the_sidewalk_at_16() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.VEGGIE_TRIKE], 16.0 / 3.6, 0.01)
	assert_eq(SuspectCar.LANES[SuspectCar.VEGGIE_TRIKE], ChaseRoute.SIDEWALK_LANE)
	assert_has(ChaseCase.ON_FOOT, SuspectCar.VEGGIE_TRIKE)
	assert_true(ChaseSuspect.MODELS.has("vendor"))


func test_the_planilla_shows_the_walk_and_the_image() -> void:
	market.image.lose(10.0)
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, tr("OBJ_MARKET_STALLS") % [0, market.stalls.size()])
	assert_has(texts, tr("OBJ_MARKET_IMAGE") % 90)
	assert_has(texts, "OBJ_MARKET_VENDOR")


func test_play_draws_it() -> void:
	var found := false
	for i in 600:
		if PlaceDraw.pick(i + 1, [], 1) == "market":
			found = true
			break
	assert_true(found)
