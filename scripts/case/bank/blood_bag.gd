class_name BloodBag
extends Grabbable

## A bag of donated blood from the blood bank's fridge (robo-banco-sangre.md, step 3, decision 128): small and light,
## red. Out of the cold (`is_cold`: the fridge, or the patrol car's cooler) it warms up and darkens, and after WARM_TIME
## it spoils for good; back in the cold it cools down again. A robber can carry it off (`carried_by`). Online the
## host's decide (`follower`). Every number here is (propuesta).

signal spoiled_now(bag: BloodBag)

const KG := 0.5
const SIZE := Vector3(0.16, 0.24, 0.05)
const WARM_TIME := 60.0
## Back in the cold it cools this many times faster than it warmed.
const COOL_SPEED := 4.0
const FRESH := Color(0.8, 0.06, 0.1)
const WARM := Color(0.35, 0.1, 0.06)
const SPOILED := Color(0.22, 0.17, 0.1)
## Where a robber carries it: in front of his belly, from his feet.
const CARRY_AT := Vector3(0, 0.95, -0.45)

## From 0 (cold) to 1 (spoiled).
var warmth := 0.0
var spoiled := false
## The level's: whether a world position is cold (in the fridge or the cooler).
var is_cold: Callable = func(_at: Vector3) -> bool: return true
var carried_by: BankRobber
var follower := false
var _paint: StandardMaterial3D


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var body := CopTool.piece(CopTool.box(SIZE), FRESH)
	_paint = (body.mesh as PrimitiveMesh).material as StandardMaterial3D
	add_child(body)
	add_child(CopTool.piece(CopTool.box(Vector3(0.1, 0.04, 0.052)), Color(0.95, 0.95, 0.92), Vector3(0, 0.06, 0)))
	add_child(CopTool.piece(CopTool.cylinder(0.008, 0.08), Color(0.9, 0.9, 0.9), Vector3(0, -0.15, 0)))


func _ready() -> void:
	add_to_group("blood_bags")
	# It waits still on its shelf until someone takes it.
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true


## A cop takes hold of it: off the shelf.
func hold(holder_id: int, point: Vector3) -> void:
	freeze = false
	super.hold(holder_id, point)


## Online (PropSync): a guest's copy is made from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_BLOOD_BAG"


## A robber takes it: it rides in front of him, frozen, until he drops it (`drop`).
func carry(robber: BankRobber) -> void:
	carried_by = robber
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	collision_layer = 0


func drop() -> void:
	carried_by = null
	collision_layer = 4
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = false


## In the robbers' van: gone for good.
func take() -> void:
	carried_by = null
	hide()
	collision_layer = 0
	process_mode = Node.PROCESS_MODE_DISABLED


func cold() -> bool:
	return carried_by == null and is_cold.call(global_position)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if carried_by:
		global_transform = carried_by.global_transform.translated_local(CARRY_AT)
	if follower:
		return
	if spoiled:
		return
	if cold():
		warmth = maxf(warmth - delta * COOL_SPEED / WARM_TIME, 0.0)
	else:
		warmth = minf(warmth + delta / WARM_TIME, 1.0)
		if warmth >= 1.0:
			spoiled = true
			spoiled_now.emit(self)
	show_warmth()


## Its color: red cold, darker as it warms, brown spoiled.
func show_warmth() -> void:
	_paint.albedo_color = SPOILED if spoiled else FRESH.lerp(WARM, warmth)
