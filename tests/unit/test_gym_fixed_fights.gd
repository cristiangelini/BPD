extends GutTest

## The gym raid's fixed fights story (allanamiento-gimnasio.md, step 5): the punching bags swing when punched and
## shove whoever stands behind them, one of them clangs like metal (the clue, once), and the betting book, the gloves
## with a horseshoe and the cardboard belt are hidden.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _gym(case_seed := 5) -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.story_id = "fixed_fights"
	gym.case_seed = case_seed
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func test_every_bag_can_be_punched_and_one_has_metal() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as FixedFightsRig
	assert_eq(rig.bags.size(), GymHall.BAGS.size())
	assert_eq(rig.bags.filter(func(bag: GymPunchBag) -> bool: return bag.metal).size(), 1)
	for bag in rig.bags:
		assert_not_null(bag.look, "%s swings its model" % bag.name)
		assert_eq(bag.prompt_key(gym.get_node("Cop")), "PROMPT_PUNCH_BAG")


func test_the_metal_bag_clangs_and_the_first_punch_is_the_clue() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as FixedFightsRig
	var cop: Cop = gym.get_node("Cop")
	var plain := rig.bags[1 - rig.metal]
	plain.use(cop)
	assert_does_not_have(gym.raid.clues_found, tr("CLUE_BAG_CLANG"), "a plain bag just thuds")
	rig.bags[rig.metal].use(cop)
	assert_has(gym.raid.clues_found, tr("CLUE_BAG_CLANG"))
	var clues: int = gym.raid.clues_found.size()
	rig.bags[rig.metal].use(cop)
	assert_eq(gym.raid.clues_found.size(), clues, "the clue only once")


func test_a_punched_bag_shoves_whoever_is_behind_it() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as FixedFightsRig
	var bag := rig.bags[0]
	var puncher: Cop = gym.get_node("Cop")
	var behind: Cop = COP_SCENE.instantiate()
	behind.input_enabled = false
	gym.add_child(behind)
	behind.get_node("Grabber").input_enabled = false
	puncher.global_position = bag.global_position + Vector3(0, 0.1, 0.8)
	behind.global_position = bag.global_position + Vector3(0, 0.1, -0.8)
	await wait_physics_frames(2)
	bag.use(puncher)
	assert_true(behind.is_staggered(), "the one behind is shoved")
	assert_false(puncher.is_staggered(), "not the puncher")


func test_the_book_is_hidden_with_its_extras() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.main, gym.hidden[0])
	assert_almost_eq((gym.main as RigidBody3D).mass, 0.5, 0.01)
	assert_eq(gym.extras.size(), 2)
	assert_true(GymRaid.SPOTS[gym.hidden_spots[2]].heavy, "the long belt lies where it fits")
	for key: String in ["BRIEF_FIXED_FIGHTS_B", "BRIEF_FIXED_FIGHTS_C", "BRIEF_FIXED_FIGHTS_D", "OBJ_FIND_BETTING_BOOK",
			"OBJ_EXTRA_HORSESHOE_GLOVES", "OBJ_EXTRA_CARDBOARD_BELT", "LULA_CLUE_fixed_fights", "CLUE_BAG_CLANG",
			"PROMPT_PUNCH_BAG", "GYM_BAG_THUD", "GYM_BAG_CLANG"]:
		assert_ne(tr(key), key)


func test_the_gym_tells_its_six_stories() -> void:
	assert_eq(GymRaid.STORIES.size(), 6)
	for id: String in GymRaid.SUSPICION_POOL:
		assert_true(GymRaid.STORIES.has(id), id)
