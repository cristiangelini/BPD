extends GutTest

## The nursery raid with the golden gnome (allanamiento-vivero.md, step 7): the 20 kg gnome in a spot for heavy things
## solves the case in the trunk, the gnome with fresh paint peels near a cop (a clue) and the row turns to look at
## the golden one.

const SCENE := preload("res://scenes/levels/nursery.tscn")


func _nursery(case_seed := 5) -> Nursery:
	var nursery: Nursery = SCENE.instantiate()
	nursery.story_id = "gold_gnome"
	nursery.case_seed = case_seed
	nursery.get_node("Cop").input_enabled = false
	nursery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(nursery)
	return nursery


func test_the_golden_gnome_solves_the_case() -> void:
	var nursery := _nursery()
	await wait_physics_frames(10)
	assert_has(nursery.raid.suspicions, "gold_gnome")
	assert_eq(nursery.main.scene_file_path, "res://scenes/props/nursery_gold_gnome.tscn")
	assert_true(Nursery.SPOTS[nursery.hidden_spots[0]].heavy, "it's in a spot for heavy things")
	assert_eq(nursery.main.mass, 20.0)
	assert_eq(nursery.extras.size(), 2, "the photo and the paint")
	nursery.main.global_position = nursery.car.to_global(Vector3(0, 0.9, -1.7))
	await wait_physics_frames(10)
	assert_true(nursery.car.is_delivered(nursery.main))
	assert_true(nursery.raid.mark(nursery.raid.suspicions.find("gold_gnome")))
	nursery.car.enter(nursery.get_node("Cop"))
	assert_true(nursery.raid.case_solved)


func test_the_painted_gnome_peels_near_a_cop() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	var rig := nursery.rig as GoldGnomeRig
	assert_eq(rig.painted, 5 % Nursery.GNOMES)
	assert_false(rig.peeled, "nobody near it")
	var cop: Cop = nursery.get_node("Cop")
	cop.global_position = nursery.gnomes[rig.painted].global_position + Vector3(0, 0.1, -1.0)
	await wait_seconds(GoldGnomeRig.CHECK_EVERY * 2.5)
	assert_true(rig.peeled)
	assert_eq(nursery.gnomes[rig.painted].find_children("Flake*", "", false, false).size(), GoldGnomeRig.FLAKES.size())
	assert_eq(nursery.raid.clues_found.count(tr("CLUE_FRESH_PAINT")), 1, "one clue")


func test_the_gnomes_look_at_the_golden_one() -> void:
	var nursery := _nursery()
	await wait_physics_frames(2)
	for gnome in nursery.gnomes:
		var to := nursery.to_local(nursery.main.global_position) - gnome.position
		assert_almost_eq(gnome.rotation.y, atan2(to.x, to.z), 0.01)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_GOLD_GNOME_B", "BRIEF_GOLD_GNOME_C", "BRIEF_GOLD_GNOME_D", "OBJ_FIND_GOLD_GNOME",
			"OBJ_EXTRA_MAYOR_PHOTO", "OBJ_EXTRA_GNOME_PAINT", "CLUE_FRESH_PAINT", "NURSERY_GOLD_SHOWS",
			"BROTECITO_CLUE_gold_gnome"]:
		assert_ne(tr(key), key, key)
