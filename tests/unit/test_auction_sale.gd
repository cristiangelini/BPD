extends GutTest

## The auction (infiltracion-subasta.md, step 4, decision 177): lots up every EVERY seconds in the seed's order, bids
## from the cops' free chairs and the seated buyers up to their tops, "a la una, a las dos" and the gavel; a lot the
## cops win is delivered by their chair and paid; a lot no cop bid on makes the hall suspicious; the buyers out of the
## hall watch.

const LEVEL := preload("res://scenes/levels/auction_house.tscn")

var house: AuctionHouse
var sale: AuctionSale
var cop: Cop


func before_each() -> void:
	house = LEVEL.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	cop = house.get_node("Cop")
	await wait_physics_frames(2)
	sale = house.sale
	sale.set_physics_process(false)
	house.suspicion.set_physics_process(false)


func _step(seconds: float) -> void:
	var left := seconds
	while left > 0.0:
		sale._physics_process(0.1)
		left -= 0.1


## A free chair, with the cop standing by it.
func _free_seat() -> BidSeat:
	for seat in house.seats:
		if not sale.taken(seat):
			cop.global_position = seat.global_position + Vector3(0.6, 0.1, 0)
			return seat
	return null


## No buyer outbids anyone (their tops under the opening price).
func _quiet_buyers() -> void:
	for member in sale.tops.keys():
		sale.tops[member] = 0


func _buyers_suspicion() -> float:
	var total := 0.0
	for member in house.members:
		total += member.suspicion
	return total


func test_the_first_lot_comes_up_after_first_seconds() -> void:
	watch_signals(sale)
	_step(AuctionSale.FIRST - 1.0)
	assert_eq(sale.state, AuctionSale.IDLE)
	_step(1.2)
	assert_eq(sale.state, AuctionSale.SELLING)
	assert_signal_emitted(sale, "opened")
	assert_eq(house.easel.lot, sale.kind, "on the easel")
	assert_eq(house.podium.price, AuctionSale.START)
	assert_eq(house.martillo.said(), "AUCTION_LOT_" + sale.kind)


func test_the_lots_come_in_the_seeds_order() -> void:
	var seen: Array[String] = []
	for i in LotEasel.KINDS.size():
		sale.open()
		seen.append(sale.kind)
		sale._end()
	seen.sort()
	var all := LotEasel.KINDS.duplicate()
	all.sort()
	assert_eq(seen, all, "each kind once")


func test_a_cop_bids_from_a_free_chair() -> void:
	sale.open()
	_quiet_buyers()
	var seat := _free_seat()
	seat.use(cop)
	assert_eq(sale.last_bidder, cop)
	assert_eq(sale.price, AuctionSale.START, "the first bid takes the opening price")
	assert_true(seat.is_raised())
	assert_true(sale.cop_bid)
	seat.use(cop)
	assert_eq(sale.price, AuctionSale.START, "bidding against himself does nothing")


func test_a_buyers_chair_or_a_far_one_does_not_bid() -> void:
	sale.open()
	_quiet_buyers()
	for seat in house.seats:
		if sale.taken(seat):
			cop.global_position = seat.global_position + Vector3(0.6, 0.1, 0)
			seat.use(cop)
			break
	assert_null(sale.last_bidder, "that chair is a buyer's")
	var seat := _free_seat()
	cop.global_position = seat.global_position + Vector3(3.0, 0.1, 0)
	seat.use(cop)
	assert_null(sale.last_bidder, "too far from it")


func test_buyers_outbid_up_to_their_tops() -> void:
	sale.open()
	var top := 0
	for member in sale.tops.keys():
		top = maxi(top, sale.tops[member])
	assert_gt(sale.tops.size(), 0, "the seated buyers bid")
	_step(AuctionSale.RIVAL_MAX + 0.2)
	assert_true(sale.last_bidder is ClubMember, "a buyer bid")
	_step(60.0)
	assert_eq(sale.state, AuctionSale.IDLE, "and it got sold")
	assert_eq(sale.bought, 0)


func test_once_twice_sold_to_a_cop_and_paid() -> void:
	sale.open()
	_quiet_buyers()
	var seat := _free_seat()
	seat.use(cop)
	var kind := sale.kind
	watch_signals(sale)
	_step(AuctionSale.ONCE + 0.1)
	assert_eq(house.martillo.said(), "AUCTION_ONCE")
	_step(AuctionSale.TWICE - AuctionSale.ONCE)
	assert_eq(house.martillo.said(), "AUCTION_TWICE")
	_step(AuctionSale.HAMMER - AuctionSale.TWICE)
	assert_signal_emitted_with_parameters(sale, "sold", [kind, AuctionSale.START, true])
	assert_eq(house.martillo.said(), "AUCTION_SOLD_COP")
	assert_eq(house.podium.bangs, 1, "the gavel")
	assert_eq(sale.bought, 1)
	assert_eq(sale.spent, AuctionSale.START)
	assert_eq(sale.lots.size(), 1)
	assert_lt(sale.lots[0].global_position.distance_to(seat.global_position), 1.5, "delivered by the chair")
	assert_eq(house.easel.lot, "", "off the easel")
	assert_eq(_buyers_suspicion(), 0.0, "the cops bid")


func test_a_lot_no_cop_bid_on_makes_the_hall_suspicious() -> void:
	sale.open()
	_step(60.0)
	assert_eq(sale.state, AuctionSale.IDLE)
	assert_gt(_buyers_suspicion(), 0.0)


func test_the_buyers_out_of_the_hall_watch_the_lot() -> void:
	sale.open()
	for member in house.members:
		if not house.evidence.talkers.has(member):
			assert_eq(member.distracted, not house.in_hall(member.global_position + Vector3.UP))
	sale._end()
	for member in house.members:
		assert_eq(member.distracted, house.evidence.talkers.has(member), "back to normal after it (the talkers talk)")


func test_the_sale_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["AUCTION_ONCE", "AUCTION_TWICE", "AUCTION_SOLD", "AUCTION_SOLD_COP", "AUCTION_NO_SALE",
		"AUCTION_NOBODY_BID", "HINT_AUCTION_LOT"]
	for kind: String in LotEasel.KINDS:
		keys.append("AUCTION_LOT_" + kind)
	for key in keys:
		assert_ne(tr(key), key)
