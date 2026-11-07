extends GutTest

## The costume shop's smoke bombs (allanamiento-disfraces.md, step 6): the box of bombs is hidden with the hat with a
## double bottom and the list of buyers, the show hat on the wig trunk puffs colored smoke when it's thrown (the clue)
## and a pink cloud comes out of the stock room every so often.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = seed
	place.story_id = "smoke_bombs"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_box_is_hidden_with_the_extras() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	assert_eq(place.main, place.hidden[0], "the box of bombs is the main evidence")
	assert_almost_eq(place.main.mass, 8.0, 0.01)
	assert_eq(place.extras.size(), 2, "the double hat and the list")


func test_the_show_hat_puffs_when_thrown_not_when_set_down() -> void:
	var place := _shop()
	await wait_physics_frames(10)
	var rig := place.rig as SmokeBombsRig
	assert_lt(rig.hat.position.distance_to(SmokeBombsRig.HAT_AT), 0.1, "on the wig trunk, still")
	assert_eq(rig.hat.puffs, 0)
	rig.hat.global_position = place.to_global(Vector3(-4.0, 1.2, 4.6))
	rig.hat.linear_velocity = Vector3(0, -4.0, 0)
	await wait_physics_frames(20)
	assert_eq(rig.hat.puffs, 1, "thrown on the floor, it puffs")
	assert_true(place.raid.clues_found.has(tr("CLUE_SHOW_HAT")))
	assert_not_null(place.find_child("SmokeCloud", false, false), "a cloud of smoke")


func test_pink_smoke_comes_out_of_the_stock_room() -> void:
	var place := _shop()
	var rig := place.rig as SmokeBombsRig
	rig._pink_left = 0.05
	await wait_physics_frames(5)
	assert_eq(rig.pink_clouds, 1)
	for key: String in ["BRIEF_SMOKE_B", "BRIEF_SMOKE_C", "BRIEF_SMOKE_D", "OBJ_FIND_SMOKE", "OBJ_EXTRA_DOUBLE_HAT",
			"OBJ_EXTRA_SMOKE_CLIENTS", "CLUE_SHOW_HAT", "MIMI_CLUE_smoke_bombs"]:
		assert_ne(tr(key), key, key)
