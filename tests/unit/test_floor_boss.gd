extends GutTest

## Mirta, the insurance office's floor boss (seguros.md, step 2): her round between the cubicles, the papers she can't
## stand to see fly, the printer she fights with her back turned, and the complaint meter.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office() -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.get_node("Cop").input_enabled = false
	add_child_autofree(office)
	return office


func _distance_to_route(at: Vector3) -> float:
	var best := INF
	var route := InsuranceOffice.MIRTA_ROUTE
	for i in route.size() - 1:
		var a := Vector2(route[i].x, route[i].z)
		var b := Vector2(route[i + 1].x, route[i + 1].z)
		var p := Vector2(at.x, at.z)
		var t := clampf((p - a).dot(b - a) / (b - a).length_squared(), 0.0, 1.0)
		best = minf(best, p.distance_to(a.lerp(b, t)))
	return best


func test_she_walks_the_aisles() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var start := office.mirta.global_position
	await wait_seconds(3.0)
	assert_gt(office.mirta.global_position.distance_to(start), 2.0, "she walks")
	assert_lt(_distance_to_route(office.mirta.global_position), 0.4, "along her round")


func test_papers_flying_where_she_sees_them_go_on_the_complaint() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.mirta.start_at(1)
	await wait_physics_frames(2)
	var pile := office.piles[3]
	assert_true(office.mirta.can_see(pile.global_position + Vector3.UP * PaperPile.FLY_HEIGHT), "the front row's pile, from the aisle")
	pile.scatter()
	assert_eq(office.mirta.complaint, FloorBoss.SAW_PAPERS)
	assert_eq(office.mirta.get_node("Bubble").text, "BOSS_FORM")
	assert_eq(office.complaint_bar.value, FloorBoss.SAW_PAPERS)


func test_the_printer_jams_and_she_fights_it_with_her_back_turned() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.mirta.fix_time = 1.5
	office.mirta.start_at(5)
	office.printer.button.use(office.get_node("Cop"))
	assert_true(office.printer.is_jammed)
	assert_eq(office.printer.jobs, 1)
	assert_eq(office.mirta.errand(), "printer")
	office.printer.button.use(office.get_node("Cop"))
	assert_eq(office.printer.jobs, 1, "jammed, it doesn't print again")
	await wait_until(func() -> bool: return office.mirta.is_fixing(), 10.0)
	assert_true(office.mirta.is_fixing(), "at the printer")
	assert_lt(office.mirta.global_position.distance_to(InsuranceOffice.PRINTER_SPOT), 0.5)
	assert_false(office.mirta.can_see(office.piles[3].global_position), "sees nothing meanwhile")
	office.piles[3].scatter()
	assert_eq(office.mirta.complaint, 0.0, "the papers fly unseen")
	await wait_seconds(1.8)
	assert_false(office.mirta.is_fixing())
	assert_false(office.printer.is_jammed, "fixed")


func test_she_sees_a_trophy_break_and_calls_her_lawyer_at_100() -> void:
	var office := _office()
	await wait_physics_frames(30)
	office.mirta.global_position = Vector3(8.0, InsuranceOffice.FLOOR_TOP, -5.0)
	await wait_physics_frames(2)
	office.trophies[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(office.mirta.complaint, FloorBoss.SAW_BREAK)
	var lawyer := []
	office.mirta.lawyer_called.connect(func() -> void: lawyer.append(true))
	for i in 6:
		office.mirta._since_struck = FloorBoss.STRUCK_COOLDOWN
		office.mirta.struck()
	assert_true(office.mirta.has_called_lawyer)
	assert_eq(lawyer.size(), 1)


func test_a_rammed_door_reaches_her_anywhere() -> void:
	var office := _office()
	await wait_physics_frames(2)
	for i in FrontDoor.RAM_HITS:
		office.archive_door.ram_hit()
	assert_eq(office.mirta.complaint, FloorBoss.DOOR_BROKEN)


func test_without_slips_she_only_supervises() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.mirta.slips.clear()
	assert_false(office.mirta.ask(office.get_node("Cop")))
	assert_eq(office.mirta.get_node("Bubble").text, "BOSS_NOTHING")
