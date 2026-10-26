extends GutTest

## The hardware store's nails on the street (docs/diseno/ferreteria.md, step 6): the patch where the patrol car parks,
## the flat tire at half speed, the giant magnet that fixes it and picks up nails, the clue across the street and the
## bucket in the trunk.

const STORE_SCENE := preload("res://scenes/levels/hardware_store.tscn")


func _store() -> HardwareStore:
	var store: HardwareStore = STORE_SCENE.instantiate()
	store.story_id = "street_nails"
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func test_the_bucket_is_hidden_and_the_nails_cover_the_parking_spot() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as StreetNailsRig
	assert_eq(store.main.scene_file_path, "res://scenes/props/nail_bucket.tscn")
	assert_eq(rig.magnet.scene_file_path, "res://scenes/props/giant_magnet.tscn")
	assert_eq(rig.clusters.size(), 9 * 4)
	var door := CityLayout.anchor("hardware") * CityLayout.parking("hardware").origin
	assert_true(rig._near_cluster(door, StreetNailsRig.HIT_RADIUS), "right where the car parks")


func test_a_flat_tire_halves_the_top_speed() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var top := store.car.top_speed()
	(store.rig as StreetNailsRig).puncture()
	assert_true(store.car.flat)
	assert_almost_eq(store.car.top_speed(), top * PatrolCar.FLAT_SHARE, 0.01)


func test_driving_over_the_nails_punctures_the_tire() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as StreetNailsRig
	store.car.global_position = rig.clusters[0].global_position + Vector3(0, 0.5, 0)
	store.car.linear_velocity = Vector3(3, 0, 0)
	await wait_physics_frames(1)
	assert_true(store.car.flat)


func test_the_magnet_fixes_the_tire_and_picks_up_nails() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var rig := store.rig as StreetNailsRig
	rig.puncture()
	var before := rig.clusters.size()
	rig.magnet.freeze = true
	rig.magnet.global_position = rig.clusters[0].global_position + Vector3(0, 0.3, 0)
	await wait_physics_frames(2)
	assert_lt(rig.clusters.size(), before, "it picked them up")
	rig.magnet.global_position = store.car.global_position + Vector3(1.5, 0, 0)
	await wait_physics_frames(2)
	assert_false(store.car.flat)


func test_the_nails_across_the_street_are_the_storys_clue() -> void:
	var store := _store()
	await wait_physics_frames(2)
	(store.rig as StreetNailsRig).clue_nails.use(store.get_node("Cop"))
	assert_eq(store.raid.clues_found, [tr("CLUE_STREET_NAILS")] as Array[String])


func test_the_bucket_in_the_trunk_solves_the_case() -> void:
	var store := _store()
	var cop: Cop = store.get_node("Cop")
	await wait_physics_frames(10)
	var bucket := store.main
	bucket.global_position = store.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(store.car.is_delivered(bucket))
	assert_true(store.raid.mark(store.raid.suspicions.find("street_nails")))
	store.car.enter(cop)
	assert_true(store.raid.case_solved)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_STREET_NAILS_B", "BRIEF_STREET_NAILS_C", "BRIEF_STREET_NAILS_D", "OBJ_FIND_NAIL_BUCKET",
			"OBJ_EXTRA_COMMISSION_BOOK", "OBJ_EXTRA_MAGNET", "COSME_CLUE_street_nails", "CLUE_STREET_NAILS",
			"PROMPT_LOOSE_NAILS", "HINT_FLAT_TIRE", "HINT_TIRE_FIXED"]:
		assert_ne(tr(key), key)
