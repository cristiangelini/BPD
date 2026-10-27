extends GutTest

## Lustre's trips to the makeup room (politico-debate.md, step 6, decision 230): off at the break, late on his own
## (a blunder when the block starts), and led back by the hand in time.

const LEVEL := preload("res://scenes/levels/tv_studio.tscn")

var studio: TvStudio
var debate: TvDebate
var walks: TvMakeupWalk
var cop: Cop


func before_each() -> void:
	studio = LEVEL.instantiate()
	studio.case_seed = 7
	cop = studio.get_node("Cop") as Cop
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(studio)
	await wait_physics_frames(3)
	debate = studio.debate
	walks = PoliticianWalks.of(studio.politician) as TvMakeupWalk
	studio.sabotage.active = false
	debate.start()


func _to_break() -> void:
	debate.left = 0.01
	await wait_physics_frames(2)


func test_he_leaves_for_the_makeup_room_at_the_break() -> void:
	assert_not_null(walks)
	assert_false(debate.lustre_away(), "at his lectern during the block")
	await _to_break()
	assert_eq(debate.state, TvDebate.State.BREAK)
	assert_true(debate.lustre_away(), "off at the break")
	var start := studio.politician.global_position
	await wait_seconds(1.0)
	assert_gt(studio.politician.global_position.distance_to(start), 0.5, "walking to the mirror")


func test_on_his_own_he_reaches_the_mirror_and_is_late() -> void:
	await _to_break()
	await wait_until(func() -> bool: return walks.state == PoliticianWalks.State.GREETING, 15.0)
	assert_eq(walks.state, PoliticianWalks.State.GREETING, "at the mirror")
	var mirror := studio.to_global(TvStudio.MIRROR_AT)
	assert_lt(Vector2(studio.politician.global_position.x - mirror.x, studio.politician.global_position.z - mirror.z)
		.length(), 1.6)
	debate.left = 0.01
	await wait_physics_frames(2)
	assert_eq(debate.state, TvDebate.State.BLOCK)
	assert_eq(debate.blunders, 1, "late for the block")


func test_led_back_by_the_hand_he_is_in_time() -> void:
	await _to_break()
	await wait_seconds(1.0)
	walks.use(cop)
	assert_eq(walks.state, PoliticianWalks.State.LED)
	cop.global_position = walks.podium
	await wait_until(func() -> bool: return not debate.lustre_away(), 10.0)
	assert_false(debate.lustre_away(), "back at his lectern")
	debate.left = 0.01
	await wait_physics_frames(2)
	assert_eq(debate.blunders, 0)


func test_away_his_turn_earns_nothing() -> void:
	walks.walk_off()
	var image := debate.image
	debate.speaker = "lustre"
	debate._close_turn()
	assert_eq(debate.image, image, "the moderator gave the word to Malvón")
