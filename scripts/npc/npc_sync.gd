class_name NpcSync
extends Node

## Keeps the level's people and animals the same on every PC (docs/diseno/online.md, "Qué se sincroniza"): the host
## runs them (where they walk, what they say, how annoyed they are) and sends it about 15 times a second; on the
## guests they are puppets that only follow. Only the host brings new ones in (the bakery's customers): the guests
## make a copy from the same scene (or script). Lives under the Net autoload as "Npcs".

const SEND_RATE := 15.0
const EASE := 12.0
## A puppet further than this from where it should be jumps there instead of walking.
const SNAP_DISTANCE := 3.0
const PER_PACKET := 12

var net: Node
var npcs: Array[Node3D] = []
## Index -> state last sent (host) or to follow (guests): [transform, bubble text, bubble shown, complaint, story,
## what else the NPC needs (net_state())].
var _sent := {}
var _targets := {}
var _gone := {}
## Index -> [scene, look, setup] of what the host brought in after the level started; setup (net_setup()) is what
## the copy needs before it's added, with its name and where it goes in the level.
var _spawned := {}
var _adding: Node
var _level: Node
var _send_left := 0.0


func _init(owner_net: Node, level: Node) -> void:
	net = owner_net
	_level = level
	name = "Npcs"
	for node in level.find_children("*", "Node3D", true, false):
		if is_npc(node):
			npcs.append(node as Node3D)


static func is_npc(node: Node) -> bool:
	return node is Grandpa or node is Baker or node is BakeryCustomer or node is Pigeon or node is DogGroomer \
		or node is PoodleLady or node is HumanCustomer or node is Gossip or node is Neighbor or node is Armero \
		or node is InterrogationSuspect or node is SuspectCar or node is ChaseSuspect \
		or node is ChaseFurniture or node is ChaseDummy or node is TrafficCar or node is QueueCar or node is NightGuard \
		or node is ClubBingo or node is ClubSuspicion or node is BankRobber or node is BankHostage \
		or node is Politician or node is RallyFan or node is PrisonInmate or node is MarketVendor \
		or node is MarketShopper or node is Cleaner or node is FloorStains or node is GuardDog \
		or node is TunnelHole or node is BankManager or node is AccompliceCar \
		or node is BlackoutInmate or node is PrisonVisitor or node is VisitInmate or node is ChaseGhost \
		or node is LaundryWorker or node is LaundryCart or node is YardInmate or node is CellHideout \
		or node is TunnelDirt or node is HamsterCage \
		or node is TalentInmate or node is TalentProp


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	if net.is_host():
		return
	# The guest's level doesn't bring anyone in; the host's copies come instead.
	if "brings_customers" in _level:
		_level.brings_customers = false
	for npc in npcs:
		_puppet(npc)


## A guest's copy: no mind of its own and nothing it notices; it only follows the host.
static func _puppet(npc: Node3D) -> void:
	npc.set_physics_process(false)
	npc.set_process(false)
	# A body that falls (the chase's furniture) falls only on the host.
	if npc is RigidBody3D:
		(npc as RigidBody3D).freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		(npc as RigidBody3D).freeze = true
	for area in npc.find_children("*", "Area3D", true, false):
		(area as Area3D).monitoring = false
	var escort := OwnerEscort.of(npc)
	if escort:
		escort.follower = true
	# One that decides something of its own (a robber dodging the cuffs) leaves it to the host's.
	if "follower" in npc:
		npc.set("follower", true)


func npc_at(index: int) -> Node3D:
	if index < 0 or index >= npcs.size() or not is_instance_valid(npcs[index]):
		return null
	return npcs[index]


## Host: everything to `peer` (it just loaded the level).
func resend_all(peer: int) -> void:
	for index: int in _spawned:
		_made.rpc_id(peer, index, _spawned[index][0], _spawned[index][1], _spawned[index][2])
	_removed.rpc_id(peer, PackedInt32Array(_gone.keys()))
	for i in npcs.size():
		if npc_at(i):
			_moved_all.rpc_id(peer, PackedInt32Array([i]), [_state_of(npcs[i])])


