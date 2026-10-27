extends GutTest

## The bowling alley raid online (allanamiento-bolera.md, step 8): Don Chuza, Pipo and the league players are run by
## the host and followed by the guests, Pipo's shoes go to a guest's cop on every PC, a host's ball trips a guest's
## cop on its own PC, and the points, the strikes, the trophy case, the screens, lane 7's balls and the popcorn's
## pebbles the host decides show on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SCENE := preload("res://scenes/levels/bowling.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "bowl_magnet"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_alley)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_alley() -> Node3D:
	var alley: Bowling = SCENE.instantiate()
	alley.case_seed = SEED
	alley.story_id = _story
	return alley


func test_don_chuza_pipo_and_the_players_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Bowling = OnlinePcs.level(pcs[0])
	var guest: Bowling = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_boss.is_physics_processing(), "the guest's Don Chuza only follows")
	assert_false(guest.pipo.is_processing(), "and Pipo")
	assert_true(guest.players[0].follower, "and the players")
	assert_false(guest.players[0].is_physics_processing(), "who don't bowl on their own")
	host.owner_boss.complaint = 30.0
	host.players[0].position += Vector3(0.5, 0, 0)
	await wait_until(func() -> bool: return absf(guest.owner_boss.complaint - 30.0) < 0.5 \
		and guest.players[0].global_position.distance_to(host.players[0].global_position) < 0.1, 5.0)
	assert_almost_eq(guest.owner_boss.complaint, 30.0, 0.5)
	assert_lt(guest.players[0].global_position.distance_to(host.players[0].global_position), 0.1)


func test_pipo_s_shoes_go_to_a_guest_s_cop_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Bowling = OnlinePcs.level(pcs[0])
	var guest: Bowling = OnlinePcs.level(pcs[1])
	var cop := OnlinePcs.own_cop(pcs[1])
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	cop.act("use", guest.pipo)
	await wait_until(func() -> bool: return host.pipo.wears(copy) and guest.pipo.wears(cop), 5.0)
	assert_true(host.pipo.wears(copy), "the host's Pipo gave them")
	assert_true(guest.pipo.wears(cop), "and the guest's cop skates less on its own PC")


func test_a_host_s_ball_trips_a_guest_s_cop() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Bowling = OnlinePcs.level(pcs[0])
	var cop := OnlinePcs.own_cop(pcs[1])
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	var ball := host.balls[0]
	ball.bowled = true
	ball.linear_velocity = Vector3(0, 0, -BowlingBall.TRIP_SPEED * 2)
	ball._hit(copy)
	await wait_until(func() -> bool: return cop.is_staggered(), 5.0)
	assert_true(cop.is_staggered(), "knocked down on the guest's own PC")


func test_the_points_the_strikes_and_what_breaks_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Bowling = OnlinePcs.level(pcs[0])
	var guest: Bowling = OnlinePcs.level(pcs[1])
	host.scores[1] = 9
	host.strike_call.strike(1, false)
	host.break_trophy_case()
	host.break_screen(2)
	await wait_until(func() -> bool: return guest.scores[1] == 9 and guest._shown_strikes == 1 and guest.case_broken \
		and guest.broken_screens.has(2), 5.0)
	assert_eq(guest._score_labels[1].text, "9", "the host's points on the guest's screen")
	assert_eq(guest._shown_strikes, 1, "Don Chuza's strike party, once")
	assert_true(guest.case_broken, "the trophy case")
	assert_true(guest.broken_screens.has(2), "and the screen")


func test_lane_7_s_foreign_balls_come_up_on_the_guest() -> void:
	_story = "bowl_lane7"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Bowling = OnlinePcs.level(pcs[0])
	var guest: Bowling = OnlinePcs.level(pcs[1])
	host.rig.extra_ball(0)
	var copies := func() -> Array: return guest.get_children().filter(func(node: Node) -> bool:
		return node is BowlingBall and (node as BowlingBall).tag != "")
	await wait_until(func() -> bool: return not copies.call().is_empty(), 5.0)
	assert_eq(copies.call().size(), 1, "the guest's copy of the host's ball")
	var tag := (copies.call()[0] as Node).get_node_or_null("Tag") as Label3D
	assert_not_null(tag)
	assert_eq(tag.text, "BOWL_FOREIGN_1", "with the other alley's name on it")


func test_the_popcorn_s_pebbles_come_out_on_the_guest() -> void:
	_story = "bowl_popcorn"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Bowling = OnlinePcs.level(pcs[0])
	var guest: Bowling = OnlinePcs.level(pcs[1])
	host.rig._since_spit = -100.0
	guest.rig._since_spit = -100.0
	host.rig.spit()
	var pebbles := func() -> Array: return guest.get_children().filter(func(node: Node) -> bool:
		return node is PopcornPebble)
	await wait_until(func() -> bool: return not pebbles.call().is_empty(), 5.0)
	assert_eq(pebbles.call().size(), 1, "the guest's copy of the host's pebble")
	host.rig.bites = 1
	await wait_until(func() -> bool: return guest.rig._shown_bites == 1, 5.0)
	assert_eq(guest.rig._shown_bites, 1, "and the «¡CRAC!» of a bite")
