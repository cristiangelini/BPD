class_name PastryContest
extends Node3D

## The pastry contest's tent in the plaza (escena-del-crimen.md, step 1), south of the fountain: open sides, poles and
## a striped roof; the jury's table at the north end with the empty display case where the Torre de Merengue stood;
## and six cook tables in two rows, each with its cake, its name tag and its cook behind it, facing the jury. The cooks
## come from CookTraits.draw with the case seed. Every number here is (propuesta).

## Where the tent's middle is, from the plaza's center: clear of the fountain (radius 4.2) and the trees.
const OFFSET := Vector3(0, 0, 10.5)
## The tent's floor: width (x) and depth (z).
const SIZE := Vector2(20, 11)
const ROOF_HEIGHT := 3.2
const TABLE_SIZE := Vector3(2.0, 0.9, 0.9)
## The cooks' tables, in the tent's space: two rows of three.
const TABLES: Array[Vector3] = [
	Vector3(-6, 0, -0.5), Vector3(0, 0, -0.5), Vector3(6, 0, -0.5),
	Vector3(-6, 0, 3), Vector3(0, 0, 3), Vector3(6, 0, 3),
]
## Each cook stands this far behind his table (south), facing north.
const COOK_BEHIND := 0.9
const JURY_AT := Vector3(0, 0, -4)
const JURY_SIZE := Vector3(5.0, 0.9, 1.0)
const CASE_SIZE := Vector3(1.0, 1.0, 0.8)
const POLE := Color(0.85, 0.85, 0.82)
const ROOF_A := Color(0.95, 0.95, 0.92)
const ROOF_B := Color(0.9, 0.35, 0.45)
const CLOTH := Color(0.97, 0.96, 0.93)
const WOOD := Color(0.55, 0.38, 0.24)
const GLASS := Color(0.75, 0.9, 1.0, 0.35)
const CAKES: Array[Color] = [
	Color(0.55, 0.32, 0.2), Color(0.98, 0.75, 0.8), Color(0.98, 0.92, 0.6), Color(0.6, 0.85, 0.55),
	Color(0.95, 0.95, 0.95), Color(0.75, 0.55, 0.85),
]

## Same seed, same cooks.
@export var case_seed := 1
var cooks: Array[PastryCook] = []
## The display case where the Torre de Merengue stood, empty.
var display_case: Node3D
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("pastry_contest")
	_builder = PlaceBuilder.new(self)
	_tent()
	_jury()
	var traits := CookTraits.draw(case_seed)
	for i in TABLES.size():
		_table(TABLES[i], i, traits[i])


## Poles at the corners and two more along each long side, between the tables, so none hides the display case; a roof
## of stripes; the sides stay open.
func _tent() -> void:
	var half := SIZE / 2
	for x: float in [-half.x, -3.0, 3.0, half.x]:
		for z: float in [-half.y, half.y]:
			_builder.box(Vector3(x, ROOF_HEIGHT / 2, z), Vector3(0.15, ROOF_HEIGHT, 0.15), POLE)
	var stripes := 8
	var width := SIZE.x / stripes
	for i in stripes:
		var x := -half.x + (i + 0.5) * width
		_builder.mesh_box(Vector3(x, ROOF_HEIGHT + 0.05, 0), Vector3(width, 0.1, SIZE.y + 0.6),
				ROOF_A if i % 2 == 0 else ROOF_B)
	var banner := Label3D.new()
	banner.name = "Banner"
	banner.text = "SIGN_CONTEST"
	banner.font_size = 96
	banner.pixel_size = 0.01
	banner.outline_size = 18
	banner.double_sided = false
	banner.position = Vector3(0, ROOF_HEIGHT + 0.6, half.y + 0.35)
	add_child(banner)


## The jury's long table at the north end, with the empty display case in its middle.
func _jury() -> void:
	_counter(JURY_AT, JURY_SIZE)
	display_case = Node3D.new()
	display_case.name = "DisplayCase"
	display_case.position = JURY_AT + Vector3(0, JURY_SIZE.y, 0)
	add_child(display_case)
	var glass := PlaceBuilder.new(display_case)
	glass.mesh_box(Vector3(0, 0.03, 0), Vector3(CASE_SIZE.x + 0.1, 0.06, CASE_SIZE.z + 0.1), WOOD)
	glass.open_box(Vector3(0, 0.06, 0), CASE_SIZE, "bottom", GLASS)
	var plate := CylinderMesh.new()
	plate.top_radius = 0.3
	plate.bottom_radius = 0.3
	plate.height = 0.02
	glass.mesh(plate, Vector3(0, 0.08, 0), CLOTH)


## One cook's table with his cake and name tag, and the cook behind it.
func _table(at: Vector3, index: int, traits: Dictionary) -> void:
	_counter(at, TABLE_SIZE)
	var cake := CylinderMesh.new()
	cake.top_radius = 0.28
	cake.bottom_radius = 0.3
	cake.height = 0.3
	_builder.mesh(cake, at + Vector3(0, TABLE_SIZE.y + 0.15, 0), CAKES[index % CAKES.size()])
	var tag := Label3D.new()
	tag.name = "Tag%d" % index
	tag.text = "%d. %s" % [index + 1, traits.name]
	tag.font_size = 48
	tag.pixel_size = 0.006
	tag.outline_size = 10
	tag.position = at + Vector3(0, TABLE_SIZE.y - 0.2, -TABLE_SIZE.z / 2 - 0.02)
	tag.rotation.y = PI
	add_child(tag)
	var cook := PastryCook.new()
	cook.name = "Cook%d" % index
	cook.traits = traits
	cook.position = at + Vector3(0, 0, COOK_BEHIND)
	# The model faces +Z; the cooks face the jury, to the north.
	cook.rotation.y = PI
	add_child(cook)
	cooks.append(cook)


## A table with a white cloth on top and four legs.
func _counter(at: Vector3, size: Vector3) -> void:
	_builder.box(at + Vector3(0, size.y - 0.03, 0), Vector3(size.x, 0.06, size.z), CLOTH)
	_builder.legs(at, Vector2(size.x, size.z), size.y - 0.06, WOOD)


## The tent's ground in the world: whether a point (ignoring height) is under the roof.
func under_roof(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) <= SIZE.x / 2 and absf(local.z) <= SIZE.y / 2
