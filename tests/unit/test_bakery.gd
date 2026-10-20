extends GutTest

## The bakery "El Pan Feliz" (docs/diseno/panaderia.md, step 1): the place itself, on its lot in the city.

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")
const TICK := 1.0 / 60.0


func _bakery() -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = "ring"
	bakery.get_node("Cop").input_enabled = false
	add_child_autofree(bakery)
	return bakery


func test_twelve_spots_inside_the_building_each_on_a_surface() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_eq(Bakery.SPOTS.size(), 12)
	var space := bakery.get_world_3d().direct_space_state
	for spot: Dictionary in Bakery.SPOTS:
		var at: Vector3 = spot.at
		assert_true(absf(at.x) < Bakery.HALF_X and absf(at.z) < Bakery.HALF_Z, "%s is inside the bakery" % spot.id)
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2, 1)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)


func test_the_shop_is_open_and_the_bakehouse_and_back_door_are_locked() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_true(bakery.bakehouse_door.locked)
	assert_true(bakery.back_door.locked)
	# Nothing stands in the open entrance from the street into the shop.
	var space := bakery.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(Vector3(Bakery.ENTRANCE_X, 1.0, Bakery.HALF_Z + 2),
		Vector3(Bakery.ENTRANCE_X, 1.0, Bakery.HALF_Z - 2))
	assert_true(space.intersect_ray(query).is_empty(), "the shop entrance is open")


func test_the_bakery_sits_on_its_lot_and_the_car_starts_at_the_station() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var city: Node3D = bakery.get_node("City")
	var lot := CityLayout.place("bakery")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the bakery is at the origin of its scene")
	assert_lt(bakery.car.global_position.distance_to(bakery.station_parking.origin), 0.2)
	assert_lt(bakery.get_node("Cop").global_position.distance_to(bakery.car.global_position), 20.0,
		"the cop starts in the station, by the car out front")
	assert_eq(bakery.city_map.target, "bakery")


