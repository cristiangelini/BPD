extends GutTest

## The supermarket's aisle 13 (allanamiento-super.md, step 6): the gondola at the back of aisle 4 slides aside when cops
## run into it for long enough, the first time is the clue, and behind it the tonic box waits in aisle 13; the sample
## bottles and the mustache are hidden.

const SCENE := preload("res://scenes/levels/supermarket.tscn")


func _super(story := "super_aisle13") -> Supermarket:
	var store: Supermarket = SCENE.instantiate()
	store.story_id = story
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


## The cop on the gondola's push side, running toward it.
func _run_into(store: Supermarket, cop: Cop) -> void:
	var rig := store.rig
	cop.global_position = store.to_global(rig.GONDOLA_AT + Vector3(-0.75, 0.1, 0))
	cop.look_at(cop.global_position + store.global_basis.x)
	cop.is_running = true


func test_the_tonic_box_is_in_aisle_13_and_the_extras_are_hidden() -> void:
	var store := _super()
	await wait_physics_frames(2)
	assert_has(store.raid.suspicions, "super_aisle13")
	assert_not_null(store.main)
	assert_eq(store.raid.main_evidence, store.main)
	var at := store.to_local(store.main.global_position)
	assert_between(at.x, Supermarket.STORE_X, store.rig.AISLE_EAST_X, "in aisle 13")
	assert_eq(store.extras.size(), 2)
	assert_eq(store.hidden, store.extras)


func test_running_into_it_long_enough_slides_it_and_is_the_clue_once() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var cop: Cop = store.get_node("Cop")
	_run_into(store, cop)
	await wait_physics_frames(30)
	assert_false(rig.opened, "half a second isn't enough")
	assert_gt(rig.pushed, 0.0)
	await wait_seconds(1.6)
	assert_true(rig.opened)
	assert_has(store.raid.clues_found, tr("SUPER_AISLE13_CLUE"))
	await wait_seconds(1.2)
	assert_almost_eq(store.to_local(rig.gondola.global_position).z, rig.GONDOLA_AT.z - rig.SLIDE, 0.05, "slid aside")
	var clues: int = store.raid.clues_found.size()
	rig.open()
	assert_eq(store.raid.clues_found.size(), clues, "the clue only once")


func test_walking_into_it_or_running_away_does_nothing() -> void:
	var store := _super()
	await wait_physics_frames(2)
	var rig := store.rig
	var cop: Cop = store.get_node("Cop")
	_run_into(store, cop)
	cop.look_at(cop.global_position - store.global_basis.x)
	await wait_physics_frames(10)
	assert_eq(rig.pushed, 0.0, "facing away")
	_run_into(store, cop)
	cop.is_running = false
	await wait_physics_frames(10)
	assert_eq(rig.pushed, 0.0, "walking")


func test_the_doorway_is_only_there_in_this_story() -> void:
	var mine := _super()
	await wait_physics_frames(2)
	assert_true(_through(mine, [mine.rig.gondola.get_rid()]), "behind the gondola there's a way through")
	assert_false(_through(mine, []), "the gondola covers it")
	mine.free()
	var other := _super("super_dates")
	await wait_physics_frames(2)
	assert_false(_through(other, []), "a wall in other stories")


## Whether a ray from aisle 4 into aisle 13, at the doorway, hits nothing.
func _through(store: Supermarket, exclude: Array[RID]) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(store.to_global(Vector3(7.0, 1.0, Supermarket.AISLE_13_DOOR_Z)),
		store.to_global(Vector3(8.6, 1.0, Supermarket.AISLE_13_DOOR_Z)))
	ray.exclude = exclude
	return store.get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func test_its_texts_exist() -> void:
	for key: String in ["BRIEF_SUPER_AISLE13_B", "BRIEF_SUPER_AISLE13_C", "BRIEF_SUPER_AISLE13_D", "OBJ_FIND_TONIC_BOX",
			"OBJ_EXTRA_TONIC_SAMPLES", "OBJ_EXTRA_FAKE_MUSTACHE", "LALO_CLUE_super_aisle13", "SUPER_AISLE_13",
			"SUPER_AISLE13_CREAK", "SUPER_AISLE13_CLUE"]:
		assert_ne(tr(key), key)
