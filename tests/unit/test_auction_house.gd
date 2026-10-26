extends GutTest

## The auction house "El Martillo de Oro" (infiltracion-subasta.md, step 2, decision 177): on its own city lot,
## millionaires only past the doorman; the hall with Don Martillo behind his podium and the rows of chairs, the gallery
## with the paintings, the storeroom and his locked office; the buyers sitting or looking at the paintings, drawn with
## the seed.

const LEVEL := preload("res://scenes/levels/auction_house.tscn")

var house: AuctionHouse


func before_each() -> void:
	house = LEVEL.instantiate()
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	await wait_physics_frames(2)


func _at(x: float, z: float) -> Vector3:
	return house.global_transform * Vector3(x, 1.0, z)


func test_it_is_on_its_own_lot_and_play_can_open_it() -> void:
	var lot: Dictionary = CityLayout.place("auction")
	assert_false(lot.is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=auction"])), "auction")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["auction"]))
	assert_almost_eq(lot.size.x, AuctionHouse.HALF_X * 2, 0.01, "as wide as its lot")
	assert_almost_eq(lot.size.z, AuctionHouse.HALF_Z * 2, 0.01, "and as deep")


func test_it_is_the_auction_infiltration_place() -> void:
	assert_true(house is InfiltrationPlace)
	assert_eq(house.variant, "auction")


func test_the_rooms_are_where_they_say() -> void:
	assert_true(house.in_hall(_at(-4.0, 5.0)))
	assert_true(house.in_gallery(_at(8.0, 5.0)))
	assert_true(house.in_storeroom(_at(-4.0, -5.0)))
	assert_true(house.in_back_room(_at(8.0, -5.0)), "the office behind the gallery")
	assert_false(house.in_hall(_at(8.0, -5.0)))


func test_the_office_is_locked() -> void:
	assert_true(house.office_door.locked)


func test_the_buyers_are_drawn_with_the_seed() -> void:
	assert_eq(house.members.size(), AuctionHouse.BUYERS)
	for member: ClubMember in house.members:
		assert_true(member.look in ["comprador", "compradora"])
		assert_true(house.is_inside(member.global_position + Vector3.UP))
	var other: AuctionHouse = LEVEL.instantiate()
	other.case_seed = house.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in house.members.size():
		assert_eq(other.members[i].position, house.members[i].position)
		assert_eq(other.members[i].look, house.members[i].look)


func test_the_buyers_in_the_chairs_sit_facing_the_podium() -> void:
	var seated := 0
	for member: ClubMember in house.members:
		var flat := Vector3(member.position.x, 0, member.position.z)
		if AuctionHouse.CHAIRS.has(flat):
			seated += 1
			assert_almost_eq(member.position.y, AuctionHouse.FLOOR_TOP + AuctionHouse.SEAT, 0.01, "on the seat")
			assert_almost_eq((-member.global_basis.z).dot(-house.global_basis.z), 1.0, 0.01, "looking at the podium")
	assert_gt(seated, 0, "some of them in the chairs")


func test_don_martillo_is_the_boss_behind_his_podium() -> void:
	assert_eq(house.boss, house.martillo)
	assert_true(house.martillo.is_boss())
	assert_true(house.in_hall(house.martillo.global_position + Vector3.UP))
	assert_almost_eq((-house.martillo.global_basis.z).dot(house.global_basis.z), 1.0, 0.01, "facing the chairs")


func test_buyers_gossip_and_don_martillo_has_his_own_lines() -> void:
	var cop: Cop = house.get_node("Cop")
	house.members[0].use(cop)
	assert_true(house.members[0].said().begins_with("AUCTION_GOSSIP_"))
	house.martillo.use(cop)
	assert_true(house.martillo.said().begins_with("MARTILLO_"))


func test_the_whole_house_watches_for_millionaires() -> void:
	assert_eq(house.suspicion.disguise_look, "auction")
	assert_eq(house.suspicion.prefix, "AUCTION_")
	assert_eq(house.suspicion.boss_found_out, "MARTILLO_FOUND_OUT")
	assert_true(house.suspicion.inside.call(_at(-4.0, 5.0)), "the hall counts")
	assert_true(house.suspicion.inside.call(_at(-4.0, -5.0)), "and the storeroom")
	assert_false(house.suspicion.inside.call(_at(0.0, 14.0)), "the street doesn't")


## A cop walking in from the street.
func _walk_in(cop: Cop) -> void:
	cop.global_position = house.global_transform * Vector3(AuctionHouse.ENTRANCE_X, 0.1, AuctionHouse.HALF_Z + 1.0)
	cop.global_rotation.y = house.global_rotation.y
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		house.doorman._physics_process(1.0 / 60.0)


func test_the_doorman_wants_a_millionaire() -> void:
	var cop: Cop = house.get_node("Cop")
	cop.put_on_disguise("biker_beard", 0.0)
	await _walk_in(cop)
	assert_eq(house.doorman.said(), "AUCTIONDOOR_NO_1", "a biker's beard isn't a millionaire")
	assert_gt((house.global_transform.affine_inverse() * cop.global_position).z, AuctionHouse.HALF_Z - 0.3,
		"didn't get in")


func test_the_doorman_lets_a_millionaire_in() -> void:
	var cop: Cop = house.get_node("Cop")
	cop.put_on_disguise("auction_monocle", 0.0)
	cop.put_on_disguise("auction_top_hat", 0.0)
	await _walk_in(cop)
	assert_eq(house.doorman.said(), "AUCTIONDOOR_WELCOME")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = house.get_node("Cop")
	var station := house.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_auction_house_s_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PLACE_AUCTION", "PROMPT_TALK_AUCTION", "AUCTION_CUFFED", "PROMPT_TALK_MARTILLO",
		"MARTILLO_CUFFED", "MARTILLO_FOUND_OUT", "AUCTIONDOOR_WELCOME", "AUCTIONDOOR_NO_0", "AUCTIONDOOR_NO_1",
		"HINT_AUCTIONDOOR_NO_DISGUISE", "HUD_AUCTION_SUSPICION", "HINT_AUCTION_FOUND_OUT"]
	for i in 10:
		keys.append("AUCTION_GOSSIP_%d" % i)
	for i in 4:
		keys.append("MARTILLO_%d" % i)
	for i in 3:
		keys.append("AUCTION_FOUND_OUT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
