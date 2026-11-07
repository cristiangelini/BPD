extends GutTest

## The print shop's rotativa (docs/diseno/allanamiento-imprenta.md, step 2): it runs on its clock or with the lever,
## its belt carries things to the rollers, the light ones come out printed on the tray, the heavy ones jam it, the
## railing stops cops before the rollers, and it throws sheets into the air while it runs.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop() -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.case_seed = 5
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func _prop(shop: PrintShop, at: Vector3, mass: float) -> Grabbable:
	var prop := ClubEvidence.make_item("Thing", PrintShop.JAR_MODEL, Vector3(0.3, 0.3, 0.3), mass)
	shop.add_child(prop)
	prop.global_position = at
	return prop


func test_it_runs_on_its_clock_and_with_the_lever() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var press := shop.press
	assert_false(press.running, "it starts still")
	assert_eq(press.belt.constant_linear_velocity, Vector3.ZERO)
	press.wait_left = 0.05
	await wait_physics_frames(10)
	assert_true(press.running, "the clock starts it")
	assert_eq(press.belt.constant_linear_velocity, Vector3(PrintingPress.SPEED, 0, 0))
	press.run_left = 0.05
	await wait_physics_frames(10)
	assert_false(press.running, "it stops after its run")
	assert_almost_eq(press.wait_left, PrintingPress.EVERY, 0.5)
	press.lever.use(shop.get_node("Cop"))
	assert_true(press.running, "the lever starts it")
	assert_eq(press.runs, 2)
	assert_ne(tr("PROMPT_PRESS_LEVER"), "PROMPT_PRESS_LEVER")


func test_a_light_thing_rides_the_belt_and_comes_out_printed() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var press := shop.press
	var thing := _prop(shop, Vector3(PrintShop.BELT_X.x + 1.0, PrintShop.BELT_TOP + 0.2, 0), 2.0)
	await wait_seconds(0.5)
	press.start()
	await wait_seconds(3.0)
	assert_true(press.printed_things.has(thing), "it went through the rollers")
	assert_gt(thing.global_position.x, PrintShop.TRAY_X.x, "it came out on the tray side")
	assert_true(thing.has_node("PressStamp"), "it has the shop's stamp")
	assert_eq(thing.get_meta("press_ink"), 0, "the first run prints blue")
	assert_ne(tr("PRINT_SHOP_STAMP"), "PRINT_SHOP_STAMP")


func test_a_heavy_thing_jams_the_press() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var press := shop.press
	watch_signals(press)
	var heavy := _prop(shop, Vector3(PrintShop.BELT_X.y - 1.0, PrintShop.BELT_TOP + 0.2, 0), 15.0)
	await wait_seconds(0.3)
	press.start()
	await wait_seconds(2.0)
	assert_signal_emitted(press, "jammed")
	assert_false(press.is_moving())
	assert_false(press.printed_things.has(heavy))
	assert_lt(heavy.global_position.x, PrintShop.HOUSING_X.x, "it was spat back")
	press.start()
	assert_false(press.running, "the lever does nothing while it is jammed")
	press.jam_left = 0.05
	await wait_physics_frames(10)
	assert_almost_eq(press.wait_left, PrintingPress.EVERY, 0.5, "the clock counts again")


func test_the_railing_stops_a_cop_before_the_rollers() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = Vector3(PrintShop.BELT_X.x + 1.5, PrintShop.BELT_TOP + 0.1, 0)
	shop.press.start()
	# Standing still: nobody presses anything, the belt does the walking.
	for i in 180:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_gt(cop.global_position.x, PrintShop.BELT_X.x + 2.0, "the belt carried the cop")
	assert_lt(cop.global_position.x, PrintShop.BELT_X.y - 0.3, "the railing stopped the cop")


func test_it_throws_sheets_while_it_runs() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var press := shop.press
	press.start()
	await wait_seconds(2.1)
	assert_between(press.sheets.size(), 3, 6, "about two a second")
	var sheet: MeshInstance3D = press.sheets[0].node
	assert_gt(sheet.position.y, PrintShop.TRAY_TOP, "up in the air")
