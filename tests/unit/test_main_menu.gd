extends GutTest

const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")


func test_menu_texts_are_translation_keys() -> void:
	var menu: Control = add_child_autofree(MENU_SCENE.instantiate())
	for label: Label in [menu.get_node("Box/Title"), menu.get_node("Box/Subtitle")]:
		assert_true(label.text.begins_with("MENU_"), "%s should use a tr() key" % label.name)


func test_play_points_to_an_existing_scene() -> void:
	var menu: Control = add_child_autofree(MENU_SCENE.instantiate())
	assert_false(menu.get_node("%PlayButton").disabled)
	for path: String in PlaceDraw.PLACES.values():
		assert_true(ResourceLoader.exists(path), "every place Play can draw should exist")


func test_test_room_points_to_an_existing_scene() -> void:
	assert_true(ResourceLoader.exists(MainMenu.TEST_ROOM_SCENE), "the test room scene should exist")


func test_the_hotel_raid_has_its_shortcut() -> void:
	var menu: Control = add_child_autofree(MENU_SCENE.instantiate())
	var button: Button = menu.get_node("%HotelRaidButton")
	assert_eq(button.text, "MENU_HOTEL_RAID")
	assert_ne(tr(button.text), button.text)
	assert_eq(MainMenu.HOTEL_RAID_SCENE, PlaceDraw.PLACES["hotel_raid"])
