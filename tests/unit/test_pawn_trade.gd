extends GutTest

## The pawn shop's counter and customers (docs/diseno/allanamiento-empenos.md, step 2): what a cop leaves on the
## counter is pawned or bought, what leaves unpaid is taken, and the customers take turns at the counter and complain.

const SCENE := preload("res://scenes/levels/pawn_shop.tscn")
const EVIDENCE_SCENE := preload("res://scenes/props/account_book.tscn")


func _shop(case_seed := 5) -> PawnShop:
	var place: PawnShop = SCENE.instantiate()
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	return place


func _on_counter(place: PawnShop, item: Grabbable) -> void:
	item.linear_velocity = Vector3.ZERO
	item.global_position = place.to_global(PawnShop.COUNTER_AT + Vector3(-1.0, PawnShop.COUNTER_SIZE.y + 0.15, 0))


func test_the_shop_goods_are_for_sale_on_the_cases() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	assert_eq(place.goods.size(), 3)
	for i in place.goods.size():
		assert_eq(place.counter.for_sale[place.goods[i]], PawnShop.GOODS[i].price)
		assert_not_null(place.goods[i].get_node_or_null("PriceTag"))


func test_evidence_left_on_the_counter_is_pawned_and_put_up_for_sale() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var evidence: Evidence = EVIDENCE_SCENE.instantiate()
	place.add_child(evidence)
	await wait_physics_frames(1)
	_on_counter(place, evidence)
	await wait_seconds(PawnCounter.TAKE_AFTER + 0.6)
	var price := PawnCounter.appraise(evidence)
	assert_eq(price, roundi(evidence.value * PawnCounter.EVIDENCE_SHARE))
	assert_eq(place.counter.cash_out, price, "the shop paid for it")
	assert_eq(place.counter.for_sale.get(evidence), price * PawnCounter.MARKUP, "for sale at twice that")
	var at := place.to_local(evidence.global_position)
	assert_almost_eq(at.y, PawnShop.FLOOR_TOP + PawnShop.CASE_SIZE.y, 0.4, "on show on a glass case")
	assert_almost_eq(at.z, PawnShop.CASES[0].z, 0.5)


func test_something_for_sale_left_on_the_counter_is_bought_once() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var radio := place.goods[1]
	_on_counter(place, radio)
	await wait_seconds(PawnCounter.TAKE_AFTER + 0.6)
	assert_eq(place.counter.spent, PawnShop.GOODS[1].price)
	assert_false(place.counter.for_sale.has(radio))
	assert_true(place.counter.paid.has(radio))
	await wait_seconds(PawnCounter.TAKE_AFTER + 0.6)
	assert_eq(place.counter.spent, PawnShop.GOODS[1].price, "it's the cops' now: not sold or pawned again")
	assert_eq(place.counter.cash_out, 0)


func test_something_for_sale_out_the_door_unpaid_is_taken() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	watch_signals(place.counter)
	var clock := place.goods[2]
	clock.global_position = place.to_global(Vector3(0, 0.5, PawnShop.HALF_Z + 2.0))
	await wait_physics_frames(3)
	assert_signal_emitted_with_parameters(place.counter, "taken", [clock])
	assert_false(place.counter.for_sale.has(clock))


func test_customers_take_turns_at_the_counter() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	await wait_seconds(PawnShop.FIRST_TURN + 4 * PawnCustomer.STRETCH + 0.5)
	var first := place.customers[0]
	assert_true(first.haggling, "haggling at the counter")
	assert_almost_eq(first.position.distance_to(PawnShop.COUNTER_SPOT), 0.0, 0.05)
	assert_false(place.customers[1].on_turn, "one at a time")


func test_a_cop_at_the_counter_makes_the_customer_complain() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	watch_signals(place)
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(PawnShop.COUNTER_SPOT + Vector3(0, 0.1, 0))
	await wait_seconds(PawnShop.FIRST_TURN + 4 * PawnCustomer.STRETCH + 0.5)
	assert_signal_emitted(place, "customer_complained")
	assert_false(place.customers[0].haggling)


func test_a_glass_case_breaking_near_a_customer_makes_them_complain() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	watch_signals(place)
	place.break_case(0)
	assert_signal_emitted(place, "customer_complained", "the first customer browses right behind it")
	assert_eq(place.customers[0].said(), "PAWN_CUSTOMER_CRASH")
