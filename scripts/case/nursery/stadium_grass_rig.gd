class_name StadiumGrassRig
extends NurseryRig

## The stadium grass (allanamiento-vivero.md, "El pasto del estadio"): Doña Hortensia took the football stadium's
## grass, rolled up. A patch of the yard (drawn with the seed among PATCHES) has grass with white lines painted on it,
## and a cop this close to it notices, the story's own clue (on the checklist the first time). And every time the
## sprinklers come on, the roll of grass sings like the stadium's crowd. Every number here is (propuesta).

const NOTICE_RANGE := 1.5
const CHECK_EVERY := 0.5
## Where the painted patch can be, in the yard away from the sprinklers and the rows, and its size.
const PATCHES: Array[Vector3] = [Vector3(-17.5, 0.0, 5.0), Vector3(-10.5, 0.0, 5.0), Vector3(-3.5, 0.0, 5.5),
	Vector3(-11.0, 0.0, -2.0)]
const PATCH_SIZE := Vector2(1.6, 1.2)
const GRASS := Color(0.3, 0.75, 0.3)
const LINE := Color(0.97, 0.97, 0.95)
const CHANT_SECONDS := 4.0

var patch: Node3D
var noticed := false
var chants := 0
var _since := 0.0


func setup(place: Nursery) -> void:
	super.setup(place)
	patch = Node3D.new()
	patch.name = "PaintedPatch"
	patch.position = PATCHES[nursery.case_seed % PATCHES.size()] + Vector3.UP * (Nursery.FLOOR_TOP + 0.012)
	nursery.add_child(patch)
	_flat(Vector2.ZERO, PATCH_SIZE, GRASS, 0.0)
	_flat(Vector2.ZERO, Vector2(0.06, PATCH_SIZE.y), LINE, 0.003)
	_flat(Vector2(-PATCH_SIZE.x / 2 + 0.03, 0), Vector2(0.06, PATCH_SIZE.y), LINE, 0.003)
	_flat(Vector2(-0.25, 0), Vector2(0.5, 0.06), LINE, 0.003)
	nursery.irrigation.started.connect(chant)


func _flat(at: Vector2, size: Vector2, color: Color, lift: float) -> void:
	var look := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(size.x, 0.01, size.y)
	look.mesh = box
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	look.material_override = paint
	look.position = Vector3(at.x, lift, at.y)
	patch.add_child(look)


func _physics_process(delta: float) -> void:
	_since += delta
	if noticed or _since < CHECK_EVERY:
		return
	_since = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var off := cop.global_position - patch.global_position
		off.y = 0.0
		if off.length() <= NOTICE_RANGE + PATCH_SIZE.x / 2:
			notice()
			break


## A cop sees the white lines painted on the grass: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	nursery.raid.add_clue(tr("CLUE_STADIUM_LINES"))
	nursery.raid.float_label(tr("NURSERY_LINES"), patch.global_position + Vector3.UP * 1.0, LINE)


## The sprinklers came on: the roll of grass sings like the crowd, wherever it is.
func chant() -> void:
	chants += 1
	var label := Label3D.new()
	label.text = "NURSERY_CHANT"
	label.font_size = 40
	label.pixel_size = 0.01
	label.outline_size = 12
	label.modulate = Color(0.55, 0.85, 1.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	nursery.add_child(label)
	label.global_position = nursery.main.global_position + Vector3.UP * 1.5
	get_tree().create_timer(CHANT_SECONDS).timeout.connect(label.queue_free)
