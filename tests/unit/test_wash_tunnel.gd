extends GutTest

## The car wash's tunnel at work (docs/diseno/allanamiento-lavadero.md, step 2): the button starts it for 30 s; the
## conveyor drags things and cops toward the end, the jets soak what passes, the brushes spin and shove, the foam
## curtain blinds a cop in it and the blower throws light things out.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash() -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.case_seed = 5
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func _box(car_wash: CarWash, at: Vector3, kg := 1.0) -> Grabbable:
	var prop := ClubEvidence.make_item("Box", CarWash.TOKEN_MODEL, Vector3(0.3, 0.3, 0.3), kg)
	car_wash.add_child(prop)
	prop.position = at
	return prop


func test_the_button_starts_it_for_a_while_and_then_it_stops() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	assert_false(car_wash.tunnel.is_running())
	car_wash.tunnel_button.pressed.emit(car_wash.get_node("Cop"))
	assert_true(car_wash.tunnel.is_running())
	assert_eq(car_wash.conveyor.constant_linear_velocity, Vector3(WashTunnel.BELT_SPEED, 0, 0))
	var turn := car_wash.side_brushes[0].rotation.y
	await wait_physics_frames(5)
	assert_ne(car_wash.side_brushes[0].rotation.y, turn, "the brushes spin")
	car_wash.tunnel.run_left = 0.05
	await wait_physics_frames(5)
	assert_false(car_wash.tunnel.is_running())
	assert_eq(car_wash.conveyor.constant_linear_velocity, Vector3.ZERO, "the belt stops")


func test_the_conveyor_carries_a_box_and_the_jets_soak_it() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var box := _box(car_wash, Vector3(CarWash.TUNNEL_X0 + 0.5, CarWash.CONVEYOR_TOP + 0.2, 0.0))
	await wait_seconds(0.5)
	car_wash.tunnel.start()
	await wait_seconds(2.5)
	assert_gt(box.position.x, CarWash.TUNNEL_X0 + 2.0, "it rode the belt (%.2f)" % box.position.x)
	assert_true(car_wash.tunnel.wet.has(box.get_instance_id()), "it went under the jets")


func test_a_cop_on_the_conveyor_rides_it() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var cop: Cop = car_wash.get_node("Cop")
	cop.global_position = Vector3(CarWash.TUNNEL_X0 + 0.4, CarWash.CONVEYOR_TOP + 0.05, 0.0)
	await wait_seconds(0.5)
	var from := cop.global_position.x
	car_wash.tunnel.start()
	await wait_seconds(1.0)
	var ride := cop.global_position.x - from
	assert_between(ride, WashTunnel.BELT_SPEED * 0.6, WashTunnel.BELT_SPEED * 1.4,
		"about a second's ride (%.2f)" % ride)


func test_the_blower_throws_a_light_box_out_but_not_a_heavy_one() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var light := _box(car_wash, Vector3(CarWash.BLOWER_X - 0.6, CarWash.CONVEYOR_TOP + 0.2, -0.5))
	var heavy := _box(car_wash, Vector3(CarWash.BLOWER_X - 0.6, CarWash.CONVEYOR_TOP + 0.2, 0.5), 8.0)
	await wait_seconds(0.3)
	car_wash.tunnel.start()
	await wait_seconds(1.5)
	assert_gt(light.position.x, CarWash.TUNNEL_X1 + 1.0, "blown out (%.2f)" % light.position.x)
	assert_lt(heavy.position.x, CarWash.TUNNEL_X1 + 1.0, "too heavy to blow (%.2f)" % heavy.position.x)


func test_the_foam_curtain_blinds_a_cop_only_while_it_runs() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var in_foam := car_wash.to_global(Vector3(CarWash.CURTAIN_X, 1.0, 0.0))
	assert_false(car_wash.tunnel.foam_covers(in_foam), "off, no foam")
	car_wash.tunnel.start()
	assert_true(car_wash.tunnel.foam_covers(in_foam))
	assert_false(car_wash.tunnel.foam_covers(car_wash.to_global(Vector3(-6.0, 1.0, 0.0))), "only at the curtain")


func test_the_texts_are_translated() -> void:
	for key: String in ["PROMPT_CARWASH_TUNNEL", "HINT_CARWASH_BRUSH", "HINT_CARWASH_TOP_BRUSH", "HINT_CARWASH_BLOWER"]:
		assert_ne(tr(key), key, key)
