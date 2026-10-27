extends GutTest

## The magic popcorn's story at the bowling alley (allanamiento-bolera.md, step 6): the sack hidden with its extras,
## the machine spitting bouncing pebbles (never more than MAX lying around) and the cop who picks one up biting it (the
## clue, once).

const SCENE := preload("res://scenes/levels/bowling.tscn")
const RIG := preload("res://scripts/case/bowling/pebble_popcorn_rig.gd")


func _alley() -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.story_id = "bowl_popcorn"
	alley.case_seed = 5
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


func test_the_sack_is_hidden_with_its_extras() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.main, alley.hidden[0])
	assert_almost_eq(alley.main.mass, 10.0, 0.01)
	assert_eq(alley.extras.size(), 2, "the paint and the receipt")


func test_the_machine_spits_bouncing_pebbles() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	assert_eq(alley.rig.pebbles.size(), 0)
	await wait_seconds(RIG.SPIT_EVERY + 0.5)
	assert_eq(alley.rig.pebbles.size(), 1, "one every few seconds")
	var pebble: Grabbable = alley.rig.pebbles[0]
	assert_almost_eq(pebble.physics_material_override.bounce, RIG.BOUNCE, 0.01)
	var from := Vector2(Bowling.POPCORN_AT.x, Bowling.POPCORN_AT.z)
	var at := alley.to_local(pebble.global_position)
	assert_gt(Vector2(at.x, at.z).distance_to(from), 0.5, "it flew out of the machine")


func test_never_more_than_max_pebbles() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	for i in RIG.MAX + 4:
		alley.rig.spit()
	await wait_physics_frames(2)
	assert_eq(alley.rig.pebbles.size(), RIG.MAX)


func test_picking_up_a_pebble_bites_it_and_is_the_clue_once() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	var first: Grabbable = alley.rig.spit()
	var second: Grabbable = alley.rig.spit()
	first.hold(cop.get_node("Grabber").get_instance_id(), first.global_position + Vector3.UP * 0.3)
	await wait_physics_frames(2)
	assert_true(alley.rig.cracked)
	assert_has(alley.raid.clues_found, tr("BOWL_POPCORN_CLUE"))
	var clues: int = alley.raid.clues_found.size()
	second.hold(cop.get_node("Grabber").get_instance_id(), second.global_position + Vector3.UP * 0.3)
	await wait_physics_frames(2)
	assert_true(alley.rig.bitten.has(second), "every pebble cracks")
	assert_eq(alley.raid.clues_found.size(), clues, "the clue once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_BOWL_POPCORN_B", "BRIEF_BOWL_POPCORN_C", "BRIEF_BOWL_POPCORN_D", "OBJ_FIND_PEBBLE_SACK",
			"OBJ_EXTRA_PAINT_CAN", "OBJ_EXTRA_POPCORN_RECEIPT", "PIPO_CLUE_bowl_popcorn", "BOWL_POPCORN_RATTLE",
			"BOWL_POPCORN_CRACK", "HINT_BOWL_POPCORN_BITE", "BOWL_POPCORN_CLUE"]:
		assert_ne(tr(key), key, key)
