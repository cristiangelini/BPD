extends GutTest

## The auction hall's things (infiltracion-subasta.md, step 3, decision 177): a numbered chair with its paddle for each
## place in the rows, facing Don Martillo's podium; E on a chair raises its paddle (on the host, `raised`); the podium's
## gavel bangs and its board shows the price; the easel shows the lot up for sale.

const LEVEL := preload("res://scenes/levels/auction_house.tscn")

var house: AuctionHouse
var cop: Cop


func before_each() -> void:
	house = LEVEL.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	cop = house.get_node("Cop")
	await wait_physics_frames(2)


func test_a_numbered_chair_for_each_place_facing_the_podium() -> void:
	assert_eq(house.seats.size(), AuctionHouse.CHAIRS.size())
	for i in house.seats.size():
		var seat := house.seats[i]
		assert_eq(seat.number, i + 1)
		assert_true(house.in_hall(seat.global_position + Vector3.UP))
		assert_lt(seat.position.z, AuctionHouse.HALF_Z, "in the hall")
		assert_gt(seat.position.z, house.podium.position.z, "in front of the podium")


func test_raising_a_paddle() -> void:
	var seat := house.seats[4]
	assert_eq(seat.prompt_key(cop), "PROMPT_AUCTION_BID")
	assert_false(seat.is_raised())
	watch_signals(seat)
	seat.use(cop)
	assert_signal_emitted_with_parameters(seat, "raised", [cop, seat])
	seat.raise()
	assert_true(seat.is_raised(), "the paddle up")
	seat._process(BidSeat.RAISE_TIME + 0.1)
	assert_false(seat.is_raised(), "and down again")


func test_the_buyers_sit_on_the_chairs() -> void:
	for member: ClubMember in house.members:
		var flat := Vector3(member.position.x, 0, member.position.z)
		if AuctionHouse.CHAIRS.has(flat):
			assert_almost_eq(member.position.y, AuctionHouse.FLOOR_TOP + BidSeat.SEAT, 0.01)


func test_the_gavel_bangs_and_the_board_shows_the_price() -> void:
	TranslationServer.set_locale("es")
	var podium := house.podium
	assert_true(house.in_hall(podium.global_position + Vector3.UP))
	assert_eq(podium.get_node("PriceBoard").text, "", "empty between lots")
	podium.show_price(350)
	assert_string_contains(podium.get_node("PriceBoard").text, "350")
	podium.bang()
	assert_eq(podium.bangs, 1)
	assert_not_null(podium.get_node("Toc").stream)
	var to_chairs := (house.global_transform * AuctionHouse.CHAIRS[7]) - house.martillo.global_position
	to_chairs.y = 0.0
	assert_gt((-house.martillo.global_basis.z).dot(to_chairs.normalized()), 0.9, "Don Martillo faces the chairs")


func test_the_easel_shows_the_lot() -> void:
	var easel := house.easel
	assert_null(easel.get_node_or_null("Lot"))
	for kind: String in LotEasel.KINDS:
		easel.show_lot(kind)
		assert_eq(easel.lot, kind)
		await wait_process_frames(1)
		assert_not_null(easel.get_node_or_null("Lot"), kind)
	easel.show_lot("")
	await wait_process_frames(1)
	assert_null(easel.get_node_or_null("Lot"), "nothing between lots")


func test_the_room_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PROMPT_AUCTION_BID", "AUCTION_PRICE"]:
		assert_ne(tr(key), key)
