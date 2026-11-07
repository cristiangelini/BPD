extends GutTest

## The plant nursery raid online (allanamiento-vivero.md, step 9): Doña Hortensia and the Dentuda are run by the host
## and followed by the guests; the valve, the horn and the tap go from any PC; the panes, the pots, the can, Brotecito
## and what each story's rig decides are decided on the host and show on every guest.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const NURSERY := preload("res://scenes/levels/nursery.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "stolen_orchid"


func before_each() -> void:
	_story = "stolen_orchid"
	_pcs = OnlinePcs.new(self, Callable(), _make_nursery)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_nursery() -> Node3D:
	var nursery: Nursery = NURSERY.instantiate()
	nursery.case_seed = SEED
	nursery.story_id = _story
	return nursery


func test_hortensia_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	assert_false(guest.owner_npc.is_physics_processing(), "the guest's Doña Hortensia only follows")
	host.owner_npc.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.owner_npc.complaint - 30.0) < 0.5 \
		and guest.owner_npc.global_position.distance_to(host.owner_npc.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.owner_npc.complaint, host.owner_npc.complaint, 0.5)


func test_the_valve_and_the_horn_from_a_guest_work_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.valve)
	await wait_until(func() -> bool: return host.irrigation.is_running() and guest.irrigation.is_running(), 5.0)
	assert_true(host.irrigation.is_running(), "the guest's valve reached the host")
	host.irrigation.stop()
	await wait_until(func() -> bool: return not guest.irrigation.is_running() and guest.irrigation.is_muddy(), 5.0)
	assert_true(guest.irrigation.is_muddy(), "it stops on the guest when it stops on the host, and it's mud")
	OnlinePcs.own_cop(pcs[1]).act("use", guest.horn.button)
	await wait_until(func() -> bool: return host.horn.is_counting() and guest.horn.truck.visible, 5.0)
	assert_eq(guest.horn.distractions, host.horn.distractions)
	host.horn.fix()
	await wait_until(func() -> bool: return not guest.horn.truck.visible, 5.0)
	assert_false(guest.horn.is_counting(), "the truck leaves on the guest when she's done on the host")


func test_panes_and_pots_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	host.break_pane(2)
	host.break_pot(1)
	await wait_until(func() -> bool: return guest.cracked == [2] and guest.broken_pots == [1], 5.0)
	assert_eq(guest.cracked, [2])
	assert_eq(guest.broken_pots, [1])
	assert_eq(guest.fines, host.fines)


func test_the_dentuda_the_can_and_brotecito_are_the_hosts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	host.can.fill()
	await wait_until(func() -> bool: return guest.can.full, 5.0)
	assert_true(guest.can.full, "full on the guest too")
	host.dentuda.bite(host.can)
	await wait_until(func() -> bool: return not guest.can.visible and guest.dentuda.bites == 1, 5.0)
	assert_false(guest.can.visible, "in her mouth on the guest too")
	assert_false(guest.can.full, "she spilled it")
	host.dentuda.tick(NurseryDentuda.HOLD_SECONDS)
	await wait_until(func() -> bool: return guest.can.visible, 5.0)
	assert_true(guest.can.visible, "spat out on the guest too")
	host.kid._tell("BROTECITO_THANKS", 4.0)
	await wait_until(func() -> bool: return guest.kid.news_count == host.kid.news_count, 5.0)
	assert_eq((guest.kid.get_node("Bubble") as Label3D).text, "BROTECITO_THANKS", "he says it on the guest")


func test_the_host_decides_the_story_clues() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	(host.rig as StolenOrchidRig).notice()
	await wait_until(func() -> bool: return (guest.rig as StolenOrchidRig).noticed, 5.0)
	assert_true((guest.rig as StolenOrchidRig).noticed, "the butterflies show on the guest")


func test_the_bees_follow_the_hosts_swarm() -> void:
	_story = "stolen_bees"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	var host_bees := host.rig as StolenBeesRig
	var guest_bees := guest.rig as StolenBeesRig
	host_bees.hear()
	host_bees.swarm_at = host_bees.home() + Vector3(2, 0, 0)
	host_bees.set_physics_process(false)
	await wait_until(func() -> bool: return guest_bees.heard \
		and guest_bees.swarm_at.distance_to(host_bees.swarm_at) < 0.1, 5.0)
	assert_true(guest_bees.heard)
	assert_lt(guest_bees.swarm_at.distance_to(host_bees.swarm_at), 0.1, "the guest's swarm flies to the host's")


func test_the_hosts_pumpkins_reach_the_guest() -> void:
	_story = "contest_seeds"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	(host.rig as ContestSeedsRig).grow_pumpkin()
	var pumpkin_name := (host.rig as ContestSeedsRig).pumpkins[0].name
	await wait_until(func() -> bool: return guest.get_node_or_null(NodePath(pumpkin_name)) is GiantPumpkin, 5.0)
	assert_true(guest.get_node_or_null(NodePath(pumpkin_name)) is GiantPumpkin, "a copy with the same name")


func test_the_dentuda_on_the_host_pushes_a_guests_cop_and_its_slips_reach_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: Nursery = OnlinePcs.level(pcs[0])
	var guest: Nursery = OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var copy: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	assert_true(Nursery.is_copy(copy))
	host.dentuda.bite(copy)
	await wait_until(func() -> bool: return guest_cop.is_staggered(), 5.0)
	assert_true(guest_cop.is_staggered(), "pushed on its own PC")
	await wait_until(func() -> bool: return not guest_cop.is_staggered() and not copy.is_staggered(), 5.0)
	host.irrigation.set_physics_process(false)
	host.irrigation.stop()
	guest_cop.global_position = guest.to_global(Vector3(-9.0, Nursery.FLOOR_TOP, -2.5))
	await wait_until(func() -> bool: return copy.global_position.distance_to(host.to_global(
		Vector3(-9.0, Nursery.FLOOR_TOP, -2.5))) < 0.3, 5.0)
	guest_cop.knock_back(Vector3(3, 0, 0), 1.0)
	await wait_until(func() -> bool: return copy.is_staggered(), 5.0)
	host.irrigation.tick(0.1)
	assert_eq(host.irrigation.slips, 1, "the host saw the guest's cop fall in the mud")