func _physics_process(delta: float) -> void:
	if net.is_host():
		_send_left -= delta
		if _send_left <= 0.0:
			_send_left = 1.0 / SEND_RATE
			_send()
	else:
		_follow(delta)


func _state_of(npc: Node3D) -> Array:
	var bubble := npc.get_node_or_null("Bubble") as Label3D
	return [npc.global_transform, bubble.text if bubble else "", bubble.visible if bubble else false,
		npc.get("complaint") if "complaint" in npc else 0.0,
		npc.is_telling_story() if npc.has_method("is_telling_story") else false,
		npc.net_state() if npc.has_method("net_state") else null, _escort_state(npc)]


## The owner's escort, if he has one: whether he's in the patrol car and which player's cop walks him (0: nobody).
func _escort_state(npc: Node3D) -> Variant:
	var escort := OwnerEscort.of(npc)
	if not escort:
		return null
	var by := 0
	for id: int in net.cop_syncs:
		if escort.escorted_by and net.cop_syncs[id].cop == escort.escorted_by:
			by = id
	return [escort.in_car, by]


func _apply_escort(npc: Node3D, state: Variant) -> void:
	var escort := OwnerEscort.of(npc)
	if not escort or state == null:
		return
	var sync: CopSync = net.cop_syncs.get(state[1])
	escort.escorted_by = sync.cop if sync and is_instance_valid(sync.cop) else null
	if state[0] and not escort.in_car:
		escort.board()


func _send() -> void:
	var ids := PackedInt32Array()
	var states := []
	var gone := PackedInt32Array()
	var sure_ids := PackedInt32Array()
	var sure := []
	for i in npcs.size():
		var npc := npc_at(i)
		if not npc or not npc.is_inside_tree():
			if not _gone.has(i):
				_gone[i] = true
				gone.append(i)
			continue
		var state := _state_of(npc)
		var before: Array = _sent.get(i, [])
		if before == state:
			continue
		_sent[i] = state
		# Only where it is changed: that goes again in a moment if lost. Anything else (what he says, getting off his
		# scooter, getting in the car) may not change again, so it goes reliably.
		if before.is_empty() or before.slice(1) != state.slice(1):
			sure_ids.append(i)
			sure.append(state)
		else:
			ids.append(i)
			states.append(state)
	for peer: int in net.scene_peers:
		if not gone.is_empty():
			_removed.rpc_id(peer, gone)
		for from in range(0, ids.size(), PER_PACKET):
			_moved.rpc_id(peer, ids.slice(from, from + PER_PACKET), states.slice(from, from + PER_PACKET))
		for from in range(0, sure_ids.size(), PER_PACKET):
			_moved_all.rpc_id(peer, sure_ids.slice(from, from + PER_PACKET), sure.slice(from, from + PER_PACKET))


@rpc("authority", "call_remote", "unreliable_ordered")
func _moved(ids: PackedInt32Array, states: Array) -> void:
	for n in ids.size():
		_apply(ids[n], states[n])


@rpc("authority", "call_remote", "reliable")
func _moved_all(ids: PackedInt32Array, states: Array) -> void:
	_moved(ids, states)


