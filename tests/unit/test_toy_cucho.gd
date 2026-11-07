extends GutTest

## Don Cucho in the toy store (docs/diseno/allanamiento-jugueteria.md, step 3): he starts at his bench and walks his
## round; the train's lever derails the train, which sets off the nearest shelf's toys, and he goes to put it back with
## his back to everything; the third time he knows the trick; and every release of toys he hears fills the complaint.

const SCENE := preload("res://scenes/levels/toy_store.tscn")


func _store() -> ToyStore:
	var store: ToyStore = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_he_starts_at_his_bench_and_walks_his_round() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var start := store.cucho.global_position
	assert_almost_eq(Vector2(start.x, start.z), Vector2(ToyStore.CUCHO_ROUTE[0].x, ToyStore.CUCHO_ROUTE[0].z),
		Vector2(0.1, 0.1))
	await wait_physics_frames(120)
	assert_gt(store.cucho.global_position.distance_to(start), 1.0, "he's on his way")
	assert_eq(store.cucho.errand(), "")


func test_the_lever_derails_the_train_and_he_puts_it_back() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	store.cucho.fix_time = 1.0
	store.train.print_copies(cop)
	assert_true(store.derailed)
	assert_true(store.train.is_jammed)
	assert_eq(store.wind_up.left[ToyStore.nearest_shelf(ToyStore.TUNNEL_AT)], WindUpRig.PER_SHELF - WindUpRig.PER_BUMP,
		"the crash sets off the nearest shelf")
	assert_eq(store.cucho.errand(), "printer")
	var fixing := false
	for i in 40:
		if store.cucho.is_fixing():
			fixing = true
			break
		await wait_physics_frames(30)
	assert_true(fixing, "he got to the train")
	assert_lt(store.cucho.global_position.distance_to(ToyStore.TRAIN_SPOT), 0.8)
	await wait_physics_frames(90)
	assert_false(store.train.is_jammed, "back on the track")
	assert_false(store.derailed)
	assert_gt(store.train.rest_left, 0.0)


func test_the_third_time_he_knows_the_trick() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	watch_signals(store.train)
	store.train.print_copies(cop)
	store.train.print_copies(cop)
	assert_eq(store.train.jobs, 1, "pushing it while derailed does nothing")
	for i in 2:
		store.train.fix()
		store.train.rest_left = 0.0
		var before := store.cucho.complaint
		store.train.print_copies(cop)
		if i == 1:
			assert_signal_emitted(store.train, "noticed")
			assert_almost_eq(store.cucho.complaint, before + ToyStore.NOTICED, 0.01)
	assert_eq(store.train.jobs, 2, "the third one doesn't derail it")


func test_he_hears_the_toys_go_off() -> void:
	var store := _store()
	await wait_physics_frames(2)
	assert_eq(store.cucho.complaint, 0.0)
	store.wind_up.release(0)
	assert_almost_eq(store.cucho.complaint, ToyStore.HEARD, 0.01)
	assert_almost_eq(store.complaint_bar.value, ToyStore.HEARD, 0.01)


func test_the_nearest_shelf_to_the_tunnel_is_the_front_right_one() -> void:
	assert_eq(ToyStore.nearest_shelf(ToyStore.TUNNEL_AT), 4)
