class_name BankSeeds
extends Node3D

## The seed bank (robo-banco-semillas.md, decision 129), a child of the bank: step 1, the place. Pots with plants in the
## hall and on the counter, a green leaf over the vault's door, and the vault's shelves holding JARS glass jars of rare
## seeds (SeedJar) instead of money; each hostage came to leave seeds from his garden and holds a small pot. Step 2: a
## gardener robber who sees a cop throws a handful of seeds halfway to him (once every THROW_EVERY) and a vine wall
## grows there (BankVine); the two pruning shears on the counter (PruningShears) cut it. Step 3: when the drill opens
## the vault, every robber still loose runs in for a jar and out to the van with it; a jar that breaks grows a big
## plant there that stays in the way (cops only) until the end. Online the host's decide (`follower`). Every number
## here is (propuesta).

## The pots (bank coordinates, on the floor or the counter): on the counter, by the entrance and in the hall's corners.
const POTS: Array[Vector3] = [
	Vector3(-6.0, 1.06, -1.0), Vector3(2.0, 1.06, -1.0), Vector3(-2.5, 0.0, 9.0), Vector3(2.5, 0.0, 9.0),
	Vector3(-10.5, 0.0, 8.5), Vector3(10.5, 0.0, 8.5),
]
const POT := Color(0.72, 0.36, 0.2)
const LEAF := Color(0.25, 0.6, 0.25)
## The vault's jars: two on each of the two lower shelves of its two racks, each of its own seeds.
const JARS := 8
const JAR_SHELVES: Array[float] = [0.4, 1.0]
const JAR_COLORS: Array[Color] = [
	Color(0.85, 0.65, 0.2), Color(0.55, 0.3, 0.15), Color(0.9, 0.9, 0.7), Color(0.3, 0.2, 0.1),
	Color(0.85, 0.35, 0.2), Color(0.5, 0.65, 0.25), Color(0.7, 0.4, 0.6), Color(0.95, 0.8, 0.5),
]
## Where the small pot sits on a crouched hostage (his root, which faces -Z).
const HOSTAGE_POT_AT := Vector3(0.0, 0.62, -0.32)
## The pruning shears, on the counter (bank coordinates).
const SHEARS: Array[Vector3] = [Vector3(-3.0, 1.2, -1.0), Vector3(5.0, 1.2, -1.0)]
## Each gardener throws seeds at most this often (s), this far towards the cop (m, at most half the way).
const THROW_EVERY := 20.0
const THROW_REACH := 2.5
const THROW_LINES := 3
## The plant a broken jar grows: how tall, how wide its trunk, how long it takes.
const PLANT_HEIGHT := 2.6
const PLANT_RADIUS := 0.45
const PLANT_GROW := 2.0
const PETALS := Color(0.98, 0.8, 0.15)

var bank: BankLevel
var pots: Array[Node3D] = []
var jars: Array[SeedJar] = []
var shears: Array[PruningShears] = []
var follower := false
var jars_taken := 0
var plants: Array[StaticBody3D] = []
var _throw_left := {}
var _vines := 0
var _carriers := {}


func setup(the_bank: BankLevel) -> void:
	bank = the_bank
	name = "Seeds"
	for i in POTS.size():
		var plant := pot(1.0)
		plant.name = "Pot%d" % i
		plant.position = POTS[i] + Vector3.UP * BankLevel.FLOOR_TOP
		add_child(plant)
		pots.append(plant)
	_leaf()
	_add_jars()
	for hostage in bank.hostages:
		var small := pot(0.45)
		small.name = "HostagePot"
		small.position = HOSTAGE_POT_AT
		hostage.add_child(small)
	for at in SHEARS:
		var pair := PruningShears.new()
		pair.name = "Shears%d" % shears.size()
		pair.position = at + Vector3.UP * BankLevel.FLOOR_TOP
		pair.rotation.y = 0.4
		bank.add_child(pair)
		shears.append(pair)
	for robber in bank.robbers:
		robber.spotted.connect(_on_spotted)


func _physics_process(delta: float) -> void:
	if not follower:
		_carry()
	for robber: BankRobber in _throw_left.keys():
		_throw_left[robber] -= delta
		if _throw_left[robber] <= 0.0:
			_throw_left.erase(robber)


