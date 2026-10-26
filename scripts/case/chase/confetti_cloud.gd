class_name ConfettiCloud
extends MultiMeshInstance3D

## The parade's El Antifaz (control-desfile.md, "Cómo es" 7) shoots a confetti cannon at every corner he turns: a
## cloud of paper bits over the street behind him that drifts down for SECONDS. The patrol car driven into one gets its
## windshield covered in confetti (cover()) for BLIND_SECONDS (ChaseDrops). Every number here is (propuesta).

const COLORS: Array[Color] = [Color("e84a9a"), Color("4ab0e8"), Color("f0c830"), Color("3ab07a"), Color("f4f4f0"),
	Color("e0302a")]
const PIECES := 220
const PIECE := 0.15
const RADIUS := 4.0
const HEIGHT := 4.0
const FALL := 0.5
const SPIN := 0.6
const SECONDS := 6.0
const BLIND_SECONDS := 3.0
## On the patrol car (forward +Z): the confetti stuck on the windshield, in front of the driver's eyes.
const COVER_PIECES := 260
const COVER_AT := Vector3(0.5, 1.6, 1.05)
const COVER_SIZE := Vector2(2.0, 1.2)

var left := SECONDS


func _init() -> void:
	name = "Confetti"


## A cloud at `at` (on the street), its bits strewn from `seed` so every PC shows the same.
static func at_corner(parent: Node, at: Vector3, seed := 0) -> ConfettiCloud:
	var cloud := ConfettiCloud.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	cloud.multimesh = _pieces(PIECES, func(_i: int) -> Transform3D:
		var a := rng.randf() * TAU
		var r := sqrt(rng.randf()) * RADIUS
		var spot := Vector3(cos(a) * r, rng.randf_range(0.4, HEIGHT), sin(a) * r)
		return Transform3D(Basis.from_euler(Vector3(rng.randf() * TAU, rng.randf() * TAU, 0)), spot), rng)
	parent.add_child(cloud, true)
	cloud.global_position = at
	return cloud


func _process(delta: float) -> void:
	left -= delta
	rotate_y(SPIN * delta)
	position.y = maxf(position.y - FALL * delta, -HEIGHT * 0.5)


## Whether `at` is in the cloud (its height doesn't matter: the car's under it).
func covers(at: Vector3) -> bool:
	var center := global_position
	return left > 0.0 and Vector2(at.x - center.x, at.z - center.z).length() < RADIUS


## Shows or hides the confetti stuck on `car`'s windshield (made the first time).
static func cover(car: Node3D, on: bool) -> void:
	var stuck := car.get_node_or_null("ConfettiCover") as MultiMeshInstance3D
	if not stuck:
		if not on:
			return
		var rng := RandomNumberGenerator.new()
		rng.seed = hash("confetti cover")
		stuck = MultiMeshInstance3D.new()
		stuck.name = "ConfettiCover"
		stuck.multimesh = _pieces(COVER_PIECES, func(_i: int) -> Transform3D:
			var spot := COVER_AT + Vector3(rng.randf_range(-0.5, 0.5) * COVER_SIZE.x,
				rng.randf_range(-0.5, 0.5) * COVER_SIZE.y, rng.randf_range(-0.03, 0.03))
			return Transform3D(Basis(Vector3.FORWARD, rng.randf() * TAU), spot), rng)
		car.add_child(stuck)
	stuck.visible = on


## `count` paper bits, each placed by `place` (its index) and colored from `rng`.
static func _pieces(count: int, place: Callable, rng: RandomNumberGenerator) -> MultiMesh:
	var quad := QuadMesh.new()
	quad.size = Vector2(PIECE, PIECE * 0.7)
	var paper := StandardMaterial3D.new()
	paper.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paper.cull_mode = BaseMaterial3D.CULL_DISABLED
	paper.vertex_color_use_as_albedo = true
	quad.material = paper
	var bits := MultiMesh.new()
	bits.transform_format = MultiMesh.TRANSFORM_3D
	bits.use_colors = true
	bits.mesh = quad
	bits.instance_count = count
	for i in count:
		bits.set_instance_transform(i, place.call(i))
		bits.set_instance_color(i, COLORS[rng.randi() % COLORS.size()])
	return bits
