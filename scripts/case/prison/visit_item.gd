class_name VisitItem
extends Grabbable

## What a visitor brings on the prison's visiting day (carcel-visitas.md, step 2): a cake, a guitar, a roast chicken...
## Left on the search table while the visitor waits there; handed back when they go in, if it's still on the table.
## Some have something hidden inside (`hidden`, drawn by VisitPlan). Step 3: E with it in hand opens it (the cake
## splits, the guitar comes apart): what was hidden lands in the cop's hands (Contraband) and is confiscated; with
## nothing inside it's just broken, and its visitor cries. Online the host decides (only it knows what's inside).
## Step 4, the tells: hidden, it weighs HEAVIER times more; a metal thing inside goes "clonc" when set down on the
## table, the pigeon in the hat coos and the phone in the watermelon buzzes every so often. Every number here is
## (propuesta).

enum Kind { CAKE, BREAD, GUITAR, FLOWERS, SCARF, BABY, CHICKEN, HAT, WATERMELON, SHOE, YARN, BOOK }

## Each kind's box (its collision) and weight in kg.
const SIZES := {
	Kind.CAKE: Vector3(0.32, 0.16, 0.32), Kind.BREAD: Vector3(0.4, 0.14, 0.18), Kind.GUITAR: Vector3(0.38, 0.1, 1.0),
	Kind.FLOWERS: Vector3(0.22, 0.5, 0.22), Kind.SCARF: Vector3(0.3, 0.12, 0.3), Kind.BABY: Vector3(0.24, 0.2, 0.5),
	Kind.CHICKEN: Vector3(0.3, 0.18, 0.24), Kind.HAT: Vector3(0.34, 0.16, 0.34),
	Kind.WATERMELON: Vector3(0.34, 0.3, 0.44), Kind.SHOE: Vector3(0.16, 0.14, 0.36), Kind.YARN: Vector3(0.16, 0.16, 0.16),
	Kind.BOOK: Vector3(0.24, 0.06, 0.32),
}
const MASSES := {Kind.CAKE: 1.0, Kind.BREAD: 0.5, Kind.GUITAR: 2.5, Kind.FLOWERS: 0.4, Kind.SCARF: 0.3, Kind.BABY: 2.0,
	Kind.CHICKEN: 1.2, Kind.HAT: 0.3, Kind.WATERMELON: 4.0, Kind.SHOE: 0.6, Kind.YARN: 0.2, Kind.BOOK: 0.6}

## Hidden, it weighs this many times more.
const HEAVIER := 1.6
## The metal things that go "clonc" (Contraband.Kind), and how often the noisy ones make their noise.
const METAL: Array[int] = [Contraband.Kind.FILE, Contraband.Kind.KEY, Contraband.Kind.SAW, Contraband.Kind.TOOLS,
	Contraband.Kind.LOCKPICKS, Contraband.Kind.SHOVEL, Contraband.Kind.SPOON]
const NOISY := {Contraband.Kind.PIGEON: "VISIT_ITEM_COO", Contraband.Kind.PHONE: "VISIT_ITEM_BUZZ"}
const NOISE_EVERY := Vector2(9.0, 15.0)
const SOUND_TIME := 1.5

var kind := Kind.CAKE
## What's hidden inside, found by opening it (step 3).
var hidden := false
## The visitor it came with.
var visitor: PrisonVisitor
## Opened (step 3): split open, found or broken.
var opened := false
var _sound: Label3D
var _sound_left := 0.0
var _noise_left := 0.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15


func _ready() -> void:
	add_to_group("visit_items")
	mass = MASSES[kind] * (HEAVIER if hidden else 1.0)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZES[kind]
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	add_child(build_model(kind))
	_sound = Label3D.new()
	_sound.name = "Sound"
	_sound.position = Vector3(0, 0.45, 0)
	_sound.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_sound.no_depth_test = true
	_sound.pixel_size = 0.003
	_sound.outline_size = 8
	_sound.font_size = 40
	_sound.modulate = Color(1, 0.95, 0.6)
	_sound.hide()
	add_child(_sound)
	_noise_left = randf_range(NOISE_EVERY.x, NOISE_EVERY.y)
	# It's made when its visitor sets it on the search table (a guest's copy too).
	set_down()


