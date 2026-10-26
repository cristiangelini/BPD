extends GutTest

## The fire drill jailbreak online (fuga-simulacro.md, "Online"): the host runs the guard and the drill; a guest sees
## the coat rack's coats, and a guest's cop taking its vest off takes it off on both PCs, with the vest on the floor
## on both.

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
	jail.case_seed = 7777
	jail.variant = "drill"
	return jail


func _copy_of(level: Node, cop: Cop) -> Cop:
	for other: Cop in level.get_tree().get_nodes_in_group("cops"):
		if other.is_ancestor_of(level) or not level.is_ancestor_of(other):
			continue
		if other.net_id() == cop.net_id():
			return other
	return null


func _pieces(level: Node, kind: String) -> Array:
	return level.get_children().filter(func(node: Node) -> bool:
		return node is DisguisePiece and (node as DisguisePiece).kind == kind and not node.is_queued_for_deletion())


func test_a_guests_cop_takes_its_vest_off_on_both_pcs() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host_level: JailbreakLevel = OnlinePcs.level(pcs[0])
	var guest_level: JailbreakLevel = OnlinePcs.level(pcs[1])
	var hung := host_level.hung.filter(func(piece: Variant) -> bool: return piece != null).size()
	await wait_until(func() -> bool:
		return _pieces(guest_level, "coat").size() + _pieces(guest_level, "hat").size() == hung, 5.0)
	assert_eq(_pieces(guest_level, "coat").size() + _pieces(guest_level, "hat").size(), hung, "the coat rack on the guest")
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var on_host := _copy_of(host_level, guest_cop)
	assert_true(guest_cop.disguise.has("prison_vest"), "in a vest on the guest")
	assert_true(on_host.disguise.has("prison_vest"), "and on the host")
	host_level.detectors[0].ring()
	await wait_until(func() -> bool: return guest_level.drill_on(), 5.0)
	assert_true(guest_level.drill_on(), "the drill on the guest too")
	guest_level.hold_vest_off(guest_cop, JailbreakLevel.VEST_OFF_TIME + 0.1)
	await wait_until(func() -> bool: return not on_host.disguise.has("prison_vest"), 5.0)
	assert_false(on_host.disguise.has("prison_vest"), "off on the host")
	assert_false(guest_cop.disguise.has("prison_vest"), "and on the guest")
	await wait_until(func() -> bool: return _pieces(guest_level, "prison_vest").size() == 1, 5.0)
	assert_eq(_pieces(host_level, "prison_vest").size(), 1, "on the host's floor")
	assert_eq(_pieces(guest_level, "prison_vest").size(), 1, "and on the guest's")
