class_name OfficeAccidentsRig
extends InsuranceRig

## The office accidents (seguros.md, "Los accidentes de oficina"): the employees fake falls at work and the office
## charges the insurers for them. The box with 20 neck braces is the main evidence (3 kg), hidden with the fake X-rays
## and the banana peels. The story's own clue: in every "Employee of the month" photo the worker wears a neck brace.
## And there are "wet floor" signs everywhere: a cop running over a wet patch skates on, out of control. Every number
## here is (propuesta).

signal skated(cop: Cop)

const PHOTO_MODEL := preload("res://assets/models/employee_photo.glb")
const SIGN_MODEL := preload("res://assets/models/wet_sign.glb")
const F := InsuranceOffice.FLOOR_TOP
## The wet patches, in the aisles, the reception and the kitchen.
const WET_SPOTS: Array[Vector3] = [
	Vector3(-8.0, F, 4.55), Vector3(-2.4, F, 2.0), Vector3(-5.2, F, -0.6), Vector3(0.6, F, -3.4),
	Vector3(-1.5, F, 6.4), Vector3(7.0, F, -1.4),
]
const WET_RADIUS := 0.9
## A cop moving faster than SKATE_SPEED on a wet patch skates on for SKATE_TIME, pushed SKATE_PUSH along, and can't
## skate again for SKATE_AGAIN.
const SKATE_SPEED := 1.0
const SKATE_TIME := 0.9
const SKATE_PUSH := 3.0
const SKATE_AGAIN := 1.5
## The photo model is 0.3 x 0.4 m; the office's frames are twice that.
const PHOTO_SCALE := 1.9

var photos: ClueSpot
var signs: Array[Node3D] = []
var skates := 0
## Cop -> seconds until they can skate again.
var _again := {}


func setup(place: InsuranceOffice) -> void:
	super.setup(place)
	for i in 4:
		var photo: Node3D = PHOTO_MODEL.instantiate()
		photo.position = InsuranceOffice.EMPLOYEE_PHOTOS_AT + Vector3(i * InsuranceOffice.EMPLOYEE_PHOTO_STEP, 0, 0.04)
		photo.scale = Vector3.ONE * PHOTO_SCALE
		place.add_child(photo)
	photos = ClueSpot.new()
	photos.prompt = "PROMPT_EMPLOYEE_PHOTOS"
	photos.text = tr("CLUE_EMPLOYEE_PHOTOS")
	photos.size = Vector3(InsuranceOffice.EMPLOYEE_PHOTO_STEP * 4, 0.9, 0.1)
	photos.position = InsuranceOffice.EMPLOYEE_PHOTOS_AT + Vector3(InsuranceOffice.EMPLOYEE_PHOTO_STEP * 1.5, 0, 0.08)
	place.add_child(photos)
	photos.read.connect(place.raid.add_clue)
	var puddle := CylinderMesh.new()
	puddle.top_radius = WET_RADIUS
	puddle.bottom_radius = WET_RADIUS
	puddle.height = 0.004
	var wet := StandardMaterial3D.new()
	wet.albedo_color = Color(0.4, 0.62, 0.9, 0.6)
	wet.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wet.roughness = 0.05
	puddle.material = wet
	for at in WET_SPOTS:
		var patch := MeshInstance3D.new()
		patch.mesh = puddle
		patch.position = at + Vector3.UP * 0.004
		place.add_child(patch)
		var sign: Node3D = SIGN_MODEL.instantiate()
		sign.position = at + Vector3(WET_RADIUS * 0.7, 0, 0)
		sign.rotation.y = PI / 2
		place.add_child(sign)
		signs.append(sign)


func is_wet(at: Vector3) -> bool:
	return WET_SPOTS.any(func(spot: Vector3) -> bool:
		return Vector2(at.x - spot.x, at.z - spot.z).length() < WET_RADIUS and absf(at.y - spot.y) < 1.0)


func _physics_process(delta: float) -> void:
	for seen: Variant in _again.keys():
		_again[seen] -= delta
		if not is_instance_valid(seen) or _again[seen] <= 0.0:
			_again.erase(seen)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or cop.vehicle or _again.has(cop) or cop.is_staggered():
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if flat.length() > SKATE_SPEED and is_wet(cop.global_position):
			skate(cop, flat.normalized())


## `cop` ran onto a wet patch heading `ahead`: skates on that way, out of control.
func skate(cop: Cop, ahead: Vector3) -> void:
	_again[cop] = SKATE_AGAIN
	skates += 1
	cop.knock_back(ahead * SKATE_PUSH, SKATE_TIME)
	cop.show_hint("HINT_WET_FLOOR")
	skated.emit(cop)
