class_name PastryContest
extends CrimeScenePlace

## The pastry contest's tent in the plaza (escena-del-crimen.md, step 1), south of the fountain: open sides, poles and
## a striped roof; the jury's table at the north end with the empty display case where the Torre de Merengue stood;
## the jury's lady; and six cook tables in two rows, each with its cake, its name tag and its cook behind it, facing the jury. The cooks
## come from CookTraits.draw with the case seed. It's the pastry case's CrimeScenePlace: it puts the case's clues on
## the tables. Every number here is (propuesta).

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
## Where the jury's lady sits, behind the jury's table.
const LADY_AT := Vector3(-1.5, 0, -4.9)
## Where the footprint in the flour can be, in the aisles between the tables (CrimeSceneCase draws one).
const FLOUR_SPOTS: Array[Vector3] = [
	Vector3(-3, 0, 1.3), Vector3(3, 0, 1.3), Vector3(-3, 0, -2.3), Vector3(3, 0, -2.3), Vector3(-8.5, 0, 1.3),
	Vector3(8.5, 0, -2.3),
]
const POLE := Color(0.85, 0.85, 0.82)
const ROOF_A := Color(0.95, 0.95, 0.92)
const ROOF_B := Color(0.9, 0.35, 0.45)
const CLOTH := Color(0.97, 0.96, 0.93)
const WOOD := Color(0.55, 0.38, 0.24)
const BREAD_SCENE := preload("res://scenes/props/bread_loaf.tscn")
## The contest's loaves on the jury's table, for the cooks to bite (their teeth for the file).
const LOAVES := 3
const COFFEE_SCENE := preload("res://scenes/props/coffee_cup.tscn")
## Where the carried clues go by a cook's table: the plate and the slice on top, the recipe on the floor at its front,
## half under the cloth, with a coffee on the table's edge just above (propuesta).
const ON_TABLE := {"hair": Vector3(0.6, 0.9, 0), "bite": Vector3(-0.6, 0.9, 0.1), "recipe": Vector3(0.3, 0.05, -0.55)}
const COFFEE_ON_TABLE := Vector3(0.3, 0.9, -0.3)
## The bike waits this far (m) out of the tent's open front, and rides straight out of the plaza before its route.
const BIKE_OUT := 1.5
const CAKES: Array[Color] = [
	Color(0.55, 0.32, 0.2), Color(0.98, 0.75, 0.8), Color(0.98, 0.92, 0.6), Color(0.6, 0.85, 0.55),
	Color(0.95, 0.95, 0.95), Color(0.75, 0.55, 0.85),
]

var cooks: Array[PastryCook] = []
## The display case where the Torre de Merengue stood, empty.
var display_case: DisplayCase
var lady: JuryLady
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("pastry_contest")
	variant = "pastry"
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


## The jury's long table at the north end, with the empty display case in its middle, the evidence bags, a few
## loaves and the jury's lady behind.
func _jury() -> void:
	_counter(JURY_AT, JURY_SIZE)
	display_case = DisplayCase.new()
	display_case.name = "DisplayCase"
	display_case.position = JURY_AT + Vector3(0, JURY_SIZE.y, 0)
	add_child(display_case)
	bags = EvidenceBags.new()
	bags.name = "EvidenceBags"
	bags.position = JURY_AT + Vector3(1.8, JURY_SIZE.y, 0)
	add_child(bags)
	for i in LOAVES:
		var loaf: Node3D = BREAD_SCENE.instantiate()
		loaf.name = "Loaf%d" % i
		loaf.position = JURY_AT + Vector3(-2.2 + i * 0.3, JURY_SIZE.y + 0.1, 0)
		add_child(loaf)
	lady = JuryLady.new()
	lady.name = "JuryLady"
	lady.position = LADY_AT
	add_child(lady)


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
	cook.index = index
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


func at_scene(world: Vector3) -> bool:
	return under_roof(world)


func suspect(index: int) -> CollisionObject3D:
	return cooks[index]


## Puts the case's clues in the tent: the display case's prints, the lady's word, the footprint in the flour and the
## carried ones, each on its own table drawn with the seed. The cooks know the case; one of them (by the seed) won't
## take off his hat for nothing.
func set_up_case(case: CrimeSceneCase) -> void:
	var plan := case.plan
	display_case.case = case
	display_case.has_prints = plan.clues.has("prints")
	lady.case = case
	lady.knows = plan.clues.has("witness")
	if plan.clues.has("footprint"):
		var flour_print := FlourPrint.new()
		flour_print.name = "FlourPrint"
		flour_print.case = case
		flour_print.shoe = case.culprit().shoe
		flour_print.position = FLOUR_SPOTS[hash("flour spot %d" % case.case_seed) % FLOUR_SPOTS.size()]
		add_child(flour_print)
		case.flour_print = flour_print
	var tables := range(TABLES.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("clue tables %d" % case.case_seed)
	for kind: String in ["hair", "bite", "recipe"]:
		if not plan.clues.has(kind):
			continue
		var table: Vector3 = TABLES[tables.pop_at(rng.randi_range(0, tables.size() - 1))]
		var item := CrimeClueItem.new()
		item.name = "Clue_" + kind
		item.kind = kind
		item.case = case
		item.hair_color = CookTraits.HAIRS[case.culprit().hair]
		item.position = table + ON_TABLE[kind]
		add_child(item)
		case.items[kind] = item
		if kind == "recipe":
			var coffee: Node3D = COFFEE_SCENE.instantiate()
			coffee.position = table + COFFEE_ON_TABLE
			add_child(coffee)
	var stubborn := hash("stubborn cook %d" % case.case_seed) % cooks.size()
	for cook in cooks:
		cook.case = case
		cook.stubborn = cook.index == stubborn


## The delivery bike waits out of the tent's open front, by the culprit's table, and rides straight out of the plaza.
func getaway(index: int, city: Node3D) -> Dictionary:
	var cook := cooks[index]
	var out := to_global(Vector3(to_local(cook.global_position).x, 0, SIZE.y / 2 + BIKE_OUT))
	var plaza := city.global_transform * CityLayout.block_center(CityLayout.PLAZA)
	var ahead := global_basis.z
	var edge := out + ahead * maxf(CityLayout.BLOCK / 2 - 1.0 - (out - plaza).dot(ahead), 0.0)
	return {"at": Transform3D(global_basis, out), "via": [edge]}


func witness_offended() -> bool:
	return lady.offended


func offend_witness() -> void:
	lady.offended = true


func shouted_by(cop: Cop) -> void:
	lady.shouted_by(cop)
