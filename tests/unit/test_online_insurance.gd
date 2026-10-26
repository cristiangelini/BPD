extends GutTest

## The insurance office online (docs/diseno/seguros.md, step 7): Mirta and Coca are run by the host and followed by
## the guests, the printer's button and the ticket machine work from any PC, a guest's printer clears when the host's
## Mirta fixes it, and the stories' phones and paintings answer a guest's cop.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const OFFICE := preload("res://scenes/levels/insurance_office.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "fake_crashes"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_office)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_office() -> Node3D:
	var office: InsuranceOffice = OFFICE.instantiate()
	office.case_seed = SEED
	office.story_id = _story
	return office


func test_mirta_and_coca_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: InsuranceOffice = OnlinePcs.level(pcs[0])
	var guest: InsuranceOffice = OnlinePcs.level(pcs[1])
	assert_false(guest.mirta.is_physics_processing(), "the guest's Mirta only follows")
	assert_false(guest.coca.is_physics_processing(), "and so does Coca")
	host.mirta.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.mirta.complaint - 30.0) < 0.5 \
		and guest.mirta.global_position.distance_to(host.mirta.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.mirta.complaint, host.mirta.complaint, 0.5)
	host.coca.call_next()
	await wait_until(func() -> bool: return guest.coca.serving == host.coca.serving, 5.0)
	assert_eq(guest.coca.serving, host.coca.serving, "the board shows the same number")


func test_the_printer_from_a_guest_jams_the_hosts_and_clears_with_mirta() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: InsuranceOffice = OnlinePcs.level(pcs[0])
	var guest: InsuranceOffice = OnlinePcs.level(pcs[1])
	host.mirta.fix_time = 0.5
	OnlinePcs.own_cop(pcs[1]).act("use", guest.printer.button)
	await wait_until(func() -> bool: return host.printer.is_jammed and guest.printer.is_jammed, 5.0)
	assert_true(host.printer.is_jammed, "the guest's press reached the host")
	assert_eq(host.mirta.errand(), "printer", "and Mirta heads to it")
	# She's there: the walk is FloorBoss's own test.
	host.mirta._path.clear()
	host.mirta._arrive()
	assert_true(host.mirta.is_fixing())
	await wait_until(func() -> bool: return not host.printer.is_jammed and not guest.printer.is_jammed, 20.0)
	assert_false(guest.printer.is_jammed, "the guest's printer prints again once she's done")


func test_a_guest_takes_a_number_from_the_hosts_machine() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: InsuranceOffice = OnlinePcs.level(pcs[0])
	var guest: InsuranceOffice = OnlinePcs.level(pcs[1])
	var before: int = host.coca.next_ticket
	OnlinePcs.own_cop(pcs[1]).act("use", guest.tickets)
	await wait_until(func() -> bool: return host.coca.next_ticket > before, 5.0)
	assert_gt(host.coca.next_ticket, before, "the host's Coca gave the guest's cop a number")


func test_a_guest_answers_a_ringing_phone() -> void:
	_story = "ufo_policies"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: InsuranceOffice = OnlinePcs.level(pcs[0])
	var guest: InsuranceOffice = OnlinePcs.level(pcs[1])
	var host_rig := host.rig as UfoPoliciesRig
	var guest_rig := guest.rig as UfoPoliciesRig
	var ringing := host_rig.phones.find(host_rig.phones.filter(func(p: DeskPhone) -> bool: return p.is_ringing())[0])
	guest_rig.phones[ringing].ring()
	OnlinePcs.own_cop(pcs[1]).act("use", guest_rig.phones[ringing])
	await wait_until(func() -> bool: return not host_rig.phones[ringing].is_ringing(), 5.0)
	assert_false(host_rig.phones[ringing].is_ringing(), "answered on the host")
	assert_false(guest_rig.phones[ringing].is_ringing(), "and on the guest")


func test_the_paintings_hang_the_same_on_every_pc() -> void:
	_story = "insured_painting"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: InsuranceOffice = OnlinePcs.level(pcs[0])
	var guest: InsuranceOffice = OnlinePcs.level(pcs[1])
	var host_rig := host.rig as InsuredPaintingRig
	var guest_rig := guest.rig as InsuredPaintingRig
	assert_eq(guest_rig.paintings.find(guest_rig.real), host_rig.paintings.find(host_rig.real), "the same real one")
	await wait_physics_frames(10)
	for i in host_rig.paintings.size():
		assert_lt(guest_rig.paintings[i].global_position.distance_to(host_rig.paintings[i].global_position), 0.05)
