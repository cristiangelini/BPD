extends GutTest

## Lucho and the cone (docs/diseno/allanamiento-heladeria.md, step 4): he rides up to the door now and then and waits;
## the dispenser puts a cone in empty hands; without one he's in a hurry, and a cop who gives him one hears what he saw,
## once per cop.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop() -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.case_seed = 5
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func _waiting(shop: IceCreamShop) -> void:
	shop.lucho.visit_now()
	await wait_until(func() -> bool: return shop.lucho.state == "waiting", 6.0)


func test_he_rides_up_waits_and_leaves() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.lucho.state, "away")
	assert_false(shop.lucho.visible)
	shop.lucho.timer = 0.05
	await _waiting(shop)
	assert_eq(shop.lucho.state, "waiting")
	assert_true(shop.lucho.visible)
	assert_almost_eq(shop.lucho.position.distance_to(IceCreamShop.LUCHO_DOOR), 0.0, 0.01, "by the door")
	shop.lucho.timer = 0.05
	await wait_until(func() -> bool: return shop.lucho.state == "away", 8.0)
	assert_false(shop.lucho.visible, "gone again")
	assert_almost_eq(shop.lucho.timer, Lucho.VISIT_EVERY, 0.5)


func test_the_dispenser_hands_a_cone() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	assert_eq(shop.dispenser.prompt_key(cop), "PROMPT_TAKE_CONE")
	shop.dispenser.use(cop)
	assert_true(cop.get_node("Grabber").held is IceCone)


func test_without_a_cone_he_is_in_a_hurry() -> void:
	var shop := _shop()
	shop.lucho.clue = "the cold room"
	shop.lucho.clue_speech = "la vi en la cámara"
	await wait_physics_frames(2)
	await _waiting(shop)
	var cop: Cop = shop.get_node("Cop")
	assert_eq(shop.lucho.prompt_key(cop), "PROMPT_TALK_LUCHO")
	shop.lucho.use(cop)
	assert_eq(shop.lucho.said(), "LUCHO_BUSY")
	assert_false(shop.lucho.has_told)


func test_a_cone_buys_what_he_saw_once_per_cop() -> void:
	var shop := _shop()
	shop.lucho.clue = "the cold room"
	shop.lucho.clue_speech = "la vi en la cámara"
	await wait_physics_frames(2)
	await _waiting(shop)
	var cop: Cop = shop.get_node("Cop")
	watch_signals(shop.lucho)
	shop.dispenser.use(cop)
	assert_eq(shop.lucho.prompt_key(cop), "PROMPT_GIVE_CONE")
	shop.lucho.use(cop)
	assert_null(cop.get_node("Grabber").held, "he took the cone")
	assert_eq(shop.lucho.said(), "la vi en la cámara")
	assert_signal_emitted_with_parameters(shop.lucho, "told", ["the cold room"])
	shop.dispenser.use(cop)
	shop.lucho.use(cop)
	assert_eq(shop.lucho.said(), "LUCHO_AGAIN")
	assert_eq(shop.lucho.cones, 2)
