extends GutTest

## The print shop's ink (docs/diseno/allanamiento-imprenta.md, step 3): a barrel hit hard or bumped by a running cop
## tips over once and leaves a puddle of its color, a broken jar leaves one too, puddles dry after a while, and a cop
## who steps in one leaves footprints of that color for a while.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop() -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.case_seed = 5
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_something_thrown_hard_tips_a_barrel_once_and_spills_its_ink() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	watch_signals(shop)
	var barrel := PrintShop.BARRELS[1]
	var prop := ClubEvidence.make_item("Thrown", PrintShop.JAR_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	shop.add_child(prop)
	prop.global_position = barrel + Vector3(0, 0.5, -2.0)
	prop.linear_velocity = Vector3(0, 0, 9.0)
	await wait_physics_frames(30)
	assert_eq(shop.tipped, [1] as Array[int])
	assert_signal_emitted_with_parameters(shop, "barrel_tipped", [1])
	assert_eq(shop.ink.puddles.size(), 1)
	assert_eq(shop.ink.puddles[0].ink, 1, "red ink from the red barrel")
	shop.tip_barrel(1, Vector3.BACK)
	assert_eq(shop.ink.puddles.size(), 1, "only once")
	await wait_physics_frames(1)
	assert_true((shop.barrel_bodies[1].get_child(0) as CollisionShape3D).disabled, "it lies on the floor")
	assert_ne(tr("PRINT_SHOP_BARREL_TIPPED"), "PRINT_SHOP_BARREL_TIPPED")


func test_a_running_cop_tips_a_barrel_but_a_walking_one_doesnt() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	cop.global_position = PrintShop.BARRELS[0] + Vector3(0, 0, -0.55)
	await wait_physics_frames(5)
	assert_eq(shop.tipped.size(), 0, "walking by is fine")
	cop.global_position = Vector3(5, 0.1, 5)
	await wait_physics_frames(5)
	cop.is_running = true
	cop.global_position = PrintShop.BARRELS[3] + Vector3(0, 0, -0.55)
	await wait_physics_frames(5)
	assert_true(shop.tipped.has(3))


func test_a_broken_jar_spills_too() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	shop.break_jar(2)
	assert_eq(shop.ink.puddles.size(), 1)


func test_a_cop_in_a_puddle_leaves_footprints_and_puddles_dry() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	watch_signals(shop.ink)
	shop.ink.spill(Vector3(-6, 0, 4), 2)
	cop.global_position = Vector3(-6, 0.1, 4)
	await wait_physics_frames(5)
	assert_true(shop.ink.is_inked(cop))
	assert_signal_emitted_with_parameters(shop.ink, "cop_inked", [cop, 2])
	for i in 6:
		cop.global_position = Vector3(-6 + (i + 1) * 0.8, 0.1, 2)
		await wait_physics_frames(2)
	assert_gt(shop.ink.footprints.size(), 3, "footprints as the cop walks")
	shop.ink.inked[cop].left = 0.01
	await wait_physics_frames(3)
	assert_false(shop.ink.is_inked(cop), "the soles dry")
	var count := shop.ink.footprints.size()
	cop.global_position = Vector3(5, 0.1, 5)
	await wait_physics_frames(3)
	assert_eq(shop.ink.footprints.size(), count, "no more footprints")
	shop.ink.puddles[0].left = 0.01
	await wait_physics_frames(3)
	assert_eq(shop.ink.puddles.size(), 0, "the puddle dried")
