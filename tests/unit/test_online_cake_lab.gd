extends GutTest

## The cake lab online (docs/diseno/laboratorio.md, step 7): chef Bruno is run by the host and followed by the guests,
## the soufflé oven's knob works from any PC, Pocha's sample answers a guest's cop on every PC, a burst flour sack
## bursts everywhere, the stolen recipe's book comes out of its cake on every PC, and the robot arm only creams each
## PC's own cop.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LAB := preload("res://scenes/levels/cake_lab.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "silver_cake"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_lab)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_lab() -> Node3D:
	var lab: CakeLab = LAB.instantiate()
	lab.case_seed = SEED
	lab.story_id = _story
	return lab


func test_the_chef_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CakeLab = OnlinePcs.level(pcs[0])
	var guest: CakeLab = OnlinePcs.level(pcs[1])
	assert_false(guest.chef.is_physics_processing(), "the guest's chef only follows")
	host.chef.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.chef.complaint - 30.0) < 0.5 \
		and guest.chef.global_position.distance_to(host.chef.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.chef.complaint, host.chef.complaint, 0.5)


func test_the_oven_knob_from_a_guest_turns_up_the_hosts_oven() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CakeLab = OnlinePcs.level(pcs[0])
	var guest: CakeLab = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.oven.button)
	await wait_until(func() -> bool: return host.oven.is_jammed and guest.oven.is_jammed, 5.0)
	assert_true(host.oven.is_jammed, "the guest's knob reached the host")
	assert_eq(host.chef.errand(), "printer", "and the chef runs to his soufflé")


func test_pochas_sample_answers_a_guests_cop_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CakeLab = OnlinePcs.level(pcs[0])
	var guest: CakeLab = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.pocha)
	await wait_until(func() -> bool: return host.pocha.has_told and guest.pocha.has_told, 5.0)
	assert_true(host.pocha.has_told, "she told on the host")
	assert_true(guest.pocha.has_told, "and on the guest")
	assert_eq(host.pocha.tasters.size(), 1)


func test_a_sack_burst_on_the_host_bursts_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CakeLab = OnlinePcs.level(pcs[0])
	var guest: CakeLab = OnlinePcs.level(pcs[1])
	await wait_physics_frames(5)
	host.sacks[0].hit(FlourSack.BURST_SPEED + 1.0)
	await wait_until(func() -> bool: return guest.burst_sacks == 1, 5.0)
	assert_eq(guest.burst_sacks, 1, "burst on the guest too")
	assert_eq(guest.flour.patches.size(), 1, "with its flour on the floor")


func test_the_stolen_book_comes_out_on_every_pc() -> void:
	_story = "stolen_recipe"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CakeLab = OnlinePcs.level(pcs[0])
	var guest: CakeLab = OnlinePcs.level(pcs[1])
	await wait_physics_frames(5)
	var host_rig := host.rig as StolenRecipeRig
	var guest_rig := guest.rig as StolenRecipeRig
	assert_eq(guest_rig.stuffed, host_rig.stuffed, "the same cake on every PC")
	host_rig.cakes[host_rig.stuffed].hit(Ornament.BREAK_SPEED + 1.0)
	assert_true(host_rig.is_found())
	assert_false(host_rig.book.freeze, "the host simulates it")
	await wait_until(func() -> bool: return guest_rig.is_found(), 5.0)
	assert_true(guest_rig.is_found(), "out on the guest too")
	assert_true(guest_rig.book.freeze, "the guest's copy only follows")


func test_the_robot_arm_only_creams_each_pcs_own_cop() -> void:
	_story = "robot_arm"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: CakeLab = OnlinePcs.level(pcs[0])
	var guest_cop_on_host: Cop = null
	for node in host.get_tree().get_nodes_in_group("cops"):
		if node != OnlinePcs.own_cop(pcs[0]) and host.is_ancestor_of(node):
			guest_cop_on_host = node
	assert_not_null(guest_cop_on_host, "the guest's cop is in the host's lab")
	var at := RobotArmRig.ARM_AT + Vector3(1.0, 0, 0.6)
	guest_cop_on_host.global_position = Vector3(at.x, CakeLab.FLOOR_TOP, at.z)
	OnlinePcs.own_cop(pcs[0]).global_position = Vector3(at.x + 5.0, CakeLab.FLOOR_TOP, at.z)
	await wait_seconds(RobotArmRig.SPLAT_EVERY + 0.3)
	assert_false((host.rig as RobotArmRig).is_creamed(guest_cop_on_host), "the guest's own PC creams it, not the host")
