extends GutTest

## The hotel's witness, guest book and bell (escena-hotel.md, step 4c): Tito tells about the glasses once his suitcase
## is in the room he asked for, the 3 a.m. signature in the guest book and don Bostezo's bell.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A seed whose case has all these clues.
func _seed_with(kinds: Array) -> int:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(GuestTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.hotel.clues)
		if kinds.all(func(kind: String) -> bool: return plan.clues.has(kind)):
			return seed_value
	return -1


func _hotel_case(kinds: Array) -> Array:
	var seed_value := _seed_with(kinds)
	assert_gt(seed_value, 0, "a seed with %s" % [kinds])
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


func test_tito_talks_once_his_suitcase_is_in_his_room() -> void:
	TranslationServer.set_locale("es")
	var made := _hotel_case(["witness"])
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	var tito := hotel.bellboy
	await wait_physics_frames(2)
	assert_true(tito.knows)
	tito.use(made[2])
	assert_string_contains(tito.said(), str(tito.asked_room), "he asks for his room")
	tito.suitcase.global_position = hotel.to_global(Hotel.room_middle(tito.asked_room) + Vector3(0, 0.3, 0))
	await wait_physics_frames(3)
	assert_true(tito.delivered)
	tito.use(made[2])
	assert_has(case.clues_found, "witness")
	assert_eq(tito.said(), "HOTEL_BELLBOY_SAW_GLASSES" if case.culprit().glasses else "HOTEL_BELLBOY_SAW_NO_GLASSES")


func test_cuffed_or_his_suitcase_down_the_stairs_he_is_offended() -> void:
	var made := _hotel_case(["witness"])
	var hotel: Hotel = made[0]
	hotel.bellboy.cuffed(5.0)
	assert_true(hotel.witness_offended())
	assert_has((made[1] as CrimeSceneCase).ruined, "witness")
	made = _hotel_case(["witness"])
	hotel = made[0]
	await wait_physics_frames(2)
	var other := 11 if hotel.bellboy.asked_room != 11 else 12
	hotel.bellboy.suitcase.global_position = hotel.to_global(Hotel.room_middle(other) + Vector3(0, 0.3, 0))
	await wait_physics_frames(2)
	hotel.bellboy.suitcase.global_position = hotel.to_global(Vector3(10.0, 0.3, 2.0))
	await wait_physics_frames(2)
	assert_true(hotel.bellboy.offended, "dropped down the stairs")


func test_the_guest_book_signature_and_signing_over_it() -> void:
	TranslationServer.set_locale("es")
	var made := _hotel_case(["signature"])
	var hotel: Hotel = made[0]
	var case: CrimeSceneCase = made[1]
	var lines := hotel.book.photo_clues()
	assert_eq(lines.size(), 1)
	assert_string_contains(lines.keys()[0], "firma")
	hotel.book.use(made[2])
	assert_has(case.ruined, "signature")
	assert_eq(hotel.book.photo_clues(), {})


func test_the_bell_wakes_the_concierge_and_too_much_makes_him_angry() -> void:
	var made := _hotel_case([])
	var hotel: Hotel = made[0]
	for i in HotelSceneBell.TOO_MANY:
		hotel.bell.use(made[2])
		assert_eq(hotel.concierge.angry_left, 0.0)
	assert_ne(hotel.concierge.said(), "", "awake, he says who sleeps where")
	hotel.bell.use(made[2])
	assert_gt(hotel.concierge.angry_left, 0.0)
	hotel.concierge.use(made[2])
	assert_eq(hotel.concierge.said(), "HOTEL_CONCIERGE_ANGRY")
	hotel.concierge._physics_process(HotelSceneBell.ANGRY_SECONDS + 1.0)
	hotel.concierge.use(made[2])
	assert_ne(hotel.concierge.said(), "HOTEL_CONCIERGE_ANGRY")