func _apply(index: int, state: Array) -> void:
	var npc := npc_at(index)
	if not npc:
		return
	var place: Transform3D = state[0]
	var riding := OwnerEscort.of(npc) != null and OwnerEscort.of(npc).in_car
	if not riding and (not _targets.has(index) or npc.global_position.distance_to(place.origin) > SNAP_DISTANCE):
		npc.global_transform = place
	_targets[index] = place
	var bubble := npc.get_node_or_null("Bubble") as Label3D
	if bubble:
		bubble.text = state[1]
		bubble.visible = state[2]
	if "complaint" in npc and not is_equal_approx(npc.get("complaint"), state[3]):
		npc.set("complaint", state[3])
		if npc.has_signal("complaint_changed"):
			npc.emit_signal("complaint_changed", state[3])
	# The story ended on the host (it ran out of time): the listening cop is free again here too.
	if npc.has_method("is_telling_story") and npc.is_telling_story() and not state[4]:
		npc.end_story()
	if state.size() > 5 and npc.has_method("apply_net_state"):
		npc.apply_net_state(state[5])
	if state.size() > 6:
		_apply_escort(npc, state[6])


@rpc("authority", "call_remote", "reliable")
func _removed(gone: PackedInt32Array) -> void:
	for i in gone:
		var npc := npc_at(i)
		_gone[i] = true
		_targets.erase(i)
		if npc:
			npc.queue_free()


func _on_node_added(node: Node) -> void:
	if not is_npc(node) or node == _adding or not _level.is_ancestor_of(node) or npcs.has(node):
		return
	if net.is_host():
		npcs.append(node as Node3D)
		var index := npcs.size() - 1
		# The look is set right after it enters the tree, so it's read on the next frame.
		_announce.call_deferred(index)
	elif node.has_method("net_setup") and not String(node.name).begins_with("@"):
		# The guest's own copy of what the host also adds (the owner's getaway car): it waits for the host's to adopt it.
		_puppet.call_deferred(node)
	else:
		node.queue_free.call_deferred()


func _announce(index: int) -> void:
	var npc := npc_at(index)
	if not npc:
		return
	# One made in code (the salon's human customers) is copied from its script.
	var source: String = npc.scene_file_path if npc.scene_file_path != "" else (npc.get_script() as Script).resource_path
	var setup: Dictionary = npc.net_setup() if npc.has_method("net_setup") else {}
	if not setup.is_empty():
		setup.name = npc.name
		setup.parent = _level.get_path_to(npc.get_parent())
	_spawned[index] = [source, npc.get("look") if "look" in npc else 0, setup]
	for peer: int in net.scene_peers:
		_made.rpc_id(peer, index, _spawned[index][0], _spawned[index][1], setup)


@rpc("authority", "call_remote", "reliable")
func _made(index: int, scene: String, look: int, setup := {}) -> void:
	while npcs.size() <= index:
		npcs.append(null)
	if npcs[index] or _gone.has(index) or scene == "" or not ResourceLoader.exists(scene):
		return
	var own := _level.get_node_or_null(NodePath(str(setup.get("parent", "."), "/", setup.get("name", "")))) \
		if setup.has("name") else null
	if own and is_npc(own):
		npcs[index] = own
		return
	var made: Variant = load(scene)
	var npc: Node3D = (made as PackedScene).instantiate() if made is PackedScene else (made as Script).new()
	if not npc.has_method("set_look") and "look" in npc:
		npc.set("look", look)
	var parent: Node = _level
	for key: String in setup:
		if key == "name":
			npc.name = setup.name
		elif key == "parent":
			parent = _level.get_node_or_null(setup.parent) if _level.get_node_or_null(setup.parent) else _level
		else:
			npc.set(key, setup[key])
	_adding = npc
	parent.add_child(npc)
	_adding = null
	# After entering the tree: on ready, Godot turns processing back on.
	_puppet(npc)
	if npc.has_method("set_look"):
		npc.set_look(look)
	npcs[index] = npc


func _follow(delta: float) -> void:
	var weight := 1.0 - exp(-EASE * delta)
	for index: int in _targets:
		var npc := npc_at(index)
		# In the patrol car his escort keeps him in the back seat, wherever the car goes.
		var escort := OwnerEscort.of(npc) if npc else null
		if npc and not (escort and escort.in_car):
			npc.global_transform = npc.global_transform.interpolate_with(_targets[index], weight)
