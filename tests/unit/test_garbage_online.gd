extends GutTest

## The garbage truck jailbreak online (fuga-basura.md, "Online"): the host runs the guard's bags, the dummies and the
## truck; the guests see the same, and a guest's cop riding the truck rides it on the guest too.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, Callable(), _make_jail)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _make_jail() -> Node3D:
	var jail: JailbreakLevel = LEVEL.instantiate()
	jail.case_seed = 7575
	jail.variant = "garbage"
	return jail


func _copy_of(level: Node, cop: Cop) -> Cop:
	for other: Cop in level.get_tree().get_nodes_in_group("cops"):
		if other.is_ancestor_of(level) or not level.is_ancestor_of(other):
			continue
		if other.net_id() == cop.net_id():
			return other
	return null


func test_the_guest_sees_the_bags_the_dummy_and_the_truck() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	var host_guard := host_level.guard as GarbageGuard
	host_guard.set_physics_process(false)
	var bag: GarbageBag = host_guard.bags[0]
	bag.take(host_level.dumpster.inside())
	var guest_bag: GarbageBag = guest_level.get_node(NodePath(bag.name))
	await wait_until(func() -> bool: return guest_bag.in_use, 5.0)
	assert_true(guest_bag.in_use, "off the roll on the guest too")
	assert_true(guest_bag.visible)
	(host_level.get_node("BunkDummy1") as BunkDummy).built = true
	var guest_dummy: BunkDummy = guest_level.get_node("BunkDummy1")
	await wait_until(func() -> bool: return guest_dummy.built, 5.0)
	assert_true(guest_dummy.built, "the dummy on the guest too")
	host_level.garbage_truck.come()
	await wait_until(func() -> bool: return guest_level.garbage_truck.visible, 5.0)
	assert_eq(guest_level.garbage_truck.stage, "coming", "the truck comes on the guest too")


func test_a_guests_cop_rides_the_truck_on_both_pcs() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var on_host := _copy_of(host_level, guest_cop)
	assert_not_null(on_host, "the host has the guest's cop")
	host_level.garbage_truck.seat(on_host)
	await wait_until(func() -> bool: return guest_cop.seated_in == guest_level.garbage_truck, 5.0)
	assert_eq(guest_cop.seated_in, guest_level.garbage_truck, "riding on the guest's own PC")
	assert_false(guest_cop.visible)
	host_level.garbage_truck.release(on_host)
	await wait_until(func() -> bool: return guest_cop.seated_in == null, 5.0)
	assert_null(guest_cop.seated_in, "and off")
	assert_true(guest_cop.visible)
