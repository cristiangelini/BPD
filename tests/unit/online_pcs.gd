extends RefCounted

## Test helper: a host and guests on this PC, each in its own multiplayer branch with a Net and a level holding the
## player's cop, as if they were different PCs. `fill_level` adds the same things to every PC's level; `make_level`
## builds the whole level instead (a real place), with its own "Cop".

const NET_SCRIPT := preload("res://scripts/core/net.gd")
const COP_SCENE := preload("res://scenes/player/cop.tscn")

var nets: Array[Node] = []
var port := randi_range(20000, 40000)
var _test: GutTest
var _fill_level: Callable
var _make_level: Callable


func _init(test: GutTest, fill_level := Callable(), make_level := Callable()) -> void:
	_test = test
	_fill_level = fill_level
	_make_level = make_level


func new_pc() -> Node:
	var branch := Node.new()
	branch.name = "Pc%d" % nets.size()
	_test.add_child(branch)
	_test.get_tree().set_multiplayer(SceneMultiplayer.new(), branch.get_path())
	var net: Node = NET_SCRIPT.new()
	net.name = "Net"
	net.change_scenes = false
	branch.add_child(net)
	# Its own physics world, so the PCs' levels don't bump into each other.
	var world := SubViewport.new()
	world.name = "World"
	world.own_world_3d = true
	world.size = Vector2i(64, 64)
	branch.add_child(world)
	if _make_level.is_valid():
		var place: Node3D = _make_level.call()
		place.name = "Level"
		place.get_node("Cop").input_enabled = false
		world.add_child(place)
		nets.append(net)
		return net
	var level := Node3D.new()
	level.name = "Level"
	world.add_child(level)
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	cop.name = "Cop"
	level.add_child(cop)
	if _fill_level.is_valid():
		_fill_level.call(level)
	nets.append(net)
	return net


static func level(net: Node) -> Node3D:
	return net.get_parent().get_node("World/Level")


static func own_cop(net: Node) -> Cop:
	return level(net).get_node("Cop")


## A host and a guest in the same level, each with its cop in place and knowing the other has it loaded.
func two_pcs() -> Array[Node]:
	var host := new_pc()
	host.host(port)
	var guest := new_pc()
	guest.join("127.0.0.1", port)
	await _test.wait_until(func() -> bool: return guest.players.size() == 2, 5.0)
	host.spawn_cops(own_cop(host))
	guest.spawn_cops(own_cop(guest))
	await _test.wait_until(func() -> bool: return not host.scene_peers.is_empty() and not guest.scene_peers.is_empty(), 5.0)
	return [host, guest]


func free_all() -> void:
	for net in nets:
		net.leave()
		net.get_parent().queue_free()
	nets.clear()
