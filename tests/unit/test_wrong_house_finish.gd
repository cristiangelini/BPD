extends GutTest

## The wrong house's last step (docs/diseno/casa-equivocada.md, step 8): the chase when he drives off with the main
## evidence, Play's raid draw, the menu test button and its people online.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")
const MENU := preload("res://scenes/ui/main_menu.tscn")

var place: WrongHouse


func _open(story := "bills") -> void:
	place = SCENE.instantiate()
	place.case_seed = 77
	place.story_id = story
	(place.get_node("Cop") as Cop).input_enabled = false
	add_child_autofree(place)
	await wait_physics_frames(2)


func test_play_draws_it_among_the_raids() -> void:
	assert_has(PlaceDraw.ORDER, "wrong_house")
	assert_eq(PlaceDraw.pick(5, ["--place=wrong_house"]), "wrong_house")
	var seen := false
	for seed_value in 400:
		if PlaceDraw.pick(seed_value + 1, [], 0, false) == "wrong_house":
			seen = true
			break
	assert_true(seen)


func test_the_shift_starts_at_the_station() -> void:
	await _open()
	assert_true(place.raid.car_at_station())
	assert_not_null(place.city_map)


func test_its_people_are_synced_online() -> void:
	await _open()
	for npc: Node in [place.chola, place.neighbor, place.mailman]:
		assert_true(NpcSync.is_npc(npc), npc.name)


func test_off_with_the_main_one_the_chase_starts_and_getting_away_loses_it() -> void:
	await _open()
	place.neighbor.on_rack.append(place.main)
	place._on_fled()
	assert_not_null(place.chase)
	assert_false(place.main.visible, "on his roof rack")
	assert_false(place.raid.case_failed)
	place.chase.ended.emit(false)
	assert_true(place.raid.case_failed)
	assert_eq(place.raid.failed_label.text, "CASE_FAILED_WH_GOT_AWAY")


func test_caught_his_loot_is_by_his_car() -> void:
	await _open()
	place.neighbor.on_rack.append(place.extras[0])
	place.neighbor.on_rack.append(place.main)
	place._on_fled()
	place.chase.ended.emit(true)
	assert_false(place.raid.case_failed)
	for item: Grabbable in [place.extras[0], place.main]:
		assert_true(item.visible)
		assert_false(item.freeze)
		assert_eq(item.collision_layer, 4)
		assert_lt(item.global_position.distance_to(place.chase.truck.global_position), 4.0)


func test_off_without_the_main_one_there_is_no_chase() -> void:
	await _open()
	place.neighbor.on_rack.append(place.extras[0])
	place._on_fled()
	assert_null(place.chase)


func test_the_menu_has_a_test_button() -> void:
	var menu: Control = MENU.instantiate()
	add_child_autofree(menu)
	assert_not_null(menu.get_node_or_null("%WrongHouseButton"))
