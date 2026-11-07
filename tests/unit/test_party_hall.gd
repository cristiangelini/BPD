extends GutTest

## The costume party's "Salón Gala" (infiltracion-fiesta.md, step 2, decision 171): its lot in the city, the dance
## floor, the photo steps with a spot for every guest and cop, the coat check, the restroom, the locked office and the
## cops starting at the station by the disguises; the guests in their costumes with the Sargento Trucho hidden among
## them, the señora Serpentina and the bouncer (step 2b).

const LEVEL := preload("res://scenes/levels/party_hall.tscn")

const SEED := 11

var hall: PartyHall


func before_each() -> void:
	hall = LEVEL.instantiate()
	# A fixed seed: some (79, 167, ...) draw her clue with no guest near her, and she tells it instead of chatting.
	hall.case_seed = SEED
	hall.get_node("Cop").input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)


func test_it_has_its_lot_and_play_can_open_it() -> void:
	assert_false(CityLayout.place("party_hall").is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=party"])), "party")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["party"]))


func test_it_is_the_party_infiltration_place() -> void:
	assert_true(hall is InfiltrationPlace)
	assert_eq(hall.variant, "party")


func test_the_photo_steps_have_room_for_everyone() -> void:
	assert_gte(hall.photo_spots.size(), PartyHall.MINGLE_SPOTS.size(), "a spot for each guest and cop")
	for spot: Vector3 in hall.photo_spots:
		assert_true(hall.on_steps(hall.global_transform * (spot + Vector3.UP * 0.1)), "up on the steps")
	assert_false(hall.on_steps(hall.global_transform * Vector3(0, 0.2, 0)), "the dance floor isn't")


func test_each_step_is_higher_than_the_one_in_front() -> void:
	var front := hall.photo_spots[0]
	var back := hall.photo_spots[hall.photo_spots.size() - 1]
	assert_lt(back.z, front.z)
	assert_almost_eq(back.y - front.y, PartyHall.STEP_RISE * (PartyHall.STEPS - 1), 0.001)


func test_the_mingle_spots_are_inside_and_clear_of_the_rooms() -> void:
	for spot: Vector3 in PartyHall.MINGLE_SPOTS:
		var at := hall.global_transform * (spot + Vector3.UP)
		assert_true(hall.is_inside(at))
		assert_false(hall.in_back_room(at) or hall.in_coat_check(at) or hall.in_restroom(at) or hall.on_steps(at),
			"%s is out in the hall" % spot)


func test_the_rooms_are_where_they_say() -> void:
	assert_true(hall.in_back_room(hall.global_transform * Vector3(9.0, 1.0, -8.5)), "the office at the back")
	assert_true(hall.in_coat_check(hall.global_transform * Vector3(-9.0, 1.0, 8.5)), "the coat check by the door")
	assert_true(hall.in_restroom(hall.global_transform * Vector3(10.0, 1.0, 8.5)), "and the restroom")
	assert_false(hall.in_back_room(hall.global_transform * Vector3(0, 1.0, 0)), "the dance floor isn't any")


func test_the_office_is_locked() -> void:
	assert_true(hall.office_door.locked)


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = hall.get_node("Cop")
	var station := hall.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_getaway_starts_on_the_street_out_of_the_entrance() -> void:
	var local := hall.global_transform.affine_inverse() * hall.getaway_at().origin
	assert_almost_eq(local.x, PartyHall.ENTRANCE_X, 0.01)
	assert_gt(local.z, PartyHall.HALF_Z + CityLayout.SIDEWALK, "past the sidewalk")


func test_the_sign_and_the_banner_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PLACE_PARTY_HALL", "PARTY_BANNER"]:
		assert_ne(tr(key), key)


func test_twelve_guests_mingle_and_one_of_them_is_the_boss() -> void:
	assert_eq(hall.members.size(), PartyHall.GUESTS)
	var bosses := 0
	for guest: ClubMember in hall.members:
		assert_true(guest.look.begins_with("invitado"))
		var flat := Vector3(guest.position.x, 0, guest.position.z)
		assert_true(PartyHall.MINGLE_SPOTS.any(func(at: Vector3) -> bool: return at.distance_to(flat) < 0.01),
			"on a mingle spot")
		bosses += int(guest.is_boss())
	assert_eq(bosses, 1, "only the Sargento Trucho")
	assert_true(hall.boss.is_boss())
	assert_eq(hall.suspicion.boss, hall.boss)


func test_each_guest_wears_their_costume() -> void:
	for i in hall.members.size():
		var worn := hall.guest_traits[i].values().filter(func(value: String) -> bool: return value != "none").size()
		assert_eq(hall.members[i].accessories.size(), worn)
	var boss_index := hall.members.find(hall.boss)
	var known := hall.guest_traits[boss_index].duplicate()
	known.erase("glasses")
	assert_eq(PartyTraits.matching(hall.guest_traits, known), [boss_index], "three bits point to him alone")


func test_the_same_seed_dresses_and_places_the_same_guests() -> void:
	var other: PartyHall = LEVEL.instantiate()
	other.case_seed = hall.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in hall.members.size():
		assert_eq(other.members[i].position, hall.members[i].position)
		assert_eq(other.guest_traits[i], hall.guest_traits[i])
	assert_eq(other.members.find(other.boss), hall.members.find(hall.boss))


func test_the_boss_talks_like_any_guest() -> void:
	var cop: Cop = hall.get_node("Cop")
	hall.boss.use(cop)
	assert_true(hall.boss.said().begins_with("PARTY_GOSSIP_"), "nothing gives him away but his costume")
	hall.serpentina.use(cop)
	assert_true(hall.serpentina.said().begins_with("SERPENTINA_"))
	assert_false(hall.serpentina.is_boss())
	assert_false(hall.members.has(hall.serpentina), "she isn't one of the gang")


func test_the_guests_watch_for_the_party_disguise() -> void:
	assert_eq(hall.suspicion.disguise_look, "party")
	assert_eq(hall.suspicion.prefix, "PARTY_")
	var cop: Cop = hall.get_node("Cop")
	assert_gt(hall.suspicion.offence(cop, 0.0), 0.0, "a cop in a real uniform is suspicious")
	cop.put_on_disguise("party_cap", 0.0)
	cop.put_on_disguise("party_badge", 0.0)
	assert_eq(hall.suspicion.offence(cop, 0.0), 0.0, "a party cop standing still isn't")


## A cop walking into the doorway from the sidewalk.
func _walk_in(cop: Cop) -> void:
	cop.global_position = hall.global_transform * Vector3(PartyHall.ENTRANCE_X, 0.1, PartyHall.HALF_Z + 1.0)
	cop.global_rotation.y = 0.0
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		hall.doorman._physics_process(1.0 / 60.0)


func test_the_bouncer_wants_a_party_cop() -> void:
	var cop: Cop = hall.get_node("Cop")
	await _walk_in(cop)
	assert_eq(hall.doorman.said(), "PARTYDOOR_NO_0", "a real uniform isn't a costume")
	var inside_z := (hall.global_transform.affine_inverse() * cop.global_position).z
	assert_gt(inside_z, PartyHall.HALF_Z - 0.5, "didn't get in")


func test_the_bouncer_lets_a_party_cop_in() -> void:
	var cop: Cop = hall.get_node("Cop")
	cop.put_on_disguise("party_mustache", 0.0)
	cop.put_on_disguise("party_cap", 0.0)
	await _walk_in(cop)
	assert_eq(hall.doorman.said(), "PARTYDOOR_WELCOME")


func test_the_party_people_s_lines_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PROMPT_TALK_GUEST", "PARTY_CUFFED", "PROMPT_TALK_SERPENTINA", "SERPENTINA_CUFFED",
		"PARTYDOOR_WELCOME", "PARTYDOOR_NO_0", "PARTYDOOR_NO_1", "HINT_PARTYDOOR_NO_DISGUISE", "HUD_PARTY_SUSPICION",
		"HINT_PARTY_FOUND_OUT", "TRUCHO_FOUND_OUT"]
	for i in 10:
		keys.append("PARTY_GOSSIP_%d" % i)
	for i in 4:
		keys.append("SERPENTINA_%d" % i)
	for i in ClubSuspicion.FOUND_OUT_LINES:
		keys.append("PARTY_FOUND_OUT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
