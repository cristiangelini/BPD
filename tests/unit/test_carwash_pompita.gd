extends GutTest

## Pompita and the dry chamois at the car wash (allanamiento-lavadero.md, step 4): the rag basket gives up to 3
## chamois, a chamois gets wet through the running tunnel's jets or dropped in a puddle, and Pompita tells whoever
## brings him a dry one what he saw, once per cop.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash() -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.case_seed = 5
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


## The cop beside Pompita with a fresh chamois in hand.
func _bring_chamois(car_wash: CarWash) -> Chamois:
	var cop: Cop = car_wash.get_node("Cop")
	var cloth := car_wash.take_chamois()
	cop.global_position = car_wash.to_global(CarWash.POMPITA_AT + Vector3(-1.2, 0.1, 0))
	await wait_physics_frames(2)
	cloth.global_position = (cop.get_node("Grabber") as Node).hold_point()
	(cop.get_node("Grabber") as Node).grab(cloth)
	await wait_physics_frames(10)
	return cloth


func test_pompita_explains_and_his_lines_are_translated() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var cop: Cop = car_wash.get_node("Cop")
	assert_eq(car_wash.pompita.prompt_key(cop), "PROMPT_POMPITA")
	car_wash.pompita.use(cop)
	assert_eq((car_wash.pompita.get_node("Bubble") as Label3D).text, "POMPITA_RULES")
	for key: String in ["PROMPT_CARWASH_CHAMOIS", "HINT_CARWASH_CHAMOIS_MAX", "PROMPT_CARWASH_CHAMOIS_HELD",
			"CARWASH_CHAMOIS_WET", "PROMPT_POMPITA", "PROMPT_POMPITA_CHAMOIS", "POMPITA_RULES", "POMPITA_AGAIN",
			"POMPITA_WON", "POMPITA_NOTHING", "POMPITA_WET", "POMPITA_THANKS", "POMPITA_IDLE_1", "POMPITA_IDLE_2",
			"POMPITA_IDLE_3"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_basket_gives_up_to_three_dry_chamois() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var cop: Cop = car_wash.get_node("Cop")
	for i in 3:
		car_wash.chamois_button.use(cop)
	assert_eq(car_wash.chamois.size(), 3)
	car_wash.chamois_button.use(cop)
	assert_eq(car_wash.chamois.size(), 3, "no more than three at once")
	await wait_physics_frames(30)
	assert_true(car_wash.chamois[0].dry, "it lies there dry")


func test_a_chamois_gets_wet_in_the_tunnel_or_a_puddle() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var tunneled := car_wash.take_chamois()
	tunneled.global_position = car_wash.to_global(Vector3(CarWash.JETS_X - 1.5, CarWash.CONVEYOR_TOP + 0.1, 0))
	await wait_physics_frames(10)
	assert_true(tunneled.dry, "the tunnel off doesn't wet it")
	car_wash.tunnel.start()
	await wait_seconds(2.5)
	assert_false(tunneled.dry, "the jets soak it")
	var dropped := car_wash.take_chamois()
	dropped.global_position = car_wash.to_global(CarWash.PUDDLES[0] + Vector3(0, 0.6, 0))
	await wait_physics_frames(40)
	assert_false(dropped.dry, "dropped in a puddle, it's wet")


func test_a_dry_chamois_makes_pompita_talk_once_per_cop() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var cop: Cop = car_wash.get_node("Cop")
	car_wash.pompita.clue = "the clue"
	car_wash.pompita.clue_speech = "I saw him hide something in the foam tank."
	watch_signals(car_wash.pompita)
	var cloth := await _bring_chamois(car_wash)
	assert_true(cloth.dry)
	assert_eq(car_wash.pompita.prompt_key(cop), "PROMPT_POMPITA_CHAMOIS")
	car_wash.pompita.use(cop)
	assert_signal_emitted_with_parameters(car_wash.pompita, "told", ["the clue"])
	assert_null((cop.get_node("Grabber") as Node).get("held"), "he took the chamois")
	await wait_physics_frames(2)
	assert_false(is_instance_valid(cloth))
	await _bring_chamois(car_wash)
	car_wash.pompita.use(cop)
	assert_eq((car_wash.pompita.get_node("Bubble") as Label3D).text, "POMPITA_THANKS")
	assert_signal_emit_count(car_wash.pompita, "told", 1, "once per cop")
	assert_eq(car_wash.pompita.chamois, 2)


func test_a_wet_chamois_gets_nothing() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var cop: Cop = car_wash.get_node("Cop")
	car_wash.pompita.clue_speech = "Something."
	watch_signals(car_wash.pompita)
	var cloth := await _bring_chamois(car_wash)
	cloth.soak()
	car_wash.pompita.use(cop)
	assert_eq((car_wash.pompita.get_node("Bubble") as Label3D).text, "POMPITA_WET")
	assert_signal_not_emitted(car_wash.pompita, "told")
