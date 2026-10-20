extends GutTest

## Synced cops (docs/diseno/online.md, step 3): every player sees the other players' cops, in their colors, moving
## where their owners move them. Host and guest run on this PC, each in its own multiplayer branch.

const NET_SCRIPT := preload("res://scripts/core/net.gd")
const COP_SCENE := preload("res://scenes/player/cop.tscn")

var _port := 0
var _nets: Array[Node] = []


func before_each() -> void:
	_port = randi_range(20000, 40000)
	_nets.clear()


func after_each() -> void:
	for net in _nets:
		net.leave()
		net.get_parent().queue_free()
	await wait_process_frames(2)


## A PC: its own multiplayer branch with a Net and a level holding the player's cop.
func _new_pc() -> Node:
	var branch := Node.new()
	branch.name = "Pc%d" % _nets.size()
	add_child(branch)
	get_tree().set_multiplayer(SceneMultiplayer.new(), branch.get_path())
	var net: Node = NET_SCRIPT.new()
	net.name = "Net"
	net.change_scenes = false
	branch.add_child(net)
	var level := Node3D.new()
	level.name = "Level"
	branch.add_child(level)
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	level.add_child(cop)
	_nets.append(net)
	return net


func _cops(net: Node) -> Array[Node]:
	return net.get_parent().get_node("Level").get_children()


## A host and a guest in the same level, each with its cop in place.
func _two_pcs() -> Array[Node]:
	var host := _new_pc()
	assert_eq(host.host(_port), OK)
	var guest := _new_pc()
	guest.join("127.0.0.1", _port)
	await wait_until(func() -> bool: return guest.players.size() == 2, 5.0)
	host.spawn_cops(_cops(host)[0])
	guest.spawn_cops(_cops(guest)[0])
	await wait_until(func() -> bool: return not host.scene_peers.is_empty() and not guest.scene_peers.is_empty(), 5.0)
	return [host, guest]


func test_each_pc_has_a_cop_per_player_in_its_color() -> void:
	var pcs: Array[Node] = await _two_pcs()
	for net in pcs:
		assert_eq(_cops(net).size(), 2, "one cop per player on every PC")
		var colors := []
		for cop: Cop in _cops(net):
			colors.append(cop.uniform)
		colors.sort()
		assert_eq(colors, [0, 1], "the host is pink and the guest orange on every PC")
	var guest_own: Cop = _cops(pcs[1])[0]
	assert_eq(guest_own.uniform, 1, "the guest's own cop wears its slot's skin")


func test_cops_start_side_by_side() -> void:
	var pcs: Array[Node] = await _two_pcs()
	var cops := _cops(pcs[0])
	assert_gt((cops[0] as Cop).global_position.distance_to((cops[1] as Cop).global_position), 1.0,
		"cops don't spawn inside each other")


func test_the_owner_moves_its_cop_on_the_other_pc() -> void:
	var pcs: Array[Node] = await _two_pcs()
	var host: Node = pcs[0]
	var guest_own: Cop = _cops(pcs[1])[0]
	var copy_on_host: Cop = host.cop_syncs[pcs[1].multiplayer.get_unique_id()].cop
	assert_ne(copy_on_host, guest_own)
	guest_own.global_position = Vector3(3, 0, -7)
	guest_own.rotation.y = 1.0
	await wait_until(func() -> bool: return copy_on_host.global_position.distance_to(Vector3(3, 0, -7)) < 0.05, 5.0)
	assert_almost_eq(copy_on_host.global_position, Vector3(3, 0, -7), Vector3.ONE * 0.05)
	assert_almost_eq(copy_on_host.global_rotation.y, 1.0, 0.05, "and it turns the same way")


func test_the_copy_crouches_with_its_owner() -> void:
	var pcs: Array[Node] = await _two_pcs()
	var host_own: Cop = _cops(pcs[0])[0]
	var copy_on_guest: Cop = pcs[1].cop_syncs[1].cop
	host_own.set_crouching(true)
	await wait_until(func() -> bool: return copy_on_guest.is_crouching, 5.0)
	assert_true(copy_on_guest.is_crouching)


func test_the_cop_of_a_player_who_leaves_goes_away() -> void:
	var pcs: Array[Node] = await _two_pcs()
	var host: Node = pcs[0]
	pcs[1].leave()
	await wait_until(func() -> bool: return _cops(host).size() == 1, 5.0)
	assert_eq(_cops(host).size(), 1)
	assert_eq(host.cop_syncs.size(), 1, "only the host's own cop is left")


func test_solo_spawns_nobody() -> void:
	var net := _new_pc()
	net.spawn_cops(_cops(net)[0])
	assert_eq(_cops(net).size(), 1)
	assert_true(net.cop_syncs.is_empty())
