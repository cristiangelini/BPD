class_name RiggedSticksRig
extends IceCreamRig

## The prize sticks (allanamiento-heladeria.md, "Los palitos premiados"): every stick says "Sigue participando". The box
## with the prize sticks that are never sold is hidden with the machine that burns them and the list of "winners"; the
## salon's bin is full of losing sticks (looking in it, E, is the story's own clue), and every SHOUT_EVERY seconds a kid
## comes back in shouting that there's nothing again. Every number here is (propuesta).

const SHOUT_EVERY := 40.0
const KID := preload("res://assets/models/npc_alumno_primaria.glb")
## The bin by the tables, near the door.
const BIN_AT := Vector3(5.4, IceCreamShop.FLOOR_TOP, 7.8)
const BIN_SIZE := Vector3(0.45, 0.7, 0.45)

var bin: ClueSpot
var kid: IceVisitor
var _since := 0.0


func setup(place: IceCreamShop) -> void:
	super.setup(place)
	bin = ClueSpot.new()
	bin.name = "StickBin"
	bin.size = BIN_SIZE
	bin.text = tr("CLUE_LOSING_STICKS")
	bin.prompt = "PROMPT_STICK_BIN"
	bin.position = BIN_AT + Vector3(0, BIN_SIZE.y / 2, 0)
	bin.read.connect(shop.raid.add_clue)
	shop.add_child(bin)
	bin.add_child(_mesh(BoxMesh.new(), BIN_SIZE, Vector3.ZERO, Color(0.3, 0.32, 0.36)))
	for i in 9:
		var at := Vector3(-0.15 + (i % 3) * 0.15, BIN_SIZE.y / 2 + 0.03, -0.12 + floori(i / 3.0) * 0.12)
		var stick := _mesh(BoxMesh.new(), Vector3(0.02, 0.1, 0.005), at, Color(0.92, 0.82, 0.62))
		stick.rotation.z = 0.3 * ((i % 3) - 1)
		bin.add_child(stick)
	kid = visitor(KID)
	kid.name = "StickKid"


## A kid comes back in with a stick and no prize.
func shout() -> void:
	_since = 0.0
	kid.come(tr("ICE_NOTHING_AGAIN"))


func _process(delta: float) -> void:
	_since += delta
	if _since >= SHOUT_EVERY:
		shout()


func _mesh(box: BoxMesh, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	box.size = size
	var mesh := MeshInstance3D.new()
	mesh.mesh = box
	mesh.position = at
	var paint := StandardMaterial3D.new()
	paint.albedo_color = color
	mesh.material_override = paint
	return mesh
