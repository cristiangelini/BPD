extends GutTest

## Chef Bruno, the cake lab's head pastry chef (laboratorio.md, step 2): his round between the counters, the cakes and
## the flour he can't stand to see wasted, the soufflé he saves with his back turned, and the complaint meter.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab() -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.get_node("Cop").input_enabled = false
	add_child_autofree(lab)
	return lab


func _distance_to_route(at: Vector3) -> float:
	var best := INF
	var route := CakeLab.CHEF_ROUTE
	for i in route.size() - 1:
		var a := Vector2(route[i].x, route[i].z)
		var b := Vector2(route[i + 1].x, route[i + 1].z)
		var p := Vector2(at.x, at.z)
		var t := clampf((p - a).dot(b - a) / (b - a).length_squared(), 0.0, 1.0)
		best = minf(best, p.distance_to(a.lerp(b, t)))
	return best


func test_he_goes_from_counter_to_counter() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var start := lab.chef.global_position
	await wait_seconds(3.0)
	assert_gt(lab.chef.global_position.distance_to(start), 2.0, "he walks")
	assert_lt(_distance_to_route(lab.chef.global_position), 0.4, "along his round")


func test_he_speaks_as_the_chef() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.chef.voice, "CHEF")
	lab.chef.slips.clear()
	assert_false(lab.chef.ask(lab.get_node("Cop")))
	assert_eq(lab.chef.get_node("Bubble").text, "CHEF_NOTHING")
	for key: String in ["CHEF_LINE_1", "CHEF_FIX_1", "CHEF_FIX_DONE", "CHEF_PRINTER", "CHEF_HURT", "CHEF_DOOR", "CHEF_SAW", "CHEF_LAWYER", "CHEF_OFFENDED"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_souffle_oven_takes_him_away_with_his_back_turned() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	lab.chef.fix_time = 1.5
	lab.chef.start_at(1)
	var cop: Cop = lab.get_node("Cop")
	lab.oven.button.use(cop)
	assert_true(lab.oven.is_jammed, "at the max")
	assert_eq(lab.chef.errand(), "printer", "he runs to it")
	lab.oven.button.use(cop)
	assert_eq(lab.oven.jobs, 1, "burning, the knob does nothing more")
	await wait_until(func() -> bool: return lab.chef.is_fixing(), 10.0)
	assert_true(lab.chef.is_fixing(), "at the oven")
	assert_lt(lab.chef.global_position.distance_to(CakeLab.SOUFFLE_SPOT), 0.5)
	assert_false(lab.chef.can_see(lab.chef.global_position + Vector3(-2, 1, 0)), "sees nothing meanwhile")
	await wait_seconds(1.8)
	assert_false(lab.chef.is_fixing())
	assert_false(lab.oven.is_jammed, "the soufflé is saved")


func test_a_squashed_cake_where_he_sees_it_goes_on_the_complaint() -> void:
	var lab := _lab()
	await wait_physics_frames(30)
	lab.chef.global_position = Vector3(-1.0, CakeLab.FLOOR_TOP, 9.0)
	await wait_physics_frames(2)
	lab.cakes[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(lab.chef.complaint, FloorBoss.SAW_BREAK)
	assert_eq(lab.chef.get_node("Bubble").text, "CHEF_CAKE")
	assert_eq(lab.complaint_bar.value, FloorBoss.SAW_BREAK)


func test_a_burst_sack_where_he_sees_it_goes_on_the_complaint() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	lab.chef.global_position = Vector3(-8.5, CakeLab.FLOOR_TOP, 3.0)
	await wait_physics_frames(2)
	lab.sacks[0].hit(FlourSack.BURST_SPEED + 1.0)
	assert_eq(lab.chef.complaint, CakeLab.SAW_FLOUR)
	assert_eq(lab.chef.get_node("Bubble").text, "CHEF_FLOUR")


func test_a_rammed_door_reaches_him_anywhere() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	for i in FrontDoor.RAM_HITS:
		lab.cold_door.ram_hit()
	assert_eq(lab.chef.complaint, FloorBoss.DOOR_BROKEN)
