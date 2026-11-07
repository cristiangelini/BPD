extends GutTest

## The karaoke raid online (allanamiento-karaoke.md, step 8): Rosaura, Toto and the customers are run by the host and
## followed by the guests, a host's microphone cable trips a guest's cop on its own PC, and the duets, what breaks and
## what each story's rig decides on the host show on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const SCENE := preload("res://scenes/levels/karaoke.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "karaoke_applause"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_karaoke)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_karaoke() -> Node3D:
	var place: Karaoke = SCENE.instantiate()
	place.case_seed = SEED
	place.story_id = _story
	return place


func test_rosaura_toto_and_the_customers_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Karaoke = OnlinePcs.level(pcs[0])
	var guest: Karaoke = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_boss.is_physics_processing(), "the guest's Rosaura only follows")
	assert_false(guest.toto.is_processing(), "and Toto")
	assert_true(guest.singers[0].follower, "and the customers")
	host._turn_left = 0.0
	await wait_until(func() -> bool: return host.on_turn != null and host.on_turn.singing, 8.0)
	var singer := host.singers.find(host.on_turn)
	await wait_until(func() -> bool:
		return guest.singers[singer].global_position.distance_to(host.on_turn.global_position) < 0.1, 5.0)
	assert_lt(guest.singers[singer].global_position.distance_to(host.on_turn.global_position), 0.1, "up on the stage")
	assert_null(guest.on_turn, "the host gives the turns")
	host.owner_boss.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.owner_boss.complaint - 30.0) < 0.5, 5.0)
	assert_almost_eq(guest.owner_boss.complaint, 30.0, 0.5)


func test_a_host_s_cable_trips_a_guest_s_cop() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Karaoke = OnlinePcs.level(pcs[0])
	var cop := OnlinePcs.own_cop(pcs[1])
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	var mic := host.mics[2]
	mic.in_stand = false
	mic.freeze = false
	mic.global_position = mic.foot + Vector3(3.0, 0.1, 0)
	copy.global_position = mic.foot + Vector3(1.5, 0, 0.1)
	copy.is_running = true
	mic._trip_cops()
	await wait_until(func() -> bool: return cop.is_staggered(), 5.0)
	assert_true(cop.is_staggered(), "knocked down on the guest's own PC")


func test_the_duets_and_what_breaks_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Karaoke = OnlinePcs.level(pcs[0])
	var guest: Karaoke = OnlinePcs.level(pcs[1])
	host.duet_call.duet()
	host.break_screen()
	host.drop_disco_ball()
	await wait_until(func() -> bool: return guest._shown_duets == 1 and guest.screen_cracked and guest.disco_fallen, 5.0)
	assert_eq(guest._shown_duets, 1, "«¡DUETO!» on the guest's screen, once")
	assert_true(guest.screen_cracked, "the screen")
	assert_true(guest.disco_fallen, "and the disco ball")


func test_the_applause_plays_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Karaoke = OnlinePcs.level(pcs[0])
	var guest: Karaoke = OnlinePcs.level(pcs[1])
	host.rig.applaud()
	await wait_until(func() -> bool: return guest.rig._played == 1, 5.0)
	assert_eq(guest.rig._played, 1, "«¡CLAP CLAP CLAP!» there too")


func test_the_lyrics_on_the_host_s_screen_show_on_the_guest() -> void:
	_story = "karaoke_lyrics"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Karaoke = OnlinePcs.level(pcs[0])
	var guest: Karaoke = OnlinePcs.level(pcs[1])
	host.rig.next_line()
	host.rig.set_physics_process(false)
	await wait_until(func() -> bool: return guest.rig._text.text == host.rig.showing, 5.0)
	assert_eq(guest.rig._text.text, host.rig.showing)


func test_a_guest_s_squeaky_voice_shows_on_its_own_pc() -> void:
	_story = "karaoke_helium"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Karaoke = OnlinePcs.level(pcs[0])
	var cop := OnlinePcs.own_cop(pcs[1])
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	host.rig._squeak(copy)
	await wait_until(func() -> bool: return cop.has_node("Squeak"), 5.0)
	assert_true(cop.has_node("Squeak"), "«¡Hola, soy la ley!» over the guest's own cop")
