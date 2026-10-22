extends GutTest

## The grandparents' suspicion (infiltracion.md, step 4): what they see in a cop fills their meters, a bingo miss or a
## falling disguise adds at once, and at 100 they shout "¡Son policías!".

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub
var cop: Cop
var watcher: ClubMember


func before_each() -> void:
	club = LEVEL.instantiate()
	club.case_seed = 4242
	cop = club.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)
	club.bingo.set_physics_process(false)
	watcher = club.members[0]


## Puts the cop 2 m in front of `watcher`, disguised.
func _in_front(disguised := true) -> void:
	if disguised:
		cop.put_on_disguise("wig", 0.0)
		cop.put_on_disguise("glasses", 0.0)
	cop.global_position = watcher.global_position - watcher.global_basis.z * 2.0
	await wait_physics_frames(2)


func test_a_disguised_cop_walking_by_is_fine() -> void:
	await _in_front()
	assert_true(watcher.sees_cop(cop))
	assert_eq(club.suspicion.offence(cop, GameScale.WALK_SPEED), 0.0)


func test_running_a_tool_and_no_disguise_are_suspicious() -> void:
	await _in_front(false)
	assert_gt(club.suspicion.offence(cop, 0.0), 0.0, "no disguise")
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("glasses", 0.0)
	assert_eq(club.suspicion.offence(cop, 0.0), 0.0)
	assert_eq(club.suspicion.offence(cop, GameScale.RUN_SPEED), ClubSuspicion.RUNNING, "running")
	cop.belt_select(0)
	assert_gt(club.suspicion.offence(cop, 0.0), 0.0, "a tool in hand")


func test_behind_them_they_dont_see() -> void:
	cop.global_position = watcher.global_position + watcher.global_basis.z * 2.0
	await wait_physics_frames(1)
	assert_false(watcher.sees_cop(cop))


func test_seeing_it_fills_the_meter_and_shows_a_mark() -> void:
	await _in_front(false)
	for i in 60:
		club.suspicion._physics_process(0.05)
	assert_gt(watcher.suspicion, ClubMember.DOUBT)
	assert_true(watcher.get_node("Mark").visible, "the ? over the head")


func test_it_calms_down() -> void:
	club.suspicion.raise(watcher, 40.0)
	for i in 20:
		club.suspicion._physics_process(0.1)
	assert_lt(watcher.suspicion, 40.0)


func test_a_bingo_miss_makes_the_neighbor_suspicious() -> void:
	var card := club.bingo.cards[0]
	card.use(cop)
	for i in ClubBingo.ROUND_CALLS:
		club.bingo.call_next()
		if not card.pending.is_empty():
			break
	club.bingo._physics_process(ClubBingo.MARK_TIME + 0.1)
	assert_gt(club.suspicion.highest(), ClubSuspicion.BINGO_MISS - 1.0)


func test_a_falling_piece_in_front_of_them() -> void:
	await _in_front()
	cop.lose_disguise("wig")
	club.suspicion._physics_process(0.016)
	assert_gt(watcher.suspicion, ClubSuspicion.DISGUISE_FELL - 1.0)


func test_at_100_they_find_out() -> void:
	watch_signals(club.suspicion)
	club.suspicion.raise(watcher, 100.0)
	assert_true(club.suspicion.found_out)
	assert_signal_emitted(club.suspicion, "discovered")
	assert_string_starts_with(watcher.said(), "CLUB_FOUND_OUT")
	assert_eq(club.chela.said(), "CHELA_FOUND_OUT")


func test_a_shout_nearby_is_heard() -> void:
	cop.global_position = watcher.global_position + Vector3(1, 0, 0)
	club.suspicion.shouted_by(cop)
	assert_eq(watcher.suspicion, ClubSuspicion.SHOUT)


func test_a_guest_follows_the_meters() -> void:
	club.suspicion.raise(watcher, 85.0)
	var state: Array = club.suspicion.net_state()
	var other: GrandpaClub = LEVEL.instantiate()
	other.case_seed = 4242
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	other.suspicion.apply_net_state(state)
	assert_eq(other.members[0].suspicion, 85.0)
