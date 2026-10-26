class_name SeedJar
extends Grabbable

## A glass jar of rare seeds from the seed bank's vault (robo-banco-semillas.md, step 1, decision 129): small, light,
## its lid and its seeds of one color. It waits still on its shelf until someone takes it. Every number here is
## (propuesta).

const KG := 0.6
const RADIUS := 0.09
const HEIGHT := 0.22
const GLASS := Color(0.8, 0.92, 0.95, 0.45)
const LID := Color(0.55, 0.4, 0.2)

## The seeds inside.
var color := Color(0.8, 0.6, 0.2)


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


## A cop takes hold of it: off the shelf.
func hold(holder_id: int, point: Vector3) -> void:
	freeze = false
	super.hold(holder_id, point)


## Online (PropSync): a guest's copy is made from this script.
func net_setup() -> Dictionary:
	return {}
