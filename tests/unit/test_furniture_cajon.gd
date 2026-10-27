extends GutTest

## Don Cajón, the furniture store's salesman (docs/diseno/allanamiento-muebleria.md, step 2): his round and the
## complaint, the pitch that brings him to a cop trying a sofa or a bed (his back to the shop), the cop who gets up and
## cuts it short, the third try he sees through, and what he sees broken or knocked down.

const SCENE := preload("res://scenes/levels/furniture_store.tscn")


func _store() -> FurnitureStore:
	var store: FurnitureStore = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


## The pitch rests and fools him again, as if 45 s had passed and it was a new day.
func _rested(store: FurnitureStore) -> void:
	store.pitch.rest_left = 0.0


## Puts Don Cajón right by `seat`'s pitch spot and waits until he's at it.
func _pitched(store: FurnitureStore, seat: ShowroomSeat) -> void:
	var cop: Cop = store.get_node("Cop")
	store.cajon.route = [store.to_local(seat.to_global(seat.pitch_point())) + Vector3(0.6, 0, 0)] as Array[Vector3]
	store.cajon.start_at(0)
	seat.use(cop)
	for i in 240:
		await wait_physics_frames(1)
		if store.cajon.is_fixing():
			return


func test_don_cajon_walks_his_round_with_the_complaint_bar() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var start := store.cajon.global_position
	assert_almost_eq(start.distance_to(FurnitureStore.CAJON_ROUTE[0]), 0.0, 0.2)
	await wait_physics_frames(60)
	assert_gt(store.cajon.global_position.distance_to(start), 0.5, "on his way")
	assert_eq(store.complaint_bar.value, 0.0)
	assert_eq(store.sofas[0].prompt_key(store.get_node("Cop")), "PROMPT_TRY_SOFA")
	assert_eq(store.beds[0].prompt_key(store.get_node("Cop")), "PROMPT_TRY_BED")


func test_trying_a_sofa_brings_him_to_sell_it_his_back_to_the_shop() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var seat := store.sofas[0]
	store.cajon.fix_time = 1.0
	await _pitched(store, seat)
	assert_almost_eq(cop.global_position.distance_to(seat.to_global(seat.sit_point())), 0.0, 0.3, "the cop sits on it")
	assert_true(store.cajon.is_fixing(), "selling it")
	assert_false(store.cajon.can_see(FurnitureStore.GOODS[2].at + Vector3.UP), "he sees nothing meanwhile")
	await wait_seconds(1.3)
	assert_false(store.cajon.is_fixing())
	assert_false(store.pitch.is_jammed)
	assert_gt(store.pitch.rest_left, 0.0, "and it rests")
	seat.use(cop)
	assert_false(store.pitch.is_jammed, "not again so soon")


func test_getting_up_cuts_the_pitch_short() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var seat := store.beds[0]
	await _pitched(store, seat)
	assert_true(store.cajon.is_fixing())
	cop.global_position += Vector3(3.0, 0, 0)
	await wait_physics_frames(3)
	assert_false(store.cajon.is_fixing(), "back to his round")
	assert_false(store.pitch.is_jammed)


func test_the_third_try_he_sees_through() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	for i in SalesPitch.TRICKS:
		store.sofas[i % 2].use(cop)
		assert_true(store.pitch.is_jammed, "try %d fools him" % (i + 1))
		store.cajon.interrupt()
		store.pitch.fix()
		_rested(store)
	store.sofas[0].use(cop)
	assert_false(store.pitch.is_jammed, "the third doesn't")
	assert_eq(store.cajon.complaint, FurnitureStore.NOTICED)


func test_he_minds_his_lamps_wardrobes_and_chairs() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cajon := store.cajon
	cajon.route = [FurnitureStore.CAJON_ROUTE[2]] as Array[Vector3]
	cajon.start_at(0)
	await wait_physics_frames(2)
	store.break_good(1)
	assert_eq(cajon.complaint, FurnitureStore.SAW_GOOD, "the bedroom's lamp, right in front of him")
	store.wardrobes[0].tip()
	assert_eq(cajon.complaint, FurnitureStore.SAW_GOOD + FurnitureStore.SAW_TIPPED)
