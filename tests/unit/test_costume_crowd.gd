extends GutTest

## The costume shop's mannequins and customers (docs/diseno/allanamiento-disfraces.md, step 2): 8 mannequins of 12 kg
## that fall like bowling pins, and 4 customers who take turns in the fitting rooms and complain when a cop is inside
## or a mannequin falls next to them.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(case_seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	return place


func test_eight_mannequins_stand_between_the_racks() -> void:
	var place := _shop()
	await wait_physics_frames(40)
	assert_eq(place.mannequins.size(), 8)
	for mannequin in place.mannequins:
		assert_eq(mannequin.mass, CostumeMannequin.KG)
		assert_true(mannequin.is_upright(), "%s stands" % mannequin.name)
		assert_false(mannequin.down)


func test_one_falling_knocks_the_next_over_like_pins() -> void:
	var place := _shop()
	await wait_physics_frames(20)
	var first := place.mannequins[0]
	watch_signals(place)
	first.knock(place.global_basis.x)
	await wait_physics_frames(150)
	assert_true(first.down, "the first one is on the floor")
	assert_true(place.mannequins[1].down, "and it took the next one with it")
	assert_signal_emitted(place, "mannequin_fell")


func test_a_mannequin_falling_next_to_a_customer_makes_them_complain() -> void:
	var place := _shop()
	await wait_physics_frames(20)
	var customer := place.customers[3]
	var mannequin := place.mannequins[6]
	mannequin.global_position = customer.global_position + place.global_basis.z
	watch_signals(place)
	mannequin.knock(place.global_basis.z)
	await wait_physics_frames(120)
	assert_true(mannequin.down)
	assert_eq(customer.complaints, 1)
	assert_eq(customer.said(), "COSTUME_CUSTOMER_CRUSH")
	assert_signal_emitted(place, "customer_complained")


func test_customers_take_turns_in_the_fitting_rooms() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	place._turn_left = 0.0
	await wait_physics_frames(2)
	assert_eq(place.on_turn, place.customers[0])
	assert_true(place.customers[0].on_turn)
	assert_false(place.customers[1].on_turn, "one at a time")
	var path := place.aisle_path(CostumeShop.CUSTOMER_HOMES[0], 0)
	assert_eq(path.back(), Vector3(CostumeShop.FITTING_X + 0.8, CostumeShop.FLOOR_TOP, CostumeShop.FITTING_Z[0]))


func test_a_customer_tries_a_costume_on_inside() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	place.on_turn = place.customers[1]
	var customer := place.customers[1]
	customer.on_turn = true
	customer.room = 1
	customer._at_curtain()
	await wait_seconds(CostumeCustomer.STRETCH + 0.3)
	assert_true(customer.trying)
	assert_eq(customer.position, place.fitting_inside(1))
	assert_eq(customer.complaints, 0)


func test_a_cop_in_the_fitting_room_makes_the_customer_complain() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(place.fitting_inside(2) + Vector3.UP * 0.1)
	await wait_physics_frames(2)
	assert_true(place.cop_in_fitting(2))
	assert_false(place.cop_in_fitting(0))
	var customer := place.customers[2]
	customer.on_turn = true
	customer.room = 2
	customer._at_curtain()
	assert_false(customer.trying)
	assert_eq(customer.complaints, 1)
	assert_eq(customer.said(), "COSTUME_CUSTOMER_BUSY")
