class_name BirthdayCake
extends Grabbable

## One of deputy Lustre's three birthday cakes (politico-cumple.md, step 1, decision 221): two round layers of its
## flavor on a white board, CANDLES candles on top and a card stuck in its front saying who sent it. Its candles are lit
## when it's the next one he'll blow (BirthdayParty); blown, they go out. Its origin is on the board's bottom. Every
## number here is (propuesta).

const FLAVORS: Array[String] = ["chocolate", "strawberry", "cream"]
## The cards: who sent each cake. They don't give the rigged one away by themselves.
const CARDS := 10
const KG := 2.0
const RADIUS := 0.28
const LAYER := 0.14
const CANDLES := 5
const BOARD := Color(0.97, 0.97, 0.95)
const CANDLE := Color(0.95, 0.85, 0.4)
const FLAME := Color(1.0, 0.6, 0.1)
const COLORS := {
	"chocolate": [Color(0.36, 0.2, 0.1), Color(0.5, 0.3, 0.16)],
	"strawberry": [Color(0.95, 0.55, 0.65), Color(0.85, 0.2, 0.3)],
	"cream": [Color(0.98, 0.93, 0.8), Color(0.96, 0.85, 0.6)],
}

var flavor := "chocolate"
## Which card it carries, 1 to CARDS.
var card := 1
var lit := false
var blown := false
var _flames: Array[MeshInstance3D] = []


func _ready() -> void:
	add_to_group("birthday_cakes")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var height := LAYER * 2 + 0.03
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = RADIUS + 0.04
	cylinder.height = height
	shape.shape = cylinder
	shape.position.y = height / 2
	add_child(shape)
	_build()


func _build() -> void:
	var colors: Array = COLORS[flavor]
	_part(_cylinder(RADIUS + 0.04, 0.03), Vector3(0, 0.015, 0), BOARD)
	_part(_cylinder(RADIUS, LAYER), Vector3(0, 0.03 + LAYER / 2, 0), colors[0])
	_part(_cylinder(RADIUS * 0.8, LAYER), Vector3(0, 0.03 + LAYER * 1.5, 0), colors[1])
	var top := 0.03 + LAYER * 2
	for i in CANDLES:
		var angle := TAU * i / CANDLES
		var at := Vector3(cos(angle), 0, sin(angle)) * RADIUS * 0.5 + Vector3.UP * top
		_part(_cylinder(0.012, 0.1), at + Vector3.UP * 0.05, CANDLE)
		var flame := _part(_sphere(0.02), at + Vector3.UP * 0.12, FLAME)
		flame.material_override.emission_enabled = true
		flame.material_override.emission = FLAME
		_flames.append(flame)
	var label := Label3D.new()
	label.name = "Card"
	label.text = card_key()
	label.font_size = 28
	label.pixel_size = 0.0022
	label.outline_size = 6
	label.width = 320.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Stuck in front of the cake, facing the crowd, like a card on a toothpick.
	label.position = Vector3(0, 0.03 + LAYER, RADIUS + 0.03)
	add_child(label)
	_show()


## The card's text, "BIRTHDAY_CARD_n".
func card_key() -> String:
	return "BIRTHDAY_CARD_%d" % card


func light() -> void:
	lit = true
	_show()


func blow() -> void:
	lit = false
	blown = true
	_show()


func _show() -> void:
	for flame in _flames:
		flame.visible = lit


func _part(mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	part.material_override = material
	part.position = at
	add_child(part)
	return part


static func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	return mesh


static func _sphere(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 6
	mesh.rings = 3
	return mesh
