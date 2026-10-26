class_name BirthdayCake
extends Grabbable

## One of deputy Lustre's three birthday cakes (politico-cumple.md, step 1, decision 221): two round layers of its
## flavor on a white board, CANDLES candles on top and a card stuck in its front saying who sent it. Its candles are lit
## when it's the next one he'll blow (BirthdayParty); blown, they go out. Its origin is on the board's bottom. Every
## number here is (propuesta).
## Step 2: one of the three is `rigged`, a spring with a kilo of cream inside, and weighs RIGGED_KG (two cops carry it).
## E listens to a cake for LISTEN_TIME: the rigged one ticks. Dropped in the plaza's fountain it's ruined for good.
## Off its spot on the table it's `taken` (BirthdayParty skips it, and a good one taken costs a stain).

signal taken(cake: BirthdayCake)
signal ruined_now(cake: BirthdayCake)

const FLAVORS: Array[String] = ["chocolate", "strawberry", "cream"]
## The cards: who sent each cake. They don't give the rigged one away by themselves.
const CARDS := 10
const KG := 2.0
const RIGGED_KG := 30.0
const LISTEN_TIME := 3.0
## The listening cop can't wander further than this from the cake.
const LISTEN_REACH := 1.8
## The tick-tock shows this long.
const TICK_TIME := 4.0
## Further than this from its spot it's off the table.
const AWAY := 0.6
## In the fountain: within its water's radius, and below this height over the plaza.
const FOUNTAIN_RADIUS := 3.9
const FOUNTAIN_TOP := 1.3
const SPRING := Color(0.75, 0.75, 0.78)
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
var rigged := false
## Its place on the table, and the fountain's middle at ground level (world space), set by the rally.
var spot := Vector3.ZERO
var fountain := Vector3.ZERO
var was_taken := false
var ruined := false
## It sprang its cream (blown while rigged).
var sprung := false
var listener: Cop
var _listen_left := 0.0
var _tick_left := 0.0
var _flames: Array[MeshInstance3D] = []
var _tick: Label3D
var _top: MeshInstance3D
var _spring: MeshInstance3D


func _ready() -> void:
	add_to_group("birthday_cakes")
	mass = RIGGED_KG if rigged else KG
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
	_top = _part(_cylinder(RADIUS * 0.8, LAYER), Vector3(0, 0.03 + LAYER * 1.5, 0), colors[1])
	var top := 0.03 + LAYER * 2
	# The spring that pops out of the rigged one, with its cream on top.
	_spring = _part(_cylinder(0.05, 0.4), Vector3(0, top + 0.2, 0), SPRING)
	_spring.add_child(_part_mesh(_sphere(0.16), Vector3(0, 0.25, 0), COLORS["cream"][0]))
	_spring.hide()
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
	_tick = Label3D.new()
	_tick.name = "Tick"
	_tick.text = "CAKE_TICK"
	_tick.font_size = 48
	_tick.pixel_size = 0.004
	_tick.outline_size = 8
	_tick.modulate = Color(1, 0.9, 0.3)
	_tick.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_tick.position = Vector3(0, top + 0.45, 0)
	_tick.hide()
	add_child(_tick)
	_show()


func prompt_key(_cop: Cop) -> String:
	return "" if ruined or sprung else "PROMPT_LISTEN_CAKE"


## E: the cop puts an ear to it for LISTEN_TIME.
func use(cop: Cop) -> void:
	if ruined or sprung:
		return
	listener = cop
	_listen_left = LISTEN_TIME
	cop.show_hint("HINT_CAKE_LISTENING")


## Where it should be: on its spot, not in the fountain.
func on_table() -> bool:
	return not ruined and global_position.distance_to(spot) < AWAY


func _physics_process(delta: float) -> void:
	super(delta)
	if _tick_left > 0.0:
		_tick_left -= delta
		if _tick_left <= 0.0:
			_tick.hide()
	if listener:
		if not is_instance_valid(listener) or listener.global_position.distance_to(global_position) > LISTEN_REACH:
			listener = null
		else:
			_listen_left -= delta
			if _listen_left <= 0.0:
				_heard()
	if not multiplayer.is_server() or ruined or spot == Vector3.ZERO:
		return
	if not was_taken and global_position.distance_to(spot) >= AWAY:
		was_taken = true
		taken.emit(self)
	var flat := Vector2(global_position.x - fountain.x, global_position.z - fountain.z)
	if flat.length() < FOUNTAIN_RADIUS and global_position.y - fountain.y < FOUNTAIN_TOP:
		ruin()


func _heard() -> void:
	var cop := listener
	listener = null
	if rigged:
		show_tick()
	cop.show_hint("HINT_CAKE_TICKING" if rigged else "HINT_CAKE_QUIET")


## The tick-tock over it, for whoever is near.
func show_tick() -> void:
	_tick_left = TICK_TIME
	_tick.show()


## In the fountain: soaked, it springs nothing on anyone any more.
func ruin() -> void:
	if ruined:
		return
	ruined = true
	lit = false
	_show()
	ruined_now.emit(self)


## A guest's cake: the host's [lit, blown, ruined, sprung] (PoliticianCase.snapshot).
func follow(state: Array) -> void:
	lit = state[0]
	blown = state[1]
	ruined = state[2]
	if state[3] and not sprung:
		spring()
	_show()


## Blown while rigged: the spring pops out with its cream.
func spring() -> void:
	sprung = true
	_top.hide()
	_spring.show()


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
	var part := _part_mesh(mesh, at, color)
	add_child(part)
	return part


static func _part_mesh(mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	part.material_override = material
	part.position = at
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
