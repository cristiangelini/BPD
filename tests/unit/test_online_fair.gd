extends GutTest

## The fun fair raid online (allanamiento-parque.md, step 8): Don Tómbola is run by the host and followed by the
## guests, the rides go from any PC, the mirrors break on the host and on every guest, and the bell and the cans
## played on one PC count on all of them.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const FAIR := preload("res://scenes/levels/fair.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "stuffed_prizes"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_fair)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_fair() -> Node3D:
	var fair: Fair = FAIR.instantiate()
	fair.case_seed = SEED
	fair.story_id = _story
	return fair


func test_don_tombola_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Fair = OnlinePcs.level(pcs[0])
	var guest: Fair = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_npc.is_physics_processing(), "the guest's Don Tómbola only follows")
	host.owner_npc.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.owner_npc.complaint - 30.0) < 0.5 \
		and guest.owner_npc.global_position.distance_to(host.owner_npc.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.owner_npc.complaint, host.owner_npc.complaint, 0.5)


func test_the_carousel_lever_and_the_crank_from_a_guest_work_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Fair = OnlinePcs.level(pcs[0])
	var guest: Fair = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.rides.switches.carousel)
	OnlinePcs.own_cop(pcs[1]).act("use", guest.rides.switches.wheel)
	await wait_until(func() -> bool: return host.rides.spinning and guest.rides.spinning, 5.0)
	assert_true(host.rides.spinning, "the guest's lever reached the host")
	await wait_seconds(FairRides.CRANK_SECONDS + 0.3)
	assert_almost_eq(host.wheel.rotation.z, -TAU / Fair.CABINS, 0.01, "the wheel turned on the host")
	assert_almost_eq(guest.wheel.rotation.z, host.wheel.rotation.z, 0.01, "and on the guest")


func test_a_mirror_broken_on_the_host_breaks_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Fair = OnlinePcs.level(pcs[0])
	var guest: Fair = OnlinePcs.level(pcs[1])
	host.break_mirror(3)
	await wait_until(func() -> bool: return guest.broken_mirrors.has(3), 5.0)
	assert_eq(guest.broken_mirrors, [3] as Array[int])
	assert_eq(guest.fines, host.fines)


func test_the_bell_rung_on_the_host_takes_don_tombola_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Fair = OnlinePcs.level(pcs[0])
	var guest: Fair = OnlinePcs.level(pcs[1])
	host.tester.ring()
	await wait_until(func() -> bool: return guest.tester.is_giving_prize(), 5.0)
	assert_true(guest.tester.is_giving_prize(), "the guest sees the prize being handed over")
	assert_eq(guest.tester.distractions, 1)


func test_nube_tells_the_guest_who_won_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Fair = OnlinePcs.level(pcs[0])
	var guest: Fair = OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var on_host: Cop = null
	for node in host.get_tree().get_nodes_in_group("cops"):
		if node != OnlinePcs.own_cop(pcs[0]) and host.is_ancestor_of(node):
			on_host = node
	host.nube.won(on_host)
	await wait_until(func() -> bool: return (guest.raid.objective_facts().clues as Array).has(host.nube.clue), 5.0)
	assert_has(guest.raid.objective_facts().clues, host.nube.clue, "the clue is on every checklist")
	assert_eq((guest.nube.get_node("Bubble") as Label3D).text, host.nube.news, "and she says it on the guest too")
	assert_not_null(guest_cop)


func test_a_ticket_printed_on_the_host_shows_on_the_guest() -> void:
	_story = "fake_tickets"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Fair = OnlinePcs.level(pcs[0])
	var guest: Fair = OnlinePcs.level(pcs[1])
	var before := guest.find_children("*", "FairTicket", true, false).size()
	(host.rig as FakeTicketsRig).print_ticket()
	await wait_until(func() -> bool: return guest.find_children("*", "", true, false).filter(
		func(n: Node) -> bool: return n is FairTicket).size() > before, 5.0)
	var tickets := guest.find_children("*", "", true, false).filter(func(n: Node) -> bool: return n is FairTicket)
	assert_eq(tickets.size(), FakeTicketsRig.TICKETS.size() + 1, "the printed one came over")
	assert_eq((tickets[-1] as FairTicket).text, tr("FAIR_TICKET"), "and it reads the same")
	assert_eq((guest.rig as FakeTicketsRig).printed, 0, "the guest's booth doesn't print on its own")


func test_a_nut_the_crank_shakes_off_on_the_host_shows_on_the_guest() -> void:
	_story = "loose_wheel"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Fair = OnlinePcs.level(pcs[0])
	var guest: Fair = OnlinePcs.level(pcs[1])
	var nuts := func(fair: Fair) -> int:
		return fair.find_children("*", "", true, false).filter(
			func(n: Node) -> bool: return n is Grabbable and n.scene_file_path.ends_with("fair_nut.tscn")).size()
	var before: int = nuts.call(guest)
	(host.rig as LooseWheelRig).shake()
	await wait_until(func() -> bool: return nuts.call(guest) > before, 5.0)
	assert_eq(nuts.call(guest), before + 1, "the host's nut came over")
	assert_eq((guest.rig as LooseWheelRig).drops, 0, "the guest's wheel doesn't drop its own")
