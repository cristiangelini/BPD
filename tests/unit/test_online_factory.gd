extends GutTest

## The doll factory online (docs/diseno/fabrica.md, step 8): Fermín, Nilda and the belt are run by the host and
## followed by the guests, the dolls the host's feeder drops come over dressed, and the red button and the giant doll's
## zipper work from any PC.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const FACTORY := preload("res://scenes/levels/doll_factory.tscn")
const SEED := 5

var _pcs: OnlinePcs
var _story := "fake_captain"


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_factory)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_factory() -> Node3D:
	var factory: DollFactory = FACTORY.instantiate()
	factory.case_seed = SEED
	factory.story_id = _story
	return factory


func test_fermin_and_nilda_follow_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DollFactory = OnlinePcs.level(pcs[0])
	var guest: DollFactory = OnlinePcs.level(pcs[1])
	assert_false(guest.fermin.is_physics_processing(), "the guest's Fermín only follows")
	assert_false(guest.nilda.is_physics_processing(), "and so does Nilda")
	host.fermin.complaint = 30.0
	await wait_until(func() -> bool: return absf(guest.fermin.complaint - 30.0) < 0.5 \
		and guest.fermin.global_position.distance_to(host.fermin.global_position) < 0.1, 5.0)
	assert_almost_eq(guest.fermin.complaint, host.fermin.complaint, 0.5)


func test_the_guests_belt_stops_and_jams_with_the_hosts() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DollFactory = OnlinePcs.level(pcs[0])
	var guest: DollFactory = OnlinePcs.level(pcs[1])
	host.belt.running = false
	host.belt._apply()
	await wait_until(func() -> bool: return not guest.belt.running, 5.0)
	assert_false(guest.belt.is_moving(), "stopped on the guest's screen too")
	assert_true(guest.belt.follower)
	host.belt.running = true
	host.belt.jammed_at = "paint"
	host.belt._apply()
	await wait_until(func() -> bool: return guest.belt.running and guest.belt.jammed_at == "paint", 5.0)
	assert_false(guest.belt.is_moving(), "jammed there too")
	host.belt.unjam()
	await wait_until(func() -> bool: return guest.belt.is_moving(), 5.0)
	assert_true(guest.belt.is_moving(), "and moving again once he clears it")


func test_the_guest_gets_the_hosts_dolls_dressed() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DollFactory = OnlinePcs.level(pcs[0])
	var guest: DollFactory = OnlinePcs.level(pcs[1])
	var captains := func(factory: DollFactory) -> Array:
		return factory.get_children().filter(func(n: Node) -> bool: return n is FactoryDoll and n.dress == "captain")
	await wait_until(func() -> bool: return not captains.call(guest).is_empty(), 15.0)
	# The one it dropped while the level loaded stands for the host's first, like the props it starts with.
	assert_lte(guest.fed.size(), 1, "the guest's feeder drops nothing of its own once it's a guest")
	var copy: FactoryDoll = captains.call(guest).front()
	assert_true(copy.has_node("CaptainHelmet"), "the guest's copy wears the helmet")
	assert_false(captains.call(host).is_empty())


func test_the_red_button_from_a_guest_stops_the_hosts_belt() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DollFactory = OnlinePcs.level(pcs[0])
	var guest: DollFactory = OnlinePcs.level(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.belt_button)
	await wait_until(func() -> bool: return not host.belt.running, 5.0)
	assert_false(host.belt.running, "the guest's press reached the host")
	assert_eq(host.fermin.errand(), "button", "and Fermín walks to the button")


func test_the_giant_dolls_zipper_opens_for_everyone() -> void:
	_story = "giant_doll"
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host: DollFactory = OnlinePcs.level(pcs[0])
	var guest: DollFactory = OnlinePcs.level(pcs[1])
	var host_doll := (host.rig as GiantDollRig).doll
	var guest_doll := (guest.rig as GiantDollRig).doll
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var host_twin: Cop = host.get_tree().get_nodes_in_group("cops").filter(func(cop: Node) -> bool:
		return cop != OnlinePcs.own_cop(pcs[0]) and cop.get_parent() == host).front()
	guest_cop.global_position = guest_doll.to_global(Vector3(0, 0.1, -1.0))
	host_twin.global_position = host_doll.to_global(Vector3(0, 0.1, -1.0))
	guest_cop.act("use", guest_doll)
	await wait_until(func() -> bool: return host_doll.is_open and guest_doll.is_open, 5.0)
	assert_true(host_doll.is_open, "open on the host")
	assert_true(guest_doll.is_open, "and on the guest")
	assert_eq((guest.rig as GiantDollRig).safe.collision_layer, 4, "the guest's safe can be grabbed")
