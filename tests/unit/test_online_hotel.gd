extends GutTest

## The hotel online (escena-hotel.md, step 6; docs/diseno/online.md): it's drawn among the crime scenes, and the
## guests' hotel follows the host's maid and the card on the suite's door, Tito, the guest book, the concierge's anger
## and the ruined clues.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/hotel.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: HotelLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _hotel(net: Node) -> Hotel:
	return (OnlinePcs.level(net) as HotelLevel).hotel


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as HotelLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as HotelLevel).case.tip_given, 5.0)
	return pcs


func test_the_hotel_is_drawn_in_quarters() -> void:
	assert_eq(PlaceDraw.CRIME_SCENES, ["crime_scene", "circus", "museum", "hotel"])
	assert_true(PlaceDraw.PLACES.has("hotel"))
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % 4]] = true
	assert_eq(drawn.size(), 4, "every crime scene comes up")


func test_the_maid_and_the_card_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _hotel(pcs[0])
	var guest := _hotel(pcs[1])
	assert_true(guest.case.follower)
	host.clues.hanger.hung = true
	host.clues.maid_walking = true
	for i in 50:
		host.clues.walk_maid(0.1)
	await wait_until(func() -> bool: return guest.clues.hanger.hung, 5.0)
	await wait_until(func() -> bool: return guest.maid.position.distance_to(host.maid.position) < 0.5, 5.0)
	assert_true(guest.clues.maid_walking)
	assert_eq(guest.clues.hanger.prompt_key(null), "PROMPT_DND_TAKE")


func test_tito_the_book_and_the_concierge_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _hotel(pcs[0])
	var guest := _hotel(pcs[1])
	host.bellboy.offend()
	host.book.signed_over = true
	host.concierge.get_angry(30.0)
	host.guests[2].sign_notebook()
	await wait_until(func() -> bool: return guest.bellboy.offended, 5.0)
	await wait_until(func() -> bool: return guest.book.signed_over, 5.0)
	await wait_until(func() -> bool: return guest.concierge.angry_left > 0.0, 5.0)
	await wait_until(func() -> bool: return guest.guests[2].signed, 5.0)
	assert_true(guest.witness_offended())


func test_a_guests_file_goes_on_the_board_once_it_has_something() -> void:
	var level: HotelLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 21
	add_child_autofree(level)
	assert_eq(level.board.file_cards.size(), 0, "no photo of anyone in cucumbers")
	level.hotel.guests[1].sign_notebook()
	assert_true(level.board.file_cards.has(1), "the signature opens their file")
