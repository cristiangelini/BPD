extends GutTest

## The laundry's tells: the sneeze, the shoe, the heavy cart, the nervous pusher and the cat in the towels
## (carcel-lavanderia.md, step 4).

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


func _first(test: Callable) -> LaundryCart:
	for cart in plan.carts:
		if test.call(cart):
			return cart
	return null


func _cop_by(cart: LaundryCart) -> void:
	var at := prison.global_transform.affine_inverse() * cart.global_position
	cop.global_position = prison.global_transform * Vector3(at.x + 0.9, PrisonLevel.FLOOR_TOP + 0.1, at.z)


func test_someone_under_the_sheets_sneezes() -> void:
	var cart := _first(func(c: LaundryCart) -> bool: return c.hidden)
	cart._tell_left = 0.01
	await wait_seconds(0.2)
	assert_eq(cart.said(), "CART_SNEEZE")


func test_an_empty_cart_without_a_cat_says_nothing() -> void:
	var cart := _first(func(c: LaundryCart) -> bool: return not c.hidden and not c.has_cat)
	assert_false(cart.has_tells())
	cart._tell_left = 0.01
	await wait_seconds(0.2)
	assert_eq(cart.said(), "")


func test_the_cat_meows_like_a_sneeze_would() -> void:
	var cart := _first(func(c: LaundryCart) -> bool: return c.has_cat)
	assert_not_null(cart, "seed 7 has a cat")
	assert_false(cart.hidden, "only in empty carts")
	cart._tell_left = 0.01
	await wait_seconds(0.2)
	assert_eq(cart.said(), "CART_MEOW")


func test_digging_finds_the_cat_and_no_one_runs() -> void:
	var cart := _first(func(c: LaundryCart) -> bool: return c.has_cat)
	_cop_by(cart)
	await wait_physics_frames(1)
	cart.use(cop)
	await wait_seconds(LaundryCart.CHECK_TIME + 0.2)
	assert_not_null(cart.get_node_or_null("Cat"))
	assert_eq(plan.found, 0)
	assert_false(cart.has_tells(), "found: it stops")


func test_the_shoe_sticks_out_only_with_someone_in() -> void:
	var feet := 0
	for cart in plan.carts:
		var foot: Node3D = cart.get_node("Foot")
		assert_eq(foot.visible, cart.hidden and cart.foot_out, cart.name)
		if foot.visible:
			feet += 1
	var cart := _first(func(c: LaundryCart) -> bool: return c.hidden)
	cart.tip(1.0)
	assert_false(cart.get_node("Foot").visible, "out of the cart, the shoe goes with them")


func test_every_seed_draws_cats_only_in_empty_carts() -> void:
	for seed_value in [1, 7, 42, 99]:
		var other: PrisonLevel = LEVEL.instantiate()
		other.case_seed = seed_value
		add_child_autofree(other)
		for cart in other.laundry.carts:
			assert_false(cart.has_cat and cart.hidden)
			assert_false(cart.foot_out and not cart.hidden)


func test_a_cart_with_someone_in_is_pushed_slower() -> void:
	var heavy := _first(func(c: LaundryCart) -> bool: return c.hidden)
	var light := _first(func(c: LaundryCart) -> bool: return not c.hidden)
	var worker := plan.workers[0]
	worker.fetch(heavy)
	worker.job = LaundryWorker.Job.PUSH
	assert_almost_eq(worker._speed(), LaundryWorker.PUSH_SPEED * LaundryWorker.HEAVY_SLOW, 0.001)
	worker.cart = light
	assert_almost_eq(worker._speed(), LaundryWorker.PUSH_SPEED, 0.001)


func test_the_pusher_of_someone_greets_a_close_cop() -> void:
	var cart := _first(func(c: LaundryCart) -> bool: return c.hidden)
	var worker := plan.workers[0]
	worker.fetch(cart)
	worker.job = LaundryWorker.Job.PUSH
	cop.global_position = worker.global_position + Vector3(1.5, 0.1, 0)
	worker._nervous(0.1)
	assert_eq(worker.said(), "WORKER_NERVOUS")
	worker.say("")
	worker._nervous(0.1)
	assert_ne(worker.said(), "WORKER_NERVOUS", "not again so soon")


func test_the_pusher_of_sheets_is_calm() -> void:
	var cart := _first(func(c: LaundryCart) -> bool: return not c.hidden)
	var worker := plan.workers[0]
	worker.fetch(cart)
	worker.job = LaundryWorker.Job.PUSH
	cop.global_position = worker.global_position + Vector3(1.5, 0.1, 0)
	worker._nervous(0.1)
	assert_ne(worker.said(), "WORKER_NERVOUS")
