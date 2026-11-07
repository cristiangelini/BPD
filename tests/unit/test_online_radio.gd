extends GutTest

## The radio raid online (allanamiento-radio.md, step 8): don Volumen and doña Rosa are run by the host and followed by
## the guests, the record player and the phone work from any PC, and what goes out on air, the "AL AIRE" light, the
## window and the records follow the host's.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const RADIO := preload("res://scenes/levels/radio_station.tscn")
const SEED := 5

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_radio)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_radio() -> Node3D:
	var radio: RadioStation = RADIO.instantiate()
	radio.case_seed = SEED
	radio.story_id = "rigged_contest"
	return radio


func test_volumen_and_rosa_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: RadioStation = OnlinePcs.level(pcs[0])
	var guest: RadioStation = OnlinePcs.level(pcs[1])
	assert_false(guest.volumen.is_physics_processing(), "the guest's don Volumen only follows")
	assert_false(guest.rosa.is_physics_processing(), "and so does doña Rosa")
	host.volumen.complaint = 30.0
	host.rosa.call_now()
	await wait_until(func() -> bool: return absf(guest.volumen.complaint - 30.0) < 0.5 and guest.rosa.calling \
		and guest.phone.is_ringing(), 5.0)
	assert_almost_eq(guest.volumen.complaint, 30.0, 0.5)
	assert_true(guest.rosa.calling, "her call rings on the guest too")
	assert_true(guest.phone.is_ringing())


func test_a_guest_answers_rosa_on_the_hosts_phone() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: RadioStation = OnlinePcs.level(pcs[0])
	var guest: RadioStation = OnlinePcs.level(pcs[1])
	host.rosa.call_now()
	await wait_until(func() -> bool: return guest.rosa.calling, 5.0)
	OnlinePcs.own_cop(pcs[1]).act("use", guest.phone)
	await wait_until(func() -> bool: return host.rosa.listener != null, 5.0)
	assert_not_null(host.rosa.listener, "the host's doña Rosa talks to the guest's cop")
	assert_eq(host.answered_calls, 0, "not a listener's call")


func test_the_record_player_from_a_guest_takes_the_radio_off_air() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: RadioStation = OnlinePcs.level(pcs[0])
	var guest: RadioStation = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.record_player.button)
	await wait_until(func() -> bool: return host.record_player.is_jammed and not guest.on_air, 5.0)
	assert_false(host.on_air, "the guest's song reached the host")
	assert_false(guest.on_air)
	host.record_player.fix()
	await wait_until(func() -> bool: return guest.on_air, 5.0)
	assert_true(guest.on_air, "back on air with the host")


func test_what_airs_on_the_host_airs_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: RadioStation = OnlinePcs.level(pcs[0])
	var guest: RadioStation = OnlinePcs.level(pcs[1])
	(host.rig as RiggedContestRig).announce()
	await wait_until(func() -> bool: return guest.aired == host.aired, 5.0)
	assert_eq(guest.last_aired, "RADIO_TITO_WINS")
	var before := guest.aired
	(guest.rig as RiggedContestRig).announce()
	assert_eq(guest.aired, before, "the guest's own stories don't air anything")


func test_the_window_and_the_records_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: RadioStation = OnlinePcs.level(pcs[0])
	var guest: RadioStation = OnlinePcs.level(pcs[1])
	host.break_glass()
	host.drop_record(host.to_global(Vector3(-4.0, 1.0, -7.7)))
	await wait_until(func() -> bool: return guest.glass_cracked and guest.records_broken == 1, 5.0)
	assert_true(guest.glass_cracked)
	assert_eq(guest.records_broken, 1)
	await wait_until(func() -> bool: return guest.raid.objective_facts().fines == host.raid.fines, 5.0)
	assert_eq(guest.raid.objective_facts().fines, RadioStation.GLASS_FINE + RadioStation.RECORD_FINE,
		"fined once, by the host")
