extends GutTest

## Play draws the place of the match from the case seed (docs/diseno/panaderia.md, step 5).

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_every_raid_comes_up_about_a_third_of_the_time() -> void:
	var count := {"grandpa": 0, "bakery": 0, "groomer": 0}
	for i in 300:
		count[PlaceDraw.pick(i + 1, [], 1)] += 1
	for place: String in count:
		assert_between(count[place], 70, 130, "even odds for %s (propuesta)" % place)
	assert_eq(PlaceDraw.pick(77, []), PlaceDraw.pick(77, []), "the same seed gives the same place for everyone")


func test_every_story_of_each_place_still_comes_up() -> void:
	var bakery := {}
	var grandpa := {}
	var groomer := {}
	for i in 300:
		var case_seed := i + 1
		match PlaceDraw.pick(case_seed, [], 1):
			"bakery":
				bakery[Bakery.pick_story(case_seed, [])] = true
			"groomer":
				groomer[Groomer.pick_story(case_seed, [])] = true
			_:
				grandpa[GrandpaHouse.pick_story(case_seed, []).id] = true
	assert_eq(bakery.size(), Bakery.STORIES.size())
	assert_eq(grandpa.size(), GrandpaHouse.STORIES.size())
	assert_eq(groomer.size(), Groomer.STORIES.size())


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
		assert_eq(PlaceDraw.pick(case_seed, ["--place=groomer"]), "groomer")
	assert_eq(PlaceDraw.pick(9, ["--place=moon"]), PlaceDraw.pick(9, []), "an unknown place is ignored")


func test_the_level_takes_the_drawn_seed_once() -> void:
	PlaceDraw.pending_seed = 41
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.get_node("Cop").input_enabled = false
	add_child_autofree(bakery)
	assert_eq(bakery.case_seed, 41)
	assert_eq(PlaceDraw.take_seed(), 0, "the next level draws its own")


func test_the_pet_salon_takes_the_drawn_seed_too() -> void:
	PlaceDraw.pending_seed = 43
	var groomer: Groomer = preload("res://scenes/levels/groomer.tscn").instantiate()
	groomer.get_node("Cop").input_enabled = false
	add_child_autofree(groomer)
	assert_eq(groomer.case_seed, 43)
	assert_eq(groomer.story_id, Groomer.pick_story(43, []), "and its story comes from it")


func test_every_third_shift_is_an_interrogation() -> void:
	for shift in range(1, 7):
		var place := PlaceDraw.pick(5, [], shift)
		assert_eq(place == "interrogation", shift % 3 == 0, "shift %d" % shift)


func test_without_a_campaign_one_in_three_is_an_interrogation() -> void:
	var interrogations := 0
	for i in 300:
		interrogations += int(PlaceDraw.pick(i + 1, []) == "interrogation")
	assert_between(interrogations, 70, 130)


func test_the_draw_follows_the_campaigns_shift() -> void:
	Campaign.current = Campaign.start_new()
	assert_eq(PlaceDraw.shift_now(), 1)
	Campaign.current.shift = 3
	assert_eq(PlaceDraw.pick(PlaceDraw.next_seed(), [], PlaceDraw.shift_now()), "interrogation")
	Campaign.current = null
	assert_eq(PlaceDraw.shift_now(), 0)
