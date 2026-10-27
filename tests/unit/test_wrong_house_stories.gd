extends GutTest

## The guilty neighbor's stories (docs/diseno/casa-equivocada.md, steps 5 to 7): what each hides in his house, the
## order he takes it out, its own clue and its mechanic.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")

var place: WrongHouse
var cop: Cop


func _open(story: String, seed_value := 77) -> void:
	place = SCENE.instantiate()
	place.case_seed = seed_value
	place.story_id = story
	cop = place.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(place)
	await wait_physics_frames(2)


func test_both_stories_come_up_and_story_picks_one() -> void:
	var seen := {}
	for seed_value in 10:
		seen[WrongHouse.pick_story(seed_value + 1, [])] = true
	assert_eq(seen.size(), WrongHouse.STORIES.size())
	assert_eq(WrongHouse.pick_story(1, ["--story=gnomes"]), "gnomes")
	assert_eq(WrongHouse.pick_story(2, ["--story=bills"]), "bills")


func test_what_each_story_hides_is_in_his_house_and_he_takes_the_main_one_last() -> void:
	for story: String in WrongHouse.STORIES:
		await _open(story)
		var keys: Array = WrongHouse.STORIES[story].extra_keys
		assert_eq(place.extras.size(), keys.size(), story)
		assert_not_null(place.main, story)
		for item: Evidence in place.hidden:
			assert_eq(WrongHouse.house_of(item.global_position), place.guilty, "%s: hidden at home" % story)
		var loot: Array[Grabbable] = []
		loot.assign(place.extras)
		loot.append(place.main)
		assert_eq(place.neighbor.loot, loot, "%s: the extras first, the main one last" % story)
		assert_true(WrongHouse.grounds_rect(place.guilty).has_point(Vector2(place.main.global_position.x,
			place.main.global_position.z)), "%s: he can take the main one" % story)
		place.free()


func test_he_can_reach_every_hiding_spot() -> void:
	await _open("bills")
	await wait_physics_frames(10)
	var map := place.get_world_3d().navigation_map
	for spot: Dictionary in WrongHouse.SPOTS:
		var to := WrongHouse.at(place.guilty, spot.at)
		var path := NavigationServer3D.map_get_path(map, place.neighbor.home, to, true)
		assert_false(path.is_empty(), spot.id)
		if path.is_empty():
			continue
		var end := path[path.size() - 1]
		assert_lt(Vector2(end.x - to.x, end.z - to.z).length(), GuiltyNeighbor.ARM, "%s: within his arm" % spot.id)
		assert_lt(absf(end.y - to.y), 1.2, "%s: on its floor" % spot.id)


func test_bills_the_ink_stains_your_hands_and_what_you_grab() -> void:
	await _open("bills")
	var rig := place.rig as WhBillsRig
	assert_eq(rig.ink_pot, place.extras[1])
	var grabber: Grabber = cop.get_node("Grabber")
	rig.ink_pot.hold(grabber.get_instance_id(), rig.ink_pot.global_position)
	rig._physics_process(0.1)
	assert_true(rig.inky.has(cop), "blue hands")
	rig.ink_pot.let_go(grabber.get_instance_id())
	var bills: Evidence = place.extras[0]
	grabber.held = bills
	rig._physics_process(0.1)
	assert_true(rig.inked.has(bills), "a blue print on it")
	assert_not_null(bills.get_node_or_null("InkPrint"))
	grabber.held = null
	rig._physics_process(WhBillsRig.INKY)
	assert_false(rig.inky.has(cop), "it wears off")
	grabber.held = place.main
	rig._physics_process(0.1)
	assert_false(rig.inked.has(place.main), "clean hands, no print")
	grabber.held = null


func test_bills_a_fake_bill_on_his_mailbox_is_a_clue() -> void:
	await _open("bills")
	var rig := place.rig as WhBillsRig
	assert_eq(WrongHouse.house_of(rig.bill_clue.global_position + Vector3(0, 0, -3)), place.guilty, "by his mailbox")
	rig.bill_clue.use(cop)
	assert_eq(place.clues, [tr("CLUE_WH_FAKE_BILL")])


func test_gnomes_one_of_twenty_alike_is_gold_and_three_times_as_heavy() -> void:
	await _open("gnomes")
	var rig := place.rig as WhGnomesRig
	assert_eq(rig.gnomes.size(), WhGnomesRig.GNOMES - 1)
	assert_eq(place.main, rig.gold)
	assert_true(place.main is HintedEvidence)
	assert_eq((place.main as HintedEvidence).hint_key, "HINT_WH_GOLD_GNOME")
	assert_almost_eq(rig.gold.mass, rig.gnomes[0].mass * 3.0, 0.01)
	var spot := WrongHouse.at(place.guilty, WhGnomesRig.gnome_at(WhGnomesRig.gold_spot(77)))
	assert_almost_eq(Vector2(rig.gold.global_position.x, rig.gold.global_position.z), Vector2(spot.x, spot.z), Vector2(0.05, 0.05))
	for gnome in rig.gnomes:
		assert_true(WrongHouse.grounds_rect(place.guilty).has_point(Vector2(gnome.global_position.x, gnome.global_position.z)))
	var fines := place.fines
	rig.gnomes[0].broken.emit(rig.gnomes[0].global_position)
	assert_eq(place.fines, fines + Ornament.FINE, "a ceramic one is a fine")


func test_gnomes_holes_in_dona_cholas_garden_are_a_clue() -> void:
	await _open("gnomes")
	var holes := place.find_children("*", "ClueSpot", false, false).filter(func(spot: Node) -> bool:
		return (spot as ClueSpot).prompt == "PROMPT_LOOK_HOLE")
	assert_eq(holes.size(), 1)
	var hole: ClueSpot = holes[0]
	assert_eq(WrongHouse.house_of(hole.global_position + Vector3(0, 0, -3)), place.chola_house())
	hole.use(cop)
	assert_eq(place.clues, [tr("CLUE_WH_GNOME_HOLES")])
