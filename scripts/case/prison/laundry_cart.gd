class_name LaundryCart
extends AnimatableBody3D

## A laundry cart of the prison's laundry (carcel-lavanderia.md, step 2): a canvas basket on a steel frame with four
## wheels and a push bar, full of sheets, towels and socks. LaundryPlan draws which ones carry an inmate under the
## sheets (`hidden`) and on which of the truck's trips each one goes (`trip`). Its origin is on the ground in its
## middle, long along Z, the push bar at its +Z end. Every number here is (propuesta).

const SIZE := Vector3(0.7, 0.9, 1.0)
const WHEEL := 0.08
const CANVAS := Color(0.85, 0.82, 0.72)
const FRAME := Color(0.55, 0.58, 0.62)
## The sheets on top, drawn from these.
const LINENS: Array[Color] = [Color(0.95, 0.95, 0.92), Color(0.6, 0.75, 0.9), Color(0.95, 0.6, 0.35),
	Color(0.85, 0.85, 0.5), Color(0.7, 0.85, 0.7)]

## An inmate under the sheets (drawn by LaundryPlan).
var hidden := false
## The truck's trip it goes out on, from 0.
var trip := 0
## Which sheets go on top (LaundryPlan draws it, so it's the same on every PC).
var linen_seed := 0


func _ready() -> void:
	add_to_group("laundry_carts")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_build_model()


func _build_model() -> void:
	var bottom := WHEEL * 2
	var height := SIZE.y - bottom
	# The basket: four canvas sides and a bottom, open on top.
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x, 0.03, SIZE.z)), CANVAS, Vector3(0, bottom, 0)))
	for side: float in [-1.0, 1.0]:
		add_child(CopTool.piece(CopTool.box(Vector3(0.03, height, SIZE.z)), CANVAS,
			Vector3(side * SIZE.x / 2, bottom + height / 2, 0)))
		add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x, height, 0.03)), CANVAS,
			Vector3(0, bottom + height / 2, side * SIZE.z / 2)))
	# The frame along the rim, the push bar and the wheels.
	for side: float in [-1.0, 1.0]:
		add_child(CopTool.piece(CopTool.box(Vector3(0.04, 0.04, SIZE.z + 0.04)), FRAME, Vector3(side * SIZE.x / 2, SIZE.y, 0)))
		add_child(CopTool.piece(CopTool.box(Vector3(0.04, 0.3, 0.04)), FRAME,
			Vector3(side * SIZE.x / 2, SIZE.y + 0.15, SIZE.z / 2 + 0.05)))
		for end: float in [-1.0, 1.0]:
			add_child(CopTool.piece(CopTool.cylinder(WHEEL, 0.05), PrisonLevel.BARS,
				Vector3(side * (SIZE.x / 2 - 0.08), WHEEL, end * (SIZE.z / 2 - 0.1)), Vector3(0, 0, PI / 2)))
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x + 0.04, 0.05, 0.05)), FRAME, Vector3(0, SIZE.y + 0.3, SIZE.z / 2 + 0.05)))
	# The sheets heaped on top, a little over the rim.
	var rng := RandomNumberGenerator.new()
	rng.seed = linen_seed
	for i in 3:
		var linen := CopTool.piece(CopTool.box(Vector3(SIZE.x - 0.1, 0.14, SIZE.z * rng.randf_range(0.4, 0.8))),
			LINENS[rng.randi_range(0, LINENS.size() - 1)],
			Vector3(rng.randf_range(-0.05, 0.05), SIZE.y - 0.12 + i * 0.06, rng.randf_range(-0.2, 0.2)),
			Vector3(0, rng.randf_range(-0.4, 0.4), 0))
		linen.name = "Linen%d" % i
		add_child(linen)
