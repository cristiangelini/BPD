class_name FakeCrashesRig
extends InsuranceRig

## The fake crashes (seguros.md, "Los choques falsos"): the office stages crashes with toy cars on a diorama, photographs
## them and charges other insurers for them. The diorama is the main evidence (8 kg), hidden with the crash photos and
## the box of toy cars. The story's own clue: the claim folder on the meeting table, whose "street" is the office's
## carpet. And toy cars lie all over the aisles: a cop who steps on one while moving slips and falls, and the car
## shoots off. Every number here is (propuesta).

signal slipped(cop: Cop)

const CAR_MODEL := preload("res://assets/models/toy_car.glb")
const FOLDER_SCENE := preload("res://scenes/props/claim_photos.tscn")
const FOLDER_AT := InsuranceOffice.MEETING_TABLE_AT + Vector3(0.8, InsuranceOffice.MEETING_TABLE_SIZE.y + 0.02, 0.2)
const CARS := 10
## The aisles the cars lie in (z) and how far along them (x).
const AISLES: Array[float] = [4.55, 2.0, -0.6, -3.4]
const AISLE_X := Vector2(-10.0, 3.5)
## A cop closer than this to a car, moving faster than SLIP_SPEED, steps on it.
const STEP_RANGE := 0.35
const SLIP_SPEED := 0.6
const SLIP_TIME := 1.2
const SLIP_PUSH := 2.5
const SLIP_AGAIN := 2.0
## How far the car shoots off ahead of the cop.
const KICK := 1.5

var folder: ClueNote
var cars: Array[Node3D] = []
var slips := 0
## Cop -> seconds until they can slip again.
var _again := {}


func setup(place: InsuranceOffice) -> void:
	super.setup(place)
	folder = FOLDER_SCENE.instantiate()
	folder.text = tr("CLUE_CLAIM_PHOTOS")
	folder.position = FOLDER_AT
	place.add_child(folder)
	folder.read.connect(place.raid.add_clue)
	var rng := RandomNumberGenerator.new()
	rng.seed = place.case_seed * 13 + 5
	for i in CARS:
		var car: Node3D = CAR_MODEL.instantiate()
		var z: float = AISLES[i % AISLES.size()] + rng.randf_range(-0.2, 0.2)
		car.position = Vector3(rng.randf_range(AISLE_X.x, AISLE_X.y), InsuranceOffice.FLOOR_TOP + 0.03, z)
		car.rotation.y = rng.randf() * TAU
		place.add_child(car)
		cars.append(car)


func _physics_process(delta: float) -> void:
	for seen: Variant in _again.keys():
		_again[seen] -= delta
		if not is_instance_valid(seen) or _again[seen] <= 0.0:
			_again.erase(seen)
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if not cop or cop.vehicle or _again.has(cop):
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if flat.length() <= SLIP_SPEED:
			continue
		for car in cars:
			var to := car.global_position - cop.global_position
			if Vector2(to.x, to.z).length() < STEP_RANGE and absf(to.y) < 1.0:
				slip(cop, car, flat.normalized())
				break


## `cop` stepped on `car` heading `ahead`: falls forward for SLIP_TIME and the car shoots off.
func slip(cop: Cop, car: Node3D, ahead: Vector3) -> void:
	_again[cop] = SLIP_AGAIN
	slips += 1
	cop.knock_back(ahead * SLIP_PUSH, SLIP_TIME)
	cop.show_hint("HINT_TOY_CAR")
	var to := car.position + ahead * KICK
	to.x = clampf(to.x, -InsuranceOffice.HALF_X + 0.4, InsuranceOffice.HALF_X - 0.4)
	to.z = clampf(to.z, -InsuranceOffice.HALF_Z + 0.4, InsuranceOffice.HALF_Z - 0.4)
	car.create_tween().tween_property(car, "position", to, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	slipped.emit(cop)
