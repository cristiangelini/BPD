extends GutTest

## The armory's box of donuts (docs/diseno/comisaria.md, "La armería").

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const BOX_SCENE := preload("res://scenes/props/donut_box.tscn")
const GRANDPA_SCENE := preload("res://scenes/npc/grandpa.tscn")


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(cop)
	return cop


func _cop_with_box() -> Cop:
	var cop := _cop()
	var box: DonutBox = BOX_SCENE.instantiate()
	add_child_autofree(box)
	cop.get_node("Grabber").grab(box)
	return cop


func test_a_donut_fills_the_stamina() -> void:
	var cop := _cop_with_box()
	cop.stamina = 0.0
	cop.exhausted = true
	assert_eq(cop.current_prompt(), "PROMPT_DONUT_BOX")
	assert_true(cop.use(), "E with the box in hand eats one")
	assert_eq(cop.stamina, GameScale.RUN_STAMINA)
	assert_false(cop.exhausted)
	var box: DonutBox = cop.get_node("Grabber").held
	assert_eq(box.donuts, DonutBox.DONUTS - 1)
	assert_eq(box, cop.get_node("Grabber").held, "the box stays in hand")


func test_four_donuts_then_an_empty_box() -> void:
	var cop := _cop_with_box()
	for i in DonutBox.DONUTS:
		assert_true(cop.use())
	assert_false(cop.use())
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_DONUTS_GONE")
	assert_eq(cop.current_prompt(), "PROMPT_DONUT_EMPTY")


func test_no_questions_with_the_mouth_full() -> void:
	var grandpa: Grandpa = GRANDPA_SCENE.instantiate()
	grandpa.position = Vector3(0, 0, -1.5)
	add_child_autofree(grandpa)
	var cop := _cop()
	cop.position.y = -0.8
	var box: DonutBox = BOX_SCENE.instantiate()
	box.position = Vector3(3, 0, 0)
	add_child_autofree(box)
	cop.eat_donut(box)
	await wait_physics_frames(2)
	assert_true(cop.mouth_full())
	assert_false(cop.ask())
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_MOUTH_FULL")
	for i in int(Cop.MOUTH_FULL * 60) + 5:
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
	assert_false(cop.mouth_full(), "after a while you can talk again")


func test_buy_and_take_a_box_at_the_armory() -> void:
	var wallet := StationWallet.new()
	wallet.money = 70
	var armory := Armory.new(wallet)
	var cop := _cop()
	assert_eq(armory.choose("donuts", cop), "", "the first E buys it")
	assert_eq(wallet.money, 40)
	assert_eq(armory.count("donuts"), 1)
	assert_eq(armory.buy("donuts"), "", "boxes can be bought again")
	assert_eq(armory.count("donuts"), 2)
	assert_eq(armory.choose("donuts", cop), "")
	assert_true(cop.get_node("Grabber").held is DonutBox, "the box is in the cop's hands")
	assert_eq(armory.count("donuts"), 1, "taking one uses it up")
	assert_eq(armory.take("donuts", cop), "ARMORY_HANDS_FULL")