## What's inside, as a Contraband.Kind, or -1 with nothing.
func inside() -> int:
	return Contraband.IN_ITEM[kind] if hidden else -1


## Set down on the search table by its visitor: a metal thing inside goes "clonc".
func set_down() -> void:
	if METAL.has(inside()):
		make_sound("VISIT_ITEM_CLONC")


func make_sound(key: String) -> void:
	_sound.text = key
	_sound.show()
	_sound_left = SOUND_TIME


func sound() -> String:
	return _sound.text if _sound.visible else ""


func _process(delta: float) -> void:
	if _sound_left > 0.0:
		_sound_left -= delta
		if _sound_left <= 0.0:
			_sound.hide()
	if not NOISY.has(inside()) or opened:
		return
	_noise_left -= delta
	if _noise_left <= 0.0:
		make_sound(NOISY[inside()])
		_noise_left = randf_range(NOISE_EVERY.x, NOISE_EVERY.y)


func held_prompt_key(_cop: Cop) -> String:
	if opened:
		return "PROMPT_VISIT_ITEM_OPENED"
	return "PROMPT_VISIT_ITEM_%s" % Kind.keys()[kind]


## Online (PropSync): the host makes them at the search table; a guest's copy is made from this script with its kind
## (and whether something's inside, for the coo and the buzz).
func net_setup() -> Dictionary:
	return {"kind": kind, "hidden": hidden}


## E with it in hand: opens it, on every PC (ActionSync). Only the host knows what's inside: whatever was hidden goes
## to the cop's hands.
func use(cop: Cop) -> void:
	if opened:
		return
	open()
	if not multiplayer.is_server():
		return
	if hidden:
		hidden = false
		var found := Contraband.new()
		found.name = "Contraband"
		found.kind = Contraband.IN_ITEM[kind]
		get_parent().add_child(found, true)
		found.global_position = global_position + Vector3.UP * 0.2
		cop.handed(found)
		cop.show_hint("HINT_VISIT_FOUND_%s" % Contraband.Kind.keys()[found.kind], true)
		if visitor:
			visitor.caught(found, true)
		return
	cop.show_hint("HINT_VISIT_NOTHING", true)
	if visitor:
		visitor.broken(self)


## Split open: its pieces tumble apart and sag (every PC, from the host's state).
func open() -> void:
	opened = true
	var model := get_node_or_null("Model")
	if not model:
		return
	var k := 0
	for part: Node3D in model.get_children():
		k += 1
		part.position += Vector3((k % 3 - 1) * 0.06, -0.02, (k % 2) * 0.05 - 0.025)
		part.rotation += Vector3(0.3 * (k % 2), 0.4 * k, 0.5 * (k % 3 - 1))


