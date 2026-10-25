extends GutTest

## The prison's laundry: the room in the kitchen, its carts and its workers (carcel-lavanderia.md, step 2).

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


func _local(node: Node3D) -> Vector2:
	var at := prison.global_transform.affine_inverse() * node.global_position
	return Vector2(at.x, at.z)


func _in_kitchen(at: Vector2, margin: float) -> bool:
	return at.x > PrisonLevel.KITCHEN_X + margin and at.x < PrisonLevel.BUILDING_X - margin \
		and at.y > PrisonLevel.CELLS_Z + margin and at.y < PrisonLevel.BUILDING_FRONT - margin


func test_the_laundry_opens_from_play() -> void:
	assert_eq(prison.variant, "laundry")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["laundry"]))
	assert_eq(PlaceDraw.pick(1, ["--place=laundry"]), "laundry")


func test_the_kitchen_door_is_off_for_the_carts() -> void:
	assert_null(prison.kitchen_door)
	assert_null(prison.get_node_or_null("KitchenDoor"))


func test_twelve_carts_in_the_kitchen() -> void:
	assert_eq(plan.carts.size(), LaundryPlan.CARTS)
	for cart in plan.carts:
		assert_true(_in_kitchen(_local(cart), LaundryCart.SIZE.z / 2), "%s in the laundry" % cart.name)


func test_three_carts_on_each_of_four_trips() -> void:
	for trip in LaundryPlan.TRIPS:
		assert_eq(plan.carts_on_trip(trip).size(), LaundryPlan.PER_TRIP)


func test_four_to_six_carts_hide_an_inmate() -> void:
	for seed_value in [1, 7, 42, 99, 1234]:
		var other: PrisonLevel = LEVEL.instantiate()
		other.case_seed = seed_value
		add_child_autofree(other)
		var hidden := other.laundry.hidden_count()
		assert_between(hidden, LaundryPlan.HIDDEN_MIN, LaundryPlan.HIDDEN_MAX)


func test_the_same_seed_draws_the_same_carts() -> void:
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 7
	add_child_autofree(other)
	for i in LaundryPlan.CARTS:
		assert_eq(other.laundry.carts[i].hidden, plan.carts[i].hidden)
		assert_eq(other.laundry.carts[i].trip, plan.carts[i].trip)


func test_six_workers_at_their_stations() -> void:
	assert_eq(plan.workers.size(), LaundryPlan.WORKERS)
	for i in plan.workers.size():
		var worker := plan.workers[i]
		assert_almost_eq(_local(worker).distance_to(LaundryPlan.STATIONS[i]), 0.0, 0.05)
		assert_true(_in_kitchen(_local(worker), 0.3), "%s in the laundry" % worker.name)


func test_nobody_works_until_a_cop_walks_in() -> void:
	await wait_physics_frames(5)
	assert_false(plan.running)
	assert_false(plan.workers[0].working)
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 15)
	await wait_physics_frames(2)
	assert_true(plan.running)
	for worker in plan.workers:
		assert_true(worker.working)


func test_carts_and_machines_are_solid() -> void:
	var space := prison.get_world_3d().direct_space_state
	var cart := plan.carts[0]
	var query := PhysicsRayQueryParameters3D.create(cart.global_position + Vector3(0, 2, 0),
		cart.global_position + Vector3(0, 0.3, 0))
	assert_eq(space.intersect_ray(query).get("collider"), cart)
	var washer := prison.global_transform * Vector3(LaundryPlan.MACHINE_X, 2, LaundryPlan.WASHER_ZS[0])
	query = PhysicsRayQueryParameters3D.create(washer, washer + Vector3(0, -1.5, 0))
	assert_false(space.intersect_ray(query).is_empty(), "a washer")
