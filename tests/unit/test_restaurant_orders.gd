extends GutTest

## The Chef Flambé's orders (infiltracion-restaurante.md, step 4, decision 174): he shouts an order and hangs it on the
## rail, the dish goes on the pass's counter and the bell sends it out; right, "¡Eso!"; wrong, raw, burnt or late, the
## cooks who see the kitchen get suspicious.

const LEVEL := preload("res://scenes/levels/restaurant_hall.tscn")

var hall: RestaurantHall
var cop: Cop


func before_each() -> void:
	hall = LEVEL.instantiate()
	cop = hall.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)


func _item(kind: String, vessel: String, cooked: float, burnt := false) -> Dictionary:
	return {"kind": kind, "cooked": cooked, "burnt": burnt, "in": vessel}


## Plate0 on the pass's counter with `items`.
func _plate_on_pass(items: Array[Dictionary]) -> KitchenVessel:
	var plate: KitchenVessel = hall.get_node("Plate0")
	plate.freeze = true
	plate.global_position = hall.global_transform * Vector3(-4.0, RestaurantHall.FLOOR_TOP + RestaurantHall.PASS_COUNTER
		+ 0.05, RestaurantHall.PASS_Z)
	plate.items.assign(items)
	return plate


func _cooks_suspicion() -> float:
	var total := 0.0
	for member in hall.members:
		if member.look.begins_with("cocin"):
			total += member.suspicion
	return total


func test_the_recipes_judge_the_plate() -> void:
	var soup: Array[Dictionary] = [_item("tomato", "pot", 6.5), _item("onion", "pot", 6.5)]
	assert_eq(RestaurantOrders.judge("soup", soup), "good")
	var raw_soup: Array[Dictionary] = [_item("tomato", "pot", 2.0), _item("onion", "pot", 2.0)]
	assert_eq(RestaurantOrders.judge("soup", raw_soup), "raw")
	var salad: Array[Dictionary] = [_item("lettuce", "", 0.0), _item("tomato", "", 0.0)]
	assert_eq(RestaurantOrders.judge("salad", salad), "good")
	assert_eq(RestaurantOrders.judge("soup", salad), "wrong", "a salad isn't a soup")
	var fish: Array[Dictionary] = [_item("fish", "pan", 9.0, true)]
	assert_eq(RestaurantOrders.judge("fish", fish), "burnt")
	var pasta: Array[Dictionary] = [_item("pasta", "pot", 5.5), _item("tomato", "", 0.0)]
	assert_eq(RestaurantOrders.judge("pasta", pasta), "good")
	var extra: Array[Dictionary] = [_item("fish", "pan", 5.0), _item("onion", "", 0.0)]
	assert_eq(RestaurantOrders.judge("fish", extra), "wrong", "something extra")
	var boiled_fish: Array[Dictionary] = [_item("fish", "pot", 5.0)]
	assert_eq(RestaurantOrders.judge("fish", boiled_fish), "wrong", "fried, not boiled")


func test_the_first_order_comes_in_and_hangs_on_the_rail() -> void:
	assert_true(hall.orders.orders.is_empty())
	hall.orders.next_left = 0.01
	await wait_process_frames(2)
	assert_eq(hall.orders.orders.size(), 1)
	assert_almost_eq(hall.orders.next_left, RestaurantOrders.EVERY, 0.5, "the next one in 40 s")
	var dish: String = hall.orders.orders[0].dish
	assert_true(RestaurantOrders.DISHES.has(dish))
	assert_string_contains(hall.orders._rail.text, tr(RestaurantOrders.dish_key(dish)))
	assert_ne(hall.chef.said(), "", "the Chef shouts it")


func test_the_same_seed_orders_the_same_dishes() -> void:
	var other: RestaurantHall = LEVEL.instantiate()
	other.case_seed = hall.case_seed
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in 3:
		hall.orders.order()
		other.orders.order()
	# The third call brings the special soup instead of an order (the restaurant case).
	assert_eq(other.orders.orders.size(), hall.orders.orders.size())
	assert_gt(hall.orders.orders.size(), 1)
	for i in hall.orders.orders.size():
		assert_eq(other.orders.orders[i].dish, hall.orders.orders[i].dish)


