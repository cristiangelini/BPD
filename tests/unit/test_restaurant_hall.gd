extends GutTest

## The restaurant "La Cuchara de Oro" (infiltracion-restaurante.md, step 2, decision 174): on its own city lot, the
## dining room open to anyone, the kitchen behind the pass where the maître only lets cooks through, and the pantry,
## the walk-in fridge and the Chef's locked office; the cooks and waiters of the gang, and the Chef Flambé at the pass.

const LEVEL := preload("res://scenes/levels/restaurant_hall.tscn")

var hall: RestaurantHall


func before_each() -> void:
	hall = LEVEL.instantiate()
	hall.get_node("Cop").input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)


func _at(x: float, z: float) -> Vector3:
	return hall.global_transform * Vector3(x, 1.0, z)


func test_it_is_on_its_own_lot_and_play_can_open_it() -> void:
	var lot: Dictionary = CityLayout.place("restaurant")
	assert_false(lot.is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=restaurant"])), "restaurant")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["restaurant"]))
	assert_almost_eq(lot.size.x, RestaurantHall.HALF_X * 2, 0.01, "as wide as its lot")
	assert_almost_eq(lot.size.z, RestaurantHall.HALF_Z * 2, 0.01, "and as deep")


func test_it_is_the_restaurant_infiltration_place() -> void:
	assert_true(hall is InfiltrationPlace)
	assert_eq(hall.variant, "restaurant")


func test_the_rooms_are_where_they_say() -> void:
	assert_true(hall.in_dining(_at(0.0, 6.0)))
	assert_false(hall.in_staff_area(_at(0.0, 6.0)), "the dining room is open to anyone")
	assert_true(hall.in_kitchen(_at(0.0, -1.0)))
	assert_true(hall.in_staff_area(_at(0.0, -1.0)))
	assert_true(hall.in_pantry(_at(-8.0, -7.0)))
	assert_true(hall.in_fridge(_at(0.0, -7.0)))
	assert_true(hall.in_back_room(_at(8.0, -7.0)), "the office at the back east")
	assert_false(hall.in_kitchen(_at(8.0, -7.0)))


func test_the_office_is_locked() -> void:
	assert_true(hall.office_door.locked)


func test_cooks_in_the_kitchen_and_waiters_in_the_dining_room() -> void:
	assert_eq(hall.members.size(), RestaurantHall.COOKS + RestaurantHall.WAITERS)
	var cooks := hall.members.filter(func(member: ClubMember) -> bool: return member.look.begins_with("cocin"))
	var waiters := hall.members.filter(func(member: ClubMember) -> bool: return member.look == "mozo")
	assert_eq(cooks.size(), RestaurantHall.COOKS)
	assert_eq(waiters.size(), RestaurantHall.WAITERS)
	for cook: ClubMember in cooks:
		assert_true(hall.in_kitchen(cook.global_position + Vector3.UP), "a cook in the kitchen")
	for waiter: ClubMember in waiters:
		assert_true(hall.in_dining(waiter.global_position + Vector3.UP), "a waiter in the dining room")
	assert_eq(hall.free_spots.size(), RestaurantHall.COOK_SPOTS.size() - RestaurantHall.COOKS, "spots for the cops")


func test_the_same_seed_puts_the_same_staff() -> void:
	var other: RestaurantHall = LEVEL.instantiate()
	other.case_seed = hall.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in hall.members.size():
		assert_eq(other.members[i].position, hall.members[i].position)
		assert_eq(other.members[i].look, hall.members[i].look)


func test_the_chef_is_the_boss_at_the_pass_looking_at_the_kitchen() -> void:
	assert_eq(hall.boss, hall.chef)
	assert_true(hall.chef.is_boss())
	assert_true(hall.in_kitchen(hall.chef.global_position + Vector3.UP))
	assert_lt((-hall.chef.global_basis.z).dot(hall.global_basis.z), -0.99, "looking at the kitchen (-Z)")


func test_cooks_gossip_and_the_chef_has_his_own_lines() -> void:
	var cop: Cop = hall.get_node("Cop")
	hall.members[0].use(cop)
	assert_true(hall.members[0].said().begins_with("RESTAURANT_GOSSIP_"))
	hall.chef.use(cop)
	assert_true(hall.chef.said().begins_with("FLAMBE_"))


func test_the_staff_watch_for_cooks_in_the_kitchen_only() -> void:
	assert_eq(hall.suspicion.disguise_look, "chef")
	assert_eq(hall.suspicion.prefix, "RESTAURANT_")
	assert_eq(hall.suspicion.boss_found_out, "FLAMBE_FOUND_OUT")
	assert_true(hall.suspicion.inside.call(_at(0.0, -1.0)), "the kitchen counts")
	assert_false(hall.suspicion.inside.call(_at(0.0, 6.0)), "the dining room doesn't")


## A cop walking from the dining room into the kitchen door.
func _walk_in(cop: Cop) -> void:
	cop.global_position = hall.global_transform * Vector3(RestaurantHall.KITCHEN_DOOR_X, 0.1, RestaurantHall.PASS_Z + 1.0)
	cop.global_rotation.y = hall.global_rotation.y
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		hall.doorman._physics_process(1.0 / 60.0)


func test_the_maitre_wants_a_cook() -> void:
	var cop: Cop = hall.get_node("Cop")
	cop.put_on_disguise("party_mustache", 0.0)
	await _walk_in(cop)
	assert_eq(hall.doorman.said(), "RESTAURANTDOOR_NO_1", "a party mustache isn't a cook")
	assert_gt((hall.global_transform.affine_inverse() * cop.global_position).z, RestaurantHall.PASS_Z - 0.3,
		"didn't get in")


func test_the_maitre_lets_a_cook_in() -> void:
	var cop: Cop = hall.get_node("Cop")
	cop.put_on_disguise("chef_hat", 0.0)
	cop.put_on_disguise("chef_apron", 0.0)
	await _walk_in(cop)
	assert_eq(hall.doorman.said(), "RESTAURANTDOOR_WELCOME")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = hall.get_node("Cop")
	var station := hall.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_restaurant_s_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["PLACE_RESTAURANT", "RESTAURANT_MENU", "PROMPT_TALK_COOK", "PROMPT_TALK_WAITER",
		"RESTAURANT_CUFFED", "PROMPT_TALK_FLAMBE", "FLAMBE_CUFFED", "FLAMBE_FOUND_OUT", "RESTAURANTDOOR_WELCOME",
		"RESTAURANTDOOR_NO_0", "RESTAURANTDOOR_NO_1", "HINT_RESTAURANTDOOR_NO_DISGUISE", "HUD_RESTAURANT_SUSPICION",
		"HINT_RESTAURANT_FOUND_OUT"]
	for i in 10:
		keys.append("RESTAURANT_GOSSIP_%d" % i)
	for i in 4:
		keys.append("FLAMBE_%d" % i)
	for i in 3:
		keys.append("RESTAURANT_FOUND_OUT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
