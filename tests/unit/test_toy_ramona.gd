extends GutTest

## Doña Ramona and the gift (docs/diseno/allanamiento-jugueteria.md, step 4): a shelf puts a toy in empty hands; she
## walks the front aisle; without a toy she's busy, and a cop who hands her one hears what she saw, once per cop.

const SCENE := preload("res://scenes/levels/toy_store.tscn")


func _store() -> ToyStore:
	var store: ToyStore = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_a_shelf_hands_a_toy_to_empty_hands() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var shelf := store.shelves[0]
	assert_eq(shelf.prompt_key(cop), "PROMPT_TAKE_TOY")
	shelf.use(cop)
	assert_true(cop.get_node("Grabber").held is ShelfToy)
	assert_eq(shelf.prompt_key(cop), "", "not with full hands")


func test_she_walks_the_front_aisle() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_almost_eq(store.ramona.position.distance_to(ToyStore.RAMONA_ROUTE[0]), 0.0, 0.05)
	await wait_physics_frames(120)
	assert_gt(store.ramona.position.x, ToyStore.RAMONA_ROUTE[0].x + 0.5, "on her way")
	assert_almost_eq(store.ramona.position.z, ToyStore.RAMONA_ROUTE[0].z, 0.01)


func test_without_a_toy_she_is_busy() -> void:
	var store := _store()
	store.ramona.clue = "the ball pit"
	store.ramona.clue_speech = "lo vi en el pelotero"
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	assert_eq(store.ramona.prompt_key(cop), "PROMPT_TALK_RAMONA")
	store.ramona.use(cop)
	assert_eq(store.ramona.said(), "RAMONA_BUSY")
	assert_false(store.ramona.has_told)


func test_a_toy_buys_what_she_saw_once_per_cop() -> void:
	var store := _store()
	store.ramona.clue = "the ball pit"
	store.ramona.clue_speech = "lo vi en el pelotero"
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	watch_signals(store.ramona)
	store.shelves[1].use(cop)
	assert_eq(store.ramona.prompt_key(cop), "PROMPT_GIVE_TOY")
	store.ramona.use(cop)
	assert_null(cop.get_node("Grabber").held, "she took the toy")
	assert_eq(store.ramona.said(), "lo vi en el pelotero")
	assert_signal_emitted_with_parameters(store.ramona, "told", ["the ball pit"])
	store.shelves[1].use(cop)
	store.ramona.use(cop)
	assert_eq(store.ramona.said(), "RAMONA_AGAIN")
	assert_eq(store.ramona.gifts, 2)


func test_without_a_story_she_saw_nothing() -> void:
	var store := _store()
	await wait_physics_frames(2)
	store.ramona.clue = ""
	store.ramona.clue_speech = ""
	var cop: Cop = store.get_node("Cop")
	store.shelves[2].use(cop)
	store.ramona.use(cop)
	assert_eq(store.ramona.said(), "RAMONA_NOTHING")
	assert_false(store.ramona.has_told)
