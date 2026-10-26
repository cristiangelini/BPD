extends GutTest

## The doll factory's belt that never stops (fabrica.md, step 2): it carries things and cops, turns at its corners,
## drops what reaches its end into the box cart, marks what goes under its machines, stops with the red button and
## jams with something heavy.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory() -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.get_node("Cop").input_enabled = false
	add_child_autofree(factory)
	return factory


func _thing(factory: DollFactory, at: Vector3, mass := 1.0) -> RigidBody3D:
	var thing := RigidBody3D.new()
	thing.collision_layer = 4
	thing.collision_mask = 15
	thing.mass = mass
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 0.2, 0.2)
	shape.shape = box
	thing.add_child(shape)
	var look := MeshInstance3D.new()
	look.mesh = BoxMesh.new()
	thing.add_child(look)
	thing.position = at
	factory.add_child(thing)
	return thing


func test_things_ride_to_the_end_and_fall_in_the_cart() -> void:
	var factory := _factory()
	await wait_physics_frames(5)
	var thing := _thing(factory, Vector3(-2.0, DollFactory.BELT_TOP + 0.12, 3.0))
	await wait_seconds(4.0)
	var cart := DollFactory.BOX_CART_AT
	assert_almost_eq(thing.position.x, cart.x, 0.6, "in the cart, across")
	assert_almost_eq(thing.position.z, cart.z, 0.5, "in the cart, along")
	assert_lt(thing.position.y, DollFactory.BELT_TOP, "fell off the end")


func test_things_turn_at_the_corners() -> void:
	var factory := _factory()
	await wait_physics_frames(5)
	var thing := _thing(factory, Vector3(-10.0, DollFactory.BELT_TOP + 0.12, -4.6))
	await wait_seconds(3.0)
	assert_gt(thing.position.x, -9.4, "went along the bottom of the U")
	assert_almost_eq(thing.position.z, -6.0, 0.4, "stayed on the belt")


func test_the_eyes_machine_marks_what_goes_under_it() -> void:
	var factory := _factory()
	await wait_physics_frames(5)
	var marks := []
	factory.belt.marked.connect(func(body: Node3D, machine: String) -> void: marks.append([body, machine]))
	var thing := _thing(factory, Vector3(-8.0, DollFactory.BELT_TOP + 0.12, -6.0))
	await wait_seconds(2.5)
	assert_true(thing.has_node("BeltEyes"), "googly eyes stuck on")
	assert_has(marks, [thing, "eyes"], "the belt tells what it marked")


func test_a_cop_rides_the_belt_and_gets_googly_eyes() -> void:
	var factory := _factory()
	var cop: Cop = factory.get_node("Cop")
	await wait_physics_frames(5)
	cop.global_position = Vector3(-7.8, DollFactory.BELT_TOP + 0.05, -6.0)
	# Standing still: nobody presses anything, the belt does the walking.
	for i in 150:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.x, -6.0, "carried along")
	assert_true(cop.model.has_node("BeltEyes"), "googly eyes on the cop")


func test_the_red_button_stops_and_starts_it() -> void:
	var factory := _factory()
	await wait_physics_frames(5)
	factory.belt_button.use(factory.get_node("Cop"))
	assert_false(factory.belt.is_moving())
	var thing := _thing(factory, Vector3(-2.0, DollFactory.BELT_TOP + 0.12, 0.0))
	await wait_seconds(1.5)
	assert_almost_eq(thing.position.z, 0.0, 0.1, "a still belt carries nothing")
	factory.belt_button.use(factory.get_node("Cop"))
	assert_true(factory.belt.is_moving())
	await wait_seconds(1.5)
	assert_gt(thing.position.z, 0.8, "moving again")


func test_something_heavy_jams_it_until_cleared() -> void:
	var factory := _factory()
	await wait_physics_frames(5)
	var heavy := _thing(factory, Vector3(-2.0, DollFactory.BELT_TOP + 0.12, -2.6), ConveyorBelt.JAM_MASS + 2.0)
	await wait_seconds(2.0)
	assert_eq(factory.belt.jammed_by, heavy, "the paint machine jammed")
	assert_false(factory.belt.is_moving())
	factory.belt.unjam()
	assert_true(factory.belt.is_moving())
