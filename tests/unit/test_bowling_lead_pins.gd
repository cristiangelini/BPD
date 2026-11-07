extends GutTest

## The lead pins' story at the bowling alley (allanamiento-bolera.md, step 6): the mold in a heavy spot with its
## extras, lane 4's pins that don't fall and send a ball back, the weight a cop feels picking one up (the clue, once),
## and the other lanes' pins still made of wood.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley(case_seed := 5) -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.story_id = "bowl_lead_pins"
	alley.case_seed = case_seed
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


func test_the_mold_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.main, alley.hidden[0])
	assert_almost_eq(alley.main.mass, 20.0, 0.01)
	assert_true(Bowling.SPOTS[alley.hidden_spots[0]].heavy, "a heavy spot")
	assert_eq(alley.extras.size(), 2, "the lead pin and the invoice")


func test_lane_4s_pins_stand_and_send_the_ball_back() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	for pin: RigidBody3D in alley.pins[3]:
		assert_almost_eq(pin.mass, 5.0, 0.01)
	assert_almost_eq((alley.pins[2][0] as RigidBody3D).mass, Bowling.PIN_KG, 0.01, "lane 3's are wood")
	var ball: BowlingBall = alley.balls[4]
	ball.position = Vector3(Bowling.LANE_X[3], Bowling.FLOOR_TOP + BowlingBall.RADIUS + 0.01, 0.0)
	ball.linear_velocity = alley.global_basis * Vector3(0, 0, -8.0)
	await wait_seconds(2.0)
	assert_eq(alley.knocked(3), 0, "none down")
	assert_gt((alley.global_basis.inverse() * ball.linear_velocity).z, 0.5, "the ball rolls back")


func test_picking_up_a_lead_pin_is_the_clue_once() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	var pin: Grabbable = alley.pins[3][4]
	pin.hold(cop.get_node("Grabber").get_instance_id(), pin.global_position + Vector3.UP * 0.5)
	await wait_physics_frames(2)
	assert_true(alley.rig.felt)
	assert_has(alley.raid.clues_found, tr("BOWL_LEAD_CLUE"))
	var clues: int = alley.raid.clues_found.size()
	await wait_physics_frames(2)
	assert_eq(alley.raid.clues_found.size(), clues, "once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_BOWL_LEAD_B", "BRIEF_BOWL_LEAD_C", "BRIEF_BOWL_LEAD_D", "OBJ_FIND_LEAD_MOLD",
			"OBJ_EXTRA_LEAD_PIN", "OBJ_EXTRA_LEAD_INVOICE", "PIPO_CLUE_bowl_lead_pins", "BOWL_LEAD_HEAVY", "BOWL_LEAD_CLUE"]:
		assert_ne(tr(key), key, key)
