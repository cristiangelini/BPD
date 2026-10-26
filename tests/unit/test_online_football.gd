extends GutTest

## The charity match online (politico-futbol.md, step 7; docs/diseno/online.md): the host's pitch plays the match and
## every PC sees the same clock, score, deputy on the grass, referee and end.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const PITCH_SCENE := preload("res://scenes/levels/football_pitch.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var pitch: FootballPitch = PITCH_SCENE.instantiate()
		pitch.case_seed = SEED
		pitch.get_node("Cop/Grabber").input_enabled = false
		return pitch)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _pitch(net: Node) -> FootballPitch:
	return OnlinePcs.level(net) as FootballPitch


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _pitch(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.match_clock.follower, "the guest's match only shows the host's")
	assert_true(guest.lustre.follower)
	assert_true(guest.referee.follower)
	assert_true(guest.match_clock.tank.follower)
	assert_false(_pitch(pcs[0]).case.follower)


func test_the_clock_and_the_score_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _pitch(pcs[0])
	var guest := _pitch(pcs[1])
	host.match_clock.start()
	host.score.goal(FootballScore.Team.VETERANS)
	await wait_until(func() -> bool: return guest.match_clock.state == FootballMatch.State.FIRST \
		and guest.score.goals == [0, 1], 5.0)
	assert_eq(guest.score.goals, [0, 1])
	assert_lt(guest.match_clock.left, FootballMatch.HALF + 0.01)
	assert_true(guest.get_node("Cop").has_node("Bib"), "the bibs go on there too")


func test_the_deputy_down_and_his_injuries_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _pitch(pcs[0])
	var guest := _pitch(pcs[1])
	host.lustre.hit(host.lustre.politician.global_position + Vector3(-1, 0, 0))
	await wait_until(func() -> bool: return guest.lustre.down and guest.case.injuries == 1, 5.0)
	assert_true(guest.lustre.down)
	assert_almost_eq((guest.politician.get_node("Model") as Node3D).rotation.x, -PI / 2, 0.01, "lying there too")
	assert_eq(guest.case.injuries, 1)


func test_the_tank_charging_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _pitch(pcs[0])
	var guest := _pitch(pcs[1])
	host.match_clock.tank.charge()
	await wait_until(func() -> bool: return guest.match_clock.tank.charging, 5.0)
	assert_true(guest.match_clock.tank.charging)


func test_a_cuffed_referee_and_the_clues_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _pitch(pcs[0])
	var guest := _pitch(pcs[1])
	host.referee.use(host.get_node("Cop"))
	host.referee.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return guest.referee.is_cuffed() and guest.case.clues.size() == 1, 5.0)
	assert_true(guest.referee.is_cuffed())
	assert_eq(guest.case.clues, ["envelope"])


func test_the_getaway_and_the_end_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _pitch(pcs[0])
	var guest := _pitch(pcs[1])
	host.score.scored.emit(FootballScore.Team.LUSTRE, host.politician)
	host.match_clock.finished.emit()
	await wait_until(func() -> bool: return guest.case.chase != null, 5.0)
	assert_not_null(guest.case.chase, "the referee rides off there too")
	assert_false(guest.referee.visible)
	host.case.chase.ended.emit(true)
	await wait_until(func() -> bool: return guest.case.shift_over, FootballCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.solved())
	assert_true(guest.case.referee_detained())
