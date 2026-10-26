extends GutTest

## Play draws the place of the match from the case seed (docs/diseno/panaderia.md, step 5).

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_half_are_chases_and_the_crime_scene_the_traffic_control_the_infiltration_and_each_raid_a_seventh_of_the_rest() -> void:
	var count := {"grandpa": 0, "bakery": 0, "groomer": 0, "hardware": 0, "doll_factory": 0, "insurance": 0, "cake_lab": 0,
		"chase": 0, "crime_scene": 0, "circus": 0, "traffic": 0, "club": 0, "choir": 0, "mime": 0, "party": 0, "gym": 0, "school": 0, "bank": 0, "plaza": 0, "market": 0,
		"prison": 0, "transfer": 0, "blackout": 0, "visits": 0, "laundry": 0}
	for i in 600:
		count[PlaceDraw.pick(i + 1, [], 1)] += 1
	assert_between(count.chase, 250, 350, "half chases (Cristian, 20/10)")
	assert_between(count.crime_scene + count.circus, 25, 80, "even odds for the crime scenes (propuesta)")
	assert_gt(count.crime_scene, 5, "half at the pastry contest")
	assert_gt(count.circus, 5, "and half at the circus")
	assert_between(count.traffic, 25, 80, "even odds for the traffic control (propuesta)")
	# With the bank and the rally drawn before them, the raids are a few shifts in a hundred, so their share is counted
	# over more seeds: each of the seven raids comes up about a seventh of them (propuesta).
	var raids := {}
	for i in 3000:
		var place := PlaceDraw.pick(i + 1, [], 1)
		if place in PlaceDraw.ORDER:
			raids[place] = raids.get(place, 0) + 1
	var total: int = raids.values().reduce(func(sum: int, n: int) -> int: return sum + n, 0)
	for place: String in PlaceDraw.ORDER:
		assert_between(float(raids.get(place, 0)) / total, 0.07, 0.23, "%s comes up about a seventh of the raids" % place)
	assert_between(count.club + count.choir + count.mime + count.party + count.gym + count.school, 25, 80, "the infiltrations, as often as a raid (propuesta)")
	assert_between(count.bank, 15, 70, "the bank robbery, about as often as a raid (propuesta)")
	assert_between(count.plaza + count.market, 10, 60, "the politician's protection, about as often as a raid (propuesta)")
	assert_between(count.prison + count.transfer + count.blackout + count.visits + count.laundry, 5, 50,
		"a prison case, about as often as a raid (propuesta)")
	assert_gt(count.prison, 0, "a fifth the riot")
	assert_gt(count.transfer, 0, "a fifth the transfer")
	assert_gt(count.blackout, 0, "a fifth the blackout")
	assert_gt(count.visits, 0, "a fifth the visiting day")
	assert_gt(count.laundry, 0, "and a fifth the laundry")
	assert_gt(count.club, 1, "a sixth of them at the grandparents' club")
	assert_gt(count.choir, 1, "a sixth at the church choir")
	assert_gt(count.mime, 1, "a sixth at the mimes' theater")
	assert_gt(count.party, 1, "a sixth at the costume party")
	assert_gt(count.gym, 1, "a sixth at the gym")
	assert_gt(count.school, 1, "and a sixth at the thieves' school")
	assert_gt(count.plaza, 2, "half of the protections at the plaza's rally")
	assert_gt(count.market, 2, "and half on the market walk")
	assert_eq(PlaceDraw.pick(77, []), PlaceDraw.pick(77, []), "the same seed gives the same place for everyone")


func test_every_story_of_each_place_still_comes_up() -> void:
	var bakery := {}
	var grandpa := {}
	var groomer := {}
	var hardware := {}
	var factory := {}
	var insurance := {}
	var cake_lab := {}
	for i in 900:
		var case_seed := i + 1
		match PlaceDraw.pick(case_seed, [], 1, false):
			"bakery":
				bakery[Bakery.pick_story(case_seed, [])] = true
			"groomer":
				groomer[Groomer.pick_story(case_seed, [])] = true
			"hardware":
				hardware[HardwareStore.pick_story(case_seed, [])] = true
			"doll_factory":
				factory[DollFactory.pick_story(case_seed, [])] = true
			"insurance":
				insurance[InsuranceOffice.pick_story(case_seed, [])] = true
			"cake_lab":
				cake_lab[CakeLab.pick_story(case_seed, [])] = true
			_:
				grandpa[GrandpaHouse.pick_story(case_seed, []).id] = true
	assert_eq(bakery.size(), Bakery.STORIES.size())
	assert_eq(grandpa.size(), GrandpaHouse.STORIES.size())
	assert_eq(groomer.size(), Groomer.STORIES.size())
	assert_eq(hardware.size(), HardwareStore.STORIES.size())
	assert_eq(factory.size(), DollFactory.STORIES.size())
	assert_eq(insurance.size(), InsuranceOffice.STORIES.size())
	assert_eq(cake_lab.size(), CakeLab.STORIES.size())


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
