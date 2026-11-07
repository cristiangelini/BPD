extends GutTest

## The garage raid online (allanamiento-taller.md, step 7): Don Tuerca is run by the host and followed by the guests,
## the bell and the lift work from any PC, and the windshields cracked on the host crack on every guest.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const GARAGE := preload("res://scenes/levels/garage.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "swapped_plates"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_garage)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_garage() -> Node3D:
	var garage: Garage = GARAGE.instantiate()
	garage.case_seed = SEED
	garage.story_id = _story
	return garage


func test_tuerca_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Garage = OnlinePcs.level(pcs[0])
	var guest: Garage = OnlinePcs.level(pcs[1])
	assert_false(guest.tuerca.is_physics_processing(), "the guest's Don Tuerca only follows")
	host.tuerca.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.tuerca.complaint - 30.0) < 0.5 \
		and guest.tuerca.global_position.distance_to(host.tuerca.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.tuerca.complaint, host.tuerca.complaint, 0.5)


func test_the_bell_from_a_guest_calls_tuerca_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Garage = OnlinePcs.level(pcs[0])
	var guest: Garage = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.bell.button)
	await wait_until(func() -> bool: return host.bell.is_jammed, 5.0)
	assert_eq(host.bell.rings, 1, "the guest's ring reached the host")
	assert_eq(host.tuerca.errand(), "printer", "and Don Tuerca goes to the counter")


func test_the_lift_from_a_guest_goes_down_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Garage = OnlinePcs.level(pcs[0])
	var guest: Garage = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.lift_button)
	await wait_until(func() -> bool: return host.lift_target == 0.0 and guest.lift_target == 0.0, 5.0)
	assert_eq(host.lift_target, 0.0, "the guest's button reached the host")
	await wait_until(func() -> bool: return guest.lift_height < Garage.LIFT_HEIGHT - 0.2, 5.0)
	assert_almost_eq(guest.lift_height, host.lift_height, 0.2, "and the guest's car goes down with the host's")


func test_a_windshield_cracked_on_the_host_cracks_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Garage = OnlinePcs.level(pcs[0])
	var guest: Garage = OnlinePcs.level(pcs[1])
	host.break_windshield(2)
	await wait_until(func() -> bool: return guest.broken_windshields.has(2), 5.0)
	assert_eq(guest.broken_windshields, [2] as Array[int])
	assert_not_null(guest.cars[2].get_node_or_null("Cracks2"), "with its cracks")


func test_a_guest_asks_grasita_and_the_tool_the_host_sees_come_tells_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Garage = OnlinePcs.level(pcs[0])
	var guest: Garage = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.grasita)
	await wait_until(func() -> bool: return host.grasita.wanted != "" and guest.grasita.wanted != "", 5.0)
	assert_eq(guest.grasita.wanted, host.grasita.wanted, "both ask for the same tool")
	var guest_cop_on_host: Cop = null
	for node in host.get_tree().get_nodes_in_group("cops"):
		if node != OnlinePcs.own_cop(pcs[0]) and host.is_ancestor_of(node):
			guest_cop_on_host = node
	host.grasita.hand(host.tools[host.grasita.wanted], guest_cop_on_host)
	await wait_until(func() -> bool: return guest.grasita.has_told, 5.0)
	assert_true(guest.grasita.listeners.has(OnlinePcs.own_cop(pcs[1])), "the guest's Grasita talks to its player")
	assert_eq(guest.grasita.wanted, "")
	await wait_until(func() -> bool: return guest.raid.objective_facts().clues.has(host.grasita.clue), 5.0)
	assert_has(guest.raid.objective_facts().clues, host.grasita.clue, "and his clue is on the guest's checklist")
