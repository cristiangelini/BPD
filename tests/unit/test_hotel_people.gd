extends GutTest

## The hotel's people (escena-hotel.md, step 2): the six guests alike (HotelGuest) in the lobby and the staff
## (HotelStaff): don Bostezo behind the desk, señora Perlita, Tito the bellboy and doña Escoba upstairs with her cart.


func test_six_guests_alike_wait_in_the_lobby() -> void:
	var hotel := Hotel.new()
	add_child_autofree(hotel)
	assert_eq(hotel.guests.size(), Hotel.GUEST_ROOMS.size(), "one guest per room")
	for i in hotel.guests.size():
		var guest := hotel.guests[i]
		assert_eq(guest.index, i)
		assert_eq(hotel.suspect(i), guest)
		assert_true(hotel.inside(guest.global_position), "%s is inside" % guest.name)
		assert_eq(hotel.floor_of(guest.global_position + Vector3.UP), 0, "downstairs")
		assert_true(guest.part("towel").visible, "the towel is on")
		assert_true(guest.part("cucumbers").visible, "and the cucumbers")
		assert_false(guest.part("hair").visible, "the hair doesn't show")
		assert_false(guest.part("glasses").visible, "nor the glasses")
		assert_false(guest.part("teeth").visible)
	assert_null(hotel.suspect(hotel.guests.size()))


func test_the_staff_stand_where_they_work() -> void:
	var hotel := Hotel.new()
	add_child_autofree(hotel)
	for person: HotelStaff in [hotel.concierge, hotel.perlita, hotel.bellboy]:
		assert_true(hotel.inside(person.global_position), "%s is inside" % person.name)
		assert_eq(hotel.floor_of(person.global_position + Vector3.UP), 0, "%s is downstairs" % person.name)
	assert_lt(hotel.to_local(hotel.concierge.global_position).z, Hotel.DESK_AT.z, "the concierge is behind the desk")
	assert_eq(hotel.floor_of(hotel.maid.global_position + Vector3.UP), 1, "the maid is upstairs")
	assert_eq(hotel.room_of(hotel.maid.global_position + Vector3.UP), -1, "in the corridor")
	assert_not_null(hotel.maid.cart, "with her cart")
	assert_eq(hotel.room_of(hotel.maid.cart.global_position + Vector3.UP), -1, "also in the corridor")
	assert_null(hotel.concierge.cart, "nobody else has one")


func test_everyone_talks_and_their_lines_are_written() -> void:
	TranslationServer.set_locale("es")
	var hotel := Hotel.new()
	add_child_autofree(hotel)
	var cop: Cop = autofree(preload("res://scenes/player/cop.tscn").instantiate())
	var guest := hotel.guests[1]
	assert_eq(guest.prompt_key(cop), "PROMPT_GUEST_SIGN", "first they sign (step 3)")
	guest.use(cop)
	assert_eq(guest.prompt_key(cop), "PROMPT_HOTEL_GUEST")
	guest.use(cop)
	var first := guest.said()
	guest.use(cop)
	assert_ne(guest.said(), first, "a different line each time")
	for who: String in HotelStaff.WHO:
		assert_ne(tr("PROMPT_HOTEL_" + who.to_upper()), "PROMPT_HOTEL_" + who.to_upper())
		for n in HotelStaff.WHO[who].lines:
			var key := "HOTEL_%s_LINE_%d" % [who.to_upper(), n]
			assert_ne(tr(key), key, "%s is written" % key)
	hotel.concierge.use(cop)
	assert_eq(hotel.concierge.said(), "HOTEL_CONCIERGE_LINE_0")
	hotel.concierge.use(cop)
	assert_eq(hotel.concierge.said(), "HOTEL_CONCIERGE_LINE_1")
	hotel.maid.use(cop)
	assert_eq(hotel.maid.said(), "HOTEL_MAID_LINE_0")


func test_without_the_crime_scene_the_hotel_is_empty() -> void:
	var hotel := Hotel.new()
	hotel.crime_scene = false
	add_child_autofree(hotel)
	assert_true(hotel.guests.is_empty(), "no guests")
	assert_null(hotel.concierge, "no staff")
	assert_eq(hotel.get_tree().get_nodes_in_group("hotel_people").size(), 0)
	assert_not_null(hotel.wardrobe, "but the building is all there")
