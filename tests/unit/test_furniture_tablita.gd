extends GutTest

## Tablita, the furniture store's assembler (docs/diseno/allanamiento-muebleria.md, step 3): a cop who holds the
## bookcase's shelf up 5 s without moving hears what he saw, once; letting go or walking off drops it.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store() -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


## The cop in front of the bookcase, standing still on the floor.
func _by_the_shelf(store: FurnitureStore) -> Cop:
	var cop: Cop = store.get_node("Cop")
	cop.global_position = store.shelf.get_parent().to_global(Vector3(0, 0.1, 1.0))
	return cop


func test_tablita_and_his_bookcase_stand_in_the_middle() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_not_null(store.tablita)
	assert_lt(Vector2(store.tablita.position.x, store.tablita.position.z).length(), 4.0, "in the middle of the shop")
	assert_eq(store.shelf.prompt_key(store.get_node("Cop")), "PROMPT_HOLD_SHELF")
	assert_false(store.shelf.is_down())


func test_holding_it_up_five_seconds_he_tells_once() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop := _by_the_shelf(store)
	await wait_physics_frames(10)
	store.tablita.clue = "the clue"
	store.tablita.clue_speech = "I saw him hide it"
	watch_signals(store.tablita)
	store.shelf.use(cop)
	assert_eq(cop.turning, store.shelf, "busy holding it")
	assert_almost_eq(store.shelf.position, BookcaseShelf.SLOT, Vector3.ONE * 0.01, "up in its slot")
	await wait_seconds(BookcaseShelf.HOLD_TIME - 1.0)
	assert_signal_not_emitted(store.tablita, "told", "not before the time")
	await wait_seconds(1.5)
	assert_signal_emitted_with_parameters(store.tablita, "told", ["the clue"])
	assert_null(cop.turning, "free again")
	assert_almost_eq(store.shelf.position, BookcaseShelf.SLOT, Vector3.ONE * 0.01, "screwed in while he talks")
	assert_eq(store.shelf.prompt_key(cop), "")
	await wait_seconds(BookcaseShelf.SCREWED + 0.3)
	assert_eq(store.shelf.prompt_key(cop), "PROMPT_HOLD_SHELF", "loose again for the next cop")
	store.shelf.use(cop)
	await wait_seconds(BookcaseShelf.HOLD_TIME + 0.5)
	assert_signal_emit_count(store.tablita, "told", 1, "once")


func test_letting_go_too_soon_drops_it() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop := _by_the_shelf(store)
	await wait_physics_frames(10)
	watch_signals(store.shelf)
	store.shelf.use(cop)
	await wait_seconds(1.0)
	store.shelf.end_turn(cop)
	assert_signal_emitted(store.shelf, "dropped")
	assert_true(store.shelf.is_down(), "on the floor")
	assert_eq(store.shelf.prompt_key(cop), "", "not until Tablita picks it up")
	assert_true(store.tablita.listeners.is_empty())
	await wait_seconds(BookcaseShelf.ON_FLOOR + 0.3)
	assert_false(store.shelf.is_down(), "leaning on the bookcase again")


func test_walking_off_drops_it() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop := _by_the_shelf(store)
	await wait_physics_frames(10)
	watch_signals(store.shelf)
	store.shelf.use(cop)
	await wait_physics_frames(5)
	cop.global_position += Vector3(1.0, 0, 0)
	await wait_physics_frames(3)
	assert_signal_emitted(store.shelf, "dropped")
	assert_null(cop.turning)
	assert_signal_not_emitted(store.shelf, "held")


func test_with_nothing_to_tell_he_saw_nothing() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop := _by_the_shelf(store)
	await wait_physics_frames(10)
	store.tablita.clue_speech = ""
	store.shelf.use(cop)
	await wait_seconds(BookcaseShelf.HOLD_TIME + 0.3)
	assert_true(store.tablita.listeners.has(cop))
	assert_eq(store.tablita.get_node("Bubble").text, "TABLITA_NOTHING")
	assert_false(store.tablita.has_told)