## A gardener saw a cop: seeds halfway to him and a vine wall there, facing him, unless he threw some just now.
func _on_spotted(robber: BankRobber, cop: Node3D) -> void:
	if follower or _throw_left.has(robber) or robber.is_cuffed() or robber.in_van or not robber.visible:
		return
	var way := cop.global_position - robber.global_position
	way.y = 0.0
	if way.length() < 0.5:
		return
	_throw_left[robber] = THROW_EVERY
	robber.say("ROBBER_SEEDS_%d" % (_vines % THROW_LINES + 1))
	grow_vine(robber.global_position + way.normalized() * minf(way.length() / 2.0, THROW_REACH), way)


## A vine wall on the floor at `at` (world), its face towards `facing`.
func grow_vine(at: Vector3, facing: Vector3) -> BankVine:
	var vine := BankVine.new()
	vine.name = "Vine%d" % _vines
	_vines += 1
	bank.add_child(vine)
	vine.global_position = Vector3(at.x, bank.global_position.y + BankLevel.FLOOR_TOP, at.z)
	vine.rotation.y = atan2(facing.x, facing.z)
	return vine


## The gang's van painted green, three pots with bushes on its roof (`root`: the parked van or the chase's truck; its
## riders keep their colors).
static func garden_van(root: Node3D) -> void:
	var green := StandardMaterial3D.new()
	green.albedo_color = Color(0.3, 0.6, 0.3)
	for mesh: Node in root.find_children("*", "MeshInstance3D", true, false):
		var rider := false
		for name_: String in ["Rider", "Rider2"]:
			var node := root.get_node_or_null(name_)
			if node and (node == mesh or node.is_ancestor_of(mesh)):
				rider = true
		if not rider:
			(mesh as MeshInstance3D).material_override = green
	var pots := Node3D.new()
	pots.name = "RoofPots"
	pots.position = Vector3(0, 2.4, -0.8)
	root.add_child(pots)
	for z: float in [-0.7, 0.0, 0.7]:
		var plant := pot(0.9)
		plant.position.z = z
		pots.add_child(plant)


## A clay pot with a round green bush, `size` times the hall's.
static func pot(size: float) -> Node3D:
	var root := Node3D.new()
	root.add_child(CopTool.piece(CopTool.cylinder(0.2 * size, 0.35 * size), POT, Vector3(0, 0.175 * size, 0)))
	var bush := SphereMesh.new()
	bush.radius = 0.3 * size
	bush.height = 0.5 * size
	var leaves := CopTool.piece(bush, LEAF, Vector3(0, 0.55 * size, 0))
	leaves.name = "Leaves"
	root.add_child(leaves)
	return root


func _add_jars() -> void:
	for i in JARS:
		var jar := SeedJar.new(JAR_COLORS[i])
		jar.name = "SeedJar%d" % i
		var rack := i / 4
		var shelf := (i / 2) % 2
		jar.position = Vector3(11.25, BankLevel.FLOOR_TOP + JAR_SHELVES[shelf] + SeedJar.HEIGHT / 2 + 0.02,
			BankBlood.RACK_ZS[rack] + (0.3 if i % 2 == 0 else -0.3))
		bank.add_child(jar)
		jars.append(jar)
		jar.broke.connect(_on_broke)


## The green leaf over the vault's door.
func _leaf() -> void:
	var leaf := CopTool.piece(SphereMesh.new(), LEAF, Vector3(BankLevel.VAULT_X - 0.25, 2.9, BankLevel.VAULT_DOOR_Z))
	leaf.name = "Leaf"
	leaf.scale = Vector3(0.12, 0.5, 0.3)
	leaf.rotation.x = 0.5
	add_child(leaf)
	var stem := CopTool.piece(CopTool.cylinder(0.02, 0.3), LEAF.darkened(0.3), Vector3(0, -0.6, 0))
	leaf.add_child(stem)


## The jars still good (not broken, not taken) and back in the vault now.
func jars_home() -> int:
	return jars.filter(func(jar: SeedJar) -> bool: return jar.visible and not jar.broken and _in_vault(jar)).size()


func jars_broken() -> int:
	return jars.filter(func(jar: SeedJar) -> bool: return jar.broken).size()


func _in_vault(jar: SeedJar) -> bool:
	var inside := bank.to_local(jar.global_position)
	return BankBlood.FRIDGE.has_point(Vector2(inside.x, inside.z))


