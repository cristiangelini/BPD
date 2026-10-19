extends GutTest

## A raid tells its story from a CaseStory resource (docs/diseno/historias.md).

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func test_bingo_story_is_complete() -> void:
	var story: CaseStory = GrandpaHouse.BINGO
	assert_eq(story.id, "bingo")
	assert_gt(story.briefing.size(), 0)
	assert_eq(story.heavy.size(), story.evidence.size(), "one heavy flag per evidence")
	assert_eq(story.half_heights.size(), story.evidence.size(), "one half height per evidence")
	assert_not_null(story.drawer_evidence)
	for key: String in story.briefing:
		assert_ne(tr(key), key, "briefing line %s is translated" % key)


func test_the_house_places_what_the_story_brings() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 41
	house.story = GrandpaHouse.BINGO
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	assert_eq(house.evidence.size(), house.story.evidence.size())
	for i in house.evidence.size():
		assert_eq(house.evidence[i].scene_file_path, house.story.evidence[i].resource_path)
	assert_eq(house.drawer_evidence.size(), house.story.drawer_count)


func test_the_story_comes_from_the_seed_or_the_command_line() -> void:
	for case_seed in [1, 2, 3, 8]:
		assert_has(GrandpaHouse.STORIES, GrandpaHouse.pick_story(case_seed, PackedStringArray()))
	assert_eq(GrandpaHouse.pick_story(3, PackedStringArray(["--story=bingo"])).id, "bingo")
	assert_eq(GrandpaHouse.pick_story(3, PackedStringArray(["--story=nope"])),
		GrandpaHouse.pick_story(3, PackedStringArray()), "an unknown id falls back to the draw")


func test_every_story_names_its_items_for_the_notes() -> void:
	for story: CaseStory in GrandpaHouse.STORIES:
		assert_eq(story.item_keys.size(), story.evidence.size(), story.id)
		for key: String in story.item_keys:
			assert_ne(tr("NOTE_ITEM_" + key), "NOTE_ITEM_" + key, "%s names %s" % [story.id, key])
		assert_ne(tr(story.find_key), story.find_key, story.id)
