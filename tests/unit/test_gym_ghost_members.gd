extends GutTest

## The gym raid's ghost members story (allanamiento-gimnasio.md, step 5): three of the six members are shop dummies
## that don't answer and don't bounce in the class, a cop who bumps into one knocks it over stiff (the clue, once), and
## the binder of invented members, the box of dummies and the fake stamp are hidden.

const RAID_SCENE := preload("res://scenes/levels/gym_raid.tscn")


func _gym(case_seed := 5) -> GymRaid:
	var gym: GymRaid = RAID_SCENE.instantiate()
	gym.story_id = "ghost_members"
	gym.case_seed = case_seed
	gym.get_node("Cop").input_enabled = false
	gym.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(gym)
	return gym


func test_three_of_the_members_are_dummies() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as GhostMembersRig
	assert_eq(rig.mannequins.size(), GhostMembersRig.MANNEQUINS)
	assert_eq(gym.members.size(), GymRaid.MEMBERS)
	var dummies := gym.members.filter(func(member: ClubMember) -> bool: return member.look == GhostMembersRig.LOOK)
	assert_eq(dummies.size(), GhostMembersRig.MANNEQUINS)
	assert_eq(gym.get_children().filter(func(node: Node) -> bool: return node is ClubMember).size(), GymRaid.MEMBERS,
		"the real members they replace are gone")
	var dummy := rig.mannequins[0]
	dummy.use(gym.get_node("Cop"))
	assert_string_starts_with(dummy.said(), "GYM_MANNEQUIN_")


func test_bumping_into_one_knocks_it_over_and_the_first_is_the_clue() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as GhostMembersRig
	var cop: Cop = gym.get_node("Cop")
	var dummy := rig.mannequins[0]
	cop.global_position = dummy.global_position + Vector3(0, 0.1, 2.0)
	await wait_physics_frames(2)
	cop.velocity = Vector3(0, 0, -4.0)
	cop.global_position = dummy.global_position + Vector3(0, 0.1, 0.5)
	await wait_physics_frames(4)
	assert_true(rig.fallen.has(dummy), "a running cop knocks it over")
	await wait_seconds(GhostMembersRig.FALL_TIME + 0.1)
	assert_almost_eq(dummy.rotation.x, -PI / 2, 0.01, "stiff as a board")
	assert_has(gym.raid.clues_found, tr("CLUE_MANNEQUIN_STIFF"))
	var clues: int = gym.raid.clues_found.size()
	rig.topple(rig.mannequins[1])
	assert_eq(gym.raid.clues_found.size(), clues, "the clue only once")


func test_the_dummies_dont_dance_in_the_class() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	var rig := gym.rig as GhostMembersRig
	var dummy := rig.mannequins[0]
	var turn := dummy.rotation.y
	gym.coach.start_at(4)
	gym.stereo.button.use(gym.get_node("Cop"))
	await wait_until(func() -> bool: return gym.in_class(), 10.0)
	await wait_physics_frames(10)
	assert_eq(dummy.rotation.y, turn, "it doesn't turn to the mirror")
	for member: ClubMember in gym.members:
		if member.look != GhostMembersRig.LOOK:
			assert_almost_eq(member.rotation.y, 0.0, 0.01, "the real ones do")


func test_the_binder_is_hidden_with_its_extras() -> void:
	var gym := _gym()
	await wait_physics_frames(2)
	assert_eq(gym.main, gym.hidden[0])
	assert_almost_eq((gym.main as RigidBody3D).mass, 1.0, 0.01)
	assert_eq(gym.extras.size(), 2)
	assert_true(GymRaid.SPOTS[gym.hidden_spots[1]].heavy, "the box of dummies in a spot it fits")
	for key: String in ["BRIEF_GHOST_MEMBERS_B", "BRIEF_GHOST_MEMBERS_C", "BRIEF_GHOST_MEMBERS_D",
			"OBJ_FIND_MEMBERS_BINDER", "OBJ_EXTRA_DUMMY_BOX", "OBJ_EXTRA_FAKE_STAMP", "LULA_CLUE_ghost_members",
			"GYM_MANNEQUIN_0", "GYM_MANNEQUIN_1", "GYM_MANNEQUIN_CUFFED", "GYM_MANNEQUIN_FELL", "CLUE_MANNEQUIN_STIFF"]:
		assert_ne(tr(key), key)
