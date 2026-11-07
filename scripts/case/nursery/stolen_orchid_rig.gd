class_name StolenOrchidRig
extends NurseryRig

## The stolen orchid (allanamiento-vivero.md, "La orquídea robada"): Doña Hortensia took the botanic garden's blue
## orchid. A cloud of butterflies circles over it wherever it is, and a cop this close to them notices, the story's
## own clue (on the checklist the first time). And the nursery's plants lean toward it, as if to look. Every number
## here is (propuesta).

const NOTICE_RANGE := 3.0
const CHECK_EVERY := 0.5
const BUTTERFLIES := 7
const CLOUD_HEIGHT := 1.2
const CLOUD_RADIUS := 0.5
## How fast they circle (radians per second) and flutter.
const CIRCLE_SPEED := 1.6
const FLUTTER_SPEED := 14.0
## How far the plants lean toward the orchid (radians).
const LEAN := 0.3
const COLORS: Array[Color] = [Color(0.95, 0.6, 0.15), Color(0.4, 0.6, 1.0), Color(0.95, 0.85, 0.2),
	Color(0.9, 0.4, 0.7)]

var noticed := false
var butterflies: Array[Node3D] = []
var _since := 0.0
var _time := 0.0


func setup(place: Nursery) -> void:
	super.setup(place)
	for i in BUTTERFLIES:
		var butterfly := Node3D.new()
		var paint := StandardMaterial3D.new()
		paint.albedo_color = COLORS[i % COLORS.size()]
		paint.cull_mode = BaseMaterial3D.CULL_DISABLED
		paint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for side: float in [-1.0, 1.0]:
			var wing := MeshInstance3D.new()
			var quad := QuadMesh.new()
			quad.size = Vector2(0.16, 0.12)
			wing.mesh = quad
			wing.material_override = paint
			wing.position.x = side * 0.08
			wing.name = "Wing%d" % (0 if side < 0 else 1)
			butterfly.add_child(wing)
		nursery.add_child(butterfly)
		butterflies.append(butterfly)
	_place_cloud()
	_lean_plants()


func _physics_process(delta: float) -> void:
	_time += delta
	_place_cloud()
	_since += delta
	if _since < CHECK_EVERY:
		return
	_since = 0.0
	_lean_plants()
	if noticed:
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(cloud_center()) <= NOTICE_RANGE:
			notice()
			break


## Where the cloud is: over the orchid.
func cloud_center() -> Vector3:
	return nursery.main.global_position + Vector3.UP * CLOUD_HEIGHT


## A cop sees the butterflies circling over something: the first time it's a clue.
func notice() -> void:
	if noticed:
		return
	noticed = true
	nursery.raid.add_clue(tr("CLUE_BUTTERFLIES"))
	nursery.raid.float_label(tr("NURSERY_BUTTERFLIES"), cloud_center() + Vector3.UP * 0.4, COLORS[1])


func _place_cloud() -> void:
	var center := cloud_center()
	for i in butterflies.size():
		var angle := _time * CIRCLE_SPEED + i * TAU / butterflies.size()
		var butterfly := butterflies[i]
		butterfly.global_position = center + Vector3(cos(angle) * CLOUD_RADIUS, sin(_time * 2.0 + i) * 0.2,
			sin(angle) * CLOUD_RADIUS)
		butterfly.rotation.y = -angle
		var flap := sin(_time * FLUTTER_SPEED + i) * 0.8
		(butterfly.get_child(0) as Node3D).rotation.y = flap
		(butterfly.get_child(1) as Node3D).rotation.y = -flap


## The nursery's plants lean toward the orchid.
func _lean_plants() -> void:
	var target := nursery.to_local(nursery.main.global_position)
	for plant in nursery.flowers:
		var to := target - plant.position
		to.y = 0.0
		if to.length() < 0.1:
			continue
		plant.rotation = Vector3(LEAN, atan2(to.x, to.z), 0.0)
