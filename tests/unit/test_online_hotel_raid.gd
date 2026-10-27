extends GutTest

## The hotel raid online (hotel-allanamiento.md, step 7; docs/diseno/online.md): the host runs don Bostezo, doña
## Escoba, the sleepwalker and señor Ramón, and the guests' copies follow it: where they are, what they say, the
## complaint, the nap, the sleepwalker woken up and Ramón running off.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL := preload("res://scenes/levels/hotel_raid.tscn")

var _pcs: OnlinePcs


func after_each() -> void:
	if _pcs:
		_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _on(story: String) -> Array[Node]:
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var raid: HotelRaid = LEVEL.instantiate()
		raid.case_seed = 5
		raid.story_id = story
		raid.get_node("Cop/Grabber").input_enabled = false
		return raid)
	return await _pcs.two_pcs()


func _raid(net: Node) -> HotelRaid:
	return OnlinePcs.level(net) as HotelRaid


func test_don_bostezo_naps_and_complains_the_same_for_the_guest() -> void:
	var pcs := await _on("casino_13")
	var on_host := _raid(pcs[0]).concierge
	var on_guest := _raid(pcs[1]).concierge
	assert_false(on_guest.is_physics_processing(), "the guest's don Bostezo only follows")
	on_host._raise(25.0)
	assert_true(on_host.tuck_pillow())
	var synced := func() -> bool:
		return on_guest.is_asleep() and absf(on_guest.complaint - on_host.complaint) < 0.01
	await wait_until(synced, 5.0)
	assert_true(on_guest.is_asleep(), "napping on every PC")
	assert_almost_eq(on_guest.complaint, on_host.complaint, 0.01, "the complaint bar fills the same")
	on_host.door_broken()
	await wait_until(func() -> bool: return not on_guest.is_asleep(), 5.0)
	assert_false(on_guest.is_asleep(), "and awake again")
	assert_eq(on_guest.get_node("Bubble").text, "HOTEL_CONCIERGE_DOOR")


func test_dona_escoba_walks_where_the_hosts_does() -> void:
	var pcs := await _on("casino_13")
	var on_host := _raid(pcs[0]).maid
	var on_guest := _raid(pcs[1]).maid
	assert_false(on_guest.is_physics_processing())
	await wait_seconds(1.0)
	await wait_until(func() -> bool: return on_guest.global_position.distance_to(on_host.global_position) < 0.1, 5.0)
	assert_almost_eq(on_guest.global_position, on_host.global_position, Vector3.ONE * 0.1)


func test_the_sleepwalker_woken_on_the_host_shouts_for_everyone() -> void:
	var pcs := await _on("sleepwalker")
	var on_host := (_raid(pcs[0]).rig as SleepwalkerRig).sleepwalker
	var on_guest := (_raid(pcs[1]).rig as SleepwalkerRig).sleepwalker
	on_host.wake()
	await wait_until(func() -> bool: return on_guest.awake and on_guest.get_node("Bubble").visible, 5.0)
	assert_true(on_guest.awake)
	assert_eq(on_guest.get_node("Bubble").text, "SLEEPWALKER_SHOUT")
	assert_eq(on_guest.prompt_key(OnlinePcs.own_cop(pcs[1])), "", "no waking him twice")
	await wait_until(func() -> bool: return _raid(pcs[1]).concierge.complaint >= SleepwalkerRig.SHOUT, 5.0)
	assert_gte(_raid(pcs[1]).concierge.complaint, SleepwalkerRig.SHOUT, "don Bostezo heard it")


func test_ramon_runs_off_for_the_guest_too_and_its_checklist_gets_the_mustache() -> void:
	var pcs := await _on("regular_guest")
	var on_host := (_raid(pcs[0]).rig as RegularGuestRig).ramon
	var on_guest := (_raid(pcs[1]).rig as RegularGuestRig).ramon
	on_host._wait = 0.0
	await wait_until(func() -> bool: return on_guest.walking and on_guest.visible, 5.0)
	assert_true(on_guest.visible, "crossing the lobby on every PC")
	assert_eq(on_guest.disguise, on_host.disguise)
	on_host.unmask()
	await wait_until(func() -> bool: return on_guest.fled, 5.0)
	assert_true(on_guest.fled)
	assert_has(_raid(pcs[1]).raid.clues_found, tr("CLUE_REGULAR_GUEST_MUSTACHE"))
