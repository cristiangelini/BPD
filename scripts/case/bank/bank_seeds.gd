class_name BankSeeds
extends Node3D

## The seed bank (robo-banco-semillas.md, decision 129), a child of the bank: step 1, the place. Pots with plants in the
## hall and on the counter, a green leaf over the vault's door, and the vault's shelves holding JARS glass jars of rare
## seeds (SeedJar) instead of money; each hostage came to leave seeds from his garden and holds a small pot. Every
## number here is (propuesta).

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

var bank: BankLevel
var pots: Array[Node3D] = []
var jars: Array[SeedJar] = []


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


## The green leaf over the vault's door.
func _leaf() -> void:
	var leaf := CopTool.piece(SphereMesh.new(), LEAF, Vector3(BankLevel.VAULT_X - 0.25, 2.9, BankLevel.VAULT_DOOR_Z))
	leaf.name = "Leaf"
	leaf.scale = Vector3(0.12, 0.5, 0.3)
	leaf.rotation.x = 0.5
	add_child(leaf)
	var stem := CopTool.piece(CopTool.cylinder(0.02, 0.3), LEAF.darkened(0.3), Vector3(0, -0.6, 0))
	leaf.add_child(stem)
