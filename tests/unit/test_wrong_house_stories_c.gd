extends GutTest

## The guilty neighbor's last pair of stories (docs/diseno/casa-equivocada.md, step 7): the mailman's stolen letters
## and the fake perfume.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")
const STEP := 1.0 / 60.0

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


func test_all_six_stories_come_up() -> void:
	var seen := {}
	for seed_value in 30:
		seen[WrongHouse.pick_story(seed_value + 1, [])] = true
	assert_eq(seen.size(), 6)
	for story: String in ["letters", "perfume"]:
		assert_eq(WrongHouse.pick_story(1, ["--story=" + story]), story)


func test_letters_shown_his_bag_the_mailman_tells_where_the_stamps_are() -> void:
	await _open("letters")
	var rig := place.rig as WhLettersRig
	var mailman := place.mailman
	mailman.set_physics_process(false)
	assert_eq(place.main, rig.bag)
	assert_eq(WrongHouse.house_of(rig.stamps.global_position), place.guilty)
	var line := tr("MAILMAN_BAG") % tr(WhLettersRig.spot_key(place.hidden_spots[1]))
	assert_eq(mailman.bag_line, line)
	mailman.use(cop)
	assert_eq(mailman.said(), mailman.clue, "without the bag, who lives where")
	rig.bag.global_position = mailman.global_position + Vector3(1.0, 0.5, 0)
	mailman.use(cop)
	assert_eq(mailman.said(), line)
	assert_true(place.clues.has(line), "it goes to the checklist")
	assert_eq(place.main, rig.bag, "he lets you keep it until the case is closed")


func test_letters_every_hiding_spot_has_a_name() -> void:
	for spot in WrongHouse.SPOTS.size():
		var key := WhLettersRig.spot_key(spot)
		assert_ne(tr(key), key, key)


func test_letters_opened_envelopes_in_his_bin_are_a_clue() -> void:
	await _open("letters")
	var bin := (place.rig as WhLettersRig).bin_clue
	assert_eq(WrongHouse.house_of(bin.global_position + Vector3(0, 0, -3)), place.guilty, "by his mailbox")
	bin.use(cop)
	assert_eq(place.clues, [tr("CLUE_WH_ENVELOPES")])


func test_perfume_the_jug_is_fragile_and_cracking_it_makes_you_smell() -> void:
	await _open("perfume")
	var rig := place.rig as WhPerfumeRig
	assert_eq(place.main, rig.jug)
	assert_lt(rig.jug.safe_speed, Evidence.SAFE_SPEED, "fragile")
	var grabber: Grabber = cop.get_node("Grabber")
	rig.flask.hold(grabber.get_instance_id(), rig.flask.global_position)
	rig.flask.hit(3.0)
	assert_true(rig.smelly.has(cop))
	rig.flask.let_go(grabber.get_instance_id())
	rig.set_physics_process(false)
	rig._physics_process(WhPerfumeRig.SMELL + 0.1)
	assert_false(rig.smelly.has(cop), "it wears off")


func test_perfume_the_street_dogs_follow_whoever_smells() -> void:
	await _open("perfume")
	var rig := place.rig as WhPerfumeRig
	rig.set_physics_process(false)
	await wait_physics_frames(10)
	cop.set_physics_process(false)
	cop.global_position = Vector3(0, 0.1, WrongHouse.LOT_Z - 1.0)
	var dog := rig.dogs[0]
	var start := dog.global_position.distance_to(cop.global_position)
	for i in int(2.0 / STEP):
		rig._physics_process(STEP)
	assert_almost_eq(dog.global_position.distance_to(WhPerfumeRig.DOG_HOMES[0]), 0.0, 0.2, "nobody smells: it stays")
	rig.smelly[cop] = WhPerfumeRig.SMELL
	for i in int(5.0 / STEP):
		rig._physics_process(STEP)
	var flat := Vector2(dog.global_position.x - cop.global_position.x, dog.global_position.z - cop.global_position.z)
	assert_lt(flat.length(), start, "it came after the cop")
	assert_lt(flat.length(), WhPerfumeRig.DOG_KEEP + 0.5, "and stays by them")


func test_perfume_the_flashlight_shows_the_smell_lines() -> void:
	await _open("perfume")
	var rig := place.rig as WhPerfumeRig
	rig.set_physics_process(false)
	assert_false(rig.lines[0].visible)
	rig._physics_process(STEP)
	assert_false(rig.lines_seen, "not without the light")
	var light := cop.belt.flashlight
	light.toggle()
	light.global_position = rig.lines[0].global_position + Vector3(0, 0, 2.0)
	light.look_at(rig.lines[0].global_position)
	rig._physics_process(STEP)
	assert_true(rig.lines_seen)
	assert_true(rig.lines[0].visible)
	assert_eq(place.clues, [tr("CLUE_WH_SMELL")])
	assert_eq(WrongHouse.house_of(rig.lines[0].global_position), place.guilty)
