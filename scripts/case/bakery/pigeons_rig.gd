class_name PigeonsRig
extends BakeryRig

## The carrier pigeons (panaderia.md, "Palomas mensajeras"): Marta sends notes around the neighborhood by pigeon.
## Five pigeons flutter loose in the shop and steal small things cops leave on the floor; feathers and crumbs under
## the bedroom window give the story away. Every number here is (propuesta).

const COUNT := 5
## Where they flutter: the shop, under its ceiling.
const AREA := AABB(Vector3(-7.0, 2.0, 1.8), Vector3(14.0, 0.4, 4.7))
## They drop what they take on the top shelf of the bread rack.
const PERCH := Vector3(Bakery.RACK_X, 2.15, Bakery.RACK_Z + 0.1)
## The feathers lie under the bedroom window; a cop this close notices them.
const FEATHERS_AT := Vector3(6.2, GameScale.FLOOR_HEIGHT, Bakery.HALF_Z - 0.5)
const NOTICE_RANGE := 1.8

var pigeons: Array[Pigeon] = []
var feathers: Node3D
var noticed := false


func setup(place: Bakery) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 13 + 1
	for i in COUNT:
		var pigeon := Pigeon.new()
		pigeon.area = AREA
		pigeon.perch = PERCH
		pigeon.floor_y = Bakery.FLOOR_TOP
		pigeon.rng.seed = rng.randi()
		pigeon.position = Vector3(rng.randf_range(AREA.position.x, AREA.end.x), AREA.get_center().y,
			rng.randf_range(AREA.position.z, AREA.end.z))
		place.add_child(pigeon)
		pigeons.append(pigeon)
	feathers = Node3D.new()
	feathers.position = FEATHERS_AT
	for j in 6:
		var white := j < 4
		var bit := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.03, 0.005, 0.1) if white else Vector3(0.03, 0.02, 0.03)
		bit.mesh = box
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.85, 0.87, 0.9) if white else Color(0.8, 0.6, 0.35)
		bit.material_override = material
		bit.position = Vector3(rng.randf_range(-0.5, 0.5), 0.01, rng.randf_range(-0.3, 0.3))
		bit.rotation.y = rng.randf() * TAU
		feathers.add_child(bit)
	place.add_child(feathers)


func _physics_process(_delta: float) -> void:
	if noticed:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(FEATHERS_AT) <= NOTICE_RANGE:
			noticed = true
			(cop as Cop).show_hint("HINT_FEATHERS")
			return


## Things the pigeons took so far.
func thefts() -> int:
	var total := 0
	for pigeon in pigeons:
		total += pigeon.thefts
	return total