## The kind's look from primitives, its base on the ground at the origin: also what the visitor carries in the queue.
static func build_model(of: Kind) -> Node3D:
	var root := Node3D.new()
	root.name = "Model"
	var flat := Vector3(PI / 2, 0, 0)
	match of:
		Kind.CAKE:
			root.add_child(CopTool.piece(CopTool.cylinder(0.16, 0.12), Color(0.95, 0.85, 0.75), Vector3(0, 0.06, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.165, 0.03), Color(0.95, 0.45, 0.6), Vector3(0, 0.13, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.008, 0.05), Color(1, 1, 0.8), Vector3(0, 0.17, 0)))
		Kind.BREAD:
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.4, 0.12, 0.18)), Color(0.8, 0.55, 0.25), Vector3(0, 0.06, 0)))
			for x: float in [-0.1, 0.0, 0.1]:
				root.add_child(CopTool.piece(CopTool.box(Vector3(0.02, 0.01, 0.14)), Color(0.95, 0.8, 0.5),
					Vector3(x, 0.125, 0)))
		Kind.GUITAR:
			root.add_child(CopTool.piece(CopTool.cylinder(0.18, 0.1), Color(0.75, 0.45, 0.2), Vector3(0, 0.05, 0.25)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.14, 0.1), Color(0.75, 0.45, 0.2), Vector3(0, 0.05, 0.0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.05, 0.11), Color(0.15, 0.1, 0.05), Vector3(0, 0.06, 0.12)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.06, 0.04, 0.5)), Color(0.3, 0.18, 0.1), Vector3(0, 0.06, -0.35)))
		Kind.FLOWERS:
			root.add_child(CopTool.piece(CopTool.cylinder(0.05, 0.3), Color(0.9, 0.85, 0.7), Vector3(0, 0.15, 0)))
			for at: Vector3 in [Vector3(0, 0.38, 0), Vector3(0.07, 0.34, 0.04), Vector3(-0.06, 0.35, -0.05)]:
				var bloom := SphereMesh.new()
				bloom.radius = 0.06
				bloom.height = 0.12
				root.add_child(CopTool.piece(bloom, Color(0.95, 0.3, 0.35), at))
		Kind.SCARF:
			for k in 3:
				root.add_child(CopTool.piece(CopTool.cylinder(0.14 - k * 0.03, 0.04), [Color(0.3, 0.6, 0.85),
					Color(0.95, 0.8, 0.3), Color(0.3, 0.6, 0.85)][k], Vector3(0, 0.02 + k * 0.04, 0)))
		Kind.BABY:
			root.add_child(CopTool.piece(CopTool.cylinder(0.11, 0.42), Color(0.7, 0.85, 1.0), Vector3(0, 0.1, 0), flat))
			var head := SphereMesh.new()
			head.radius = 0.08
			head.height = 0.16
			root.add_child(CopTool.piece(head, Color(1.0, 0.82, 0.7), Vector3(0, 0.12, -0.24)))
		Kind.CHICKEN:
			var body := SphereMesh.new()
			body.radius = 0.13
			body.height = 0.18
			root.add_child(CopTool.piece(body, Color(0.75, 0.45, 0.15), Vector3(0, 0.09, 0)))
			for x: float in [-0.07, 0.07]:
				root.add_child(CopTool.piece(CopTool.cylinder(0.025, 0.12), Color(0.85, 0.6, 0.3), Vector3(x, 0.1, 0.13),
					flat))
		Kind.HAT:
			root.add_child(CopTool.piece(CopTool.cylinder(0.17, 0.02), Color(0.2, 0.2, 0.25), Vector3(0, 0.01, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.1, 0.14), Color(0.2, 0.2, 0.25), Vector3(0, 0.08, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.102, 0.03), Color(0.8, 0.2, 0.2), Vector3(0, 0.03, 0)))
		Kind.WATERMELON:
			var melon := SphereMesh.new()
			melon.radius = 0.2
			melon.height = 0.3
			root.add_child(CopTool.piece(melon, Color(0.2, 0.55, 0.2), Vector3(0, 0.15, 0)))
		Kind.SHOE:
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.14, 0.06, 0.36)), Color(0.15, 0.1, 0.08), Vector3(0, 0.03, 0)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.13, 0.08, 0.16)), Color(0.55, 0.3, 0.15),
				Vector3(0, 0.1, 0.08)))
		Kind.YARN:
			var ball := SphereMesh.new()
			ball.radius = 0.08
			ball.height = 0.16
			root.add_child(CopTool.piece(ball, Color(0.85, 0.4, 0.75), Vector3(0, 0.08, 0)))
			root.add_child(CopTool.piece(CopTool.cylinder(0.004, 0.2), Color(0.7, 0.7, 0.7), Vector3(0.03, 0.16, 0),
				Vector3(0, 0, 0.5)))
		Kind.BOOK:
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.24, 0.06, 0.32)), Color(0.55, 0.15, 0.15), Vector3(0, 0.03, 0)))
			root.add_child(CopTool.piece(CopTool.box(Vector3(0.22, 0.05, 0.31)), Color(0.95, 0.93, 0.85),
				Vector3(0.012, 0.03, 0)))
	return root
