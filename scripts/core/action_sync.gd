class_name ActionSync
extends Node

## What cops do to the level (E, R, the battering ram, dropping it, getting out of the car) happens on every PC in
## the same order (docs/diseno/online.md, "Quién manda"): the owner asks the host, the host does it with its copy of
## that cop and tells every guest to do the same with theirs. A hint only shows on the owner's screen, since only
## that cop has a player at the keys. Lives under the Net autoload as "Actions".

## Methods that take the cop doing them.
const ACTOR_METHODS: Array[String] = ["use", "ask", "exit", "armory_choose", "armory_given"]

var net: Node
## Everything in the level a cop can do something to, in tree order (the same on every PC), plus what was added later
## in the same order everywhere (a dropped ram).
var targets: Array[Node] = []
## True while the host does a guest's action: that guest does it too, so its hints aren't sent twice.
var performing := false
var _level: Node


func _init(owner_net: Node, level: Node) -> void:
	net = owner_net
	_level = level
	name = "Actions"
	for node in level.find_children("*", "", true, false):
		if is_target(node):
			targets.append(node)


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


static func is_target(node: Node) -> bool:
	if node is Cop:
		return false
	return node.has_method("use") or node.has_method("ask") or node.has_method("ram_hit") \
		or node.has_method("struck")


## `actor` (this PC's own cop) does `method` on `target` (the actor itself for "drop_ram"), on every PC. `args` are
## what the actor's own PC decided (which car seat), so every PC does exactly the same.
func act(actor: Cop, method: String, target: Node, args := []) -> void:
	var index := -1 if target == actor else targets.find(target)
	if index < 0 and target != actor:
		return
	args = args.map(encode)
	if multiplayer.is_server():
		_do_and_tell(multiplayer.get_unique_id(), index, method, args)
	else:
		_ask.rpc_id(net.HOST_ID, index, method, args)


## Host: tells every guest to do `method` on `target` with `actor`, without doing it here (what the host decided alone,
## like the armory's answer).
func tell_guests(actor: Cop, method: String, target: Node, args := []) -> void:
	var actor_id := -1
	for id: int in net.cop_syncs:
		if net.cop_syncs[id].cop == actor:
			actor_id = id
	var index := -1 if target == actor else targets.find(target)
	if actor_id < 0 or (index < 0 and target != actor):
		return
	for peer: int in net.scene_peers:
		_told.rpc_id(peer, actor_id, index, method, args.map(encode))


@rpc("any_peer", "call_remote", "reliable")
func _ask(index: int, method: String, args: Array) -> void:
	if multiplayer.is_server():
		_do_and_tell(multiplayer.get_remote_sender_id(), index, method, args)


func _do_and_tell(actor_id: int, index: int, method: String, args: Array) -> void:
	performing = actor_id != multiplayer.get_unique_id()
	var done := _perform(actor_id, index, method, args)
	performing = false
	if done:
		for peer: int in net.scene_peers:
			_told.rpc_id(peer, actor_id, index, method, args)


@rpc("authority", "call_remote", "reliable")
func _told(actor_id: int, index: int, method: String, args: Array) -> void:
	_perform(actor_id, index, method, args)


func _perform(actor_id: int, index: int, method: String, args: Array) -> bool:
	var sync: CopSync = net.cop_syncs.get(actor_id)
	if not sync or not is_instance_valid(sync.cop):
		return false
	var actor := sync.cop
	var target: Node = actor if index < 0 else (targets[index] if index < targets.size() else null)
	if not is_instance_valid(target) or not target.has_method(method):
		return false
	target.callv(method, ([actor] if ACTOR_METHODS.has(method) else []) + args.map(decode))
	return true


## A node among an action's arguments, as every PC can find it: a cop by its player's id (its name differs on each PC),
## a prop by its place in PropSync's list (one made during the case has no name in common), anything else by its path
## in the level.
func encode(arg: Variant) -> Variant:
	if arg is Cop:
		for id: int in net.cop_syncs:
			if net.cop_syncs[id].cop == arg:
				return {"cop": id}
		return null
	if arg is RigidBody3D and net.props and net.props.index_of(arg) >= 0:
		return {"prop": net.props.index_of(arg)}
	if arg is Node:
		return {"path": _level.get_path_to(arg)}
	return arg


func decode(arg: Variant) -> Variant:
	if arg is Dictionary and arg.has("cop"):
		var sync: CopSync = net.cop_syncs.get(arg.cop)
		return sync.cop if sync and is_instance_valid(sync.cop) else null
	if arg is Dictionary and arg.has("prop"):
		return net.props.prop_at(arg.prop) if net.props else null
	if arg is Dictionary and arg.has("path"):
		return _level.get_node_or_null(arg.path)
	return arg


func _on_node_added(node: Node) -> void:
	if is_target(node) and _level.is_ancestor_of(node) and not targets.has(node):
		targets.append(node)
