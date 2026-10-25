extends GutTest

## The city's covered market (politico-mercado.md, step 1, decision 120): its lot on block (2, 0), the 12 stalls along
## the U-shaped aisle with their goods drawn by the seed, a vendor behind each counter, the shoppers, the chemical
## toilet at the back and the ribbon across the way out.

const LEVEL := preload("res://scenes/levels/market.tscn")

var market: MarketLevel


func before_each() -> void:
	market = LEVEL.instantiate()
	market.case_seed = 7
	market.get_node("Cop").input_enabled = false
	add_child_autofree(market)
	await wait_physics_frames(2)


func test_play_can_open_it() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=market"])), "market")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["market"]))


func test_it_sits_on_its_block_in_the_city() -> void:
	assert_eq(CityLayout.place("market").block, Vector2i(2, 0))
	assert_eq(CityLayout.lot("market").origin.distance_to(market.city.transform.affine_inverse().origin), 0.0,
		"the city is laid around the market")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = market.get_node("Cop")
	assert_gt(cop.global_position.distance_to(market.global_position), 40.0, "they drive here")


func test_twelve_stalls_each_selling_something_else() -> void:
	assert_eq(market.stalls.size(), 12)
	var kinds := {}
	for stall in market.stalls:
		kinds[stall.kind] = true
		assert_true(market.inside(stall.stop), "the deputy's stop is inside the hall")
	assert_eq(kinds.size(), 12)


func test_the_seed_changes_what_each_stall_sells() -> void:
	assert_eq(MarketLevel.kinds_for(7), MarketLevel.kinds_for(7))
	var differs := false
	for s in range(1, 6):
		differs = differs or MarketLevel.kinds_for(s) != MarketLevel.kinds_for(7)
	assert_true(differs)


func test_each_vendor_is_behind_their_counter_facing_the_aisle() -> void:
	for stall in market.stalls:
		var vendor: MarketVendor = stall.vendor
		assert_eq(vendor.kind, stall.kind)
		var to_aisle: Vector3 = stall.facing
		assert_lt((vendor.position - (stall.at as Vector3)).dot(to_aisle), 0.0, "behind the counter")
		assert_gt((-vendor.global_basis.z).dot(to_aisle), 0.9, "looking at the customers")


func test_a_vendor_praises_what_they_sell() -> void:
	var vendor: MarketVendor = market.stalls[0].vendor
	vendor.use(market.get_node("Cop"))
	assert_eq(vendor.said(), "VENDOR_%s" % vendor.kind.to_upper())


func test_shoppers_stand_at_the_counters() -> void:
	assert_eq(market.shoppers.size(), MarketLevel.SHOPPERS)
	for shopper in market.shoppers:
		assert_true(market.inside(shopper.global_position))


func test_the_toilet_is_at_the_back_and_the_ribbon_by_the_way_out() -> void:
	var toilet: Node3D = market.get_node("Built/Toilet")
	assert_lt(toilet.position.z, -MarketLevel.HALF_Z + 1.5)
	assert_gt(market.photo_spot().x, 0.0, "on the east side, by the way out")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PLACE_MARKET", "MARKET_STALL_ICE_CREAM", "VENDOR_FISH", "SHOPPER_7", "PROMPT_TALK_VENDOR"]:
		assert_ne(tr(key), key)
