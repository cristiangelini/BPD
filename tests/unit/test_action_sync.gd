extends GutTest

## Doing things online (docs/diseno/online.md, step 4): what a cop does to the level happens on every PC, the hint
## only on its owner's screen, and only the host makes new props.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const DOOR := preload("res://scenes/props/front_door.tscn")
const POT := preload("res://scenes/props/key_pot.tscn")
const SAFE := preload("res://scenes/props/heavy_safe.tscn")
const RAM_PICKUP := preload("res://scenes/tools/ram_pickup.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	_pcs = OnlinePcs.new(self, _fill_level)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _fill_level(level: Node3D) -> void:
	var floor := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 1, 40)
	shape.shape = box
	floor.add_child(shape)
	floor.position = Vector3(0, -0.5, 0)
	level.add_child(floor)
	for scene: PackedScene in [DOOR, POT, SAFE, RAM_PICKUP]:
		var node: Node3D = scene.instantiate()
		node.name = scene.resource_path.get_file().get_basename()
		level.add_child(node)
	level.get_node("front_door").position = Vector3(0, 0, -8)
	level.get_node("key_pot").position = Vector3(3, 0.2, -3)
	level.get_node("heavy_safe").position = Vector3(-4, 0.3, -4)
	level.get_node("ram_pickup").position = Vector3(5, 0, 2)


func _in(net: Node, name: String) -> Node:
	return OnlinePcs.level(net).get_node(name)


func test_a_guest_opens_the_door_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	for net in pcs:
		(_in(net, "front_door") as FrontDoor).locked = false
	OnlinePcs.own_cop(pcs[1]).act("use", _in(pcs[1], "front_door"))
	await wait_until(func() -> bool: return (_in(pcs[1], "front_door") as FrontDoor).is_open, 5.0)
	assert_true((_in(pcs[0], "front_door") as FrontDoor).is_open, "open for the host")
	assert_true((_in(pcs[1], "front_door") as FrontDoor).is_open, "and for the guest")


func test_the_key_goes_to_the_guest_cop_everywhere_and_the_hint_only_to_its_screen() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	for net in pcs:
		(_in(net, "key_pot") as KeyPot).has_key = true
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var copy_on_host: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	guest_cop.act("use", _in(pcs[1], "key_pot"))
	await wait_until(func() -> bool: return guest_cop.has_key, 5.0)
	assert_true(copy_on_host.has_key, "the host's copy of the guest's cop has the key too")
	assert_false(OnlinePcs.own_cop(pcs[0]).has_key, "the host's own cop doesn't")
	assert_eq(guest_cop.get_node("Hud/Hint").text, "HINT_KEY_FOUND")
	assert_false(OnlinePcs.own_cop(pcs[0]).get_node("Hud/Hint").visible, "nothing on the host's screen")


func test_a_hint_the_host_gives_a_guest_cop_reaches_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var copy_on_host: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	copy_on_host.show_hint("HINT_HEAVY_BREAD")
	await wait_until(func() -> bool: return guest_cop.get_node("Hud/Hint").text == "HINT_HEAVY_BREAD", 5.0)
	assert_true(guest_cop.get_node("Hud/Hint").visible)


func test_the_ram_is_picked_up_and_dropped_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var copy_on_host: Cop = pcs[0].cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	guest_cop.act("use", _in(pcs[1], "ram_pickup"))
	await wait_until(func() -> bool: return guest_cop.ram != null, 5.0)
	assert_not_null(copy_on_host.ram, "the others see the ram in the guest's hands")
	guest_cop.act("drop_ram", guest_cop)
	await wait_until(func() -> bool: return guest_cop.ram == null, 5.0)
	assert_null(copy_on_host.ram)
	for net in pcs:
		assert_eq(OnlinePcs.level(net).find_children("*", "RamPickup", true, false).size(), 1,
			"one ram on the floor on every PC")
	assert_eq(pcs[1].actions.targets.size(), pcs[0].actions.targets.size(), "both PCs know the same things to use")


func test_the_takings_come_out_of_the_safe_once_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	for net in pcs:
		(_in(net, "heavy_safe") as SafeBox).code_known = true
	OnlinePcs.own_cop(pcs[1]).act("use", _in(pcs[1], "heavy_safe"))
	await wait_until(func() -> bool: return pcs[1].props.props.size() == pcs[0].props.props.size(), 5.0)
	await wait_process_frames(5)
	var bundles: Array[Node] = OnlinePcs.level(pcs[1]).find_children("*", "Evidence", true, false).filter(
		func(node: Node) -> bool: return not node is SafeBox)
	assert_eq(bundles.size(), 1, "the guest has the host's takings, not its own too")
	assert_true((bundles[0] as Grabbable).freeze, "a frozen copy of the host's")
	assert_eq(pcs[1].props.index_of(bundles[0]), pcs[0].props.props.size() - 1)
