class_name SeedJar
extends Grabbable

## A glass jar of rare seeds from the seed bank's vault (robo-banco-semillas.md, step 1, decision 129): small, light,
## its lid and its seeds of one color. It waits still on its shelf until someone takes it. Step 3: hitting something at
## BREAK_SPEED or more (thrown, or let go of while running) it breaks (`broke`; BankSeeds grows a plant there). A cop
## who runs with it in hand for TRIP_TIME lets go of it. A robber can carry it off (`carried_by`). Online the host's
## decide (`follower`). Every number here is (propuesta).

signal broke(jar: SeedJar)

const KG := 0.6
const RADIUS := 0.09
const HEIGHT := 0.22
const GLASS := Color(0.8, 0.92, 0.95, 0.45)
const LID := Color(0.55, 0.4, 0.2)
## It breaks hitting something this fast (m/s): a walking cop can let go of it, not throw it or drop it running.
const BREAK_SPEED := 6.0
## Running this long (s) with it in hand, the cop drops it.
const TRIP_TIME := 2.0
## Where a robber carries it: in front of his belly, from his feet.
const CARRY_AT := Vector3(0, 0.95, -0.45)

## The seeds inside.
var color := Color(0.8, 0.6, 0.2)
var broken := false
var carried_by: BankRobber
var follower := false
var _speed := 0.0
var _trip_left := TRIP_TIME


func _init(seeds_color := Color(0.8, 0.6, 0.2)) -> void:
	color = seeds_color
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = RADIUS
	cylinder.height = HEIGHT
	shape.shape = cylinder
	add_child(shape)
	var glass := CopTool.piece(CopTool.cylinder(RADIUS, HEIGHT), GLASS)
	var see_through := (glass.mesh as PrimitiveMesh).material as StandardMaterial3D
	see_through.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	add_child(glass)
	var seeds := CopTool.piece(CopTool.cylinder(RADIUS * 0.85, HEIGHT * 0.6), color, Vector3(0, -HEIGHT * 0.18, 0))
	seeds.name = "Seeds"
	add_child(seeds)
	add_child(CopTool.piece(CopTool.cylinder(RADIUS * 1.05, 0.03), LID, Vector3(0, HEIGHT / 2 + 0.015, 0)))


func _ready() -> void:
	add_to_group("seed_jars")
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_hit)


## A cop takes hold of it: off the shelf.
func hold(holder_id: int, point: Vector3) -> void:
	freeze = false
	super.hold(holder_id, point)


## Online (PropSync): a guest's copy is made from this script.
func net_setup() -> Dictionary:
	return {}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_SEED_JAR"


## A robber takes it: it rides in front of him, frozen, until he sets it down (`drop`).
func carry(robber: BankRobber) -> void:
	carried_by = robber
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	collision_layer = 0


## Cuffed, he sets it down at his feet: it doesn't break.
func drop() -> void:
	if carried_by:
		global_position = carried_by.global_position + Vector3.UP * (HEIGHT / 2 + 0.05)
	carried_by = null
	collision_layer = 4
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = false
	linear_velocity = Vector3.ZERO


## In the robbers' van: gone for good.
func take() -> void:
	carried_by = null
	hide()
	collision_layer = 0
	process_mode = Node.PROCESS_MODE_DISABLED


## Broken: the glass and the seeds gone, and a plant grows there (BankSeeds).
func shatter() -> void:
	if broken:
		return
	broken = true
	for id: int in holders.keys():
		var grabber := instance_from_id(id) as Grabber
		if grabber:
			grabber.release()
	hide()
	collision_layer = 0
	freeze = true
	broke.emit(self)


func _on_hit(_body: Node) -> void:
	if not follower and not broken and not freeze and not carried_by and _speed >= BREAK_SPEED:
		shatter()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if carried_by:
		global_transform = carried_by.global_transform.translated_local(CARRY_AT)
	if follower or broken:
		return
	_speed = linear_velocity.length()
	var running := false
	for id: int in holders.keys():
		var grabber := instance_from_id(id) as Grabber
		if grabber and grabber.get_parent() is Cop and (grabber.get_parent() as Cop).is_running:
			running = true
			_trip_left -= delta
			if _trip_left <= 0.0:
				grabber.release()
				(grabber.get_parent() as Cop).show_hint("HINT_SEED_JAR_TRIP")
	if not running:
		_trip_left = TRIP_TIME
