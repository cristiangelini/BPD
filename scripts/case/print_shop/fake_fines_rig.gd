class_name FakeFinesRig
extends PrintShopRig

## The fake fines (allanamiento-imprenta.md, "Las multas falsas"): Don Renglón prints fines with a fake station stamp
## and collects them himself. When the cops arrive, their own patrol car already has one stuck on the windshield, and
## a cop this close to it notices, the story's own clue (on the checklist the first time). And the rotativa prints
## fines instead of sheets, each one with a cop's name on it (in turn), flying over the shop. Every number here is
## (propuesta).

## How near the fine (along the ground) a cop reads it: from in front of the car, not where they get off.
const NOTICE_RANGE := 1.8
const CHECK_EVERY := 0.5
const FINE_YELLOW := Color(0.96, 0.88, 0.45)
## The fine on the patrol car's windshield, in the car's space (its front is +Z), and leaning back like the glass.
const FINE_ON_CAR := Vector3(0.45, 1.45, 1.13)
const GLASS_LEAN := -0.55

var noticed := false
var windshield_fine: MeshInstance3D
## The names on the flying fines, in order.
var printed_names: Array[String] = []
var _since := 0.0
var _next_cop := 0


func setup(place: PrintShop) -> void:
	super.setup(place)
	shop.press.sheet_color = FINE_YELLOW
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.24, 0.32, 0.005)
	windshield_fine = MeshInstance3D.new()
	windshield_fine.name = "WindshieldFine"
	windshield_fine.mesh = mesh
	var paper := StandardMaterial3D.new()
	paper.albedo_color = FINE_YELLOW
	windshield_fine.material_override = paper
	windshield_fine.position = FINE_ON_CAR
	windshield_fine.rotation.x = GLASS_LEAN
	shop.car.add_child(windshield_fine)
	var text := Label3D.new()
	text.text = "PRINT_SHOP_WINDSHIELD_FINE"
	text.font_size = 13
	text.pixel_size = 0.003
	text.width = 75.0
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.modulate = Color(0.75, 0.12, 0.12)
	text.outline_size = 0
	text.position = Vector3(0, 0, 0.004)
	windshield_fine.add_child(text)


func _process(_delta: float) -> void:
	for sheet: Dictionary in shop.press.sheets:
		var node: MeshInstance3D = sheet.node
		if is_instance_valid(node) and not node.has_node("FineName"):
			_name_fine(node)


func _physics_process(delta: float) -> void:
	_since += delta
	if noticed or _since < CHECK_EVERY:
		return
	_since = 0.0
	var at := windshield_fine.global_position
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if Vector2(cop.global_position.x - at.x, cop.global_position.z - at.z).length() <= NOTICE_RANGE:
			notice()
			break


## A cop reads the fine on the windshield: the stamp is the station's, but it isn't. The first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	shop.raid.add_clue(tr("CLUE_WINDSHIELD_FINE"))
	shop.raid.float_label(tr("PRINT_SHOP_FINE_FAKE"), windshield_fine.global_position + Vector3(0, 0.8, 0),
		FINE_YELLOW)


## A fine the press just threw: it gets the next cop's name.
func _name_fine(node: MeshInstance3D) -> void:
	var cops := get_tree().get_nodes_in_group("cops")
	var who := "?"
	if not cops.is_empty():
		who = Net.player_name(cops[_next_cop % cops.size()].get_multiplayer_authority())
		_next_cop += 1
	printed_names.append(who)
	var label := Label3D.new()
	label.name = "FineName"
	label.text = tr("PRINT_SHOP_FINE_FOR") % who
	label.font_size = 24
	label.pixel_size = 0.004
	label.outline_size = 6
	label.modulate = Color(0.85, 0.15, 0.15)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0.12, 0)
	node.add_child(label)
