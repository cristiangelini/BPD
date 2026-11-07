class_name FakeDiplomasRig
extends PrintShopRig

## The fake diplomas (allanamiento-imprenta.md, "Los diplomas falsos"): Don Renglón prints "Doctor en Todo" diplomas.
## On his office's wall hangs his own, "Doctor en Astronautas", and a cop this close to it notices, the story's own
## clue (on the checklist the first time). And every run of the rotativa prints a diploma with a cop's name on it, in
## turn, and throws diplomas instead of sheets. Every number here is (propuesta).

const NOTICE_RANGE := 2.5
const CHECK_EVERY := 0.5
const PARCHMENT := Color(0.95, 0.9, 0.77)
## His framed diploma on the office's east wall, inside.
const FRAME_AT := Vector3(PrintShop.HALF_X - 0.12, PrintShop.FLOOR_TOP + 1.7, -6.0)

var noticed := false
var frame: MeshInstance3D
## The diplomas printed with cops' names, in order.
var printed_names: Array[String] = []
var _since := 0.0
var _next_cop := 0


func setup(place: PrintShop) -> void:
	super.setup(place)
	shop.press.sheet_color = PARCHMENT
	shop.press.started.connect(_print_diploma)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.04, 0.6, 0.8)
	frame = MeshInstance3D.new()
	frame.name = "OfficeDiploma"
	frame.mesh = mesh
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.28, 0.15)
	frame.material_override = wood
	frame.position = FRAME_AT
	shop.add_child(frame)
	var text := Label3D.new()
	text.text = "PRINT_SHOP_OFFICE_DIPLOMA"
	text.font_size = 22
	text.pixel_size = 0.004
	text.width = 170.0
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.modulate = Color(0.2, 0.15, 0.1)
	text.outline_size = 0
	text.position = Vector3(-0.03, 0, 0)
	text.rotation.y = -PI / 2
	frame.add_child(text)


func _physics_process(delta: float) -> void:
	_since += delta
	if noticed or _since < CHECK_EVERY:
		return
	_since = 0.0
	var at := shop.to_global(FRAME_AT)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= NOTICE_RANGE:
			notice()
			break


## A cop reads the diploma on the office wall: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	shop.raid.add_clue(tr("CLUE_ASTRONAUT_DIPLOMA"))
	shop.raid.float_label(tr("PRINT_SHOP_ASTRONAUT"), shop.to_global(FRAME_AT) + Vector3(-0.5, 0.6, 0), PARCHMENT)


## The press started: this run's diploma goes to the next cop, by name.
func _print_diploma(_cop: Cop) -> void:
	var cops := get_tree().get_nodes_in_group("cops")
	if cops.is_empty():
		return
	var cop: Node = cops[_next_cop % cops.size()]
	_next_cop += 1
	var who := Net.player_name(cop.get_multiplayer_authority())
	printed_names.append(who)
	var tray := Vector3(PrintShop.TRAY_X.y, PrintShop.TRAY_TOP + 1.2, 0)
	shop.raid.float_label(tr("PRINT_SHOP_DIPLOMA_FOR") % who, shop.to_global(PrintShop.PRESS_AT + tray), PARCHMENT)