func test_cop_walks_up_to_martas_flat() -> void:
	var bakery := _bakery()
	var cop: Cop = bakery.get_node("Cop")
	cop.global_position = Vector3(Bakery.STAIR_X, Bakery.FLOOR_TOP + 0.1, Bakery.STAIR_FOOT + 0.5)
	for i in 20:
		cop.step(TICK, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	for i in 150:
		cop.step(TICK, Vector2(0, -1), false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.y, GameScale.FLOOR_HEIGHT - 0.1, "the cop reaches the upper floor")


func test_a_customer_walks_in_gets_served_and_walks_out() -> void:
	var bakery := _bakery()
	bakery._customer_wait = 999.0
	await wait_physics_frames(2)
	var customer := bakery.add_customer()
	await wait_until(func() -> bool: return customer.state == BakeryCustomer.State.WAITING, 20.0)
	assert_eq(customer.state, BakeryCustomer.State.WAITING, "the customer reaches the counter")
	assert_true(bakery.baker.is_serving(), "Marta goes to the till")
	await wait_until(func() -> bool: return bakery.customers.is_empty(), 40.0)
	assert_true(bakery.customers.is_empty(), "served, the customer walks back out and is gone")
	assert_eq(bakery.baker.complaint, 0.0, "a paying customer doesn't bother her")


func test_marta_guards_the_bakehouse_door_when_nobody_is_waiting() -> void:
	var bakery := _bakery()
	bakery._customer_wait = 999.0
	await wait_physics_frames(30)
	assert_lt(bakery.baker.global_position.distance_to(bakery.baker.door_post), 0.3)
	assert_false(bakery.baker.is_serving())


func test_a_scare_sends_everyone_out_without_paying_and_raises_the_complaint() -> void:
	var bakery := _bakery()
	bakery._customer_wait = 999.0
	await wait_physics_frames(2)
	var first := bakery.add_customer()
	var second := bakery.add_customer()
	await wait_physics_frames(60)
	bakery.scare_customers()
	assert_eq(first.state, BakeryCustomer.State.FLEEING)
	assert_eq(second.state, BakeryCustomer.State.FLEEING)
	assert_eq(bakery.baker.complaint, Baker.CUSTOMER_FLED * 2)
	assert_true(bakery.baker.queue.is_empty())
	assert_eq(bakery._customer_wait, Bakery.SCARE_PAUSE, "no one comes in for a while")


func test_the_sample_calms_marta_and_keeps_the_cops_hands_busy() -> void:
	var bakery := _bakery()
	bakery._customer_wait = 999.0
	var cop: Cop = bakery.get_node("Cop")
	cop.global_position = bakery.baker.door_post + Vector3(0, 0.1, 1.8)
	await wait_physics_frames(2)
	bakery.baker.struck()
	bakery.baker._sample_wait = 0.0
	await wait_physics_frames(3)
	assert_true(bakery.baker.offering)
	assert_eq(bakery.baker.prompt_key(cop), "PROMPT_SAMPLE")
	bakery.baker.use(cop)
	assert_eq(bakery.baker.complaint, Baker.STRUCK - Baker.SAMPLE_CALM)
	assert_true(cop.is_eating())
	assert_false(cop.get_node("Grabber").try_grab(), "no grabbing while eating")


func test_forty_loaves_and_one_hides_the_ring_drawn_from_the_seed() -> void:
	var first := _bakery_with_seed(42)
	await wait_physics_frames(2)
	assert_eq(first.loaves.size(), 40)
	var filled := first.loaves.filter(func(loaf: Bread) -> bool: return loaf.filling != null)
	assert_eq(filled.size(), 1, "only one loaf hides something")
	assert_eq(filled[0].filling, first.ring)
	assert_gt(filled[0].mass, first.loaves[(first.ring_loaf + 1) % 40].mass, "the ring loaf weighs more")
	var again := _bakery_with_seed(42)
	await wait_physics_frames(2)
	assert_eq(again.ring_loaf, first.ring_loaf, "same seed, same loaf")
	assert_eq(again.hidden_spots, first.hidden_spots, "same seed, same spots for the extras")


func test_pulling_the_ring_loaf_apart_drops_the_ring_and_costs_a_fine() -> void:
	var bakery := _bakery_with_seed(7)
	await wait_physics_frames(5)
	var loaf: Bread = bakery.loaves[bakery.ring_loaf]
	var across := loaf.global_basis.x
	for i in 30:
		if not is_instance_valid(loaf):
			break
		loaf.hold(1, loaf.global_position + across * 0.7)
		loaf.hold(2, loaf.global_position - across * 0.7)
		await wait_physics_frames(1)
	assert_false(is_instance_valid(loaf), "two hands pulling the ends split it")
	assert_true(bakery.ring.is_inside_tree(), "the ring drops out")
	await wait_physics_frames(40)
	assert_eq(bakery.ring.value, 1000.0, "a gold ring survives the fall")
	assert_eq(bakery.fines, Bread.FINE)
	assert_eq(bakery.broken_goods, 1)


func test_carrying_a_loaf_around_does_not_split_it() -> void:
	var bakery := _bakery_with_seed(7)
	await wait_physics_frames(5)
	var loaf: Bread = bakery.loaves[(bakery.ring_loaf + 1) % 40]
	var point := loaf.global_position + Vector3.UP * 0.5
	for i in 90:
		point += Vector3(GameScale.RUN_SPEED / 60.0, 0, 0)
		loaf.hold(1, point)
		await wait_physics_frames(1)
	assert_true(is_instance_valid(loaf) and not loaf.is_broken, "running with it is fine")
	assert_eq(bakery.fines, 0)


func test_a_hard_throw_squashes_a_loaf() -> void:
	var bakery := _bakery_with_seed(7)
	await wait_physics_frames(5)
	var loaf: Bread = bakery.loaves[(bakery.ring_loaf + 2) % 40]
	loaf.global_position = Vector3(0, 1.0, 5.0)
	loaf.linear_velocity = Vector3(0, -8, 0)
	await wait_physics_frames(20)
	assert_false(is_instance_valid(loaf), "it hit the floor too hard")
	assert_eq(bakery.fines, Bread.FINE)


func test_the_till_has_the_bakehouse_key_and_marta_sees_it_opened() -> void:
	var bakery := _bakery_with_seed(7)
	bakery._customer_wait = 999.0
	var cop: Cop = bakery.get_node("Cop")
	await wait_physics_frames(30)
	assert_eq(bakery.till.prompt_key(cop), "PROMPT_TILL")
	bakery.till.use(cop)
	assert_true(cop.has_key)
	assert_eq(bakery.baker.complaint, Baker.SAW_TILL, "she was watching from the bakehouse door")
	bakery.bakehouse_door.use(cop)
	assert_false(bakery.bakehouse_door.locked, "the key opens the bakehouse")


func test_the_extras_wait_at_their_spots() -> void:
	var bakery := _bakery_with_seed(11)
	await wait_physics_frames(30)
	for i in bakery.extras.size():
		var spot: Vector3 = Bakery.SPOTS[bakery.hidden_spots[i]].at
		var item := bakery.extras[i]
		assert_lt(Vector2(item.global_position.x - spot.x, item.global_position.z - spot.z).length(), 0.1)
		assert_gt(item.global_position.y, spot.y, "%s rests on its spot" % item.name)


func _bakery_with_seed(case_seed: int) -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = "ring"
	bakery.case_seed = case_seed
	bakery.get_node("Cop").input_enabled = false
	add_child_autofree(bakery)
	return bakery
