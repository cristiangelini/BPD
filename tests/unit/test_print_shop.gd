extends GutTest

## The print shop as a place to raid (docs/diseno/allanamiento-imprenta.md, step 1): the shed on its lot, the rotativa
## with room under its rollers, the locked office with its key in the till, the display panes and the ink jars that
## break when something hits them fast, and the 12 hiding spots.

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func _prop(shop: PrintShop, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", PrintShop.JAR_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	shop.add_child(prop)
	prop.global_position = at
	prop.linear_velocity = velocity
	return prop


func test_the_shop_has_its_press_door_and_spots() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_true(shop.office_door.locked)
	assert_true(shop.till.has_key, "the office's key is in the counter's till")
	assert_eq(shop.panes.size(), PrintShop.DISPLAY_PANES)
	assert_eq(shop.jars.size(), PrintShop.INK_JARS)
	assert_eq(PrintShop.BARRELS.size(), 4, "blue, red, yellow and black")
	assert_gt(PrintShop.HOUSING_LOW, 0.5, "something fits under the rollers")
	assert_eq(PrintShop.SPOTS.size(), 12)
	assert_eq(PrintShop.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	for spot: Dictionary in PrintShop.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), PrintShop.HALF_X, spot.id)
		assert_lt(absf(at.z), PrintShop.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)
	for key: String in ["PLACE_PRINT_SHOP", "MENU_PRINT_SHOP", "PRINT_SHOP_GLASS_BROKEN", "PRINT_SHOP_JAR_BROKEN",
			"CASE_FAILED_LAWYER_PRINT_SHOP", "HINT_TILL_KEY_PRINT_SHOP"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_shop_stands_on_its_lot() -> void:
	var shop := _shop()
	await wait_physics_frames(1)
	assert_eq(CityLayout.place("print_shop").block, Vector2i(2, 5))
	assert_eq((shop.get_node("City") as Node3D).transform, CityLayout.anchor("print_shop"))


func test_something_hidden_in_every_spot_stays_there() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var props: Array[Grabbable] = []
	for spot: Dictionary in PrintShop.SPOTS:
		props.append(_prop(shop, spot.at + Vector3.UP * 0.2, Vector3.ZERO))
	await wait_seconds(1.5)
	for i in props.size():
		var spot: Dictionary = PrintShop.SPOTS[i]
		var at: Vector3 = spot.at
		assert_lt(props[i].global_position.distance_to(at + Vector3.UP * 0.15), 0.6, "%s keeps it" % spot.id)


func test_something_thrown_hard_at_a_pane_breaks_it_once_and_opens_it() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var pane := shop.panes[0].position
	_prop(shop, pane + Vector3(0, 0, -2.0), Vector3(0, 0, 9.0))
	await wait_physics_frames(30)
	assert_eq(shop.cracked, [0] as Array[int])
	assert_eq(shop.fines, PrintShop.PANE_FINE)
	shop.break_pane(0)
	assert_eq(shop.fines, PrintShop.PANE_FINE, "only once")
	await wait_physics_frames(1)
	assert_true((shop.panes[0].get_child(0) as CollisionShape3D).disabled, "the invitations are in reach")


func test_a_slow_prop_doesnt_break_a_jar_but_a_fast_one_does() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var jar := shop.jars[0].position + Vector3(0, 0.1, 0)
	_prop(shop, jar + Vector3(-0.7, 0, 0), Vector3.ZERO)
	await wait_physics_frames(30)
	assert_eq(shop.broken_jars.size(), 0)
	_prop(shop, jar + Vector3(-2.5, 0.05, 0), Vector3(9.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(shop.broken_jars.has(0))
	assert_false(shop.jars[0].visible)
	assert_eq(shop.fines, PrintShop.JAR_FINE * shop.broken_jars.size())


func test_the_till_key_opens_the_office() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	shop.till.use(cop)
	assert_true(cop.has_key)
	shop.office_door.use(cop)
	assert_false(shop.office_door.locked)
