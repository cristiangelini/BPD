extends GutTest

## The supermarket's carts and customers (docs/diseno/allanamiento-super.md, step 2): a cart is pushed and loaded like
## the wheelbarrow, a crouched cop climbs into an empty one and rides along, flies out when it stops dead, and a
## customer whose cart gets bumped complains once every so often.

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const CRATE_SCENE := preload("res://scenes/props/crate.tscn")
const SUPER_SCENE := preload("res://scenes/levels/supermarket.tscn")
const TICK := 1.0 / 60.0


func _floor() -> void:
	var ground := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 1, 40)
	shape.shape = box
	shape.position.y = -0.5
	ground.add_child(shape)
	add_child_autofree(ground)


func _cop(at := Vector3(0, 0.1, 0)) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	cop.position = at
	add_child_autofree(cop)
	return cop


func _cart(at := Vector3.ZERO) -> ShoppingCart:
	var cart := ShoppingCart.new()
	add_child_autofree(cart)
	cart.global_position = at
	return cart


func _crouch(cop: Cop) -> void:
	for i in 20:
		cop.step(TICK, Vector2.ZERO, false, true, false)
		await wait_physics_frames(1)


func test_a_cart_is_pushed_and_loaded_like_the_wheelbarrow() -> void:
	_floor()
	var cop := _cop()
	var cart := _cart(Vector3(0, 0, -1.2))
	assert_eq(cart.prompt_key(cop), "PROMPT_CART_TAKE")
	cart.use(cop)
	assert_eq(cart.pusher, cop)
	var crate: Grabbable = CRATE_SCENE.instantiate()
	add_child_autofree(crate)
	assert_true(cart.add(crate))
	cart.dump()
	assert_null(cart.pusher, "tipped over, it's parked")
	assert_eq(cart.cargo.size(), 0)


func test_a_crouched_cop_rides_in_an_empty_cart_and_climbs_out() -> void:
	_floor()
	var rider := _cop(Vector3(2, 0.1, 0))
	var cart := _cart(Vector3(2, 0, -1))
	await _crouch(rider)
	assert_eq(cart.prompt_key(rider), "PROMPT_CART_RIDE")
	cart.use(rider)
	assert_eq(cart.rider, rider)
	assert_eq(rider.seated_in, cart)
	assert_eq(cart.prompt_key(rider), "PROMPT_CART_OUT")
	# Another cop pushes it: the rider goes along.
	var pusher := _cop(Vector3(2, 0.1, 0.4))
	cart.use(pusher)
	assert_eq(cart.pusher, pusher)
	for i in 40:
		pusher.step(TICK, Vector2(0, -1), false, false, false)
		rider.step(TICK, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_lt(rider.global_position.z, -1.5, "the rider rides along")
	assert_almost_eq(rider.global_position.distance_to(cart.hold_point(rider)), 0.0, 0.05)
	cart.stand_up()
	assert_null(cart.rider)
	assert_null(rider.seated_in)


func test_a_cart_with_something_in_it_isnt_for_riding() -> void:
	var cop := _cop()
	var cart := _cart(Vector3(0, 0, -1))
	var crate: Grabbable = CRATE_SCENE.instantiate()
	add_child_autofree(crate)
	cart.add(crate)
	await _crouch(cop)
	assert_eq(cart.prompt_key(cop), "PROMPT_CART_TAKE")


func test_stopping_dead_when_fast_throws_the_rider_out() -> void:
	_floor()
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6, 3, 0.4)
	shape.shape = box
	wall.add_child(shape)
	add_child_autofree(wall)
	wall.position = Vector3(0, 1.5, -8)
	var rider := _cop(Vector3(0, 0.1, 0))
	var cart := _cart(Vector3(0, 0, -1))
	await _crouch(rider)
	cart.use(rider)
	var pusher := _cop(Vector3(0, 0.1, 0.4))
	cart.use(pusher)
	var thrown := false
	for i in 240:
		pusher.step(TICK, Vector2(0, -1), true, false, false)
		rider.step(TICK, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
		if not cart.rider:
			thrown = true
			break
	assert_true(thrown, "running into the wall throws the rider out")
	assert_null(rider.seated_in)
	assert_true(rider.is_staggered())


func test_slow_into_the_wall_the_rider_stays() -> void:
	var cart := _cart()
	cart._last_speed = ShoppingCart.CRASH_SPEED * 0.5
	var rider := _cop()
	cart.rider = rider
	rider.seated_in = cart
	cart._physics_process(TICK)
	assert_eq(cart.rider, rider, "nobody pushes it: no crash")


func test_the_supermarket_has_its_carts_and_customers() -> void:
	var store: Supermarket = SUPER_SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	await wait_physics_frames(2)
	assert_eq(store.carts.size(), 8)
	assert_eq(store.customers.size(), 6)
	var customer := store.customers[0]
	var from := customer.position
	await wait_physics_frames(60)
	assert_gt(customer.position.distance_to(from), 0.3, "they walk their loop")
	for other in store.customers:
		for point: Vector3 in other.route:
			assert_lt(absf(point.x), Supermarket.HALF_X, other.name)
			assert_lt(absf(point.z), Supermarket.HALF_Z, other.name)


func test_a_bumped_customer_complains_once_in_a_while() -> void:
	var store: Supermarket = SUPER_SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	await wait_physics_frames(2)
	var customer := store.customers[0]
	customer.route = []
	var cop: Cop = store.get_node("Cop")
	var cart := store.carts[3]
	cart.use(cop)
	cart.top_speed = 2.0
	cop.global_position = customer.cart_position() - customer.global_basis.z * 0.5 - cop.global_basis.z * -1.2
	cart.global_position = customer.cart_position() - customer.global_basis.z * 0.5
	await wait_physics_frames(2)
	assert_eq(customer.complaints, 1)
	assert_almost_eq(store.manager.complaint, Supermarket.COMPLAINT_BUMP, 0.01, "it goes to the manager's complaint")
	assert_eq(customer.said(), "SUPER_CUSTOMER_BUMPED_0")
	await wait_physics_frames(10)
	cart.top_speed = 2.0
	await wait_physics_frames(2)
	assert_eq(customer.complaints, 1, "not again so soon")


func test_a_customer_has_a_line_and_waits_in_the_queue() -> void:
	var aisle := Node3D.new()
	add_child_autofree(aisle)
	var customer := SuperCustomer.new()
	aisle.add_child(customer)
	customer.use(null)
	assert_eq(customer.said(), "SUPER_CUSTOMER_0")
	customer.route = [Vector3.ZERO, Vector3(0, 0, -2)]
	customer.queue_at = 0
	customer.next_point = 0
	await wait_physics_frames(2)
	assert_true(customer.is_queuing())
	assert_eq(customer.said(), "SUPER_CUSTOMER_QUEUE")
