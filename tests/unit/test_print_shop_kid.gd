extends GutTest

## Tipito and the wooden letters (docs/diseno/allanamiento-imprenta.md, step 5): six letters lie around the shop, the
## seed draws the one he wants, the right one brought by a cop gets what he saw (once per cop) and another one only
## gets "Esa no".

const SCENE := preload("res://scenes/levels/print_shop.tscn")


func _shop(case_seed := 5) -> PrintShop:
	var shop: PrintShop = SCENE.instantiate()
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_six_letters_and_the_seed_draws_the_one_he_wants() -> void:
	var shop := _shop(5)
	await wait_physics_frames(2)
	assert_eq(shop.letters.size(), 6)
	assert_true(PrintShop.LETTERS.has(shop.kid.wanted), "always one of the six")
	assert_eq(shop.wanted_letter().letter, shop.kid.wanted)
	for letter in shop.letters:
		assert_almost_eq(letter.mass, WoodenLetter.KG, 0.01)
	var other := _shop(6)
	await wait_physics_frames(2)
	assert_ne(other.kid.wanted, shop.kid.wanted, "another seed, another letter")
	for key: String in ["PROMPT_TIPITO", "TIPITO_ASK", "TIPITO_WRONG", "TIPITO_AGAIN", "TIPITO_THANKS",
			"TIPITO_NOTHING", "TIPITO_IDLE_1", "TIPITO_IDLE_2", "TIPITO_IDLE_3"]:
		assert_ne(tr(key), key, key)
	assert_string_contains(tr("TIPITO_ASK") % "Ñ", "Ñ")


func test_the_right_letter_gets_the_gossip_once_per_cop() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var kid := shop.kid
	kid.clue = "clue line"
	kid.clue_speech = "what he saw"
	var cop: Cop = shop.get_node("Cop")
	watch_signals(kid)
	var wrong := shop.letters[(PrintShop.LETTERS.find(kid.wanted) + 1) % 6]
	kid.take(wrong, cop)
	assert_signal_not_emitted(kid, "told", "not that one")
	assert_string_contains(kid.get_node("Bubble").text, wrong.letter)
	kid.take(shop.wanted_letter(), cop)
	assert_signal_emitted_with_parameters(kid, "told", ["clue line"])
	kid.take(shop.wanted_letter(), cop)
	assert_signal_emit_count(kid, "told", 1, "once per cop")
	assert_eq(kid.letters_brought, 2)


func test_a_cop_carrying_the_letter_to_him_is_enough() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var kid := shop.kid
	kid.clue = "clue line"
	kid.clue_speech = "what he saw"
	watch_signals(kid)
	var cop: Cop = shop.get_node("Cop")
	var letter := shop.wanted_letter()
	letter.global_position = kid.global_position + Vector3(4, 0.5, 0)
	await wait_physics_frames(5)
	assert_signal_not_emitted(kid, "told", "a letter nobody brought doesn't count")
	cop.get_node("Grabber").grab(letter)
	letter.global_position = kid.global_position + Vector3(0.8, 0.6, 0)
	await wait_physics_frames(3)
	assert_signal_emitted(kid, "told")
