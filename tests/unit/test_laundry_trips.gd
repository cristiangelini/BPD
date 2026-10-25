extends GutTest

## The laundry's truck, the carts pushed to it, checking them and the inmates under the sheets
## (carcel-lavanderia.md, step 3).

const LEVEL := preload("res://scenes/levels/prison_laundry.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: LaundryPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.laundry


func _at(x: float, z: float) -> Vector3:
	return prison.global_transform * Vector3(x, PrisonLevel.FLOOR_TOP + 0.1, z)


func _local(node: Node3D) -> Vector2:
	var at := prison.global_transform.affine_inverse() * node.global_position
	return Vector2(at.x, at.z)


func _cart(hidden: bool) -> LaundryCart:
	for cart in plan.carts:
		if cart.hidden == hidden:
			return cart
	return null


## The cop right by `cart`.
func _cop_by(cart: LaundryCart) -> void:
	var spot := _local(cart)
	cop.global_position = _at(spot.x + 0.9, spot.y)


func test_the_truck_comes_after_the_start_and_sends_three_pushers() -> void:
	plan.start()
	assert_false(plan.truck.here)
	plan.next_trip_in = 0.05
	await wait_physics_frames(6)
	assert_eq(plan.trip_now, 0)
	assert_true(plan.truck.here)
	var pushers := plan.workers.filter(func(worker: LaundryWorker) -> bool: return worker.cart != null)
	assert_eq(pushers.size(), LaundryPlan.PER_TRIP)
	for worker: LaundryWorker in pushers:
		assert_eq(worker.cart.trip, 0)
		assert_eq(worker.job, LaundryWorker.Job.TO_CART)
	assert_almost_eq(plan.next_trip_in, LaundryPlan.TRIP_EVERY, 0.5)


func test_the_pusher_pulls_the_cart_out_and_pushes_it_ahead() -> void:
	plan.start()
	var cart := plan.carts[0]
	var worker := plan.workers[0]
	worker.fetch(cart)
	var spot := LaundryPlan.cart_spot(cart.index)
	worker.global_position = _at(LaundryPlan.AISLE_X, spot.y + LaundryWorker.CART_AHEAD)
	worker._next = worker.route.size() - 1
	await wait_physics_frames(4)
	assert_eq(worker.job, LaundryWorker.Job.PUSH)
	await wait_physics_frames(90)
	assert_almost_eq(_local(cart).x, LaundryPlan.AISLE_X, 0.2, "out in the aisle")
	assert_lt(_local(cart).y, spot.y - 0.3, "pushed down the aisle")
	assert_almost_eq(cart.global_position.distance_to(worker.global_position), LaundryWorker.CART_AHEAD, 0.15)


func test_a_cart_at_the_truck_goes_up_the_ramp_and_the_pusher_heads_back() -> void:
	plan.start()
	var cart := _cart(false)
	var worker := plan.workers[0]
	worker.fetch(cart)
	worker._at_cart()
	var route := LaundryPlan.push_route()
	worker.global_position = _at(route[-1].x, route[-1].y - 0.1)
	worker._next = route.size() - 1
	await wait_physics_frames(40)
	assert_true(cart.loaded)
	assert_false(cart.visible)
	assert_eq(worker.job, LaundryWorker.Job.BACK)
	assert_eq(plan.escaped, 0, "only sheets")


func test_a_cart_up_the_ramp_with_someone_under_the_sheets_is_an_escape() -> void:
	var cart := _cart(true)
	cart.load_up()
	assert_eq(plan.escaped, 1)


func test_the_truck_leaves_once_its_carts_are_up() -> void:
	plan.start()
	plan.start_trip()
	var trip_carts := plan.carts_on_trip(0)
	for i in trip_carts.size() - 1:
		trip_carts[i].load_up()
	assert_true(plan.truck.here)
	trip_carts[-1].load_up()
	assert_false(plan.truck.here)
	assert_false(plan.is_over)


func test_the_day_is_over_after_the_last_trip() -> void:
	watch_signals(plan)
	plan.start()
	for trip in LaundryPlan.TRIPS:
		plan.start_trip()
		for cart in plan.carts_on_trip(trip):
			cart.load_up()
	assert_true(plan.is_over)
	assert_signal_emitted(plan, "ended")


func test_digging_through_a_cart_lets_out_who_hides_there() -> void:
	plan.start()
	var cart := _cart(true)
	_cop_by(cart)
	await wait_physics_frames(1)
	cart.use(cop)
	assert_eq(cart.prompt_key(cop), "PROMPT_CART_CHECKED")
	await wait_seconds(LaundryCart.CHECK_TIME + 0.2)
	assert_true(cart.checked)
	assert_false(cart.hidden)
	assert_eq(plan.found, 1)
	assert_eq(plan.runners.size(), 1)
	assert_true(plan.runners[0].active)
	assert_eq(plan.runners[0].route[-1], LaundryPlan.GATE)


func test_digging_through_an_empty_cart_finds_only_sheets() -> void:
	plan.start()
	var cart := _cart(false)
	_cop_by(cart)
	await wait_physics_frames(1)
	cart.use(cop)
	await wait_seconds(LaundryCart.CHECK_TIME + 0.2)
	assert_true(cart.checked)
	assert_eq(plan.found, 0)
	assert_true(plan.runners.is_empty())


func test_walking_away_stops_the_digging() -> void:
	var cart := _cart(true)
	_cop_by(cart)
	await wait_physics_frames(1)
	cart.use(cop)
	cop.global_position = _at(0, 15)
	await wait_seconds(LaundryCart.CHECK_TIME + 0.2)
	assert_false(cart.checked)
	assert_true(cart.hidden)


func test_knocking_a_cart_over_spills_who_hides_there() -> void:
	var cart := _cart(true)
	_cop_by(cart)
	assert_true(cart.ask(cop))
	assert_true(cart.tipped)
	assert_eq(plan.found, 1)
	assert_false(cart.ask(cop), "already over")
	await wait_seconds(LaundryCart.TIP_TIME + 0.1)
	assert_lt(cart.global_basis.y.dot(prison.global_basis.y), 0.2, "on its side")
	cart.set_upright()
	await wait_seconds(LaundryCart.TIP_TIME + 0.1)
	assert_gt(cart.global_basis.y.dot(prison.global_basis.y), 0.95, "back on its wheels")


func test_a_runner_through_the_gate_is_an_escape() -> void:
	plan.start()
	var cart := _cart(true)
	cart.tip(1.0)
	var runner := plan.runners[0]
	runner.global_position = _at(0, PrisonLevel.HALF_Z - 1.0)
	runner.route = [LaundryPlan.GATE]
	await wait_seconds(1.0)
	assert_true(runner.is_escaped)
	assert_eq(plan.escaped, 1)


func test_the_way_to_the_gate_from_anywhere() -> void:
	for at: Vector2 in [Vector2(9.0, 4.2), Vector2(5.0, PrisonLevel.KITCHEN_DOOR_Z), Vector2(3.2, 2.0),
			Vector2(2.0, 9.0), Vector2(1.0, 16.0)]:
		var route := LaundryPlan.escape_route(at)
		assert_eq(route[-1], LaundryPlan.GATE, "from %s" % at)
		assert_gt(route.size(), 1)