func test_a_right_dish_at_the_pass_is_served() -> void:
	hall.orders.order("salad")
	var plate := _plate_on_pass([_item("lettuce", "", 0.0), _item("tomato", "", 0.0)])
	assert_eq(hall.plates_on_pass(), [plate] as Array[KitchenVessel])
	watch_signals(hall.orders)
	hall.bell.use(cop)
	assert_signal_emitted_with_parameters(hall.orders, "served", ["salad"])
	assert_true(hall.orders.orders.is_empty())
	assert_true(plate.items.is_empty(), "a waiter took it")
	assert_eq(hall.chef.said(), "FLAMBE_GOOD")
	assert_eq(_cooks_suspicion(), 0.0)


func test_the_right_order_is_found_even_if_it_isnt_the_oldest() -> void:
	hall.orders.order("soup")
	hall.orders.order("fish")
	_plate_on_pass([_item("fish", "pan", 5.0)])
	hall.bell.use(cop)
	assert_eq(hall.orders.orders.size(), 1)
	assert_eq(hall.orders.orders[0].dish, "soup")


func test_a_wrong_dish_loses_the_order_and_the_cooks_notice() -> void:
	hall.orders.order("soup")
	_plate_on_pass([_item("tomato", "", 0.0)])
	watch_signals(hall.orders)
	hall.bell.use(cop)
	assert_signal_emitted_with_parameters(hall.orders, "failed", [RestaurantOrders.WRONG])
	assert_true(hall.orders.orders.is_empty())
	assert_eq(hall.chef.said(), "FLAMBE_WRONG")
	assert_gt(_cooks_suspicion(), 0.0, "the cooks in the kitchen saw it")
	for member in hall.members:
		if member.look == "mozo":
			assert_eq(member.suspicion, 0.0, "the waiters don't count")


func test_a_burnt_dish_is_worse() -> void:
	hall.orders.order("fish")
	_plate_on_pass([_item("fish", "pan", 9.0, true)])
	watch_signals(hall.orders)
	hall.bell.use(cop)
	assert_signal_emitted_with_parameters(hall.orders, "failed", [RestaurantOrders.BURNT])
	assert_eq(hall.chef.said(), "FLAMBE_BURNT")
	assert_gt(RestaurantOrders.BURNT, RestaurantOrders.WRONG)


func test_an_order_not_served_in_time_is_lost() -> void:
	hall.orders.order("pasta")
	hall.orders.orders[0].left = 0.01
	watch_signals(hall.orders)
	await wait_process_frames(2)
	assert_signal_emitted(hall.orders, "failed")
	assert_true(hall.orders.orders.is_empty())
	assert_eq(hall.chef.said(), "FLAMBE_LATE")


func test_the_bell_with_nothing_on_the_pass() -> void:
	hall.orders.order("soup")
	hall.bell.use(cop)
	assert_eq(hall.orders.orders.size(), 1, "the order is still there")
	assert_eq(hall.chef.said(), "FLAMBE_NO_DISH")
	assert_eq(hall.bell.prompt_key(cop), "PROMPT_PASS_BELL")


func test_a_cooked_soup_from_the_pot_makes_the_order() -> void:
	hall.orders.order("soup")
	var pot: KitchenVessel = hall.get_node("Pot0")
	pot.items.append(_item("tomato", "", 0.0))
	pot.items.append(_item("onion", "", 0.0))
	pot.cook(6.5)
	var plate := _plate_on_pass([])
	pot.freeze = true
	pot.global_position = plate.global_position + Vector3(0, 0.4, -0.3)
	pot.use(cop)
	hall.bell.use(cop)
	assert_true(hall.orders.orders.is_empty())
	assert_eq(hall.chef.said(), "FLAMBE_GOOD")


func test_the_order_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["FLAMBE_ORDER", "FLAMBE_HURRY", "FLAMBE_GOOD", "FLAMBE_WRONG", "FLAMBE_RAW",
		"FLAMBE_BURNT", "FLAMBE_LATE", "FLAMBE_NO_DISH", "FLAMBE_NO_ORDER", "HINT_PASS_EMPTY", "PROMPT_PASS_BELL",
		"HUD_ORDERS"]
	for dish in RestaurantOrders.DISHES:
		keys.append(RestaurantOrders.dish_key(dish))
	for key in keys:
		assert_ne(tr(key), key)
	assert_string_contains(tr("FLAMBE_ORDER"), "%s")
