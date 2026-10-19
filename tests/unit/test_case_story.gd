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
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	assert_eq(house.story, GrandpaHouse.BINGO, "the bingo is the default story")
	assert_eq(house.evidence.size(), house.story.evidence.size())
	for i in house.evidence.size():
		assert_eq(house.evidence[i].scene_file_path, house.story.evidence[i].resource_path)
	assert_eq(house.cards.size(), house.story.drawer_count)
