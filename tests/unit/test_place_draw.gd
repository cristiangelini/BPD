extends GutTest

## Play draws the place of the match from the case seed (docs/diseno/panaderia.md, step 5).

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_both_places_come_up_about_half_the_time() -> void:
	var count := {"grandpa": 0, "bakery": 0}
	for i in 200:
		count[PlaceDraw.pick(i + 1, [])] += 1
	assert_between(count.bakery, 70, 130, "even odds (propuesta)")
	assert_eq(PlaceDraw.pick(77, []), PlaceDraw.pick(77, []), "the same seed gives the same place for everyone")


func test_every_story_of_each_place_still_comes_up() -> void:
	var bakery := {}
	var grandpa := {}
	for i in 200:
		var case_seed := i + 1
		if PlaceDraw.pick(case_seed, []) == "bakery":
			bakery[Bakery.pick_story(case_seed, [])] = true
		else:
			grandpa[GrandpaHouse.pick_story(case_seed, []).id] = true
	assert_eq(bakery.size(), Bakery.STORIES.size())
	assert_eq(grandpa.size(), GrandpaHouse.STORIES.size())


func test_new_seeds_are_odd_and_even() -> void:
	var odd := 0
	for i in 100:
		var case_seed := PlaceDraw.new_seed()
		assert_gt(case_seed, 0)
		odd += case_seed % 2
	assert_between(odd, 20, 80, "with only odd seeds the grandpa's house always told the same story")


func test_place_argument_forces_the_place() -> void:
	for case_seed in [1, 3, 5, 7]:
		assert_eq(PlaceDraw.pick(case_seed, ["--place=bakery"]), "bakery")
		assert_eq(PlaceDraw.pick(case_seed, ["--place=grandpa"]), "grandpa")
	assert_eq(PlaceDraw.pick(9, ["--place=moon"]), PlaceDraw.pick(9, []), "an unknown place is ignored")


func test_the_level_takes_the_drawn_seed_once() -> void:
	PlaceDraw.pending_seed = 41
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.get_node("Cop").input_enabled = false
	add_child_autofree(bakery)
	assert_eq(bakery.case_seed, 41)
	assert_eq(PlaceDraw.take_seed(), 0, "the next level draws its own")
