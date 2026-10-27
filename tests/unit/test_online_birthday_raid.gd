extends GutTest

## The birthday party raid online (allanamiento-cumple.md, step 6): Chispita and the kids are run by the host and
## followed by the guests, the candles work from any PC, the cake and the balloons break everywhere, a kid hanging on
## a guest's cop slows it down on the guest's own PC, and the stories' rigs (the castle that lets the air out, the
## gifts Chispita takes, the horn in the restroom) show on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const PARTY := preload("res://scenes/levels/birthday_raid.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "diamond_balloons"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_party)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_party() -> Node3D:
	var party: BirthdayRaid = PARTY.instantiate()
	party.case_seed = SEED
	party.story_id = _story
	return party


func test_chispita_and_the_kids_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: BirthdayRaid = OnlinePcs.level(pcs[0])
	var guest: BirthdayRaid = OnlinePcs.level(pcs[1])
	assert_false(guest.chispita.is_physics_processing(), "the guest's Chispita only follows")
	assert_false(guest.kids[1].is_physics_processing(), "and so do its kids")
	await wait_seconds(1.0)
	await wait_until(func() -> bool: return guest.kids[1].global_position.distance_to(host.kids[1].global_position) < 0.2,
		5.0)
	assert_lt(guest.kids[1].global_position.distance_to(host.kids[1].global_position), 0.2, "where the host's runs")


func test_the_candles_from_a_guest_start_the_song_everywhere() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: BirthdayRaid = OnlinePcs.level(pcs[0])
	var guest: BirthdayRaid = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.candles.button)
	await wait_until(func() -> bool: return host.candles.is_lit() and guest.candles.is_lit(), 5.0)
	assert_true(host.candles.is_lit(), "the guest's match reached the host")
	await wait_until(func() -> bool: return host.singing() and guest.singing(), 10.0)
	assert_true(guest.singing(), "they sing on the guest too")


func test_the_cake_and_a_balloon_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: BirthdayRaid = OnlinePcs.level(pcs[0])
	var guest: BirthdayRaid = OnlinePcs.level(pcs[1])
	host.break_cake()
	host.pop(3)
	await wait_until(func() -> bool: return guest.cake_broken and guest.popped.has(3), 5.0)
	assert_true(guest.cake_broken)
	assert_eq(guest.popped, [3] as Array[int])


func test_a_kid_on_a_guests_leg_slows_it_down_on_the_guests_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: BirthdayRaid = OnlinePcs.level(pcs[0])
	var guest: BirthdayRaid = OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var kid := host.kids[1]
	for other in host.kids:
		if other != kid:
			other.wanders = false
			other.position = Vector3(-9, BirthdayRaid.FLOOR_TOP, 9)
	guest_cop.global_position = guest.to_global(kid.position + Vector3(0.4, 0.1, 0))
	await wait_until(func() -> bool: return kid.is_hanging(), 5.0)
	assert_true(kid.is_hanging(), "on the guest's cop, on the host")
	await wait_until(func() -> bool: return guest_cop.slow_factor < 1.0, 5.0)
	assert_eq(guest_cop.slow_factor, PartyKid.HANG_SLOW, "the guest walks at half speed")


func test_the_castle_lets_the_air_out_on_the_guest_too() -> void:
	_story = "watch_castle"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: BirthdayRaid = OnlinePcs.level(pcs[0])
	var guest: BirthdayRaid = OnlinePcs.level(pcs[1])
	(host.rig as WatchCastleRig).deflate()
	await wait_until(func() -> bool: return guest.castle_flat and not (guest.rig as WatchCastleRig).inside, 5.0)
	assert_true(guest.castle_flat, "flat on the guest")
	assert_true(guest.main.visible, "and the bag is out")


func test_the_gifts_chispita_takes_go_on_the_guest_too() -> void:
	_story = "returning_gifts"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: BirthdayRaid = OnlinePcs.level(pcs[0])
	var guest: BirthdayRaid = OnlinePcs.level(pcs[1])
	(host.rig as ReturningGiftsRig).take_gift()
	await wait_until(func() -> bool: return (guest.rig as ReturningGiftsRig).taken == 1, 5.0)
	assert_false(guest.gifts[-1].visible, "gone from the guest's table too")


func test_the_horn_in_the_restroom_honks_on_the_guest_too() -> void:
	_story = "double_clown"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: BirthdayRaid = OnlinePcs.level(pcs[0])
	var guest: BirthdayRaid = OnlinePcs.level(pcs[1])
	host.chispita.global_position = host.to_global(Vector3(-8, BirthdayRaid.FLOOR_TOP, -6))
	(host.rig as DoubleClownRig).honk()
	(host.rig as DoubleClownRig).swap()
	await wait_until(func() -> bool: return (guest.rig as DoubleClownRig).honks == 1, 5.0)
	assert_eq((guest.rig as DoubleClownRig).honks, 1, "heard on the guest")
	assert_eq((guest.rig as DoubleClownRig).twin, 1, "and the other Chispita is back there too")
