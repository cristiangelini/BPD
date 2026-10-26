extends GutTest

## The restaurant's kitchen (infiltracion-restaurante.md, step 3, decision 174): the crates give ingredients, an
## ingredient dropped into a pot, a pan or a plate goes in, a pot or a pan on a burner cooks and past its time burns and
## smokes, and E with a pot or a pan in hand serves it onto the nearest plate.

const LEVEL := preload("res://scenes/levels/restaurant_hall.tscn")

var hall: RestaurantHall
var cop: Cop


func before_each() -> void:
	hall = LEVEL.instantiate()
	cop = hall.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)


func _vessel(vessel_name: String) -> KitchenVessel:
	return hall.get_node(vessel_name)


func test_the_kitchenware_and_crates_are_in_place() -> void:
	assert_eq(hall.vessels.size(), RestaurantHall.POTS.size() + RestaurantHall.PANS.size() + RestaurantHall.PLATES.size())
	for vessel in hall.vessels:
		assert_true(hall.in_kitchen(vessel.global_position), "%s in the kitchen" % vessel.name)
	assert_ne(hall.burner_at(_vessel("Pot0").global_position), -1, "the first pot on a burner")
	assert_eq(hall.burner_at(_vessel("Pan0").global_position), -1, "the pans on the island")
	assert_true(hall.in_pantry(hall.get_node("Crate_tomato").global_position))
	assert_true(hall.in_fridge(hall.get_node("Crate_fish").global_position), "the fish in the fridge")


func test_a_crate_gives_an_ingredient_until_there_are_enough() -> void:
	var crate: IngredientCrate = hall.get_node("Crate_tomato")
	assert_eq(crate.prompt_key(cop), "PROMPT_CRATE_tomato")
	crate.use(cop)
	await wait_physics_frames(1)
	assert_eq(crate.loose(), 1)
	var tomato: Ingredient = get_tree().get_nodes_in_group("ingredients")[0]
	assert_eq(tomato.kind, "tomato")
	assert_lt(tomato.global_position.distance_to(crate.global_position), 1.0, "on top of the crate")
	for i in IngredientCrate.MAX_LOOSE + 2:
		crate.use(cop)
	await wait_physics_frames(1)
	assert_eq(crate.loose(), IngredientCrate.MAX_LOOSE, "no more than enough")


func test_an_ingredient_dropped_into_the_pot_goes_in() -> void:
	var pot := _vessel("Pot1")
	var onion := Ingredient.new()
	onion.kind = "onion"
	hall.add_child(onion)
	onion.global_position = pot.global_position + Vector3.UP * 0.3
	await wait_physics_frames(20)
	assert_eq(pot.kinds(), ["onion"] as Array[String])
	assert_true(not is_instance_valid(onion) or onion.is_queued_for_deletion(), "it's in the pot now")


func test_a_held_ingredient_doesnt_go_in() -> void:
	var pot := _vessel("Pot1")
	var tomato := Ingredient.new()
	hall.add_child(tomato)
	tomato.global_position = pot.global_position + Vector3.UP * 0.2
	tomato.hold(1, tomato.global_position)
	tomato.freeze = true
	await wait_physics_frames(5)
	assert_true(pot.items.is_empty())


func test_on_a_burner_it_cooks_and_off_it_doesnt() -> void:
	var pot := _vessel("Pot0")
	var pan := _vessel("Pan0")
	pot.items.append({"kind": "tomato", "cooked": 0.0, "burnt": false, "in": ""})
	pan.items.append({"kind": "fish", "cooked": 0.0, "burnt": false, "in": ""})
	await wait_physics_frames(30)
	assert_true(pot.on_fire())
	assert_gt(pot.items[0].cooked, 0.3, "the pot on the burner cooks")
	assert_false(pan.on_fire())
	assert_eq(pan.items[0].cooked, 0.0, "the pan on the island doesn't")


func test_past_its_time_it_burns_and_smokes() -> void:
	var pan := _vessel("Pan0")
	pan.items.append({"kind": "fish", "cooked": 0.0, "burnt": false, "in": ""})
	watch_signals(pan)
	pan.cook(KitchenVessel.BURN["pan"] - 0.5)
	assert_false(pan.is_burnt())
	pan.cook(1.0)
	assert_true(pan.is_burnt())
	assert_signal_emitted(pan, "burnt")
	assert_true(pan._smoke.emitting, "it smokes")
	assert_gt(KitchenVessel.BURN["pot"], KitchenVessel.BURN["pan"], "the pot holds out longer")


func test_e_serves_the_pot_onto_the_nearest_plate() -> void:
	var pot := _vessel("Pot0")
	var plate := _vessel("Plate0")
	pot.items.append({"kind": "tomato", "cooked": 6.5, "burnt": false, "in": ""})
	pot.items.append({"kind": "onion", "cooked": 6.5, "burnt": false, "in": ""})
	assert_eq(pot.held_prompt_key(cop), "PROMPT_POUR_NO_PLATE", "far from the plates")
	pot.use(cop)
	assert_eq(pot.items.size(), 2, "nowhere to serve it")
	pot.freeze = true
	pot.global_position = plate.global_position + Vector3(0, 0.4, 0.3)
	assert_eq(pot.held_prompt_key(cop), "PROMPT_POUR")
	assert_eq(pot.nearest_plate(), plate)
	pot.use(cop)
	assert_true(pot.items.is_empty())
	assert_eq(plate.kinds(), ["tomato", "onion"] as Array[String])
	assert_eq(plate.items[0]["in"], "pot", "cooked in the pot")
	assert_almost_eq(plate.items[0].cooked, 6.5, 0.01)


func test_a_lettuce_dropped_on_a_plate_stays_raw() -> void:
	var plate := _vessel("Plate3")
	var lettuce := Ingredient.new()
	lettuce.kind = "lettuce"
	hall.add_child(lettuce)
	lettuce.global_position = plate.global_position + Vector3.UP * 0.25
	await wait_physics_frames(20)
	assert_eq(plate.kinds(), ["lettuce"] as Array[String])
	assert_eq(plate.items[0]["in"], "", "raw")
	assert_eq(plate.held_prompt_key(cop), "PROMPT_HOLDING", "a plate isn't poured")


func test_the_kitchen_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_CRATE_ENOUGH", "PROMPT_POT_EMPTY", "PROMPT_PAN_EMPTY", "PROMPT_POUR",
		"PROMPT_POUR_NO_PLATE", "HINT_POUR_NO_PLATE"]
	for kind: String in Ingredient.KINDS:
		keys.append("PROMPT_CRATE_" + kind)
	for key in keys:
		assert_ne(tr(key), key)
