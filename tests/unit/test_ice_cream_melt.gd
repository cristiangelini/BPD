extends GutTest

## What melts in the ice cream shop (docs/diseno/allanamiento-heladeria.md, step 2): a freezer's lid opens and shuts
## with E, a lid left open melts it once (a fine and a puddle in front), shutting it in time saves it, the cold room
## melts if its door stays open, and a cop who runs on a puddle falls while one who walks only slides.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop() -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.case_seed = 5
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_e_opens_and_shuts_a_freezer() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	var freezer := shop.freezers[0]
	assert_eq(shop.freezers.size(), 4)
	assert_eq(freezer.prompt_key(cop), "PROMPT_FREEZER_OPEN")
	freezer.use(cop)
	assert_true(freezer.is_open)
	assert_eq(freezer.prompt_key(cop), "PROMPT_FREEZER_CLOSE")
	freezer.use(cop)
	assert_false(freezer.is_open)


func test_a_lid_left_open_melts_the_freezer_once() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var freezer := shop.freezers[1]
	watch_signals(shop)
	freezer.set_open(true)
	freezer.open_for = IceFreezer.MELT_AFTER - 0.05
	await wait_physics_frames(10)
	assert_true(freezer.is_melted)
	assert_signal_emitted_with_parameters(shop, "freezer_melted", [1])
	assert_eq(shop.fines, IceCreamShop.FREEZER_FINE)
	assert_eq(shop.puddles.size(), 1)
	var puddle := shop.puddles[0]
	assert_gt(puddle.position.z, freezer.position.z, "the puddle is in front of it")
	freezer.melt()
	await wait_physics_frames(5)
	assert_eq(shop.fines, IceCreamShop.FREEZER_FINE, "only once")


func test_shutting_the_lid_in_time_saves_it() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var freezer := shop.freezers[2]
	freezer.set_open(true)
	freezer.open_for = IceFreezer.MELT_AFTER - 1.0
	freezer.set_open(false)
	freezer.set_open(true)
	await wait_physics_frames(10)
	assert_false(freezer.is_melted, "the count starts over")
	assert_eq(shop.fines, 0)


func test_the_cold_room_melts_with_its_door_open() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	cop.has_key = true
	shop.cold_door.use(cop)
	assert_true(shop.cold_door.is_open)
	shop.cold_open_for = IceCreamShop.COLD_MELT_AFTER - 0.05
	await wait_physics_frames(10)
	assert_true(shop.cold_melted)
	assert_eq(shop.fines, IceCreamShop.COLD_FINE)
	assert_eq(shop.puddles.size(), 1)


func test_a_running_cop_falls_on_a_puddle_and_a_walking_one_slides() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	var puddle := shop._puddle(Vector3(6.0, 0.0, 6.0), Vector2(3.0, 3.0))
	cop.global_position = shop.to_global(Vector3(6.0, 0.2, 6.0))
	for i in 20:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
		await wait_physics_frames(1)
	assert_true(cop.is_on_floor())
	cop.velocity = Vector3(1.5, 0.0, 0.0)
	cop.is_running = false
	puddle.slip(cop)
	assert_false(cop.is_staggered(), "walking only slides")
	assert_gt(cop._knock.x, 0.0, "but it slides on")
	assert_eq(puddle.falls, 0)
	cop.velocity = Vector3(5.0, 0.0, 0.0)
	cop.is_running = true
	puddle.slip(cop)
	assert_true(cop.is_staggered(), "running falls")
	assert_eq(puddle.falls, 1)


func test_running_through_a_puddle_knocks_the_cop_down() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	var puddle := shop._puddle(Vector3(3.0, 0.0, 5.0), Vector2(3.0, 3.0))
	cop.global_position = shop.to_global(Vector3(3.0, 0.2, 8.0))
	cop.global_rotation = Vector3(0, shop.global_rotation.y, 0)
	for i in 90:
		cop.step(1.0 / 60.0, Vector2(0, -1), true, false, false)
		await wait_physics_frames(1)
	assert_eq(puddle.falls, 1, "fell once, then the stagger keeps it down")