## The vault is open: every robber still loose runs to it for a jar (the corridor's way from the hall), as in the
## blood bank (BankBlood.load_up).
func load_up() -> void:
	for robber in bank.robbers:
		if not BankLevel.is_loose(robber) or robber.in_van or not robber.visible:
			continue
		robber.run_path.clear()
		var way: Array[Vector3] = []
		var from := bank.to_local(robber.global_position)
		if from.z < BankLevel.COUNTER_Z and not BankLevel.in_corridor(from):
			way.append_array(BankLevel.HALL_TO_CORRIDOR.slice(2))
		elif not BankLevel.in_corridor(from):
			way.append_array(BankLevel.HALL_TO_CORRIDOR)
		way.append(BankLevel.AT_DRILL)
		for at in way:
			robber.run_path.append(bank.global_transform * at)
		robber.into_van = false
		robber.surrendered = false
		robber.running = true
		_carriers[robber] = null


## The robbers fetching and carrying jars: at the vault, a jar and out to the van; cuffed, he sets it down; in the van,
## it's gone (and El Oso in it starts the getaway).
func _carry() -> void:
	for robber: BankRobber in _carriers.keys():
		var jar: SeedJar = _carriers[robber]
		if jar and jar.broken:
			_carriers[robber] = null
			jar = null
		if robber.is_cuffed():
			if jar:
				jar.drop()
			_carriers.erase(robber)
		elif robber.in_van:
			if jar:
				jar.take()
				jars_taken += 1
				bank.bags_taken += 1
			_carriers.erase(robber)
			if robber == bank.boss:
				bank._run_getaway(false)
		elif not robber.running and not robber.into_van:
			jar = _free_jar()
			if jar:
				jar.carry(robber)
				_carriers[robber] = jar
			var way := BankLevel.HALL_TO_CORRIDOR.duplicate()
			way.reverse()
			way.append_array(BankLevel.PIG_RUN)
			for at: Vector3 in way:
				robber.run_path.append(bank.global_transform * at)
			robber.into_van = true
			robber.running = true


## A jar still in the vault that nobody carries.
func _free_jar() -> SeedJar:
	for jar in jars:
		if jar.visible and not jar.broken and not jar.carried_by and jar.holders.is_empty() and _in_vault(jar):
			return jar
	return null


func _on_broke(jar: SeedJar) -> void:
	grow_plant(jar.global_position)


## A big sunflower on the floor at `at` (world), growing in PLANT_GROW: it stops the cops (not the gang) until the end.
func grow_plant(at: Vector3) -> StaticBody3D:
	var plant := StaticBody3D.new()
	plant.name = "Plant%d" % plants.size()
	plant.add_to_group("bank_plants")
	plant.collision_layer = 4
	plant.collision_mask = 0
	var shape := CollisionShape3D.new()
	var trunk := CylinderShape3D.new()
	trunk.radius = PLANT_RADIUS
	trunk.height = PLANT_HEIGHT
	shape.shape = trunk
	shape.position.y = PLANT_HEIGHT / 2
	plant.add_child(shape)
	var look := Node3D.new()
	look.name = "Look"
	look.add_child(CopTool.piece(CopTool.cylinder(0.1, PLANT_HEIGHT), LEAF.darkened(0.2), Vector3(0, PLANT_HEIGHT / 2, 0)))
	for side: float in [-1.0, 1.0]:
		var leaf := CopTool.piece(SphereMesh.new(), LEAF, Vector3(side * 0.35, PLANT_HEIGHT * 0.45, 0))
		leaf.scale = Vector3(0.6, 0.15, 0.35)
		look.add_child(leaf)
	var flower := CopTool.piece(CopTool.cylinder(0.6, 0.08), PETALS, Vector3(0, PLANT_HEIGHT, 0.1), Vector3(1.2, 0, 0))
	flower.add_child(CopTool.piece(CopTool.cylinder(0.3, 0.1), Color(0.35, 0.2, 0.08), Vector3(0, 0.02, 0)))
	look.add_child(flower)
	look.scale = Vector3.ONE * 0.05
	plant.add_child(look)
	bank.add_child(plant)
	plant.global_position = Vector3(at.x, bank.global_position.y + BankLevel.FLOOR_TOP, at.z)
	plants.append(plant)
	create_tween().tween_property(look, "scale", Vector3.ONE, PLANT_GROW)
	return plant
