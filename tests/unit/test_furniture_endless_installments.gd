extends GutTest

## The furniture store's endless installments story (allanamiento-muebleria.md, step 5): the book of installments is
## hidden with its extras, the price tags' fine print is the clue for a cop close enough, Don Cajón offers installments
## to every cop who looks at him (even with his complaint high), and the book solves the case in the trunk.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store(case_seed := 5) -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.story_id = "endless_installments"
	store.case_seed = case_seed
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


## Puts `cop` 3 m in front of Don Cajón, looking at his face (or away from it).
func _face_cajon(store: FurnitureStore, cop: Cop, away := false) -> void:
	var cajon := store.cajon
	var at := cajon.global_position + Vector3(0, 0, 3.0)
	cop.global_position = at
	var eye := cajon.global_position + Vector3.UP * FloorBoss.EYE
	var look := eye if not away else at * 2.0 - eye
	cop.camera.look_at(look, Vector3.UP)


func test_the_book_is_hidden_with_its_extras() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "endless_installments")
	assert_eq(store.hidden.size(), 3)
	assert_eq(store.main, store.hidden[0])
	assert_almost_eq(store.main.mass, 1.0, 0.01)
	assert_eq(store.main.full_value, 1000.0)
	assert_eq(store.extras.size(), 2, "the stamp and the calculator")
	var rig := store.rig as EndlessInstallmentsRig
	assert_eq(rig.tags.size(), store.sofas.size() + store.beds.size(), "a price tag on every sofa and bed")


func test_a_cop_close_to_a_tag_reads_the_fine_print_once() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as EndlessInstallmentsRig
	assert_false(rig.fine_print_read, "the cop starts out by the patrol car")
	var cop: Cop = store.get_node("Cop")
	cop.global_position = store.sofas[0].global_position + Vector3(0, 0.5, 1.0)
	await wait_physics_frames(3)
	assert_true(rig.fine_print_read)
	assert_has(store.raid.clues_found, tr("CLUE_FINE_PRINT"))
	var clues: int = store.raid.clues_found.size()
	rig.read_fine_print(cop)
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_looking_at_cajon_brings_an_offer_even_with_his_complaint_high() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as EndlessInstallmentsRig
	var cop: Cop = store.get_node("Cop")
	store.cajon.scold(80.0, "CAJON_SAW")
	_face_cajon(store, cop, true)
	assert_false(rig.looks_at_cajon(cop), "looking away")
	_face_cajon(store, cop)
	assert_true(rig.looks_at_cajon(cop))
	assert_true(rig.offer(cop))
	assert_eq(rig.offers, 1)
	assert_eq(store.cajon._bubble.text, "CAJON_OFFER_1")
	assert_false(rig.offer(cop), "not to the same cop again right away")
	assert_eq(rig.offers, 1)


func test_he_offers_on_his_own_when_looked_at() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as EndlessInstallmentsRig
	var cop: Cop = store.get_node("Cop")
	store.cajon.set_physics_process(false)
	_face_cajon(store, cop)
	await wait_physics_frames(2)
	assert_eq(rig.offers, 1)


func test_the_book_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	await wait_physics_frames(10)
	var book := store.main
	book.global_position = store.car.to_global(Vector3(0, 1.0, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(book))
	assert_true(store.raid.mark(store.raid.suspicions.find("endless_installments")))
	store.car.enter(store.get_node("Cop"))
	assert_true(store.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_ENDLESS_INSTALLMENTS_B", "BRIEF_ENDLESS_INSTALLMENTS_C", "BRIEF_ENDLESS_INSTALLMENTS_D",
			"OBJ_FIND_INSTALLMENT_BOOK", "OBJ_EXTRA_INSTALLMENT_STAMP", "OBJ_EXTRA_ENDLESS_CALCULATOR",
			"TABLITA_CLUE_endless_installments", "PRICE_TAG_INSTALLMENTS", "PRICE_TAG_FINE_PRINT", "HINT_FINE_PRINT",
			"CLUE_FINE_PRINT", "CAJON_OFFER_1", "CAJON_OFFER_2", "CAJON_OFFER_3"]:
		assert_ne(tr(key), key)
