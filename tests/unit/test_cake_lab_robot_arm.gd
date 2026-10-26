extends GutTest

## The cake lab with the robot arm's story (docs/diseno/laboratorio.md, step 5): the 15 kg arm decorating on a kitchen
## counter, the cream it throws in the face of a cop nearby, the cake with oil in its cream as the clue, and the
## remote and the manual hidden with the seed.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab(case_seed := 5) -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.story_id = "robot_arm"
	lab.case_seed = case_seed
	lab.get_node("Cop").input_enabled = false
	lab.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_the_arm_decorates_on_its_counter_and_the_extras_are_hidden() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	var rig := lab.rig as RobotArmRig
	assert_eq(lab.main, rig.arm)
	assert_almost_eq(rig.arm.mass, 15.0, 0.01)
	assert_lt(rig.arm.global_position.distance_to(RobotArmRig.ARM_AT), 0.1, "stays on the counter")
	assert_true(rig.is_working())
	assert_eq(lab.extras.size(), 2, "the remote and the manual")


func test_a_cop_close_by_gets_cream_in_the_face() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as RobotArmRig
	var cop: Cop = lab.get_node("Cop")
	cop.global_position = Vector3(RobotArmRig.ARM_AT.x + 1.0, CakeLab.FLOOR_TOP, RobotArmRig.ARM_AT.z + 0.8)
	await wait_seconds(RobotArmRig.SPLAT_EVERY + 0.3)
	assert_eq(rig.splats, 1)
	assert_true(rig.is_creamed(cop), "can't see")
	await wait_seconds(RobotArmRig.CREAM_TIME + 0.2)
	assert_false(rig.is_creamed(cop), "wiped off")


func test_a_cop_far_away_stays_clean() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as RobotArmRig
	var cop: Cop = lab.get_node("Cop")
	cop.global_position = Vector3(RobotArmRig.ARM_AT.x + 4.0, CakeLab.FLOOR_TOP, RobotArmRig.ARM_AT.z)
	await wait_seconds(RobotArmRig.SPLAT_EVERY + 0.3)
	assert_eq(rig.splats, 0)


func test_carried_off_it_stops_decorating() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as RobotArmRig
	rig.arm.hold(1, rig.arm.global_position)
	assert_false(rig.is_working())
	rig.arm.let_go(1)


func test_the_oily_cake_is_a_clue() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as RobotArmRig
	assert_eq(rig.oily_cake.prompt_key(lab.get_node("Cop")), "PROMPT_OILY_CAKE")
	rig.oily_cake.use(lab.get_node("Cop"))
	assert_has(lab.raid.clues_found, tr("CLUE_OIL_CREAM"))


func test_the_arm_in_the_trunk_solves_the_case() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	lab.main.global_position = lab.car.to_global(Vector3(0, 0.9, -1.7))
	await wait_physics_frames(10)
	assert_true(lab.car.is_delivered(lab.main))
	assert_true(lab.raid.mark(lab.raid.suspicions.find("robot_arm")))
	lab.car.enter(lab.get_node("Cop"))
	assert_true(lab.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_ROBOT_ARM_B", "BRIEF_ROBOT_ARM_C", "BRIEF_ROBOT_ARM_D", "OBJ_FIND_ROBOT_ARM",
			"OBJ_EXTRA_REMOTE_CONTROL", "OBJ_EXTRA_FOREIGN_MANUAL", "POCHA_CLUE_robot_arm", "CLUE_OIL_CREAM",
			"PROMPT_OILY_CAKE", "HINT_CREAM_FACE"]:
		assert_ne(tr(key), key)
	assert_eq(CakeLab.STORIES.size(), CakeLab.SUSPICION_POOL.size(), "all six stories")
