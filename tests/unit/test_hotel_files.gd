extends GutTest

## The guests' files, their rooms and the concierge's lie (escena-hotel.md, step 3): GuestTraits, RoomThing,
## HotelGuest's parts and CrimeSceneCase's guest_part, room_part and open_suitcase.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_each_guest_sleeps_somewhere_and_the_concierge_swaps_the_culprit() -> void:
	for seed_value in range(1, 30):
		var guests := GuestTraits.draw(seed_value)
		assert_eq(GuestTraits.draw(seed_value), guests, "same seed, same guests")
		var culprit := CrimePlan.culprit_of(GuestTraits.COUNT, seed_value)
		var rooms := guests.map(func(g: Dictionary) -> int: return g.room)
		rooms.sort()
		assert_eq(rooms, Array(Hotel.GUEST_ROOMS), "one guest per room")
		var lies := guests.filter(func(g: Dictionary) -> bool: return g.said != g.room)
		assert_eq(lies.size(), 2, "seed %d: the concierge swaps two" % seed_value)
		assert_ne(guests[culprit].said, guests[culprit].room, "one of them the culprit")
		var plan := CrimePlan.draw(guests, seed_value, CrimeSceneCase.VARIANTS.hotel.clues)
		assert_eq(plan.culprit, culprit)
		assert_eq(CrimePlan.suspects_left(guests, guests[culprit], plan.clues, plan.traits).size(), 1,
			"the 4 clues leave only them")


func test_every_room_shows_its_sleepers_things() -> void:
	var hotel := Hotel.new()
	hotel.case_seed = 6
	add_child_autofree(hotel)
	var guests := GuestTraits.draw(6)
	for guest in guests:
		for what: String in ["shoe", "hair", "glasses", "suitcase"]:
			var thing: RoomThing = hotel.things[guest.room][what]
			assert_eq(thing.sleeper, guest, "the %s in %d are its sleeper's" % [what, guest.room])
			assert_eq(hotel.room_of(thing.global_position + Vector3.UP * 0.05), guest.room, "and in the room")
	assert_false(hotel.things.has(Hotel.HIDDEN_ROOM), "nobody sleeps in the 13")
	for i in hotel.guests.size():
		assert_eq(hotel.guests[i].traits, guests[i])


## A hotel with its case set up, and a cop at hand.
func _hotel_case(seed_value: int) -> Array:
	var hotel := Hotel.new()
	hotel.case_seed = seed_value
	add_child_autofree(hotel)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hotel
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [hotel, case, cop]


func test_the_concierges_lie_goes_to_the_wrong_file_until_the_suitcase_is_opened() -> void:
	var made := _hotel_case(3)
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var culprit := case.plan.culprit
	var room: int = case.cooks[culprit].room
	var fooled := case.room_file(room)
	assert_ne(fooled, culprit, "the concierge says someone else sleeps there")
	assert_eq(case.guest_room(fooled), room)
	(hotel.things[room].shoe as RoomThing).use(cop)
	(hotel.things[room].hair as RoomThing).use(cop)
	assert_eq(case.file_traits(fooled).shoe, case.cooks[culprit].shoe, "the culprit's shoes in the wrong file")
	assert_eq(case.file_traits(fooled).hair, case.cooks[culprit].hair)
	assert_false(case.file_traits(culprit).has("shoe"))
	assert_true(case.file_parts[fooled].shoe)
	(hotel.things[room].suitcase as RoomThing).use(cop)
	assert_eq(hotel.things[room].suitcase.said(), tr("ROOM_TAG") % case.cooks[culprit].name)
	assert_eq(case.room_file(room), culprit, "the tag tells the truth")
	assert_eq(case.file_traits(culprit).shoe, case.cooks[culprit].shoe, "the file corrects itself")
	assert_false(case.file_traits(fooled).has("shoe"), "and the fooled one's loses it")
	assert_false(case.file_parts[fooled].shoe)
	assert_true(case.file_parts[culprit].hair)
	assert_eq(case.guest_room(fooled), 0, "now nobody knows where they sleep")
	assert_string_contains(case.file_text(culprit), str(room))


func test_a_guest_gives_prints_teeth_and_signature_and_the_rooms_finish_the_file() -> void:
	var made := _hotel_case(8)
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var honest := -1
	for i in case.cooks.size():
		if case.cooks[i].said == case.cooks[i].room:
			honest = i
	var guest := hotel.guests[honest]
	assert_eq(guest.prompt_key(cop), "PROMPT_GUEST_SIGN")
	guest.use(cop)
	assert_eq(guest.said(), "GUEST_SIGNS_LEFT" if guest.traits.left else "GUEST_SIGNS_RIGHT")
	assert_eq(case.file_traits(honest).left, guest.traits.left)
	assert_eq(guest.prompt_key(cop), "PROMPT_HOTEL_GUEST")
	guest.dusted(cop)
	guest.feed(autofree(Bread.new()))
	assert_true(guest.part("teeth").visible, "the teeth show")
	assert_eq(case.file_traits(honest).teeth, guest.traits.teeth)
	assert_false(case.files.has(honest), "the room is still missing")
	for what: String in ["shoe", "hair", "glasses"]:
		(hotel.things[guest.traits.room][what] as RoomThing).use(cop)
	assert_true(case.files.has(honest), "the file is complete")
	assert_eq(case.file_traits(honest).glasses, guest.traits.glasses)
	hotel.concierge.use(cop)
	assert_string_contains(hotel.concierge.said(), "%d: %s" % [guest.traits.room, guest.traits.name])
