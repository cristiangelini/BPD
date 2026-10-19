extends GutTest

const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")


func test_menu_texts_are_translation_keys() -> void:
	var menu: Control = add_child_autofree(MENU_SCENE.instantiate())
	for label: Label in [menu.get_node("Box/Title"), menu.get_node("Box/Subtitle")]:
		assert_true(label.text.begins_with("MENU_"), "%s should use a tr() key" % label.name)


func test_play_is_disabled_until_the_first_case_exists() -> void:
	var menu: Control = add_child_autofree(MENU_SCENE.instantiate())
	assert_true(menu.get_node("%PlayButton").disabled)
