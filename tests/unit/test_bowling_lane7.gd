extends GutTest

## Lane 7's story at the bowling alley (allanamiento-bolera.md, step 6): the crate hidden with its extras, the curtain
## in the back wall, the return giving back a ball too many with another alley's name every few rolls (never more than
## MAX), and the cop who picks one up reading the name (the clue, once).

const SCENE := preload("res://scenes/levels/bowling.tscn")
const RIG := preload("res://scripts/case/bowling/lane_seven_rig.gd")


func _alley() -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.story_id = "bowl_lane7"
	alley.case_seed = 5
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


func test_the_crate_is_hidden_with_its_extras_and_the_curtain_hangs() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.main, alley.hidden[0])
	assert_almost_eq(alley.main.mass, 15.0, 0.01)
	assert_eq(alley.extras.size(), 2, "the sign and the plan")
	var sign := alley.get_node("Built").get_children().filter(func(node: Node) -> bool:
		return node is Label3D and (node as Label3D).text == "BOWL_LANE7_SIGN")
	assert_eq(sign.size(), 1, "the curtain's sign")


func test_every_third_roll_brings_a_foreign_ball_up_its_return() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	alley.reset_pins(0)
	alley.reset_pins(2)
	assert_eq(alley.rig.foreign.size(), 0)
	alley.reset_pins(4)
	assert_eq(alley.rig.foreign.size(), 1)
	var ball: BowlingBall = alley.rig.foreign[0]
	assert_eq(ball.rack, Bowling.rack_of(4), "up the return of the lane that rolled")
	await wait_seconds(1.0)
	var rack := Bowling.rack_spot(ball.rack, 1)
	assert_lt(Vector2(ball.position.x - rack.x, ball.position.z - rack.z).length(), 0.6, "on its rack")
	var tags := ball.get_children().filter(func(node: Node) -> bool: return node is Label3D)
	assert_eq((tags[0] as Label3D).text, "BOWL_FOREIGN_1", "another alley's name")


func test_never_more_than_max_foreign_balls() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	for i in RIG.EXTRA_EVERY * (RIG.MAX + 2):
		alley.reset_pins(i % 3 * 2)
	assert_eq(alley.rig.foreign.size(), RIG.MAX)


func test_picking_up_a_foreign_ball_is_the_clue_once() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	var ball: BowlingBall = alley.rig.extra_ball(0)
	await wait_physics_frames(2)
	assert_false(alley.rig.read)
	ball.hold(cop.get_node("Grabber").get_instance_id(), ball.global_position + Vector3.UP * 0.4)
	await wait_physics_frames(2)
	assert_true(alley.rig.read)
	assert_has(alley.raid.clues_found, tr("BOWL_FOREIGN_CLUE"))
	var clues: int = alley.raid.clues_found.size()
	await wait_physics_frames(2)
	assert_eq(alley.raid.clues_found.size(), clues, "once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_BOWL_LANE7_B", "BRIEF_BOWL_LANE7_C", "BRIEF_BOWL_LANE7_D", "OBJ_FIND_STOLEN_BALLS",
			"OBJ_EXTRA_TORN_SIGN", "OBJ_EXTRA_SECRET_PLAN", "PIPO_CLUE_bowl_lane7", "BOWL_LANE7_SIGN", "BOWL_RETURN_EXTRA",
			"BOWL_FOREIGN_1", "BOWL_FOREIGN_2", "BOWL_FOREIGN_3", "BOWL_FOREIGN_CLUE"]:
		assert_ne(tr(key), key, key)
