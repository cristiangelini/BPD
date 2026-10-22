class_name ChaseTrap
extends Area3D

## What the back left seat throws out of the window in a chase (persecucion.md, "Las cuatro tareas"): a spike strip
## dropped behind the patrol car, which punctures the suspect's tires when he drives over it, or a net thrown ahead,
## which tangles him up for a while. Against the delivery scooter, a row of cones across the street and both sidewalks,
## which he brakes in front of. Each catches him once; unused, it goes after LIFETIME. Every number here is (propuesta).

const SPIKES := "spikes"
const NET := "net"
const CONES := "cones"
## Across the street's lane and along it (m); the cones go from one building front to the other.
const SIZE := {"spikes": Vector3(4.5, 0.6, 1.2), "net": Vector3(5.0, 2.0, 5.0),
	"cones": Vector3(CityLayout.STREET + CityLayout.SIDEWALK * 2, 1.0, 1.2)}
const LIFETIME := {"spikes": 20.0, "net": 3.0, "cones": 30.0}
## Seconds he stays braked in front of the cones (longer than ChaseCase.STOP_SECONDS: he gives up).
const CONE_SECONDS := 4.0
## Meters between two cones.
const CONE_EVERY := 1.5
## Seconds the net holds him.
const NET_SECONDS := 4.0
## How high on him it lies (over the truck's roof).
const NET_DRAPE := 2.35

var kind := SPIKES
## Online, a guest's copy: it only shows; the host's catches him.
var shown_only := false
var _left := 0.0
var _caught := false


func _ready() -> void:
	add_to_group("chase_trap")
	monitoring = true
	_left = LIFETIME[kind]
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE[kind]
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	add_child(_spikes_model() if kind == SPIKES else _cones_model() if kind == CONES else _net_model())
	if shown_only:
		monitoring = false
		return
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		queue_free()
		return
	if shown_only:
		return
	# Already over him when it lands (the net thrown right on top of him).
	for body in get_overlapping_bodies():
		_on_body_entered(body)


func _on_body_entered(body: Node3D) -> void:
	var truck := body as SuspectCar
	if not truck or _caught:
		return
	_caught = true
	if kind == SPIKES:
		truck.puncture()
		queue_free()
		return
	if kind == CONES:
		# He brakes in front of them, and they stay where they are.
		truck.tangle(CONE_SECONDS)
		return
	# The net stays draped over him while it holds him.
	truck.tangle(NET_SECONDS)
	set_physics_process(false)
	set_deferred("monitoring", false)
	reparent.call_deferred(truck, false)
	set_deferred("transform", Transform3D(Basis.IDENTITY, Vector3(0, NET_DRAPE, 0)))
	get_tree().create_timer(NET_SECONDS).timeout.connect(queue_free)


func _spikes_model() -> Node3D:
	var root := Node3D.new()
	var size: Vector3 = SIZE[SPIKES]
	root.add_child(CopTool.piece(CopTool.box(Vector3(size.x, 0.05, 0.4)), Color(0.15, 0.15, 0.17), Vector3(0, 0.03, 0)))
	for i in 9:
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.07
		cone.height = 0.18
		cone.radial_segments = 4
		cone.rings = 1
		root.add_child(CopTool.piece(cone, Color(0.95, 0.8, 0.2), Vector3(-size.x / 2 + 0.25 + i * (size.x - 0.5) / 8, 0.14, 0)))
	return root


func _net_model() -> Node3D:
	var root := Node3D.new()
	var size: Vector3 = SIZE[NET]
	var color := Color(0.45, 0.6, 0.35)
	for i in 6:
		var along := -size.x / 2 + i * size.x / 5
		root.add_child(CopTool.piece(CopTool.box(Vector3(0.06, 0.04, size.z)), color, Vector3(along, 0.05, 0)))
		root.add_child(CopTool.piece(CopTool.box(Vector3(size.x, 0.04, 0.06)), color, Vector3(0, 0.05, along)))
	return root


func _cones_model() -> Node3D:
	var root := Node3D.new()
	var width: float = SIZE[CONES].x
	var count := int(width / CONE_EVERY) + 1
	for i in count:
		var x := -width / 2 + i * width / (count - 1)
		var cone := CylinderMesh.new()
		cone.top_radius = 0.04
		cone.bottom_radius = 0.2
		cone.height = 0.7
		cone.radial_segments = 8
		cone.rings = 1
		root.add_child(CopTool.piece(cone, Color(1.0, 0.45, 0.1), Vector3(x, 0.38, 0)))
		root.add_child(CopTool.piece(CopTool.box(Vector3(0.45, 0.04, 0.45)), Color(1.0, 0.45, 0.1), Vector3(x, 0.02, 0)))
		var stripe := CylinderMesh.new()
		stripe.top_radius = 0.1
		stripe.bottom_radius = 0.13
		stripe.height = 0.1
		stripe.radial_segments = 8
		stripe.rings = 1
		root.add_child(CopTool.piece(stripe, Color(0.95, 0.95, 0.95), Vector3(x, 0.5, 0)))
	return root
