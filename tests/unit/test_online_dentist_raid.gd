extends GutTest

## The dental office raid online (allanamiento-dentista.md, step 7): Dr. Molina is run by the host and followed by the
## guests, the next-patient bell works from any PC, the fish tank and a gas tank that opens on the host do the same on
## every guest, the rising chair and its hatch follow the host and the floss threads cross the same places on every PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const OFFICE := preload("res://scenes/levels/dentist_raid.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "gold_teeth"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_office)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_office() -> Node3D:
	var office: DentistRaid = OFFICE.instantiate()
	office.case_seed = SEED
	office.story_id = _story
	return office


func test_molina_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DentistRaid = OnlinePcs.level(pcs[0])
	var guest: DentistRaid = OnlinePcs.level(pcs[1])
	assert_false(guest.molina.is_physics_processing(), "the guest's doctor only follows")
	host.molina.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.molina.complaint - 30.0) < 0.5 \
		and guest.molina.global_position.distance_to(host.molina.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.molina.complaint, host.molina.complaint, 0.5)


func test_the_bell_from_a_guest_calls_him_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DentistRaid = OnlinePcs.level(pcs[0])
	var guest: DentistRaid = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.bell.button)
	await wait_until(func() -> bool: return host.bell.is_ringing(), 5.0)
	assert_true(host.bell.is_ringing(), "the guest's button reached the host")
	assert_eq(host.molina.errand(), "printer", "and the doctor goes to see the next patient")


func test_the_fish_tank_and_a_gas_tank_on_the_host_do_the_same_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DentistRaid = OnlinePcs.level(pcs[0])
	var guest: DentistRaid = OnlinePcs.level(pcs[1])
	host.break_fish_tank()
	host.gas_tanks[1].leak()
	await wait_until(func() -> bool: return guest.tank_broken and guest.gas_tanks[1].is_leaking(), 5.0)
	assert_true(guest.tank_broken, "broken on the guest too")
	assert_true(guest.gas_tanks[1].is_leaking(), "leaking on the guest too")
	assert_false(guest.gas_tanks[0].is_leaking(), "only that one")
	assert_eq(guest.gas_tanks[1].leaks, 1)


func test_the_rising_chair_and_its_hatch_follow_the_host() -> void:
	_story = "rising_chair"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DentistRaid = OnlinePcs.level(pcs[0])
	var guest: DentistRaid = OnlinePcs.level(pcs[1])
	var guest_rig := guest.rig as RisingChairRig
	(host.rig as RisingChairRig).toggle()
	(host.rig as RisingChairRig).open_hatch()
	await wait_until(func() -> bool: return guest_rig.raised and guest_rig.opened, 5.0)
	assert_true(guest_rig.raised, "up on the guest too")
	assert_true(guest_rig.opened, "and the hatch open")
	assert_true(guest.main.visible, "the bag is out")


func test_the_floss_threads_cross_the_same_places_on_every_pc() -> void:
	_story = "dental_floss"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DentistRaid = OnlinePcs.level(pcs[0])
	var guest: DentistRaid = OnlinePcs.level(pcs[1])
	assert_eq((guest.rig as DentalFlossRig).thread_xs, (host.rig as DentalFlossRig).thread_xs)
