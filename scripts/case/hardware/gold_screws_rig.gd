class_name GoldScrewsRig
extends HardwareRig

## The golden screws (ferreteria.md, "Tornillos de oro"): Tobías melts the stolen jewels of the corner jeweler's into
## screws and keeps them in one of the 60 little drawers of the screw wall, drawn with the seed. Every drawer opens
## with E, once. The golden one gives up the main evidence, the drawer itself; one in three of the others is jammed and
## comes out all at once, spilling its screws on the floor, where a running cop slips. The story's own clue: under the
## flashlight the golden drawer's front glints. Tobías complains a little for every drawer he sees opened. Every number
## here is (propuesta).

const GOLD_SCENE := preload("res://scenes/props/gold_screw_drawer.tscn")
## How far out of the wall the golden drawer lands when pulled, and the spilled screws on the floor.
const PULL_OUT := 0.3
const SPILL_OUT := 0.6
## One drawer in SPILL_EVERY spills.
const SPILL_EVERY := 3

var drawers: Array[ScrewDrawer] = []
var gold_index := 0
var gold: Evidence
var spills: Array[SpilledScrews] = []
var glinted := false
var _glint: MeshInstance3D


func setup(place: HardwareStore) -> void:
	super.setup(place)
	gold_index = gold_drawer(place.case_seed)
	var step := HardwareStore.drawer_step()
	for row in HardwareStore.SCREW_ROWS:
		for column in HardwareStore.SCREW_COLUMNS:
			var drawer := ScrewDrawer.new()
			drawer.size = Vector3(0.04, step.y - 0.05, step.x - 0.05)
			drawer.position = HardwareStore.drawer_front(row, column)
			place.add_child(drawer)
			drawer.opened.connect(_on_opened.bind(drawers.size()))
			drawers.append(drawer)
	# The golden drawer waits inside the wall, out of the world, until it's pulled.
	gold = GOLD_SCENE.instantiate()
	gold.position = drawers[gold_index].position + Vector3(-0.2, 0, 0)
	gold.freeze = true
	gold.visible = false
	gold.collision_layer = 0
	gold.collision_mask = 0
	place.add_child(gold)
	place.main = gold
	_glint = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.005, step.y - 0.09, step.x - 0.09)
	_glint.mesh = mesh
	var shine := StandardMaterial3D.new()
	shine.albedo_color = Color(1.0, 0.85, 0.3)
	shine.emission_enabled = true
	shine.emission = Color(1.0, 0.8, 0.25)
	shine.emission_energy_multiplier = 2.0
	_glint.material_override = shine
	_glint.position = drawers[gold_index].position + Vector3(0.025, 0, 0)
	_glint.visible = false
	place.add_child(_glint)


## Which of the 60 drawers is the golden one (row by row from the floor), from the seed.
static func gold_drawer(case_seed: int) -> int:
	return (case_seed * 7 + 3) % (HardwareStore.SCREW_ROWS * HardwareStore.SCREW_COLUMNS)


## Whether the drawer at `index` is jammed and spills when opened (never the golden one).
func spills_at(index: int) -> bool:
	return index != gold_index and (index + store.case_seed) % SPILL_EVERY == 0


func _on_opened(cop: Cop, index: int) -> void:
	var drawer := drawers[index]
	store.tobias.saw(drawer.global_position, HardwareMan.SAW_DRAWER)
	if index == gold_index:
		_glint.visible = false
		gold.position = drawer.position + Vector3(PULL_OUT, 0, 0)
		gold.collision_layer = 4
		gold.collision_mask = 15
		gold.visible = true
		gold.freeze = false
		cop.show_hint("HINT_GOLD_DRAWER")
	elif spills_at(index):
		var spilled := SpilledScrews.new()
		spilled.position = Vector3(drawer.position.x + SPILL_OUT, HardwareStore.FLOOR_TOP, drawer.position.z)
		store.add_child(spilled)
		spills.append(spilled)
		cop.show_hint("HINT_SCREWS_SPILL")
	else:
		cop.show_hint("HINT_DRAWER_PLAIN")


## The golden drawer's front glints while a cop's flashlight is on it, until it's opened.
func _physics_process(_delta: float) -> void:
	if drawers[gold_index].is_open:
		return
	var lit := false
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.belt and cop.belt.flashlight.lights(_glint.global_position):
			lit = true
	_glint.visible = lit
	if lit and not glinted:
		glinted = true
		store.raid.add_clue(tr("CLUE_GOLD_GLINT"))
