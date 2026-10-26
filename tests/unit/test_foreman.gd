extends GutTest

## Fermín, the doll factory's foreman (fabrica.md, step 3): his walk along the belt, the red button he can't stand,
## the jams he clears with his back turned, and the complaint meter.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory() -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.get_node("Cop").input_enabled = false
	add_child_autofree(factory)
	return factory


func _distance_to_route(at: Vector3) -> float:
	var best := INF
	var route := DollFactory.FERMIN_ROUTE
	for i in route.size() - 1:
		var a := Vector2(route[i].x, route[i].z)
		var b := Vector2(route[i + 1].x, route[i + 1].z)
		var p := Vector2(at.x, at.z)
		var t := clampf((p - a).dot(b - a) / (b - a).length_squared(), 0.0, 1.0)
		best = minf(best, p.distance_to(a.lerp(b, t)))
	return best


func test_he_walks_along_the_belt() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var start := factory.fermin.global_position
	await wait_seconds(3.0)
	assert_gt(factory.fermin.global_position.distance_to(start), 2.0, "he walks")
	assert_lt(_distance_to_route(factory.fermin.global_position), 0.4, "along his route")


func test_stopping_the_belt_angers_him_and_he_starts_it_again() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	factory.fermin.start_at(3)
	factory.belt_button.use(factory.get_node("Cop"))
	assert_eq(factory.fermin.complaint, Foreman.BELT_STOPPED)
	assert_eq(factory.fermin.errand(), "button")
	await wait_seconds(2.5)
	assert_true(factory.belt.is_moving(), "he pressed the button again")
	assert_eq(factory.fermin.errand(), "")


func test_he_clears_a_jam_with_his_back_turned() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	factory.fermin.unjam_time = 1.5
	factory.fermin.start_at(3)
	var heavy := RigidBody3D.new()
	heavy.collision_layer = 4
	heavy.collision_mask = 15
	heavy.mass = ConveyorBelt.JAM_MASS + 2.0
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	heavy.add_child(shape)
	heavy.position = Vector3(-2.0, DollFactory.BELT_TOP + 0.6, -2.4)
	factory.add_child(heavy)
	await wait_seconds(1.5)
	assert_eq(factory.belt.jammed_at, "paint")
	assert_eq(factory.fermin.errand(), "jam")
	await wait_seconds(4.0)
	assert_true(factory.fermin.is_fixing(), "bent over the paint machine")
	assert_false(factory.fermin.can_see(factory.molds[0].global_position), "sees nothing meanwhile")
	await wait_seconds(1.5)
	assert_false(factory.fermin.is_fixing())
	assert_true(factory.belt.is_moving(), "cleared")


func test_he_sees_a_mold_break_and_calls_his_lawyer_at_100() -> void:
	var factory := _factory()
	await wait_physics_frames(30)
	factory.fermin.start_at(3)
	await wait_physics_frames(2)
	factory.molds[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(factory.fermin.complaint, Foreman.SAW_BREAK)
	assert_eq(factory.complaint_bar.value, Foreman.SAW_BREAK)
	for i in 6:
		factory.fermin._since_struck = Foreman.STRUCK_COOLDOWN
		factory.fermin.struck()
	assert_true(factory.fermin.has_called_lawyer)
	assert_true(factory.raid.case_failed)


func test_without_slips_he_only_makes_dolls() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	factory.fermin.slips.clear()
	assert_false(factory.fermin.ask(factory.get_node("Cop")))
	assert_eq(factory.fermin.get_node("Bubble").text, "FOREMAN_NOTHING")
