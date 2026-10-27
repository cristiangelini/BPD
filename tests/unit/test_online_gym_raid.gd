extends GutTest

## The gym raid online (allanamiento-gimnasio.md, step 7): el profe is run by the host and followed by the guests, the
## stereo works from any PC, the mirror and the treadmills break on the host and on every guest, the dummies the host
## knocks over fall everywhere, and the treadmills that run on their own only throw off each PC's own cop.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const GYM := preload("res://scenes/levels/gym_raid.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "silver_dumbbells"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_gym)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_gym() -> Node3D:
	var gym: GymRaid = GYM.instantiate()
	gym.case_seed = SEED
	gym.story_id = _story
	return gym


func test_the_profe_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: GymRaid = OnlinePcs.level(pcs[0])
	var guest: GymRaid = OnlinePcs.level(pcs[1])
	assert_false(guest.coach.is_physics_processing(), "the guest's profe only follows")
	host.coach.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.coach.complaint - 30.0) < 0.5 \
		and guest.coach.global_position.distance_to(host.coach.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.coach.complaint, host.coach.complaint, 0.5)


func test_the_stereo_from_a_guest_starts_the_class_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: GymRaid = OnlinePcs.level(pcs[0])
	var guest: GymRaid = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.stereo.button)
	await wait_until(func() -> bool: return host.stereo.is_playing() and guest.stereo.is_playing(), 5.0)
	assert_true(host.stereo.is_playing(), "the guest's button reached the host")
	assert_eq(host.coach.errand(), "printer", "and the profe goes to give his class")


func test_the_mirror_and_a_treadmill_broken_on_the_host_break_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: GymRaid = OnlinePcs.level(pcs[0])
	var guest: GymRaid = OnlinePcs.level(pcs[1])
	host.break_mirror()
	host.break_treadmill(2)
	await wait_until(func() -> bool: return guest.mirror_is_broken and guest.broken_treadmills.has(2), 5.0)
	assert_true(guest.mirror_is_broken, "cracked on the guest too")
	assert_eq(guest.broken_treadmills, [2] as Array[int])
	assert_not_null(guest.get_node_or_null("Built/Cracks"), "with its cracks")


func test_a_dummy_knocked_over_on_the_host_falls_on_the_guest() -> void:
	_story = "ghost_members"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: GymRaid = OnlinePcs.level(pcs[0])
	var guest: GymRaid = OnlinePcs.level(pcs[1])
	var host_rig := host.rig as GhostMembersRig
	var guest_rig := guest.rig as GhostMembersRig
	host_rig.topple(host_rig.mannequins[1])
	await wait_until(func() -> bool: return guest_rig.fallen.has(guest_rig.mannequins[1]), 5.0)
	assert_true(guest_rig.fallen.has(guest_rig.mannequins[1]), "fell on the guest too")
	assert_eq(guest_rig.fallen.size(), 1, "only that one")


func test_the_treadmills_only_throw_off_each_pcs_own_cop() -> void:
	_story = "power_treadmills"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: GymRaid = OnlinePcs.level(pcs[0])
	var guest_cop_on_host: Cop = null
	for node in host.get_tree().get_nodes_in_group("cops"):
		if node != OnlinePcs.own_cop(pcs[0]) and host.is_ancestor_of(node):
			guest_cop_on_host = node
	assert_not_null(guest_cop_on_host, "the guest's cop is in the host's gym")
	guest_cop_on_host.global_position = host.to_global(GymHall.TREADMILLS[3] + Vector3(0, GymHall.FLOOR_TOP + 0.25, 0))
	(host.rig as PowerTreadmillsRig).start_running()
	await wait_physics_frames(3)
	assert_false(guest_cop_on_host.is_staggered(), "the guest's own PC throws it off, not the host")
